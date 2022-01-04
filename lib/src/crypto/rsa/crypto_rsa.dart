/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/foundation.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:pointycastle/key_generators/api.dart';
import 'package:pointycastle/key_generators/rsa_key_generator.dart';

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
