/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';
import 'package:wallet/src/tiki/api/tiki_api_model_rsp_message.dart';
import 'package:wallet/src/tiki/bkup/tiki_bkup_error_lock.dart';

import '../../crypto/crypto_utils.dart' as cryptoutils;
import 'tiki_bkup_model_add_req.dart';
import 'tiki_bkup_model_find_req.dart';
import 'tiki_bkup_model_update_req.dart';
import 'tiki_bkup_repository.dart';

class TikiBkupService {
  final HttppClient _client;
  final TikiBkupRepository _repository;

  TikiBkupService({Httpp? httpp})
      : _repository = TikiBkupRepository(),
        _client = httpp == null ? Httpp().client() : httpp.client();

  Future<void> backup(
      {required String email,
      required String accessToken,
      required String pin,
      required Uint8List ciphertext,
      Function(Object)? onError,
      Function()? onSuccess}) async {
    RegExp pinCheck = RegExp(r'[0-9]{6,}$');
    if (!pinCheck.hasMatch(pin)) throw ArgumentError('pin must be 6+ digits');
    return _repository.add(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelAddReq(
            email: _hash(email),
            pin: _hash(pin),
            ciphertext: base64.encode(ciphertext)),
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<void> recover(
      {required String email,
      required String accessToken,
      required String pin,
      Function(Object)? onError,
      Function(Uint8List?)? onSuccess}) async {
    return _repository.find(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelFindReq(email: _hash(email), pin: _hash(pin)),
        onError: onError,
        onResult: (rsp) {
          if (rsp.code == 403) {
            Iterable<TikiApiModelRspMessage>? lockMsgs = rsp.messages
                ?.where((e) => e.properties?.containsKey('LockCode') ?? false);
            if (lockMsgs != null && lockMsgs.length > 0) {
              TikiBkupErrorLock error =
                  TikiBkupErrorLock(lockMsgs.first.properties!['LockCode']!);
              onError == null ? throw error : onError(error);
            }
          }
        },
        onSuccess: (rsp) {
          try {
            if (onSuccess != null)
              onSuccess(rsp.ciphertext != null
                  ? base64.decode(rsp.ciphertext!)
                  : null);
          } catch (error) {
            onError == null ? throw error : onError(error);
          }
        });
  }

  Future<void> cycle(
      {required String email,
      required String accessToken,
      required String oldPin,
      required String newPin,
      required Uint8List ciphertext,
      Function(Object)? onError,
      Function()? onSuccess}) async {
    RegExp pinCheck = RegExp(r'[0-9]{6,}$');
    if (!pinCheck.hasMatch(newPin) && oldPin != newPin)
      throw ArgumentError('new pin must be different and 6+ digits');

    return _repository.update(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelUpdateReq(
            email: _hash(email),
            oldPin: _hash(oldPin),
            newPin: _hash(newPin),
            ciphertext: base64.encode(ciphertext)),
        onError: onError,
        onSuccess: onSuccess);
  }

  String _hash(String s) => base64.encode(
      cryptoutils.sha256(Uint8List.fromList(utf8.encode(s)), sha3: true));
}
