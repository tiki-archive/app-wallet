/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';
import 'package:localchain/localchain.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:syncchain/syncchain.dart';
import 'package:tiki_kv/tiki_kv.dart';

import '../../crypto/aes/crypto_aes.dart' as aes;
import '../../crypto/crypto_utils.dart';
import '../../crypto/rsa/crypto_rsa.dart' as rsa;
import '../keys/tiki_keys_model.dart';
import 'tiki_chain_cache_model.dart';
import 'tiki_chain_cache_repository.dart';
import 'tiki_chain_props_key.dart';
import 'tiki_chain_props_model.dart';
import 'tiki_chain_props_repository.dart';

class TikiChainService {
  final _log = Logger('TikiChainService');
  final TikiKeysModel _keys;
  late final Localchain _localchain;
  late final TikiChainCacheRepository _cacheRepository;
  late final TikiChainPropsRepository _propsRepository;
  late final SyncChain _syncChain;

  TikiChainService(this._keys);

  Future<TikiChainService> open(
      {required Database database,
      Httpp? httpp,
      TikiKv? kv,
      String? accessToken,
      Future<void> Function(void Function(String?)? onSuccess)?
          refresh}) async {
    if (!database.isOpen) {
      throw ArgumentError.value(database, 'database', 'database is not open');
    }

    _cacheRepository = TikiChainCacheRepository(database);
    _propsRepository = TikiChainPropsRepository(database);
    await _cacheRepository.createTable();
    await _propsRepository.createTable();
    _localchain = await Localchain().open(_keys.address);

    _syncChain = await SyncChain(
            httpp: httpp,
            kv: kv,
            database: database,
            refresh: refresh,
            sign: (textToSign) => rsa.sign(textToSign, _keys.sign.privateKey))
        .init(
            address: _keys.address,
            accessToken: accessToken,
            publicKey: _keys.sign.publicKey.encode());

    TikiChainPropsModel? cachedOn =
        await _propsRepository.get(TikiChainPropsKey.cachedOn);
    if (cachedOn == null) build();
    return this;
  }

  //note: think about if we need a special case for writes when cache is still building.
  Future<Map<String, TikiChainCacheModel>> write(
      Map<String, BlockContents> reqs,
      {String? accessToken,
      int pageSize = 100}) async {
    Map<String, TikiChainCacheModel> rsp = {};
    int numPages = (reqs.length / pageSize).ceil();

    for (int i = 0; i < numPages; i++) {
      int start = i * pageSize;
      int end = start + pageSize > reqs.length ? reqs.length : start + pageSize;

      List<Future<MapEntry<String, Uint8List>>> encrypting =
          List.empty(growable: true);
      for (int j = start; j < end; j++) {
        MapEntry<String, BlockContents> entry = reqs.entries.elementAt(j);
        encrypting.add(_encrypt(entry.key, entry.value));
      }

      Map<String, Uint8List> encrypted =
          Map.fromEntries(await Future.wait(encrypting));

      Map<String, Block> blockMap = {};
      (await _localchain.append(List.of(encrypted.values))).forEach((block) {
        if (block.contents != null) {
          String id = base64.encode(block.contents!);
          blockMap[id] = block;
        }
      });

      List<TikiChainCacheModel> toCache = List.empty(growable: true);
      encrypted.entries.forEach((entry) {
        Block block = blockMap[base64.encode(entry.value)]!;
        BlockContents contents = reqs[entry.key]!;
        Uint8List hash = _hash(block);

        _syncChain.syncBlock(
            accessToken: accessToken,
            hash: hash,
            block: SyncChainBlock(
                contents: block.contents,
                created: block.created,
                previous: block.previousHash));

        TikiChainCacheModel cacheBlock = TikiChainCacheModel(
            hash: hash,
            previousHash: block.previousHash,
            contents: contents.payload,
            created: block.created,
            schema: contents.schema);

        toCache.add(cacheBlock);
        rsp[entry.key] = cacheBlock;
      });

      await _cacheRepository.insertAll(toCache);
    }
    return rsp;
  }

