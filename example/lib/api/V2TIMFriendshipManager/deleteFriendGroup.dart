import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class DeleteFriendGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DeleteFriendGroupState();
  }
}

class _DeleteFriendGroupState extends State<DeleteFriendGroup> {
  String result = '';
  List<String> friends = [];
  List<String> groups = [];
  String selectedId = '';
  String selectedGroup = '';
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getFriendGroupList();
  }

  getFriendGroupList() async {
    V2TimValueCallback<List<V2TimFriendGroup>> getFriendGroupsRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendGroups(groupNameList: null);
    if (getFriendGroupsRes.code == 0) {
      List<String> temp = [];
      getFriendGroupsRes.data?.forEach((element) {
        String name = element.name ?? "";
        if (name != "") {
          temp.add(name);
        }
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimCallback deleteFriendGroupRes = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFriendGroup(groupNameList: [selectedGroup]);
    setState(() {
      result = deleteFriendGroupRes.toJson().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   friends = context.watch<ListenerConfig>().friendList;
    // });

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('DeleteFriendGroup'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<String>(
                    width: 200,
                    label: const Text('group name'),
                    onSelected: (String? id) {
                      selectedGroup = id ?? '';
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries:
                        groups.map<DropdownMenuEntry<String>>((String id) {
                      return DropdownMenuEntry<String>(
                        value: id,
                        label: id,
                      );
                    }).toList()),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('DeleteFriendGroup'),
              onPressed: () {
                pressedFunction();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Text(result)
          ],
        ),
      ),
    ));
  }
}
