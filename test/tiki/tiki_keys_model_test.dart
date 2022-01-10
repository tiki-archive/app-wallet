/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/api.dart';
import 'package:wallet/src/crypto/aes/crypto_aes.dart' as aes;
import 'package:wallet/src/crypto/aes/crypto_aes_key.dart';
import 'package:wallet/src/crypto/rsa/crypto_rsa.dart' as rsa;
import 'package:wallet/src/crypto/rsa/crypto_rsa_private_key.dart';
import 'package:wallet/src/crypto/rsa/crypto_rsa_public_key.dart';
import 'package:wallet/src/tiki/keys/tiki_keys_model.dart';

void main() {
  group('tiki-keys-model unit tests', () {
    test('encrypt_success', () async {
      CryptoAESKey dataKey = await aes.generate();
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> signKeyPair =
          await rsa.generate();
      TikiKeysModel model = TikiKeysModel('1234abcd', signKeyPair, dataKey);
      Uint8List encrypted = model.encrypt('passphrase');
      expect(encrypted.isNotEmpty, true);
    });

    test('decrypt_success', () async {
      CryptoAESKey dataKey = await aes.generate();
      AsymmetricKeyPair<CryptoRSAPublicKey, CryptoRSAPrivateKey> signKeyPair =
          await rsa.generate();
      TikiKeysModel model = TikiKeysModel('1234abcd', signKeyPair, dataKey);
      Uint8List ciphertext = model.encrypt('passphrase');
      TikiKeysModel decrypted = TikiKeysModel.decrypt('passphrase', ciphertext);
      expect(decrypted, model);
    });
  });
}
