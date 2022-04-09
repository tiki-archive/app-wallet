/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/localchain.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'package:wallet/src/crypto/aes/crypto_aes.dart' as aes;
import 'package:wallet/src/tiki/chain/tiki_chain_props_key.dart';
import 'package:wallet/src/tiki/chain/tiki_chain_props_model.dart';
import 'package:wallet/src/tiki/chain/tiki_chain_props_repository.dart';
import 'package:wallet/wallet.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('tiki-chain-service integration tests', () {
    test('write_success', () async {
      TikiKeysService tikiKeysService = TikiKeysService();
      TikiKeysModel keys = await tikiKeysService.generate();
      Database database = await openDatabase(
          await getDatabasesPath() + '/${Uuid().v4()}.db',
          singleInstance: true);
      TikiChainService tikiChainService =
          await TikiChainService(keys).open(database);
      BlockContentsJson contents = BlockContentsJson(json: '"hello":"world"');
      TikiChainCacheBlock block = await tikiChainService.write(contents);
      expect(block.plaintextContents != null, true);
      expect(block.cipherContents != null, true);
      expect(block.hash != null, true);
      expect(block.previousHash != null, true);
      expect(block.created != null, true);
      TikiChainCacheBlock? read = await tikiChainService.read(block.hash!);
      expect(read?.hash, block.hash);
      expect(read?.plaintextContents, block.plaintextContents);
      expect(read?.previousHash, block.previousHash);
    });

    test('cache_init success', () async {
      TikiKeysService tikiKeysService = TikiKeysService();
      TikiKeysModel keys = await tikiKeysService.generate();

      Localchain localchain = await Localchain().open(keys.address);

      for (int i = 0; i < 100; i++) {
        BlockContentsJson contents = BlockContentsJson(json: '"hello":"world"');
        Uint8List ciphertext =
            await aes.encrypt(Localchain.codec.encode(contents), keys.data);
        await localchain.append(ciphertext);
      }

      Database database = await openDatabase(
          await getDatabasesPath() + '/${Uuid().v4()}.db',
          singleInstance: true);

      await TikiChainService(keys).open(database);

      await Future.delayed(Duration(minutes: 1));

      TikiChainPropsRepository propsRepository =
          TikiChainPropsRepository(database);

      TikiChainPropsModel? createdOn =
          await propsRepository.get(TikiChainPropsKey.cachedOn);
      expect(createdOn != null, true);
    });
  });
}
