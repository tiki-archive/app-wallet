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
      this.email = json['email'];
      this.oldPin = json['oldPin'];
      this.newPin = json['newPin'];
      this.ciphertext = json['ciphertext'];
    }
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'oldPin': oldPin,
        'newPin': newPin,
        'ciphertext': ciphertext
      };
}
