/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:pointycastle/api.dart';

import '../../crypto/aes/crypto_aes.dart' as aes;
import '../../crypto/aes/crypto_aes_key.dart';
import '../../crypto/crypto_utils.dart' as cryptoutils;
import '../../crypto/rsa/crypto_rsa.dart' as rsa;
import '../../crypto/rsa/crypto_rsa_private_key.dart';
import '../../crypto/rsa/crypto_rsa_public_key.dart';
import '../../keystore/keystore_model.dart';
import '../../keystore/keystore_service.dart';
import 'tiki_keys_model.dart';

class TikiKeysService {
  static const int _SALT_LEN = 16;
  static const String _DELIMITER = ',';
  static const String _chain = "TIKI";
  final Logger _log = Logger('TikiKeysService');
  final KeystoreService _keystore;

  TikiKeysService({FlutterSecureStorage? secureStorage})
      : this._keystore = KeystoreService(secureStorage: secureStorage);

  Future<TikiKeysModel> generate() async {
    CryptoAESKey dataKey = await aes.generate();
    AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> signKeyPair =
        await rsa.generate();
    String address = _address(signKeyPair.publicKey);
    await _keystore.add(KeystoreModel(
        address: address,
        chain: _chain,
        signKey: signKeyPair.privateKey.encode(),
        dataKey: dataKey.encode()));
    return TikiKeysModel(address, signKeyPair, dataKey);
  }

  Future<void> provide(TikiKeysModel model) => _keystore.add(KeystoreModel(
      address: model.address,
      chain: _chain,
      signKey: model.sign.privateKey.encode(),
      dataKey: model.data.encode()));

  Future<TikiKeysModel?> get(String address) async {
    KeystoreModel? model = await _keystore.get(address);
    if (model != null && model.signKey != null && model.dataKey != null) {
      CryptoRSAPrivateKey privateKey =
          CryptoRSAPrivateKey.decode(model.signKey!);

      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> signKeyPair =
          new AsymmetricKeyPair(privateKey.public, privateKey);

      CryptoAESKey dataKey = CryptoAESKey.decode(model.dataKey!);

      return TikiKeysModel(address, signKeyPair, dataKey);
    }
  }

  Future<TikiKeysModel?> decrypt(
      String passphrase, Uint8List ciphertext) async {
    try {
      Uint8List salt = ciphertext.sublist(0, _SALT_LEN);
      CryptoAESKey key = await aes.derive(passphrase, salt: salt);
      String plaintext =
          utf8.decode(await aes.decrypt(ciphertext.sublist(_SALT_LEN), key));
      List<String> encodedKeys = plaintext.split(_DELIMITER);
      if (encodedKeys.length >= 3) {
        CryptoRSAPrivateKey signPrivate =
            CryptoRSAPrivateKey.decode(encodedKeys.elementAt(1));
        return TikiKeysModel(
            encodedKeys.elementAt(0),
            AsymmetricKeyPair(signPrivate.public, signPrivate),
            CryptoAESKey.decode(encodedKeys.elementAt(2)));
      }
    } catch (error) {
      _log.warning(error);
    }
  }

  Future<Uint8List> encrypt(String passphrase, TikiKeysModel keys) async {
    Uint8List salt = cryptoutils.secureRandom().nextBytes(_SALT_LEN);
    CryptoAESKey key = await aes.derive(passphrase, salt: salt);
    String plaintext = keys.address +
        _DELIMITER +
        keys.sign.privateKey.encode() +
        _DELIMITER +
        keys.data.encode();
    BytesBuilder payload = BytesBuilder();
    payload.add(salt);
    payload.add(
        await aes.encrypt(Uint8List.fromList(utf8.encode(plaintext)), key));
    return payload.toBytes();
  }

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
