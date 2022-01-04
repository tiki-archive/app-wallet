/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/api.dart';
import 'package:wallet/src/crypto/aes/crypto_aes.dart' as aes;
import 'package:wallet/src/crypto/aes/crypto_aes_key.dart';
import 'package:wallet/src/crypto/crypto_utils.dart' as cryptoutils;
import 'package:wallet/src/crypto/rsa/crypto_rsa.dart' as rsa;
import 'package:wallet/src/crypto/rsa/crypto_rsa_private_key.dart';
import 'package:wallet/src/crypto/rsa/crypto_rsa_public_key.dart';
import 'package:wallet/src/keystore/keystore_model.dart';

import '../../keystore/keystore_service.dart';

class TikiKeysService {
  static const String _chain = "TIKI";
  final KeystoreService _keystore;

  TikiKeysService({FlutterSecureStorage? secureStorage})
      : this._keystore = KeystoreService(secureStorage: secureStorage);

  Future<String> generate() async {
    CryptoAESKey dataKey = await aes.generate();
    AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> signKeyPair =
        await rsa.generate();
    String address = _address(signKeyPair.publicKey);
    await _keystore.add(KeystoreModel(
        address: address,
        chain: _chain,
        signKey: signKeyPair.privateKey.encode(),
        dataKey: dataKey.encode()));
    return address;
  }

  void provide() {}

  void recover() {}

  String _address(CryptoRSAPublicKey publicKey) {
    if (publicKey.modulus == null || publicKey.exponent == null)
      throw ArgumentError("modulus and exponent required");

    String raw = publicKey.modulus!.toRadixString(16);
    raw += publicKey.exponent!.toRadixString(16);

    Uint8List hashed =
        cryptoutils.sha256(cryptoutils.hexDecode(raw), sha3: true);

    return base64.encode(hashed);
  }
}
