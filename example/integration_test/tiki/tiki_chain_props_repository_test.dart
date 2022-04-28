/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:tiki_wallet/src/tiki/chain/tiki_chain_props_key.dart';
import 'package:tiki_wallet/src/tiki/chain/tiki_chain_props_model.dart';
import 'package:tiki_wallet/src/tiki/chain/tiki_chain_props_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('tiki_chain_props_repository integration tests', () {
    test('create success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();
    });

    test('insert success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();

      String date = DateTime.now().toIso8601String();

      TikiChainPropsModel inserted = await repository.insert(
          TikiChainPropsModel(key: TikiChainPropsKey.cachedOn, value: date));

      expect(inserted.key, TikiChainPropsKey.cachedOn);
      expect(inserted.value, date);
    });

    test('update success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();

      String date = DateTime.now().toIso8601String();

      await repository.insert(TikiChainPropsModel(
          key: TikiChainPropsKey.cachedOn,
          value: DateTime.now().toIso8601String()));

      TikiChainPropsModel updated = await repository.update(
          TikiChainPropsModel(key: TikiChainPropsKey.cachedOn, value: date));

      expect(updated.key, TikiChainPropsKey.cachedOn);
      expect(updated.value, date);
    });

    test('upsert update success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();

      String date = DateTime.now().toIso8601String();

      await repository.insert(TikiChainPropsModel(
          key: TikiChainPropsKey.cachedOn,
          value: DateTime.now().toIso8601String()));

      TikiChainPropsModel upsert = await repository.upsert(
          TikiChainPropsModel(key: TikiChainPropsKey.cachedOn, value: date));

      expect(upsert.key, TikiChainPropsKey.cachedOn);
      expect(upsert.value, date);
    });

    test('upsert insert success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();

      String date = DateTime.now().toIso8601String();

      TikiChainPropsModel upsert = await repository.upsert(
          TikiChainPropsModel(key: TikiChainPropsKey.cachedOn, value: date));

      expect(upsert.key, TikiChainPropsKey.cachedOn);
      expect(upsert.value, date);
    });

    test('get success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainPropsRepository repository = TikiChainPropsRepository(database);
      await repository.createTable();

      String date = DateTime.now().toIso8601String();

      TikiChainPropsModel upsert = await repository.upsert(
          TikiChainPropsModel(key: TikiChainPropsKey.cachedOn, value: date));

      TikiChainPropsModel? found =
          await repository.get(TikiChainPropsKey.cachedOn);

      expect(found != null, true);
      expect(found?.key, upsert.key);
      expect(found?.value, upsert.value);
    });
  });
}
