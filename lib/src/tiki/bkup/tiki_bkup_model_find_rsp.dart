/*
 * Copyright (c) TIKI Inc.
 * MIT license. See LICENSE file in root directory.
 */

class TikiBkupModelFindRsp {
  String? ciphertext;

  TikiBkupModelFindRsp({this.ciphertext});

  TikiBkupModelFindRsp.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      ciphertext = json['ciphertext'];
    }
  }

  Map<String, dynamic> toJson() => {'ciphertext': ciphertext};
}
