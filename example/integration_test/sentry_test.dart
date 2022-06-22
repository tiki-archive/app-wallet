import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:tiki_wallet/tiki_wallet.dart';

main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Log Error Tests', () {
    test("runzoneguarded catch uncaught errors", () async {
      bool errorCaught = false;
      await runZonedGuarded(() async {
        Logger.root.level = Level.INFO;
        Logger.root.onRecord.listen((record) => errorCaught = true);
        WidgetsFlutterBinding.ensureInitialized();

        TikiKeysService service = TikiKeysService(
            secureStorage: FlutterSecureStorage());
        TikiKeysModel tikiKeysModel = TikiKeysModel(
            '', getDynamic(), getDynamic());
        await service.provide(tikiKeysModel);

        FlutterError.onError = (FlutterErrorDetails details) {
          Logger("Flutter Error").severe(
              details.summary, details.exception, details.stack);
        };
        runApp(Container());
      }, (exception, stackTrace) async {
        Logger("Uncaught Exception").severe(
            "Caught by runZoneGuarded", exception, stackTrace);
      });
      expect(errorCaught, true);
    });
  });
}

getDynamic() {
  return null;
}