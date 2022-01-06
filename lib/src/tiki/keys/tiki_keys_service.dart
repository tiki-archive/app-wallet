/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  static const String _chain = "TIKI";
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

  void recover() {
    //hash pin + email
    //get encrypted keys
    //decrypt
    //cycle pin
    //cycle pw

    //use callbacks to wire in the multiple state funcs.
  }

  Future<void> backup(
      String email, String pin, String passphrase, String address) async {
    RegExp pinCheck = RegExp(r'[0-9]{6,}$');
    RegExp phraseCheck = RegExp(r'^[\x20-\x7E]{8,}$');
    if (pinCheck.hasMatch(pin) && phraseCheck.hasMatch(passphrase))
      throw ArgumentError('pin must be 6+ digits and passphrase 8+ chars');

    TikiKeysModel? keys = await get(
        address); //idk about this, maybe the keys should be provided to the func.

    if (keys != null) {
      String ciphertext = base64.encode(keys.encrypt(passphrase));
      String proofKey = base64.encode(cryptoutils
          .sha256(Uint8List.fromList(utf8.encode(email + pin)), sha3: true));

      //push to backup.
    }
  }

  //feels like there should be a get QR code or something like that function,
  //no reason to expose the actual keys to the application, right?
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
