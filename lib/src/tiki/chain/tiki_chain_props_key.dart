/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiChainPropsKey {
  final String _string;

  static const TikiChainPropsKey cachedOn = TikiChainPropsKey('cached_on');

  static const List<TikiChainPropsKey> all = [
    cachedOn,
  ];

  const TikiChainPropsKey(this._string);

  String get string => _string;

  static TikiChainPropsKey? fromString(String string) {
    try {
      return all.firstWhere((element) => element.string == string);
    } catch (error) {
      return null;
    }
  }
}
