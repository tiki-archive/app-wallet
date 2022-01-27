/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:pointycastle/api.dart';

import '../../crypto/aes/crypto_aes_key.dart';
import '../../crypto/rsa/crypto_rsa_private_key.dart';
import '../../crypto/rsa/crypto_rsa_public_key.dart';

class TikiKeysModel {
  late final String address;
  late final AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> sign;
  late final CryptoAESKey data;

  TikiKeysModel(this.address, this.sign, this.data);

  TikiKeysModel.decode(this.address, String sign, String data) {
    CryptoRSAPrivateKey pKey = CryptoRSAPrivateKey.decode(sign);
    this.sign = AsymmetricKeyPair(pKey.public, pKey);
    this.data = CryptoAESKey.decode(data);
  }

  @override
  String toString() {
    return 'TikiKeysModel{address: $address, sign: *****, data: *****}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiKeysModel &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          sign == other.sign &&
          data == other.data;

  @override
  int get hashCode => address.hashCode ^ sign.hashCode ^ data.hashCode;
}
