/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiBkupErrorLock extends Error {
  final String code;
  TikiBkupErrorLock(this.code);

  @override
  String toString() => "Backup locked. Code: $code";
}
