/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/src/crypto/aes/crypto_aes.dart' as aes;
import 'package:wallet/src/crypto/aes/crypto_aes_key.dart';

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
  });
}
