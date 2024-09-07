import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/addConversationListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/addConversationToGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/createConversationGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/deleteConversation.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/deleteConversationFromGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/deleteConversationGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getConversation.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getConversationGroupList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getConversationList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getConversationListByConversationIds.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getConversationListByFilter.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/getTotalUnreadMessageCount.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/markConversation.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/pinConversation.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/removeConversationListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/renameConversationGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/setConversationCustomData.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMConversationManager/setConversationDraft.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/addAdvancedMessageListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/clearC2CMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/clearGroupMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/getHistoryMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/removeAdvancedMessageListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/sendMessage.dart';

class V2TIMConversationManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2TIMConversationManagerState();
  }
}

class _V2TIMConversationManagerState
    extends State<V2TIMConversationManagerPage> {
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
              title: Text('V2TIMConversationManager 会话模块'),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                spacing: 10, // 子小部件之间的水平间距
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    child: Text('GetConversationList 获取会话列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetConversationList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetConversaiton 获取会话'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetConversation()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteConversation 删除会话'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteConversation()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetTotalUnreadMessageCount 获取会话未读总数'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetTotalUnreadMessageCount()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child:
                        Text('getConversationByConversationIds 通过会话ID获取指定会话列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GetConversationListByConversationIds()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getConversationListByFilter 获取会话列表的高级接口'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GetConversationListByFilter()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetConversationGroupList 获取会话分组列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetConversationGroupList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('AddConversationsToGroup 添加会话到一个会话分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddConversationsToGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('CreateConversationGroup 创建会话分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreateConversationGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteConversationGroup 删除会话分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteConversationGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteConversationFromGroup 从一个会话分组中删除会话'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DeleteConversationFromGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('MarkConversation 标记会话'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarkConversation()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('PinConversation 会话置顶'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PinConversation()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('RenameConversationGroup 重命名会话分组'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RenameConversationGroup()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetConversationCustomData 设置会话自定义消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetConversationCustomData()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetConversationDraft 设置会话草稿'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetConversationDraft()),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
