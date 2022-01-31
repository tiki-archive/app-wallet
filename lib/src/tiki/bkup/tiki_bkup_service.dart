/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';

import '../../crypto/crypto_utils.dart' as cryptoutils;
import 'tiki_bkup_error_http.dart';
import 'tiki_bkup_model_add_req.dart';
import 'tiki_bkup_model_find_req.dart';
import 'tiki_bkup_model_update_req.dart';
import 'tiki_bkup_repository.dart';

class TikiBkupService {
  final HttppClient _client;
  final TikiBkupRepository _repository;
  final Future<String> Function()? onUnauthorized;

  TikiBkupService({Httpp? httpp, this.onUnauthorized})
      : _repository = TikiBkupRepository(),
        _client = httpp == null ? Httpp().client() : httpp.client();

  Future<void> backup(
          {required String email,
          required String accessToken,
          required String pin,
          required Uint8List ciphertext,
          Function(Object)? onError,
          Function()? onSuccess}) =>
      _backup(
          email: email,
          accessToken: accessToken,
          pin: pin,
          ciphertext: ciphertext,
          onSuccess: onSuccess,
          onError: (error) async {
            if (error is TikiBkupErrorHttp && onUnauthorized != null) {
              await _backup(
                  email: email,
                  accessToken: await onUnauthorized!(),
                  pin: pin,
                  ciphertext: ciphertext,
                  onSuccess: onSuccess,
                  onError: (error) async =>
                      onError != null ? onError(error) : throw error);
            } else
              onError != null ? onError(error) : throw error;
          });

  Future<void> _backup(
      {required String email,
      required String accessToken,
      required String pin,
      required Uint8List ciphertext,
      required Future<void> Function(Object)? onError,
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
          Function(Uint8List?)? onSuccess}) =>
      _recover(
          email: email,
          accessToken: accessToken,
          pin: pin,
          onSuccess: onSuccess,
          onError: (error) async {
            if (error is TikiBkupErrorHttp && onUnauthorized != null) {
              await _recover(
                  email: email,
                  accessToken: await onUnauthorized!(),
                  pin: pin,
                  onSuccess: onSuccess,
                  onError: (error) async =>
                      onError != null ? onError(error) : throw error);
            } else
              onError != null ? onError(error) : throw error;
          });

  Future<void> _recover(
          {required String email,
          required String accessToken,
          required String pin,
          required Future<void> Function(Object) onError,
          Function(Uint8List?)? onSuccess}) =>
      _repository.find(
          client: _client,
          accessToken: accessToken,
          body: TikiBkupModelFindReq(email: _hash(email), pin: _hash(pin)),
          onError: onError,
          onSuccess: (rsp) {
            try {
              if (onSuccess != null)
                onSuccess(rsp.ciphertext != null
                    ? base64.decode(rsp.ciphertext!)
                    : null);
            } catch (error) {
              onError(error);
            }
          });

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
        onError: (error) async {
          if (error is TikiBkupErrorHttp && onUnauthorized != null) {
            await _cycle(
                email: email,
                accessToken: await onUnauthorized!(),
                oldPin: oldPin,
                newPin: newPin,
                ciphertext: ciphertext,
                onSuccess: onSuccess,
                onError: (error) async =>
                    onError != null ? onError(error) : throw error);
          } else
            onError != null ? onError(error) : throw error;
        },
        onSuccess: onSuccess);
  }

  Future<void> _cycle(
      {required String email,
      required String accessToken,
      required String oldPin,
      required String newPin,
      required Uint8List ciphertext,
      Future<void> Function(Object)? onError,
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
