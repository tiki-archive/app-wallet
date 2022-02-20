/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:localchain/localchain.dart';

import '../../crypto/aes/crypto_aes.dart' as aes;
import '../keys/tiki_keys_model.dart';

class TikiChainService {
  final TikiKeysModel _keys;
  late final Localchain _localchain;

  TikiChainService(this._keys);

  Future<TikiChainService> open() async {
    _localchain = await Localchain().open(_keys.address);
    // - init/load the cache
    return this;
  }

  Future<Block> write(BlockContents contents) async {
    Uint8List ciphertext = await _encrypt(contents);
    return _localchain.append(ciphertext);
  }

  Future<BlockContents> decrypt(Uint8List ciphertext) async {
    Uint8List plaintext = await aes.decrypt(ciphertext, _keys.data);
    return Localchain.codec.decode(plaintext);
  }

  Future<Uint8List> _encrypt(BlockContents contents) =>
      aes.encrypt(Localchain.codec.encode(contents), _keys.data);
}
