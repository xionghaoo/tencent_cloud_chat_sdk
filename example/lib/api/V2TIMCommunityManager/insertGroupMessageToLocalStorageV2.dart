// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/commonWidget/getFriendList.dart';
import 'package:tencent_cloud_chat_sdk_example/commonWidget/getJoinedGroupList.dart';
import 'package:tencent_cloud_chat_sdk_example/utils/fluttertoast.dart';

typedef OnData = void Function(Map<String, dynamic> d);

class InsertGroupMessageToLocalStorageV2 extends StatefulWidget {
  const InsertGroupMessageToLocalStorageV2({super.key});

  @override
  State<StatefulWidget> createState() => _InsertGroupMessageToLocalStorageV2State();
}

class _InsertGroupMessageToLocalStorageV2State extends State<InsertGroupMessageToLocalStorageV2> {
  List<String> datas = [];

  void onData(Map<String, dynamic> d) {
    List<String> dc = datas;
    dc.add(d.toString());
    setState(() {
      datas = dc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InsertGroupMessageToLocalStorageV2"),
      ),
      body: Column(children: [
        InsertGroupMessageToLocalStorageV2Btns(
          onData: onData,
        ),
        Expanded(
          child: InsertGroupMessageToLocalStorageV2Returns(
            data: datas,
          ),
        )
      ]),
    );
  }
}

class InsertGroupMessageToLocalStorageV2Btns extends StatefulWidget {
  final OnData onData;
  const InsertGroupMessageToLocalStorageV2Btns({
    super.key,
    required this.onData,
  });

  @override
  State<StatefulWidget> createState() => _InsertGroupMessageToLocalStorageV2BtnsState();
}

class _InsertGroupMessageToLocalStorageV2BtnsState extends State<InsertGroupMessageToLocalStorageV2Btns> {
  String groupID = "";
  String userID = "";
  String createMsgId = "";
  ceateMessage() async {
    var data = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: "1231");
    if (data.code == 0) {
      if (data.data != null) {
        if (data.data!.id != null) {
          setState(() {
            createMsgId = data.data!.id ?? "";
          });
        }
      }
    }
    widget.onData(data.toJson());
  }

  String sendcid = "";
  insertMessage() async {
    if (groupID.isEmpty || userID.isEmpty || createMsgId.isEmpty) {
      await ToastUtils.showToast("groupID or userID or createMsgId is empty");
      return;
    }
    var data = await TencentImSDKPlugin.v2TIMManager.getMessageManager().insertGroupMessageToLocalStorageV2(
          groupID: groupID,
          senderID: userID,
          createdMsgID: createMsgId,
        );
    if (data.code == 0) {
      if (data.data != null) {
        if (data.data!.id != null) {
          setState(() {
            sendcid = data.data!.id ?? "";
          });
        }
      }
    }
    widget.onData(data.toJson());
  }

  selectGroup() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("choose group"),
          content: SelectGroupIds(
            isMultSelect: false,
            onselected: (data) {
              if (data.isNotEmpty) {
                setState(() {
                  groupID = data.first;
                });
              }
            },
          ),
        );
      },
    );
  }

  selectUser() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("choose group"),
          content: SelectFriendsIds(
            isMultSelect: false,
            onselected: (data) {
              if (data.isNotEmpty) {
                setState(() {
                  userID = data.first;
                });
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: selectGroup,
              child: Text(groupID.isEmpty ? "choose a groupID" : groupID),
            ),
            ElevatedButton(
              onPressed: selectUser,
              child: Text(userID.isEmpty ? "choose a userID" : userID),
            ),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(onPressed: ceateMessage, child: const Text("create a text message")),
            ElevatedButton(
              onPressed: insertMessage,
              child: const Text("insert to local"),
            )
          ],
        ),
        const Divider(),
      ],
    );
  }
}

class InsertGroupMessageToLocalStorageV2Returns extends StatefulWidget {
  final List<String> data;
  const InsertGroupMessageToLocalStorageV2Returns({
    super.key,
    required this.data,
  });

  @override
  State<StatefulWidget> createState() => _InsertGroupMessageToLocalStorageV2ReturnsState();
}

class _InsertGroupMessageToLocalStorageV2ReturnsState extends State<InsertGroupMessageToLocalStorageV2Returns> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: ListView(
          children: widget.data
              .map(
                (e) => Column(
                  children: [
                    Text(e),
                    const Divider(),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
