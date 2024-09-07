// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_application_type_enum.dart';
import 'package:tencent_cloud_chat_sdk/enum/friend_response_type_enum.dart';

import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class FriendApplication {
  String id;
  int type;
  FriendApplication({
    required this.id,
    required this.type,
  });
}

class RefuseFriendApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RefuseFriendApplicationState();
  }
}

class _RefuseFriendApplicationState extends State<RefuseFriendApplication> {
  String result = '';
  List<FriendApplication> applicationList = [];
  late FriendApplication selected;
  TextEditingController _statusController = TextEditingController();
  TextEditingController _messageController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    result = '';
    getApplicationList();
  }

  getApplicationList() async {
    V2TimValueCallback<V2TimFriendApplicationResult>
        getFriendApplicationListRes = await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (getFriendApplicationListRes.code == 0) {
      List<FriendApplication> temp = [];
      getFriendApplicationListRes.data?.friendApplicationList
          ?.forEach((element) {
        temp.add(FriendApplication(id: element!.userID, type: element.type));
      });
      setState(() {
        applicationList = temp;
      });
    }
  }

  pressedFunction() async {
    V2TimValueCallback<V2TimFriendOperationResult> refuseFriendApplicationRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .refuseFriendApplication(
                type: FriendApplicationTypeEnum.values[selected.type], //拒绝好友类型
                userID: "");
    setState(() {
      result = refuseFriendApplicationRes.toJson().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text('RefuseFriendApplication'),
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                DropdownMenu<FriendApplication>(
                    width: 200,
                    label: const Text('conversation'),
                    onSelected: (FriendApplication? id) {
                      selected = id ?? FriendApplication(id: '', type: 0);
                    },
                    requestFocusOnTap: true,
                    dropdownMenuEntries: applicationList
                        .map<DropdownMenuEntry<FriendApplication>>(
                            (FriendApplication id) {
                      return DropdownMenuEntry<FriendApplication>(
                        value: id,
                        label: id.id,
                      );
                    }).toList()),
              ],
            ),
            ElevatedButton(
              child: Text('RefuseFriendApplication'),
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
