// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_info.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class CreatePermissionGroupInCommunity extends StatefulWidget {
  const CreatePermissionGroupInCommunity({super.key});

  @override
  State<StatefulWidget> createState() =>
      _CreatePermissionGroupInCommunityState();
}

class _CreatePermissionGroupInCommunityState
    extends State<CreatePermissionGroupInCommunity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TencentImSDKPlugin.managerInstance()
        .getCommunityManager()
        .createPermissionGroupInCommunity(
          info: V2TimPermissionGroupInfo.fromJson({
            "customData": "",
              "groupID": "@TGS#_test_community",
              "groupPermission": 1,
              "memberCount": 10,
              "permissionGroupID": "@PMG#_test23456",
              "permissionGroupName": "test23456"
          }),
        ).then((value){
          print(value.toJson());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CreatePermissionGroupInCommunity"),
      ),
      body: Container(),
    );
  }
}
