/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/asymmetric/oaep.dart';
import 'package:pointycastle/asymmetric/rsa.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

import '../crypto_utils.dart' as utils;
import 'crypto_rsa_private_key.dart';
import 'crypto_rsa_public_key.dart';

Future<AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey>> generate() =>
    compute(_generate, "").then((keyPair) => keyPair);

AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> _generate(_) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), 2048, 64),
        utils.secureRandom()));

  AsymmetricKeyPair<PublicKey, PrivateKey> keyPair = keyGen.generateKeyPair();
  RSAPublicKey publicKey = keyPair.publicKey as RSAPublicKey;
  RSAPrivateKey privateKey = keyPair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey>(
      CryptoRSAPublicKey(publicKey.modulus!, publicKey.publicExponent!),
      CryptoRSAPrivateKey(privateKey.modulus!, privateKey.privateExponent!,
          privateKey.p, privateKey.q));
}

Future<Uint8List> encrypt(Uint8List plaintext, CryptoRSAPublicKey key) {
  Map<String, String> q = Map();
  q['plaintext'] = base64.encode(plaintext);
  q['key'] = key.encode();
  return compute(_encrypt, q).then((ciphertext) => ciphertext);
}

Uint8List _encrypt(Map<String, String> q) {
  Uint8List plaintext = base64.decode(q['plaintext']!);
  CryptoRSAPublicKey key = CryptoRSAPublicKey.decode(q['key']!);
  final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(key));
  return utils.processInBlocks(encryptor, plaintext);
}

Future<Uint8List> decrypt(Uint8List ciphertext, CryptoRSAPrivateKey key) {
  Map<String, String> q = Map();
  q['ciphertext'] = base64.encode(ciphertext);
  q['key'] = key.encode();
  return compute(_decrypt, q).then((plaintext) => plaintext);
}

Uint8List _decrypt(Map<String, String> q) {
  CryptoRSAPrivateKey key = CryptoRSAPrivateKey.decode(q['key']!);
  Uint8List ciphertext = base64.decode(q['ciphertext']!);
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(false, PrivateKeyParameter<RSAPrivateKey>(key));
  return utils.processInBlocks(decryptor, ciphertext);
}

Future<Uint8List> sign(Uint8List message, CryptoRSAPrivateKey key) {
  Map<String, String> q = Map();
  q['message'] = base64.encode(message);
  q['key'] = key.encode();
  return compute(_sign, q).then((signature) => signature);
}

Uint8List _sign(Map<String, String> q) {
  CryptoRSAPrivateKey key = CryptoRSAPrivateKey.decode(q['key']!);
  Uint8List message = base64.decode(q['message']!);
  RSASigner signer = RSASigner(SHA256Digest(), '0609608648016503040201');
  signer.init(true, PrivateKeyParameter<RSAPrivateKey>(key));
  RSASignature signature = signer.generateSignature(message);
  return signature.bytes;
}

Future<bool> verify(
    Uint8List message, Uint8List signature, CryptoRSAPublicKey key) {
  Map<String, String> q = Map();
  q['message'] = base64.encode(message);
  q['signature'] = base64.encode(signature);
  q['key'] = key.encode();
  return compute(_verify, q).then((isVerified) => isVerified);
}

bool _verify(Map<String, String> q) {
  Uint8List message = base64.decode(q['message']!);
  Uint8List signature = base64.decode(q['signature']!);
  CryptoRSAPublicKey key = CryptoRSAPublicKey.decode(q['key']!);
  RSASignature rsaSignature = RSASignature(signature);
  final verifier = RSASigner(SHA256Digest(), '0609608648016503040201');
  verifier.init(false, PublicKeyParameter<RSAPublicKey>(key));
  try {
    return verifier.verifySignature(message, rsaSignature);
  } on ArgumentError {
    return false;
  }
}
