/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/api.dart';

import '../../crypto/aes/crypto_aes_key.dart';
import '../../crypto/crypto_utils.dart' as cryptoutils;
import '../../crypto/rsa/crypto_rsa_private_key.dart';
import '../../crypto/rsa/crypto_rsa_public_key.dart';

class TikiKeysModel {
  static const int _SALT_LEN = 16;
  static const String _DELIMITER = ',';

  late final String address;
  late final AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> sign;
  late final CryptoAESKey data;

  TikiKeysModel(this.address, this.sign, this.data);

  TikiKeysModel.decode(this.address, String sign, String data) {
    CryptoRSAPrivateKey pKey = CryptoRSAPrivateKey.decode(sign);
    this.sign = AsymmetricKeyPair(pKey.public, pKey);
    this.data = CryptoAESKey.decode(data);
  }

  TikiKeysModel.decrypt(String passphrase, Uint8List ciphertext) {
    Uint8List salt = ciphertext.sublist(0, _SALT_LEN);
    CryptoAESKey key = CryptoAESKey.derive(passphrase, salt: salt);
    String plaintext = utf8.decode(key.decrypt(ciphertext.sublist(_SALT_LEN)));
    List<String> encodedKeys = plaintext.split(_DELIMITER);
    if (encodedKeys.length >= 3) {
      address = encodedKeys.elementAt(0);
      CryptoRSAPrivateKey signPrivate =
          CryptoRSAPrivateKey.decode(encodedKeys.elementAt(1));
      sign = AsymmetricKeyPair(signPrivate.public, signPrivate);
      data = CryptoAESKey.decode(encodedKeys.elementAt(2));
    }
  }

  Uint8List encrypt(String passphrase) {
    Uint8List salt = cryptoutils.secureRandom().nextBytes(_SALT_LEN);
    CryptoAESKey key = CryptoAESKey.derive(passphrase, salt: salt);
    String plaintext = address +
        _DELIMITER +
        sign.privateKey.encode() +
        _DELIMITER +
        data.encode();
    BytesBuilder payload = BytesBuilder();
    payload.add(salt);
    payload.add(key.encrypt(Uint8List.fromList(utf8.encode(plaintext))));
    return payload.toBytes();
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
