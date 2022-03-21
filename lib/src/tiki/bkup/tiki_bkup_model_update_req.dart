/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiBkupModelUpdateReq {
  String? email;
  String? oldPin;
  String? newPin;
  String? ciphertext;

  TikiBkupModelUpdateReq(
      {this.email, this.oldPin, this.newPin, this.ciphertext});

  TikiBkupModelUpdateReq.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      email = json['email'];
      oldPin = json['oldPin'];
      newPin = json['newPin'];
      ciphertext = json['ciphertext'];
    }
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'oldPin': oldPin,
        'newPin': newPin,
        'ciphertext': ciphertext
      };
}
