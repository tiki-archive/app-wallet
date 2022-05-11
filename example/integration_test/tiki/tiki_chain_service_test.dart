/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pointycastle/export.dart';
import 'package:tiki_localchain/tiki_localchain.dart';
import 'package:tiki_wallet/src/crypto/crypto_utils.dart' as crypto;
import 'package:tiki_wallet/src/tiki/keys/tiki_keys_model.dart';
import 'package:tiki_wallet/src/tiki/keys/tiki_keys_service.dart';
import 'package:tiki_wallet/tiki_wallet.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Uint8List _encrypt(Uint8List plaintext, CryptoAESKey aes) {
    Uint8List iv = crypto.secureRandom().nextBytes(16);
    final cipher = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    )..init(
        true,
        PaddedBlockCipherParameters<CipherParameters, CipherParameters>(
          ParametersWithIV<KeyParameter>(KeyParameter(aes.key!), iv),
          null,
        ),
      );

    BytesBuilder cipherBuilder = BytesBuilder();
    cipherBuilder.add(iv);
    cipherBuilder.add(cipher.process(crypto.addPadding(plaintext, 16, pad: 0)));
    return cipherBuilder.toBytes();
  }

  group('tiki_chain_service integration tests', () {
    test('write 100', () async {
      TikiKeysService service = TikiKeysService();
      TikiKeysModel tikiKeysModel = await service.generate();

      int pageSize = 100;

      Map<String, Uint8List> raw = {
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
        '${Uuid().v4().toString()}':
            Uint8List.fromList(utf8.encode(Uuid().v4().toString())),
      };

      Map<String, BlockContentsDataNft> reqs = raw.map((key, value) {
        Uint8List proof = crypto.secureRandom().nextBytes(32);
        BytesBuilder builder = BytesBuilder();
        builder.add(value);
        builder.add(proof);
        Uint8List fingerprint = crypto.sha256(builder.toBytes(), sha3: true);
        return MapEntry(
            key,
            BlockContentsDataNft(
                fingerprint: base64.encode(fingerprint),
                proof: base64.encode(proof)));
      });

      print(DateTime.now().toIso8601String());
      int numPages = (reqs.length / pageSize).ceil();

      for (int i = 0; i < numPages; i++) {
        int start = i * pageSize;
        int end =
            start + pageSize > reqs.length ? reqs.length : start + pageSize;

        List<Future<MapEntry<String, Uint8List>>> encrypting =
            List.empty(growable: true);
        for (int j = start; j < end; j++) {
          MapEntry<String, BlockContents> entry = reqs.entries.elementAt(j);
          Uint8List ciphertext = _encrypt(
              TikiLocalchain.codec.encode(entry.value), tikiKeysModel.data);
        }

        print('doneski: ${i}');
        print(DateTime.now().toIso8601String());
      }
      print(DateTime.now().toIso8601String());
    });
  });
}
