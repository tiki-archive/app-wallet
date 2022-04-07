/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter/foundation.dart';

class TikiChainCacheBlock {
  Uint8List? hash;
  Uint8List? cipherContents;
  Uint8List? plaintextContents;
  Uint8List? previousHash;
  DateTime? created;

  TikiChainCacheBlock(
      {this.hash,
      this.cipherContents,
      this.plaintextContents,
      this.previousHash,
      this.created});

  @override
  String toString() {
    return 'TikiChainCacheBlock{hash: $hash, cipherContents: $cipherContents, plaintextContents: $plaintextContents, previousHash: $previousHash, created: $created}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiChainCacheBlock &&
          runtimeType == other.runtimeType &&
          listEquals(hash, other.hash) &&
          listEquals(cipherContents, other.cipherContents) &&
          listEquals(plaintextContents, other.plaintextContents) &&
          listEquals(previousHash, other.previousHash) &&
          created == other.created;

  @override
  int get hashCode =>
      hash.hashCode ^
      cipherContents.hashCode ^
      plaintextContents.hashCode ^
      previousHash.hashCode ^
      created.hashCode;
}
