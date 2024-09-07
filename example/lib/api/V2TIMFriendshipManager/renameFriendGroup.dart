import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class RenameFriendGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RenameFriendGroupState();
  }
}

class _RenameFriendGroupState extends State<RenameFriendGroup> {
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
    V2TimCallback renameFriendGroupRes = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .renameFriendGroup(
          oldName: selectedId, //旧的分组名称
          newName: _statusController.text, //新的分组名称
        );
    setState(() {
      result = renameFriendGroupRes.toJson().toString();
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
        title: Text('RenameFriendGroup'),
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
                      selectedId = id ?? '';
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
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "new name",
                  hintText: "new name",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('RenameFriendGroup'),
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
