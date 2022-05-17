/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:tiki_localchain/tiki_localchain.dart';
import 'package:tiki_syncchain/tiki_syncchain.dart';

import 'tiki_chain_cache_model.dart';

class TikiChainBlock {
  Uint8List? hash;
  Uint8List? previousHash;
  BlockContentsSchema? schema;
  Uint8List? plaintext;
  Uint8List? ciphertext;
  DateTime? created;
  DateTime? synced;

  TikiChainBlock(
      {this.hash,
      this.previousHash,
      this.schema,
      this.plaintext,
      this.ciphertext,
      this.created,
      this.synced});

  TikiChainBlock.join(
      {Block? block, TikiChainCacheModel? cache, DBModel? sync}) {
    hash = cache?.hash ?? sync?.hash;
    previousHash = block?.previousHash ?? cache?.previousHash;
    schema = cache?.schema;
    plaintext = cache?.contents;
    created = block?.created ?? cache?.created;
    ciphertext = block?.contents;
    synced = sync?.synced;
  }
}
