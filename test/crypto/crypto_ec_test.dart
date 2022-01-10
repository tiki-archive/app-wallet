/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:wallet/src/crypto/ec/crypto_ec.dart' as ec;
import 'package:wallet/src/crypto/ec/crypto_ec_private_key.dart';
import 'package:wallet/src/crypto/ec/crypto_ec_public_key.dart';

void main() {
  group('crypto-ec unit tests', () {
    test('generate_success', () async {
      await ec.generate();
    });

    test('encode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          await ec.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      String privateKeyEncoded = keyPair.privateKey.encode();
      expect(publicKeyEncoded.isNotEmpty, true);
      expect(privateKeyEncoded.isNotEmpty, true);
    });

    test('publicKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          await ec.generate();
      String publicKeyEncoded = keyPair.publicKey.encode();
      CryptoECPublicKey publicKeyDecoded =
          CryptoECPublicKey.decode(publicKeyEncoded);
      expect(publicKeyDecoded.Q, keyPair.publicKey.Q);
      expect(publicKeyDecoded.Q?.x, keyPair.publicKey.Q?.x);
      expect(publicKeyDecoded.Q?.y, keyPair.publicKey.Q?.y);
      expect(publicKeyDecoded.Q?.curve, keyPair.publicKey.Q?.curve);
    });

    test('privateKeyDecode_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          await ec.generate();
      String privateKeyEncoded = keyPair.privateKey.encode();
      CryptoECPrivateKey privateKeyDecoded =
          CryptoECPrivateKey.decode(privateKeyEncoded);

      expect(privateKeyDecoded.d, keyPair.privateKey.d);
      expect(privateKeyDecoded.parameters?.curve,
          keyPair.privateKey.parameters?.curve);
    });

    test('sign_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          await ec.generate();
      String message = "hello world";
      Uint8List signature =
          keyPair.privateKey.sign(Uint8List.fromList(utf8.encode(message)));
      expect(signature.isNotEmpty, true);
    });

    test('verify_success', () async {
      AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> keyPair =
          await ec.generate();
      String message = "hello world";
      Uint8List signature =
          keyPair.privateKey.sign(Uint8List.fromList(utf8.encode(message)));
      bool verify = keyPair.publicKey
          .verify(Uint8List.fromList(utf8.encode(message)), signature);
      expect(verify, true);
    });
  });
}
