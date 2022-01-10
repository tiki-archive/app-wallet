/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:flutter/foundation.dart';

import '../crypto_utils.dart' as utils;
import 'crypto_aes_key.dart';

Future<CryptoAESKey> generate() => compute(_generate, "").then((key) => key);

CryptoAESKey _generate(_) => CryptoAESKey(utils.secureRandom().nextBytes(32));
