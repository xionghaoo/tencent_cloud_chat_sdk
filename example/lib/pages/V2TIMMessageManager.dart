import 'package:flutter/material.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/addAdvancedMessageListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/appendMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/clearC2CMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/clearGroupMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/deleteMessageExtensions.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/deleteMessageFromLocalStorage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/deleteMessages.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/downloadMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/getGroupMessageReadMemberList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/getHistoryMessageList.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/getMessageOnlineUrl.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/getmessageReadReceipt.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/insertC2CMessageToLocalStorage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/insertGroupMessageToLocalStorage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/markAllMessageAsRead.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/markC2CMessageAsRead.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/markGroupMessageAsRead.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/modifyMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/reSendMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/removeAdvancedMessageListener.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/revokeMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/searchLocalMessages.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/sendMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/sendMessageReadReceipt.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/sendReplyMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/setC2CReceiveMessageOpt.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/setGroupReceiveMessageOpt.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/setLocalCustomData.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/setLocalCustomInt.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/setMessageExtensions.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMMessageManager/translateText.dart';

class V2TIMMessageManagerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _V2TIMMessageManagerState();
  }
}

class _V2TIMMessageManagerState extends State<V2TIMMessageManagerPage> {
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
              title: Text('V2TIMMessageManager 消息模块'),
            ),
            body: SingleChildScrollView(
              child: Wrap(
                spacing: 10, // 子小部件之间的水平间距
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    child: Text('send message 发送消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SendMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('GetHistoryMessageList 获取历史消息高级接口'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetHistoryMessageList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('clearC2CMessageList 清空单聊本地及云端的消息（不删除会话）'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClearC2CMessageList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('clearGroupMessageList 清空群聊本地及云端的消息（不删除会话）'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ClearGroupMessageList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteMessages	删除本地及漫游消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteMessages()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('appendMessage 附着另一条消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AppendMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('deleteMessageExtensions	删除消息扩展'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DeleteMessageExtensions()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('DeleteMessageFromLocalStorage	删除本地消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                DeleteMessageFromLocalStorage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('downloadMessage 下载多媒体消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DownloadMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child:
                        Text('getGroupMessageReadMemberList 获取群消息已读或未读群成员列表'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                GetGroupMessageReadMemberList()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getMessageOnlineUrl 获取多媒体消息URL'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetMessageOnlineUrl()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('getMessageReadReceipt 获取消息已读回执'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetMessageReadReceipt()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child:
                        Text('InsertC2CMessageToLocalStorage 向C2C消息列表中添加一条消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                InsertC2CMessageToLocalStorage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text(
                        'InsertGroupMessageToLocalStorage 向Group消息列表中添加一条消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                InsertGroupMessageToLocalStorage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('MarkAllMessageAsRead 标记所有消息为已读'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarkAllMessageAsRead()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('MarkC2CMessageAsRead 设置单聊消息已读'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarkC2CMessageAsRead()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('MarkGroupMessageAsRead 设置群聊消息已读'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MarkGroupMessageAsRead()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('ModifyMessage 消息编辑'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ModifyMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('reSendMessage 消息重发'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ResendMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('revokeMessage 撤回消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RevokeMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('searchLocalMessages 消息搜索参数'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchLocalMessages()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('sendMessageReadReceipt 发送消息已读回执'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendMessageReadReceipt()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('sendReplyMessage 发送回复消息'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SendReplyMessage()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetC2CReceiveMessageOpt 设置用户消息接收选项'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetC2CReceiveMessageOpt()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('SetGroupReceiveMessageOpt 设置群组消息接收选项'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetGroupReceiveMessageOpt()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setLocalCustomData 设置消息自定义数据'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetLocalCustomData()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setLocalCustomInt 设置消息自定义数据'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetLocalCustomInt()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('setMessageExtensions 设置消息扩展'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetMessageExtensions()),
                      );
                    },
                  ),
                  ElevatedButton(
                    child: Text('translateText 文本翻译'),
                    style: style,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TranslateText()),
                      );
                    },
                  ),
                ],
              ),
            )));
  }
}
