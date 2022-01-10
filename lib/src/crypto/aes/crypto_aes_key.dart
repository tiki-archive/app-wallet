/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../crypto_utils.dart' as utils;

class CryptoAESKey {
  static const int _PBKDF2_ITERATIONS = 200000;

  late final Uint8List? key;

  CryptoAESKey(this.key);

  CryptoAESKey.decode(String encodedKey) : key = base64.decode(encodedKey);

  CryptoAESKey.derive(String passphrase, {Uint8List? salt}) {
    if (salt == null) salt = utils.secureRandom().nextBytes(16);

    KeyDerivator keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2');
    Pbkdf2Parameters pbkdf2parameters =
        Pbkdf2Parameters(salt, _PBKDF2_ITERATIONS, 32);
    keyDerivator.init(pbkdf2parameters);

    key = keyDerivator.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CryptoAESKey &&
          runtimeType == other.runtimeType &&
          key.toString() == other.key.toString();

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return 'CryptoAESKey{key: *****}';
  }
}
