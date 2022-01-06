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
      this.email = json['email'];
      this.pin = json['pin'];
      this.ciphertext = json['ciphertext'];
    }
  }

  Map<String, dynamic> toJson() =>
      {'email': email, 'pin': pin, 'ciphertext': ciphertext};
}
