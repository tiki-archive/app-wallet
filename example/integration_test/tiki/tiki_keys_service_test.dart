/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiki_wallet/src/keystore/keystore_model.dart';
import 'package:tiki_wallet/src/keystore/keystore_service.dart';
import 'package:tiki_wallet/src/tiki/keys/tiki_keys_model.dart';
import 'package:tiki_wallet/src/tiki/keys/tiki_keys_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('tiki_keys_service integration tests', () {
    test('generate_success', () async {
      FlutterSecureStorage secureStorage = FlutterSecureStorage();

      TikiKeysService service = TikiKeysService(secureStorage: secureStorage);
      TikiKeysModel tikiKeysModel = await service.generate();

      tikiKeysModel.sign.publicKey.encode();

      KeystoreService keystoreService =
          KeystoreService(secureStorage: secureStorage);
      KeystoreModel? model = await keystoreService.get(tikiKeysModel.address);

      expect(tikiKeysModel.address.length, 44);
      expect(model != null, true);
      expect(model!.address, tikiKeysModel.address);
    });

    test('provide_dupe_success', () async {
      FlutterSecureStorage secureStorage = FlutterSecureStorage();

      TikiKeysService service = TikiKeysService(secureStorage: secureStorage);
      TikiKeysModel tikiKeysModel = await service.generate();
      await service.provide(tikiKeysModel);

      expect(tikiKeysModel.address.length, 44);
    });
  });
}
