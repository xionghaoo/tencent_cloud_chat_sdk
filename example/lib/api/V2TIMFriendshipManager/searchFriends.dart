import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class SearchFriends extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchFriendsState();
  }
}

class _SearchFriendsState extends State<SearchFriends> {
  String result = '';
  List<String> conversations = [];
  String selectedconv = '';
  bool userID = true;
  bool nickName = true;
  bool remark = true;
  TextEditingController _keywordController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    V2TimFriendSearchParam searchParam = V2TimFriendSearchParam(
      isSearchNickName: nickName, //是否搜索昵称
      isSearchRemark: remark, //是否搜索备注
      isSearchUserID: userID, //是否搜索id
      keywordList: [_keywordController.text], //关键字列表，最多支持5个。
    );
    V2TimValueCallback<List<V2TimFriendInfoResult>> searchFriendsRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .searchFriends(searchParam: searchParam);
    setState(() {
      result = searchFriendsRes.toJson().toString();
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
        title: Text('SearchFriends'),
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
              child: Text('SearchFriends'),
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
