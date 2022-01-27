/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import '../api/tiki_api_model_rsp.dart';

class TikiBkupErrorHttp extends Error {
  final TikiApiModelRsp rsp;
  TikiBkupErrorHttp(this.rsp);

  @override
  String toString() => "Http error. ${rsp.toJson()}";
}
