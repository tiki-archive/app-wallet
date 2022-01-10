/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/src/keystore/keystore_model.dart';
import 'package:wallet/src/keystore/keystore_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('keystore_service integration tests', () {
    test('add_success', () async {
      KeystoreService service = KeystoreService();
      KeystoreModel model = KeystoreModel(
          address: Uuid().v4(),
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await service.add(model);
    });

    test('add_duplicate', () async {
      KeystoreService service = KeystoreService();
      KeystoreModel model = KeystoreModel(
          address: Uuid().v4(),
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await service.add(model);
      expect(() async => await service.add(model),
          throwsA(isInstanceOf<StateError>()));
    });

    test('get_success', () async {
      KeystoreService service = KeystoreService();
      KeystoreModel model = KeystoreModel(
          address: Uuid().v4(),
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await service.add(model);
      KeystoreModel? saved = await service.get(model.address!);
      expect(saved, model);
    });

    test('remove_success', () async {
      KeystoreService service = KeystoreService();
      KeystoreModel model = KeystoreModel(
          address: Uuid().v4(),
          chain: "chain",
          dataKey: "dataKey",
          signKey: "signKey");

      await service.add(model);
      await service.remove(model.address!);
      KeystoreModel? saved = await service.get(model.address!);
      expect(saved, null);
    });
  });
}
