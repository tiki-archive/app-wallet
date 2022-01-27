/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';

import '../crypto_utils.dart' as utils;
import 'crypto_aes_key.dart';

const int _PBKDF2_ITERATIONS = 200000;

Future<CryptoAESKey> generate() => compute(_generate, "").then((key) => key);

CryptoAESKey _generate(_) => CryptoAESKey(utils.secureRandom().nextBytes(32));

Future<Uint8List> encrypt(Uint8List plaintext, CryptoAESKey key) {
  Map<String, String> q = Map();
  q['key'] = key.encode();
  q['plaintext'] = base64.encode(plaintext);
  return compute(_encrypt, q).then((ciphertext) => ciphertext);
}

Uint8List _encrypt(Map<String, String> q) {
  Uint8List plaintext = base64.decode(q['plaintext']!);
  CryptoAESKey aes = CryptoAESKey.decode(q['key']!);
  if (aes.key!.length != 32) throw ArgumentError("key length must be 256-bits");

  Uint8List iv = utils.secureRandom().nextBytes(16);
  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      true,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(aes.key!), iv),
        null,
      ),
    );

  BytesBuilder cipherBuilder = BytesBuilder();
  cipherBuilder.add(iv);
  cipherBuilder.add(cipher.process(utils.addPadding(plaintext, 16, pad: 0)));
  return cipherBuilder.toBytes();
}

Future<Uint8List> decrypt(Uint8List ciphertext, CryptoAESKey key) {
  Map<String, String> q = Map();
  q['key'] = key.encode();
  q['ciphertext'] = base64.encode(ciphertext);
  return compute(_decrypt, q).then((plaintext) => plaintext);
}

Uint8List _decrypt(Map<String, String> q) {
  Uint8List ciphertext = base64.decode(q['ciphertext']!);
  CryptoAESKey aes = CryptoAESKey.decode(q['key']!);
  if (aes.key!.length != 32) throw ArgumentError("key length must be 256-bits");
  if (ciphertext.length < 16)
    throw ArgumentError("cipher length must be > 128-bits");

  Uint8List iv = ciphertext.sublist(0, 16);
  Uint8List message = ciphertext.sublist(16);

  final cipher = PaddedBlockCipherImpl(
    PKCS7Padding(),
    CBCBlockCipher(AESEngine()),
  )..init(
      false,
      PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
        ParametersWithIV<KeyParameter>(KeyParameter(aes.key!), iv),
        null,
      ),
    );

  return utils.removePadding(cipher.process(message), pad: 0);
}

Future<CryptoAESKey> derive(String passphrase, {Uint8List? salt}) {
  if (salt == null) salt = utils.secureRandom().nextBytes(16);
  Map<String, String> q = Map();
  q['salt'] = base64.encode(salt);
  q['passphrase'] = passphrase;
  return compute(_derive, q).then((key) => key);
}

CryptoAESKey _derive(Map<String, String> q) {
  Uint8List salt = base64.decode(q['salt']!);
  KeyDerivator keyDerivator = KeyDerivator('SHA-1/HMAC/PBKDF2');
  Pbkdf2Parameters pbkdf2parameters =
      Pbkdf2Parameters(salt, _PBKDF2_ITERATIONS, 32);
  keyDerivator.init(pbkdf2parameters);
  return CryptoAESKey(
      keyDerivator.process(Uint8List.fromList(utf8.encode(q['passphrase']!))));
}
