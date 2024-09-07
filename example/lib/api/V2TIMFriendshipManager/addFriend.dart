import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class AddFriend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AddFriendState();
  }
}

class _AddFriendState extends State<AddFriend> {
  String result = '';

  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
  }

  pressedFunction() async {
    V2TimValueCallback<V2TimFriendOperationResult> addFriendRes =
        await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriend(
              userID: _statusController.text, //需要添加的用户id
              remark: "", //添加的好友的好友备注
              friendGroup: "", //添加好友所在分组
              addWording: "", //添加好友附带信息
              addSource: "", //添加来源描述
              addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH, //设置加好友类型，默认双向
            );
            var data = await TencentImSDKPlugin.v2TIMManager.getSignalingManager().invite(invitee: "121405",data: "");
            print(data.toJson());
            var data1 = await TencentImSDKPlugin.v2TIMManager.getSignalingManager().inviteInGroup(groupID: "121405",inviteeList: [],data: "");
            print(data1.toJson());
    setState(() {
      result = addFriendRes.toJson().toString();
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
        title: Text('AddFriend'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              autofocus: true,
              controller: _statusController,
              decoration: InputDecoration(
                  labelText: "user id",
                  hintText: "user id",
                  prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('AddFriend'),
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
