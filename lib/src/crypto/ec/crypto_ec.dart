/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

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
