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

  // - init/load the cache
  Future<void> open(String address) async {
    _localchain = await Localchain().open(address);
  }

  // write
  Future<void> write(BlockContents contents) async {}

  // read

  Future<Uint8List> _encrypt(BlockContents contents) =>
      aes.encrypt(Localchain.codec.encode(contents), _keys.data);

  Future<BlockContents> _decrypt(Uint8List ciphertext) async {
    Uint8List plaintext = await aes.decrypt(ciphertext, _keys.data);
    return Localchain.codec.decode(plaintext);
  }
}
