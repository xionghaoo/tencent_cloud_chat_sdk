// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class VoiceToText extends StatefulWidget {
  const VoiceToText({super.key});

  @override
  State<StatefulWidget> createState() => _VoiceToTextState();
}

class _VoiceToTextState extends State<VoiceToText> {
  String res = "";

  translate() async {
    // var ret = await TencentImSDKPlugin.v2TIMManager.getMessageManager().translateText(texts: ["hello"], targetLanguage: "zh", sourceLanguage: "auto");

    var dd = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageReactions(
      msgIDList: ["144115383705021855-1718874076-21084529", "144115383705021855-1718874022-88975690", "144115383188335150-1718873987-78920249", "144115383188335150-1718873978-19735258"],
      maxUserCountPerReaction: 10,
    );
    print(dd.toJson());

    // TencentImSDKPlugin.v2TIMManager
    //     .getMessageManager()
    //     .getHistoryMessageListV2(
    //       count: 2,
    //       userID: "964162008",
    //     )
    //     .then((data) async {
    //   var ar = await TencentImSDKPlugin.v2TIMManager.getMessageManager().addMessageReaction(msgID: data.data?.messageList.first.msgID ?? "", reactionID: "[TUIEmoji_Smile]");
    //   var dd = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getMessageReactions(
    //         msgIDList: data.data!.messageList.map((e) => (e.msgID ?? "")).toList(),
    //         maxUserCountPerReaction: 10,
    //       );
    //   print(dd.toJson());
    //   // var mergere = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createMergerMessage(
    //   //   abstractList: ["小何:heheh", "小王:hahaha"],
    //   //   msgIDList: data.data!.messageList.map((e) => e.msgID ?? "").toList(),
    //   //   title: "小何和小王的聊天记录",
    //   //   compatibleText: "不兼容",
    //   // );

    // });

    setState(() {
      res = dd.toJson().toString();
    });
    // TencentImSDKPlugin.v2TIMManager.callExperimentalAPI(api: "disableBadgeNumber", param: true);
  }

  @override
  void initState() {
    super.initState();
    translate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TranslateTextPage"),
      ),
      body: Text(res),
    );
  }
}
