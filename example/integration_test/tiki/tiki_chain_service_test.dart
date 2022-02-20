/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:localchain/localchain.dart';
import 'package:wallet/src/tiki/chain/tiki_chain_service.dart';
import 'package:wallet/src/tiki/keys/tiki_keys_model.dart';
import 'package:wallet/src/tiki/keys/tiki_keys_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('tiki-chain-service integration tests', () {
    test('write_success', () async {
      TikiKeysService tikiKeysService = TikiKeysService();
      TikiKeysModel keys = await tikiKeysService.generate();
      TikiChainService tikiChainService = await TikiChainService(keys).open();
      BlockContentsJson contents = BlockContentsJson(json: '"hello":"world"');
      Block block = await tikiChainService.write(contents);
      expect(block.contents != null, true);
      expect(block.previousHash != null, true);
      expect(block.created != null, true);
      BlockContents decryptBlock =
          await tikiChainService.decrypt(block.contents!);
      expect(decryptBlock.schema, BlockContentsSchema.json);
      BlockContentsJson decrypted = decryptBlock as BlockContentsJson;
      expect(decrypted.json, contents.json);
    });
  });
}
