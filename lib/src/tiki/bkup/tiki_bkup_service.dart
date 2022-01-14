/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

import 'dart:convert';
import 'dart:typed_data';

import 'package:httpp/httpp.dart';

import '../../crypto/crypto_utils.dart' as cryptoutils;
import '../keys/tiki_keys_model.dart';
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
      required String passphrase,
      required TikiKeysModel keys,
      Function(Object)? onError,
      Function()? onSuccess}) {
    RegExp pinCheck = RegExp(r'[0-9]{6,}$');
    RegExp phraseCheck = RegExp(r'^[\x20-\x7E]{8,}$');
    if (!pinCheck.hasMatch(pin) || !phraseCheck.hasMatch(passphrase))
      throw ArgumentError('pin must be 6+ digits and passphrase 8+ chars');

    String ciphertext = base64.encode(keys.encrypt(passphrase));
    return _repository.add(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelAddReq(
            email: _hash(email), pin: _hash(pin), ciphertext: ciphertext),
        onSuccess: onSuccess,
        onError: onError);
  }

  Future<void> recover(
      {required String email,
      required String accessToken,
      required String pin,
      required String passphrase,
      Function(Object)? onError,
      Function(TikiKeysModel)? onSuccess}) {
    return _repository.find(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelFindReq(email: _hash(email), pin: _hash(pin)),
        onError: onError,
        onSuccess: (rsp) async {
          try {
            if (rsp.ciphertext == null) throw StateError('No ciphertext');
            TikiKeysModel keys = TikiKeysModel.decrypt(
                passphrase, base64.decode(rsp.ciphertext!));
            if (onSuccess != null) onSuccess(keys);
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
      required String passphrase,
      required TikiKeysModel keys,
      Function(Object)? onError,
      Function()? onSuccess}) {
    RegExp pinCheck = RegExp(r'[0-9]{6,}$');
    RegExp phraseCheck = RegExp(r'^[\x20-\x7E]{8,}$');
    if (!pinCheck.hasMatch(newPin) || !phraseCheck.hasMatch(passphrase))
      throw ArgumentError('pin must be 6+ digits and passphrase 8+ chars');

    String ciphertext = base64.encode(keys.encrypt(passphrase));
    return _repository.update(
        client: _client,
        accessToken: accessToken,
        body: TikiBkupModelUpdateReq(
            email: _hash(email),
            oldPin: _hash(oldPin),
            newPin: _hash(newPin),
            ciphertext: ciphertext),
        onError: onError,
        onSuccess: onSuccess);
  }

  String _hash(String s) => base64.encode(
      cryptoutils.sha256(Uint8List.fromList(utf8.encode(s)), sha3: true));
}
