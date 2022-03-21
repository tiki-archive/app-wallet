/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/ecc/api.dart';
import 'package:pointycastle/ecc/curves/secp256r1.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';

import '../crypto_utils.dart' as utils;
import 'crypto_ec_private_key.dart';
import 'crypto_ec_public_key.dart';

Future<AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey>> generate() =>
    compute(_generate, "").then((keyPair) => keyPair);

AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey> _generate(_) {
  final ECKeyGeneratorParameters keyGeneratorParameters =
      ECKeyGeneratorParameters(ECCurve_secp256r1());

  ECKeyGenerator ecKeyGenerator = ECKeyGenerator();
  ecKeyGenerator
      .init(ParametersWithRandom(keyGeneratorParameters, utils.secureRandom()));
  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair =
      ecKeyGenerator.generateKeyPair();
  ECPublicKey publicKey = keyPair.publicKey as ECPublicKey;
  ECPrivateKey privateKey = keyPair.privateKey as ECPrivateKey;

  return AsymmetricKeyPair<CryptoECPublicKey, CryptoECPrivateKey>(
      CryptoECPublicKey(publicKey.Q, publicKey.parameters),
      CryptoECPrivateKey(privateKey.d, privateKey.parameters));
}

Future<Uint8List> sign(Uint8List message, CryptoECPrivateKey key) {
  Map<String, String> q = {};
  q['message'] = base64.encode(message);
  q['key'] = key.encode();
  return compute(_sign, q).then((signature) => signature);
}

Uint8List _sign(Map<String, String> q) {
  Uint8List message = base64.decode(q['message']!);
  CryptoECPrivateKey key = CryptoECPrivateKey.decode(q['key']!);
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(
      true,
      ParametersWithRandom(
          PrivateKeyParameter<ECPrivateKey>(key), utils.secureRandom()));
  ECSignature signature = signer.generateSignature(message) as ECSignature;

  BytesBuilder bytesBuilder = BytesBuilder();
  Uint8List encodedR = utils.encodeBigInt(signature.r);
  bytesBuilder.addByte(encodedR.length);
  bytesBuilder.add(encodedR);
  bytesBuilder.add(utils.encodeBigInt(signature.s));
  return bytesBuilder.toBytes();
}

Future<bool> verify(
    Uint8List message, Uint8List signature, CryptoECPublicKey key) {
  Map<String, String> q = {};
  q['message'] = base64.encode(message);
  q['signature'] = base64.encode(signature);
  q['key'] = key.encode();
  return compute(_verify, q).then((isVerified) => isVerified);
}

bool _verify(Map<String, String> q) {
  Uint8List signature = base64.decode(q['signature']!);
  Uint8List message = base64.decode(q['message']!);
  CryptoECPublicKey key = CryptoECPublicKey.decode(q['key']!);
  Signer signer = Signer("SHA-256/ECDSA");
  signer.init(false, PublicKeyParameter<ECPublicKey>(key));

  int rLength = signature[0];
  Uint8List encodedR = signature.sublist(1, 1 + rLength);
  Uint8List encodedS = signature.sublist(1 + rLength);
  ECSignature ecSignature =
      ECSignature(utils.decodeBigInt(encodedR), utils.decodeBigInt(encodedS));

  return signer.verifySignature(message, ecSignature);
}
