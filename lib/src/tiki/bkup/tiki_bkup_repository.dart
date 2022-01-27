/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'package:httpp/httpp.dart';
import 'package:logging/logging.dart';
import 'package:wallet/src/tiki/api/tiki_api_model_rsp_message.dart';

import '../api/tiki_api_model_rsp.dart';
import 'tiki_bkup_error_http.dart';
import 'tiki_bkup_error_lock.dart';
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
        onResult: (rsp) {
          TikiApiModelRsp body =
              TikiApiModelRsp.fromJson(rsp.body?.jsonBody, (json) {});
          TikiBkupErrorHttp error = TikiBkupErrorHttp(body);
          onError == null ? throw error : onError(error);
        },
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
        onResult: (rsp) {
          TikiApiModelRsp body =
              TikiApiModelRsp.fromJson(rsp.body?.jsonBody, (json) {});
          TikiBkupErrorHttp error = TikiBkupErrorHttp(body);
          onError == null ? throw error : onError(error);
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }

  Future<void> find(
      {required HttppClient client,
      String? accessToken,
      TikiBkupModelFindReq? body,
      void Function(TikiBkupModelFindRsp)? onSuccess,
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
          TikiApiModelRsp body =
              TikiApiModelRsp.fromJson(rsp.body?.jsonBody, (json) {});
          Error error;
          if (body.code == 403) {
            Iterable<TikiApiModelRspMessage>? lockMsgs = body.messages
                ?.where((e) => e.properties?.containsKey('LockCode') ?? false);
            if (lockMsgs != null && lockMsgs.length > 0)
              error =
                  TikiBkupErrorLock(lockMsgs.first.properties!['LockCode']!);
            else
              error = TikiBkupErrorHttp(body);
          } else
            error = TikiBkupErrorHttp(body);
          onError == null ? throw error : onError(error);
        },
        onError: onError);
    _log.finest('${request.verb.value} — ${request.uri}');
    return client.request(request);
  }
}
