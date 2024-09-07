import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/acceptGroupApplication.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/createGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/createTopicInCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/deleteGroupAttributes.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/deleteTopicFromCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupApplicationList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupAttributes.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupMemberList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupMembersInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupOnlineMemberCount.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getGroupsInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getJoinedCommunityList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getJoinedGroupList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/getTopicInfoList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/initGroupAttributes.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/inviteUserToGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/kickGroupMember.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/muteGroupMember.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/refuseGroupApplication.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/searchGroupMembers.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/searchGroups.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setGroupApplicationRead.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setGroupAttributes.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setGroupInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setGroupMemberInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setGroupMemberRole.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/setTopicInfo.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMGroupManager/transferGroupOwner.dart';

class V2TIMGroupManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2TIMGroupManagerPageState();
  }
}

class _V2TIMGroupManagerPageState extends State<V2TIMGroupManagerPage> {
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
              title: Text('V2TIMGroupManager 群组模块'),
            ),
            body: SingleChildScrollView(
                child: Wrap(
                    spacing: 10, // 子小部件之间的水平间距
                    runSpacing: 10,
                    children: [
                  ElevatedButton(
                    child: Text('createGroup 创建群组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateGroup()),
                      );
                    },
                  ),
                  
                  ElevatedButton(
                    child: Text('getGroupAttributes 获取群成员列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupAttributes()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getGroupMemberList 获取群成员列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupMemberList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getJoinedGroupList 获取当前用户已经加入的群组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetJoinedGroupList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getJoinedCommunityList 获取当前用户已经加入的支持话题的社群列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetJoinedCommunityList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getGroupsInfo 	获取群资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupsInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getGroupMembersInfo 获取指定的群成员资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupMembersInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getGroupApplicationList 获取加群的申请列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupApplicationList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setGroupInfo 修改群资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetGroupInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('acceptGroupApplication 同意某一条加群申请'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AcceptGroupApplication()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('CreateTopicInCommunity 创建话题'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateTopicInCommunity()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteGroupAttributes 获取指定群属性'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteGroupAttributes()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteTopicFromCommunity 删除话题'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteTopicFromCommunity()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetGroupOnlineMemberCount 获取指定群在线人数'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetGroupOnlineMemberCount()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetTopicInfoList 获取话题属性的列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetTopicInfoList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('initGroupAttributes 初始化群属性'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InitGroupAttributes()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('inviteUserToGroup 邀请他人入群'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InviteUserToGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('kickGroupMember 踢人'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => KickGroupMember()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('muteGroupMember 禁言'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MuteGroupMember()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('RefuseGroupApplication 拒绝某一条加群申请'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RefuseGroupApplication()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('searchGroupMembers 搜索群成员'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchGroupMembers()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('searchGroups 搜索群'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchGroups()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetGroupApplicationRead 标记所有群组申请列表为已读'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetGroupApplicationRead()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetGroupAttributes 设置群属性'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetGroupAttributes()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetGroupMemberInfo 修改指定的群成员资料'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetGroupMemberInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetGroupMemberRole 设置群成员的角色'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetGroupMemberRole()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetTopicInfo 设置话题属性'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetTopicInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetTopicInfo 设置话题属性'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetTopicInfo()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('TransferGroupOwner 转让群主'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TransferGroupOwner()),
                      );
                    },
                  ),
                ]))));
  }
}
