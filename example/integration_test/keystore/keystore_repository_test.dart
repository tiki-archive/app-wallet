/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tiki_wallet/src/keystore/keystore_model.dart';
import 'package:tiki_wallet/src/keystore/keystore_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('keystore_repository integration tests', () {
    test('save_success', () async {
      KeystoreRepository repository =
          KeystoreRepository(FlutterSecureStorage());
      KeystoreModel model = KeystoreModel(
          address: "address",
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await repository.save(model);
    });

    test('get_success', () async {
      KeystoreRepository repository =
          KeystoreRepository(FlutterSecureStorage());
      KeystoreModel model = KeystoreModel(
          address: "address",
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await repository.save(model);

      KeystoreModel? saved = await repository.get(model.address!);
      expect(saved, model);
    });

    test('delete_success', () async {
      KeystoreRepository repository =
          KeystoreRepository(FlutterSecureStorage());
      KeystoreModel model = KeystoreModel(
          address: "address",
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await repository.save(model);
      await repository.delete(model.address!);
      KeystoreModel? saved = await repository.get(model.address!);
      expect(saved, null);
    });

    test('exists_success', () async {
      KeystoreRepository repository =
          KeystoreRepository(FlutterSecureStorage());
      KeystoreModel model = KeystoreModel(
          address: "address",
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await repository.save(model);
      bool exists = await repository.exists(model.address!);
      expect(exists, true);
    });
  });
}
