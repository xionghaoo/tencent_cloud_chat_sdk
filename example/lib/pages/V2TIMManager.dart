import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/addGroupListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/dismissGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getLoginStatus.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getLoginUser.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getServerTime.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getUserStatus.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getUsersInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/getVersion.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/initSDK.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/joinGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/login.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/logout.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/quitGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/removeGroupListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/setSelfInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/setSelfStatus.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/subscribeUserStatus.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMManager/unsubscribeUserStatus.dart';

class V2TIMManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2TIMManagerState();
  }
}

class _V2TIMManagerState extends State<V2TIMManagerPage> {
  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      textStyle: const TextStyle(fontSize: 20),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
    );
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back_ios),
              ),
              title: Text('V2TIMManager 基础模块'),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                spacing: 10, // 子小部件之间的水平间距
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    child: Text('getLoginStatus 获取登录状态'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetLoginStatus()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetLoginUser 获取登录用户的UserID'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetLoginUser()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getServerTime 获取服务器当前时间'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetServerTime()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetUserStatus 获取用户在线状态'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetUserStatus()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getUsersInfo 获取用户资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetUsersInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getVersion 获取版本号'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetVersion()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetSelfInfo 修改个人资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetSelfInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetSelfStatus 设置当前登录用户在线状态'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetSelfStatus()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('JoinGroup 加入群组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => JoinGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('QuitGroup 退出群组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => QuitGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DismissGroup 解散群组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DismissGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SubscribeUserStatus 订阅用户状态'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SubscribeUserStatus()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('UnsubscribeUserStatus 取消订阅用户状态'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UnsubscribeUserStatus()),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
