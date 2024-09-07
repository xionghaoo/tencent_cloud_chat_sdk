import 'dart:convert';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';

class V2TimMessageReactionResult {
  int? resultCode;
  String? resultInfo;
  late String messageID;
  List<V2TimMessageReaction>? reactionList;

  V2TimMessageReactionResult({
    this.resultCode,
    this.resultInfo,
    required this.messageID,
    this.reactionList,
  });

  V2TimMessageReactionResult.fromJson(Map json) {
    json = Utils.formatJson(json);
    resultCode = json['resultCode'] ?? 0;
    resultInfo = json['resultInfo'] ?? "";
    messageID = json['messageID'] ?? "";
    if (json['reactionList'] != null) {
      reactionList = List.empty(growable: true);
      json['reactionList'].forEach((v) {
        reactionList?.add(V2TimMessageReaction.fromJson(v));
      });
    } else {
      reactionList = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['resultCode'] = resultCode;
    data['resultInfo'] = resultInfo;
    data['messageID'] = messageID;
    data['reactionList'] = reactionList?.map((v) => v.toJson()).toList();
    return data;
  }
  String toLogString() {
    String res = "resultCode:$resultCode|resultInfo:$resultInfo|messageID:$messageID|reactionList:${json.encode(reactionList?.map((e) => e.toLogString()).toList())}";
    return res;
  }
}