  Future<Map<String, TikiChainCacheModel>> mint(Map<String, Uint8List> reqs,
      {String? accessToken, int pageSize = 100}) async {
    Map<String, BlockContentsDataNft> writeReq = reqs.map((key, value) {
      Uint8List proof = secureRandom().nextBytes(32);
      BytesBuilder builder = BytesBuilder();
      builder.add(value);
      builder.add(proof);
      Uint8List fingerprint = sha256(builder.toBytes(), sha3: true);
      return MapEntry(
          key,
          BlockContentsDataNft(
              fingerprint: base64.encode(fingerprint),
              proof: base64.encode(proof)));
    });
    return write(writeReq, accessToken: accessToken, pageSize: pageSize);
  }

  Future<TikiChainCacheModel?> read(Uint8List hash) =>
      _cacheRepository.get(hash);

  //TODO one day this will blow up because we can't hold like 50k blocks in memory.
  Future<void> build() async {
    List<Block> blocks = await _localchain.get(
        pageSize: 1000,
        onPage: (page) =>
            _log.finest('cache open — paged ${page.length} blocks'));
    blocks.removeWhere((block) =>
        block.previousHash?.length == 1 && block.previousHash?[0] == 0);
    await _batchBuild(blocks);
    await _propsRepository.upsert(TikiChainPropsModel(
        key: TikiChainPropsKey.cachedOn,
        value: DateTime.now().toIso8601String()));
  }

  Future<void> drop() => _cacheRepository.drop();

  Uint8List _hash(Block block) {
    BytesBuilder bytesBuilder = BytesBuilder();
    bytesBuilder.add(block.contents!);
    bytesBuilder.add(block.previousHash!);
    bytesBuilder
        .add(_encodeBigInt(BigInt.from(block.created!.millisecondsSinceEpoch)));
    return SHA256Digest().process(bytesBuilder.toBytes());
  }

  Future<BlockContents> _decrypt(Uint8List ciphertext) async {
    Uint8List plaintext = await aes.decrypt(ciphertext, _keys.data);
    return Localchain.codec.decode(plaintext);
  }

  Future<MapEntry<String, Uint8List>> _encrypt(
          String id, BlockContents contents) =>
      aes.encryptWithId(id, Localchain.codec.encode(contents), _keys.data);

  // From pointycastle/src/utils
  Uint8List _encodeBigInt(BigInt? number) {
    if (number == BigInt.zero) {
      return Uint8List.fromList([0]);
    }

    int needsPaddingByte;
    int rawSize;

    if (number! > BigInt.zero) {
      rawSize = (number.bitLength + 7) >> 3;
      needsPaddingByte = ((number >> (rawSize - 1) * 8) & BigInt.from(0x80)) ==
              BigInt.from(0x80)
          ? 1
          : 0;
    } else {
      needsPaddingByte = 0;
      rawSize = (number.bitLength + 8) >> 3;
    }

    final size = rawSize + needsPaddingByte;
    var result = Uint8List(size);
    for (var i = 0; i < rawSize; i++) {
      result[size - i - 1] = (number! & BigInt.from(0xff)).toInt();
      number = number >> 8;
    }
    return result;
  }

  Future<void> _batchBuild(List<Block> blocks, {int batch = 10}) async {
    List<TikiChainCacheModel> cache = List.empty(growable: true);
    for (int i = 0; i < batch && i < blocks.length; i++) {
      var decrypted = await _decrypt(blocks[i].contents!);
      cache.add(TikiChainCacheModel(
          hash: _hash(blocks[i]),
          previousHash: blocks[i].previousHash,
          contents: decrypted.payload,
          created: blocks[i].created,
          schema: decrypted.schema));
    }
    await _cacheRepository.transaction((txn) async {
      for (var block in cache) {
        await _cacheRepository.insert(block, txn: txn);
      }
    });
    _log.finest('added ${cache.length} blocks to cache');
    if (blocks.length > batch) {
      return _batchBuild(blocks.sublist(batch), batch: batch);
    }
  }
}
