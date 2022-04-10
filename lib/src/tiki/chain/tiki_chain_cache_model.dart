/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:localchain/localchain.dart';

class TikiChainCacheModel {
  Uint8List? hash;
  Uint8List? contents;
  Uint8List? previousHash;
  DateTime? created;
  BlockContentsSchema? schema;

  TikiChainCacheModel(
      {this.hash, this.contents, this.previousHash, this.created, this.schema});

  TikiChainCacheModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      hash = map['hash'];
      contents = map['contents'];
      previousHash = map['previous_hash'];
      schema = BlockContentsSchema.fromCode(map['block_schema']);
      if (map['created_epoch'] != null) {
        created = DateTime.fromMillisecondsSinceEpoch(map['created_epoch']);
      }
    }
  }

  Map<String, dynamic> toMap() => {
        'hash': hash,
        'contents': contents,
        'previous_hash': previousHash,
        'created_epoch': created?.millisecondsSinceEpoch,
        'block_schema': schema?.code
      };

  @override
  String toString() {
    return 'TikiChainCacheModel{contents: $contents, previousHash: $previousHash, created: $created, schema: $schema}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiChainCacheModel &&
          runtimeType == other.runtimeType &&
          listEquals(hash, other.hash) &&
          listEquals(contents, other.contents) &&
          listEquals(previousHash, other.previousHash) &&
          created == other.created &&
          schema?.code == other.schema?.code;

  @override
  int get hashCode =>
      hash.hashCode ^
      contents.hashCode ^
      previousHash.hashCode ^
      created.hashCode ^
      schema.hashCode;
}
