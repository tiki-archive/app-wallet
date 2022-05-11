/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:tiki_wallet/src/crypto/rsa/crypto_rsa.dart' as rsa;
import 'package:tiki_wallet/src/crypto/rsa/crypto_rsa_private_key.dart';
import 'package:tiki_wallet/src/crypto/rsa/crypto_rsa_public_key.dart';

void main() {
  group('crypto-rsa unit tests', () {
    test('generate_success', () {
      rsa.generate();
    });

    test('encode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      String privateKeyEncoded = keyPair.privateKey.encode();
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('publicKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      CryptoRSAPublicKey publicKeyDecoded =
          CryptoRSAPublicKey.decode(publicKeyEncoded);
      expect(publicKeyDecoded.exponent, keyPair.publicKey.exponent);
      expect(publicKeyDecoded.modulus, keyPair.publicKey.modulus);
    });

    test('privateKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
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
          rsa.generate();
      Uint8List cipherText = rsa.encrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode("hello world")));
      String cipherTextString = String.fromCharCodes(cipherText);

      expect(cipherText.isNotEmpty, true);
      expect(cipherTextString.isNotEmpty, true);
    });

    test('decrypt_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
      String plainText = "hello world";
      Uint8List cipherText = rsa.encrypt(
          keyPair.publicKey, Uint8List.fromList(utf8.encode(plainText)));
      String result =
          utf8.decode(await rsa.decryptAsync(keyPair.privateKey, cipherText));
      expect(result, plainText);
    });

    test('sign_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
      String message = "hello world";
      Uint8List signature = rsa.sign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('verify_success', () async {
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> keyPair =
          rsa.generate();
      String message = "hello world";
      Uint8List signature = rsa.sign(
          keyPair.privateKey, Uint8List.fromList(utf8.encode(message)));
      bool verify = rsa.verify(keyPair.publicKey,
          Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });
  });
}
