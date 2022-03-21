/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:localchain/localchain.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../../crypto/aes/crypto_aes.dart' as aes;
import '../keys/tiki_keys_model.dart';
import 'tiki_chain_cache_block.dart';
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

  TikiChainService(this._keys);

  Future<TikiChainService> open(Database database) async {
    if (!database.isOpen) {
      throw ArgumentError.value(database, 'database', 'database is not open');
    }

    _cacheRepository = TikiChainCacheRepository(database);
    _propsRepository = TikiChainPropsRepository(database);
    await _cacheRepository.createTable();
    await _propsRepository.createTable();
    _localchain = await Localchain().open(_keys.address);

    TikiChainPropsModel? createdOn =
        await _propsRepository.get(TikiChainPropsKey.cachedOn);
    if (createdOn == null) build();
    return this;
  }

  Future<TikiChainCacheBlock> write(BlockContents contents) async {
    Uint8List ciphertext = await _encrypt(contents);
    Block block = await _localchain.append(ciphertext);
    Uint8List plaintextContents = Localchain.codec.encode(contents);
    Uint8List hash = _hash(block);
    await _cacheRepository.insert(TikiChainCacheModel(
        hash: hash,
        previousHash: block.previousHash,
        contents: plaintextContents,
        created: block.created,
        schema: contents.schema));
    return TikiChainCacheBlock(
        hash: hash,
        cipherContents: block.contents,
        plaintextContents: plaintextContents,
        previousHash: block.previousHash,
        created: block.created);
  }

  Future<TikiChainCacheBlock?> read(Uint8List hash) async {
    TikiChainCacheModel? cache = await _cacheRepository.get(hash);
    if (cache != null) {
      return TikiChainCacheBlock(
          hash: cache.hash,
          plaintextContents: cache.contents,
          previousHash: cache.previousHash,
          created: cache.created);
    }
    return null;
  }

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

  Future<Uint8List> _encrypt(BlockContents contents) =>
      aes.encrypt(Localchain.codec.encode(contents), _keys.data);

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
