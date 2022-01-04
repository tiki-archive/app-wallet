/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:pointycastle/api.dart';

import '../../crypto/aes/crypto_aes_key.dart';
import '../../crypto/rsa/crypto_rsa_private_key.dart';
import '../../crypto/rsa/crypto_rsa_public_key.dart';

class TikiKeysModel {
  final String address;
  final AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> sign;
  final CryptoAESKey data;

  TikiKeysModel(this.address, this.sign, this.data);

  @override
  String toString() {
    return 'TikiKeysModel{address: $address, sign: *****, data: *****}';
  }
}
