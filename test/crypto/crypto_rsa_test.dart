/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:wallet/src/crypto/rsa/crypto_rsa.dart' as rsa;
import 'package:wallet/src/crypto/rsa/crypto_rsa_private_key.dart';
import 'package:wallet/src/crypto/rsa/crypto_rsa_public_key.dart';

void main() {
  group('crypto-rsa unit tests', () {
    test('generate_success', () async {
      await rsa.generate();
    });

    test('encode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          await rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      String privateKeyEncoded = keyPair.privateKey.encode();
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('publicKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          await rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      CryptoRSAPublicKey publicKeyDecoded =
          CryptoRSAPublicKey.decode(publicKeyEncoded);
      expect(publicKeyDecoded.exponent, keyPair.publicKey.exponent);
      expect(publicKeyDecoded.modulus, keyPair.publicKey.modulus);
    });

    test('privateKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          await rsa.generate();
      String privateKeyEncoded = keyPair.privateKey.encode();
      CryptoRSAPrivateKey privateKeyDecoded =
          CryptoRSAPrivateKey.decode(privateKeyEncoded);

      expect(privateKeyDecoded.modulus, keyPair.privateKey.modulus);
      expect(privateKeyDecoded.exponent, keyPair.privateKey.exponent);
      expect(privateKeyDecoded.privateExponent,
          keyPair.privateKey.privateExponent);
      expect(
          privateKeyDecoded.publicExponent, keyPair.privateKey.publicExponent);
      expect(privateKeyDecoded.p, keyPair.privateKey.p);
      expect(privateKeyDecoded.q, keyPair.privateKey.q);
    });

    test('encrypt_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          await rsa.generate();
      Uint8List cipherText = keyPair.publicKey
          .encrypt(Uint8List.fromList(utf8.encode("hello world")));
      String cipherTextString = String.fromCharCodes(cipherText);

      expect(cipherText.isNotEmpty, true);
      expect(cipherTextString.isNotEmpty, true);
    });

    test('decrypt_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          await rsa.generate();
      String plainText = "hello world";
      Uint8List cipherText =
          keyPair.publicKey.encrypt(Uint8List.fromList(utf8.encode(plainText)));
      String result = utf8.decode(keyPair.privateKey.decrypt(cipherText));
      expect(result, plainText);
    });
  });
}
