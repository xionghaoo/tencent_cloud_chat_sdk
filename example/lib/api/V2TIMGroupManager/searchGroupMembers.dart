import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SearchGroupMembers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchGroupMembersState();
  }
}

class _SearchGroupMembersState extends State<SearchGroupMembers> {
  String result = '';
  List<String> conversations = [];
  String selectedconv = '';
  bool userID = true;
  bool nickName = true;
  bool namecard = true;
  bool remark = true;
  List<String> groups = [];
  String selectedGroup = '';
  TextEditingController _keywordController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getJoinedGroup();
  }

  getJoinedGroup() async {
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedGroupListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedGroupList();
    if (getJoinedGroupListRes.code == 0) {
      List<String> temp = [];
      getJoinedGroupListRes.data?.forEach((element) {
        temp.add(element.groupID);
      });
      setState(() {
        groups = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimGroupMemberSearchParam param = V2TimGroupMemberSearchParam(
        groupIDList: [selectedGroup], // 指定群 ID 列表，若为 null 则搜索全部群中的群成员
        isSearchMemberNameCard: namecard, // 设置是否搜索群成员名片，默认为true
        isSearchMemberRemark: remark, // 设置是否搜索群成员备注，默认为true
        isSearchMemberNickName: nickName, // 设置是否搜索群成员昵称，默认为true
        isSearchMemberUserID: userID, // 设置是否搜索群成员 userID，默认为true
        keywordList: [_keywordController.text]);
    V2TimValueCallback<V2GroupMemberInfoSearchResult> searchGroupMembersRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .searchGroupMembers(param: param);
    setState(() {
      result = searchGroupMembersRes.toJson().toString();
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
        title: Text('SearchGroupMembers'),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownMenu<String>(
                width: 200,
                label: const Text('group id'),
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
            const SizedBox(
              height: 20,
            ),
            TextField(
              autofocus: true,
              controller: _keywordController,
              decoration: InputDecoration(
                  labelText: "keyword",
                  hintText: "keyword",
                  prefixIcon: Icon(Icons.person)),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('isSearchUserID'),
                Switch(
                  // This bool value toggles the switch.
                  value: userID,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      userID = value;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('isSearchNamecard'),
                Switch(
                  // This bool value toggles the switch.
                  value: namecard,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      namecard = value;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('isSearchNickName'),
                Switch(
                  // This bool value toggles the switch.
                  value: nickName,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      nickName = value;
                    });
                  },
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Text('isSearchRemark'),
                Switch(
                  // This bool value toggles the switch.
                  value: remark,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    // This is called when the user toggles the switch.
                    setState(() {
                      remark = value;
                    });
                  },
                )
              ],
            ),
            ElevatedButton(
              child: Text('SearchGroupMembers'),
              onPressed: () {
                pressedFunction();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(child: SingleChildScrollView(child: (Text(result))))
          ],
        ),
      ),
    ));
  }
}
