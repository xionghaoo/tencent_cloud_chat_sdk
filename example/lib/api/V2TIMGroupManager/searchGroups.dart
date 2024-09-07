import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SearchGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchGroupsState();
  }
}

class _SearchGroupsState extends State<SearchGroups> {
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
  }

  pressedFunction() async {
    V2TimGroupSearchParam param = V2TimGroupSearchParam(
        isSearchGroupID: userID, //设置是否搜索群 ID，默认为true
        isSearchGroupName: namecard, // 设置是否搜索群名称，默认为true
        keywordList: [_keywordController.text]);
    V2TimValueCallback<List<V2TimGroupInfo>> searchGroupsRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .searchGroups(searchParam: param);
    setState(() {
      result = searchGroupsRes.toJson().toString();
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
        title: Text('SearchGroups'),
      ),
      body: Center(
        child: Column(
          children: [
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
                Text('SearchGroupID'),
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
                Text('SearchName'),
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
            ElevatedButton(
              child: Text('SearchGroups'),
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
