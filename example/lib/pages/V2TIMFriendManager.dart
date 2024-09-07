import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/acceptFriendApplication.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/addFriend.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/addFriendsToFriendGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/addToBlackList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/checkFriend.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/createFriendGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/deleteFriendApplication.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/deleteFriendGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/deleteFriendsFromFriendGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/deleteFromBlackList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/deleteFromFriendList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/getBlackList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/getFriendApplicationList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/getFriendGroups.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/getFriendList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/getFriendsInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/refuseFriendApplication.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/renameFriendGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/searchFriends.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/setFriendApplicationRead.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMFriendshipManager/setFriendInfo.dart';

class V2TIMFriendshipManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2TIMFriendshipManagerState();
  }
}

class _V2TIMFriendshipManagerState extends State<V2TIMFriendshipManagerPage> {
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
              title: Text('V2TIMFriendshipManager 好友模块'),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                spacing: 10, // 子小部件之间的水平间距
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    child: Text('getFriendList 获取好友列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetFriendList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getFriendsInfo 获取指定好友资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetFriendsInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getFriendApplicationList 获取好友申请列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetFriendApplicationList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('AcceptFriendApplication 同意好友申请'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AcceptFriendApplication()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteFriendApplication 删除好友申请'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteFriendApplication()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('RefuseFriendApplication 拒绝好友申请'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RefuseFriendApplication()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('AddFriend 添加好友'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddFriend()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetFriendGroups 获取好友分组列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetFriendGroups()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetBlackList 获取黑名单列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GetBlackList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('AddFriendsToFriendGroup 添加好友到一个好友分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddFriendsToFriendGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('AddToBlackList 添加用户到黑名单'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddToBlackList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteFromBlackList 把用户从黑名单中删除'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteFromBlackList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('CheckFriend 检查指定用户的好友关系'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CheckFriend()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('CreateFriendGroup 新建好友分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateFriendGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteFriendGroup 删除好友分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteFriendGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteFriendsFromFriendGroup 从好友分组中删除好友'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DeleteFriendsFromFriendGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteFromFriendList 删除好友'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteFromFriendList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('RenameFriendGroup 修改好友分组的名称'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RenameFriendGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('searchFriends 搜索好友'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchFriends()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setFriendApplicationRead 设置好友申请已读'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetFriendApplicationRead()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setFriendInfo 设置指定好友资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetFriendInfo()),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
