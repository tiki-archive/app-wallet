/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'tiki_chain_props_key.dart';

class TikiChainPropsModel {
  TikiChainPropsKey? key;
  String? value;

  TikiChainPropsModel({this.key, this.value});

  TikiChainPropsModel.fromMap(Map<String, dynamic>? map) {
    if (map != null) {
      if (map['key'] != null) {
        key = TikiChainPropsKey.fromString(map['key']);
      }
      value = map['value'];
    }
  }

  Map<String, dynamic> toMap() => {'key': key?.string, 'value': value};

  @override
  String toString() {
    return 'TikiChainPropsModel{key: $key, value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TikiChainPropsModel &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          value == other.value;

  @override
  int get hashCode => key.hashCode ^ value.hashCode;
}
