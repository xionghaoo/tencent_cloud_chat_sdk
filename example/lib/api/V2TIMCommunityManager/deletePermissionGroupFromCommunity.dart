// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class DeletePermissionGroupFromCommunity extends StatefulWidget {
  const DeletePermissionGroupFromCommunity({super.key});

  @override
  State<StatefulWidget> createState() => _DeletePermissionGroupFromCommunityState();
}

class _DeletePermissionGroupFromCommunityState extends State<DeletePermissionGroupFromCommunity> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    TencentImSDKPlugin.managerInstance().getCommunityManager().getPermissionGroupListInCommunity(groupID: "@TGS#_test_community", permissionGroupIDList: ["@PMG#_test23456"]).then((value){
      print(value.toJson());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DeletePermissionGroupFromCommunity"),
      ),
      body: Container(),
    );
  }
}
