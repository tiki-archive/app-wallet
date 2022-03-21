/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiBkupModelAddReq {
  String? email;
  String? pin;
  String? ciphertext;

  TikiBkupModelAddReq({this.email, this.pin, this.ciphertext});

  TikiBkupModelAddReq.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      email = json['email'];
      pin = json['pin'];
      ciphertext = json['ciphertext'];
    }
  }

  Map<String, dynamic> toJson() =>
      {'email': email, 'pin': pin, 'ciphertext': ciphertext};
}
