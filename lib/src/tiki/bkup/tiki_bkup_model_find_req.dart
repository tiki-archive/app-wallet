/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiBkupModelFindReq {
  String? email;
  String? pin;

  TikiBkupModelFindReq({this.email, this.pin});

  TikiBkupModelFindReq.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      this.email = json['email'];
      this.pin = json['pin'];
    }
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'pin': pin,
      };
}
