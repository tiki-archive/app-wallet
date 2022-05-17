/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:tiki_localchain/tiki_localchain.dart';
import 'package:tiki_wallet/src/tiki/chain/tiki_chain_cache_model.dart';
import 'package:tiki_wallet/src/tiki/chain/tiki_chain_cache_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('tiki_chain_cache_repository integration tests', () {
    test('create success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainCacheRepository repository = TikiChainCacheRepository(database);
      await repository.createTable();
    });

    test('insert success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainCacheRepository repository = TikiChainCacheRepository(database);
      await repository.createTable();

      Uint8List dummy = Uint8List.fromList(utf8.encode('hello'));

      TikiChainCacheModel inserted = await repository.insert(
          TikiChainCacheModel(
              hash: dummy,
              contents: dummy,
              previousHash: dummy,
              created: DateTime.now(),
              schema: BlockContentsSchema.bytea));

      expect(inserted.previousHash, dummy);
      expect(inserted.contents, dummy);
      expect(inserted.previousHash, dummy);
      expect(inserted.created != null, true);
      expect(inserted.schema, BlockContentsSchema.bytea);
    });

    test('get success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainCacheRepository repository = TikiChainCacheRepository(database);
      await repository.createTable();

      Uint8List dummy = Uint8List.fromList(utf8.encode('hello'));

      TikiChainCacheModel inserted = await repository.insert(
          TikiChainCacheModel(
              hash: dummy,
              contents: dummy,
              previousHash: dummy,
              created: DateTime.now(),
              schema: BlockContentsSchema.bytea));

      TikiChainCacheModel? found = await repository.get(dummy);

      expect(found != null, true);
      expect(found?.previousHash, inserted.previousHash);
      expect(found?.contents, inserted.contents);
      expect(found?.previousHash, inserted.previousHash);
      expect(found?.created != null, true);
      expect(found?.schema, BlockContentsSchema.bytea);
    });

    test('drop success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainCacheRepository repository = TikiChainCacheRepository(database);
      await repository.createTable();

      Uint8List dummy = Uint8List.fromList(utf8.encode('hello'));

      await repository.insert(TikiChainCacheModel(
          hash: dummy,
          contents: dummy,
          previousHash: dummy,
          created: DateTime.now(),
          schema: BlockContentsSchema.bytea));

      await repository.drop();

      TikiChainCacheModel? found = await repository.get(dummy);

      expect(found == null, true);
    });

    test('getAll success', () async {
      Database database =
          await openDatabase(await getDatabasesPath() + '/${Uuid().v4()}.db');
      TikiChainCacheRepository repository = TikiChainCacheRepository(database);
      await repository.createTable();

      Uint8List h1 = Uint8List.fromList(utf8.encode(Uuid().v4()));
      Uint8List h2 = Uint8List.fromList(utf8.encode(Uuid().v4()));

      Uint8List dummy = Uint8List.fromList(utf8.encode('hello'));

      await repository.insert(TikiChainCacheModel(
          hash: h1,
          contents: dummy,
          previousHash: dummy,
          created: DateTime.now(),
          schema: BlockContentsSchema.bytea));

      await repository.insert(TikiChainCacheModel(
          hash: h2,
          contents: dummy,
          previousHash: dummy,
          created: DateTime.now(),
          schema: BlockContentsSchema.bytea));

      List<TikiChainCacheModel> found = await repository
          .getAll([h1, h2, Uint8List.fromList(utf8.encode(Uuid().v4()))]);

      expect(found.length, 2);
      expect(found.any((element) => ListEquality().equals(element.hash, h1)),
          true);
      expect(found.any((element) => ListEquality().equals(element.hash, h2)),
          true);
    });
  });
}
