/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/src/crypto/aes/crypto_aes.dart' as aes;
import 'package:wallet/src/crypto/aes/crypto_aes_key.dart';
import 'package:wallet/src/crypto/crypto_utils.dart' as utils;

void main() {
  group('crypto-aes unit tests', () {
    test('generate_success', () async {
      await aes.generate();
    });

    test('encode_success', () async {
      CryptoAESKey key = await aes.generate();
      String keyEncoded = key.encode();
      expect(keyEncoded.isNotEmpty, true);
    });

    test('keyDecode_success', () async {
      CryptoAESKey key = await aes.generate();
      String keyEncoded = key.encode();
      CryptoAESKey keyDecoded = CryptoAESKey.decode(keyEncoded);
      expect(keyDecoded.key, key.key);
    });

    test('encrypt_success', () async {
      CryptoAESKey key = await aes.generate();
      String plaintext = "hello";
      Uint8List cipherText =
          key.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
      expect(cipherText.isNotEmpty, true);
    });

    test('decrypt_success', () async {
      CryptoAESKey key = await aes.generate();
      String plaintext = "hello";
      Uint8List cipherText =
          key.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(key.decrypt(cipherText));
      expect(result, plaintext);
    });

    test('derive_success', () async {
      Uint8List salt = utils.secureRandom().nextBytes(16);
      String passphrase = 'passphrase';
      CryptoAESKey key1 = CryptoAESKey.derive(passphrase, salt: salt);
      CryptoAESKey key2 = CryptoAESKey.derive(passphrase, salt: salt);

      expect(key1.key, key2.key);

      String plaintext = "hello";
      Uint8List cipherText =
          key1.encrypt(Uint8List.fromList(utf8.encode(plaintext)));
      String result = utf8.decode(key1.decrypt(cipherText));
      expect(result, plaintext);
    });
  });
}
