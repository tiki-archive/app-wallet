/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';

import '../api/tiki_api_model_rsp.dart';
import 'tiki_bkup_model_add_req.dart';
import 'tiki_bkup_model_find_req.dart';
import 'tiki_bkup_model_find_rsp.dart';
import 'tiki_bkup_model_update_req.dart';

class TikiBkupRepository {
  final Logger _log = Logger('TikiBkupRepository');

  static const String _path = 'https://bouncer.mytiki.com/api/latest/backup';
  static const String _pathAdd = _path + '/add';
  static const String _pathUpdate = _path + '/update';
  static const String _pathFind = _path + '/find';

  Future<void> add(
      {required HttppClient client,
      String? accessToken,
      TikiBkupModelAddReq? body,
      void Function()? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_pathAdd),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody.fromJson(body?.toJson()),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) onSuccess();
        },
        onResult: onError,
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> update(
      {required HttppClient client,
      String? accessToken,
      TikiBkupModelUpdateReq? body,
      void Function()? onSuccess,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_pathUpdate),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody.fromJson(body?.toJson()),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) onSuccess();
        },
        onResult: onError,
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> find(
      {required HttppClient client,
      String? accessToken,
      TikiBkupModelFindReq? body,
      void Function(TikiBkupModelFindRsp)? onSuccess,
      void Function(TikiApiModelRsp)? onResult,
      void Function(Object)? onError}) {
    HttppRequest request = HttppRequest(
        uri: Uri.parse(_pathFind),
        verb: HttppVerb.POST,
        headers: HttppHeaders.typical(bearerToken: accessToken),
        body: HttppBody.fromJson(body?.toJson()),
        timeout: Duration(seconds: 30),
        onSuccess: (rsp) {
          if (onSuccess != null) {
            TikiApiModelRsp<TikiBkupModelFindRsp> body =
                TikiApiModelRsp.fromJson(rsp.body?.jsonBody,
                    (json) => TikiBkupModelFindRsp.fromJson(json));
            onSuccess(body.data);
          }
        },
        onResult: (rsp) {
          if (onResult != null) {
            TikiApiModelRsp body =
                TikiApiModelRsp.fromJson(rsp.body?.jsonBody, (json) {});
            onResult(body);
          }
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }
}
