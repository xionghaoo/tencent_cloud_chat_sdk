import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_sdk_example/config.dart';

class GetJoinedCommunityList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GetJoinedCommunityListState();
  }
}

class _GetJoinedCommunityListState extends State<GetJoinedCommunityList> {
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
  }

  pressedFunction() async {
    V2TimValueCallback<List<V2TimGroupInfo>> getJoinedCommunityListRes =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getJoinedCommunityList();
            if(getJoinedCommunityListRes.data!=null){
              var data = getJoinedCommunityListRes.data!;
              for (var i = 0; i < data.length; i++) {
                if(data[i].customInfo!=null){
                  var keys = data[i].customInfo!.keys.toList();
                  print(keys);
                  for (var i = 0; i < keys.length; i++) {
                    print(keys[i]);
                    if(keys[i] == "feature_switch"){
                      try{
                        print(json.decode(data[i].customInfo![keys[i]] ?? ""));
                      }catch(err){
                        print(err);
                      }
                    }
                      
                    
                    print(data[i].customInfo![keys[i]]);
                  }
                }
              }
            }
    setState(() {
      result = getJoinedCommunityListRes.toJson().toString();
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
        title: Text('GetJoinedCommunityList'),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: Text('GetJoinedCommunityList'),
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
