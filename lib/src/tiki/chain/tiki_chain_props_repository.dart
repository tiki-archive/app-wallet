/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:logging/logging.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:sqflite_sqlcipher/sqlite_api.dart';

import 'tiki_chain_props_key.dart';
import 'tiki_chain_props_model.dart';

class TikiChainPropsRepository {
  static const String _table = 'localchain_props';
  final _log = Logger('TikiChainPropsRepository');

  final Database _database;

  TikiChainPropsRepository(this._database);

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _database.transaction(action);

  Future<void> createTable() =>
      _database.execute('CREATE TABLE IF NOT EXISTS $_table('
          'key TEXT PRIMARY KEY, '
          'value TEXT);');

  Future<TikiChainPropsModel> insert(TikiChainPropsModel props,
      {Transaction? txn}) async {
    await (txn ?? _database).insert(_table, props.toMap());
    _log.finest('inserted: #${props.key?.string}');
    return props;
  }

  Future<TikiChainPropsModel> update(TikiChainPropsModel props,
      {Transaction? txn}) async {
    await (txn ?? _database).update(_table, props.toMap(),
        where: 'key = ?', whereArgs: [props.key?.string]);
    _log.finest('updated: #${props.key?.string}');
    return props;
  }

  Future<TikiChainPropsModel> upsert(TikiChainPropsModel props) =>
      _database.transaction<TikiChainPropsModel>((txn) async {
        TikiChainPropsModel? exists = await get(props.key!, txn: txn);
        return exists != null
            ? update(props, txn: txn)
            : insert(props, txn: txn);
      });

  Future<TikiChainPropsModel?> get(TikiChainPropsKey key,
      {Transaction? txn}) async {
    List<Map<String, Object?>> rows = await (txn ?? _database).query(_table,
        columns: [
          'key',
          'value',
        ],
        where: 'key = ?',
        whereArgs: [key.string]);
    if (rows.isEmpty) {
      _log.finest('${key.string} not found');
      return null;
    } else {
      _log.finest('got ${key.string}');
      return TikiChainPropsModel.fromMap(rows[0]);
    }
  }
}
