// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class CreateCommunity extends StatefulWidget {
  const CreateCommunity({super.key});

  @override
  State<StatefulWidget> createState() => _CreateCommunityState();
}

class _CreateCommunityState extends State<CreateCommunity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TencentImSDKPlugin.managerInstance().getCommunityManager().createCommunity(
        info: V2TimGroupInfo.fromJson({
          "groupID": "@TGS#_test_community", "groupType": "Community", "isSupportTopic": true,"groupName": "testtest","isEnablePermissionGroup": true
        }),
        memberList: []).then((value){
          print(value.toJson());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CreateCommunityPage"),
      ),
      body: Container(),
    );
  }
}
