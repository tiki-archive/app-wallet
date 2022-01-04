/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../crypto_utils.dart' as utils;

class CryptoAESKey {
  final Uint8List? key;

  CryptoAESKey(this.key);

  static CryptoAESKey decode(String encodedKey) =>
      CryptoAESKey(base64.decode(encodedKey));

  String encode() => base64.encode(this.key!);

  Uint8List encrypt(Uint8List plaintext) {
    if (this.key!.length != 32)
      throw ArgumentError("key length must be 256-bits");

    Uint8List iv = utils.secureRandom().nextBytes(16);
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    )..init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(this.key!), iv),
          null,
        ),
      );

    BytesBuilder cipherBuilder = BytesBuilder();
    cipherBuilder.add(iv);
    cipherBuilder.add(cipher.process(utils.addPadding(plaintext, 16, pad: 0)));
    return cipherBuilder.toBytes();
  }

  Uint8List decrypt(Uint8List cipherText) {
    if (this.key!.length != 32)
      throw ArgumentError("key length must be 256-bits");
    if (cipherText.length < 16)
      throw ArgumentError("cipher length must be > 128-bits");

    Uint8List iv = cipherText.sublist(0, 16);
    Uint8List message = cipherText.sublist(16);

    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    )..init(
        false,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(this.key!), iv),
          null,
        ),
      );

    return utils.removePadding(cipher.process(message), pad: 0);
  }
}
