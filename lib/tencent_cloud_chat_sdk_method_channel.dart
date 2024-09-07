import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimCommunityListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimFriendshipListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimGroupListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSignalingListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimUIKitListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/callbacks.dart';
import 'package:tencent_cloud_chat_sdk/enum/get_group_message_read_member_list_filter.dart';
import 'package:tencent_cloud_chat_sdk/enum/history_message_get_type.dart';
import 'package:tencent_cloud_chat_sdk/enum/offlinePushInfo.dart';
import 'package:tencent_cloud_chat_sdk/enum/v2_tim_plugins.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_create_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_follow_type_check_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_check_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_group.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_application_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_message_read_member_list.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_extension.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_extension_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_list_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_online_url.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_user_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_param.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_search_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_official_account_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_official_account_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_member_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_receive_message_opt_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_signaling_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_permission_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_status.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/utils/utils.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_download_progress.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_reaction_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_change_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/enum/listener_type.dart';
import 'tencent_cloud_chat_sdk_platform_interface.dart';

/// An implementation of [TencentCloudChatSdkPlatform] that uses method channels.
class MethodChannelTencentCloudChatSdk extends TencentCloudChatSdkPlatform {
  /// The method channel used to interact with the native platform.
  static const _channel = MethodChannel('tencent_cloud_chat_sdk');

  static final Map<String, V2TimSimpleMsgListener> simpleMessageListenerList = {};
  static final Map<String, V2TimSDKListener> initSDKListenerList = {};

  static final Map<String, V2TimGroupListener> groupListenerList = {};

  static final Map<String, V2TimConversationListener> conversationListenerList = {};

  static final Map<String, V2TimFriendshipListener> friendListenerList = {};

  static final Map<String, V2TimSignalingListener> signalingListenerList = {};
  static final Map<String, V2TimAdvancedMsgListener> advancedMsgListenerList = {};

  static final Map<String, V2TimCommunityListener> communityListenerList = {};

  static final Map<String, V2TimUIKitListener> uikitIKitListener = {};

  @override
  Future<String?> getPlatformVersion() async {
    final version = await _channel.invokeMethod<String>('getPlatformVersion', buildTimManagerParam({}));
    return version;
  }

  _catchListenerError(Function listener) {
    try {
      listener();
    } catch (err, errorStack) {
      debugPrint("$err $errorStack");
    }
  }

  @override
  void addNativeCallback() {
    _channel.setMethodCallHandler((call) async {
      try {
        if (call.method == ListenerType.simpleMsgListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          Map<String, dynamic> params = data['data'] == null ? formatJson({}) : formatJson(data["data"]);
          String type = data['type'];
          simpleMessageListenerList.forEach((key, value) {
            final msgID = params['msgID'];
            switch (type) {
              case 'onRecvC2CCustomMessage':
                // String msgID, V2TIMUserInfo sender, byte[] customData
                final sender = V2TimUserInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  value.onRecvC2CCustomMessage(
                    msgID,
                    sender,
                    params['customData'],
                  );
                });
                log(
                  "onRecvC2CCustomMessage",
                  {"key": key},
                  json.encode(
                    {
                      "sender": sender.toLogString(),
                      "msgID": msgID,
                      "customData": params['customData'],
                    },
                  ),
                );
                break;
              case 'onRecvC2CTextMessage':
                // String msgID, V2TIMUserInfo sender, String text
                final sender = V2TimUserInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  value.onRecvC2CTextMessage(
                    msgID,
                    sender,
                    params['text'],
                  );
                });
                log(
                  "onRecvC2CTextMessage",
                  {"key": key},
                  json.encode(
                    {
                      "sender": sender.toLogString(),
                      "msgID": msgID,
                      "text": params['text'],
                    },
                  ),
                );
                break;
              case 'onRecvGroupCustomMessage':
                // String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData
                final groupSender = V2TimGroupMemberInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  value.onRecvGroupCustomMessage(
                    msgID,
                    params['groupID'],
                    groupSender,
                    params['customData'],
                  );
                });
                log(
                  "onRecvGroupCustomMessage",
                  {"key": key},
                  json.encode(
                    {
                      "groupID": params['groupID'],
                      "msgID": msgID,
                      "groupSender": groupSender.toLogString(),
                      "customData": params['customData'],
                    },
                  ),
                );
                break;
              case 'onRecvGroupTextMessage':
                // String msgID, String groupID, V2TIMGroupMemberInfo sender, String text
                final groupSender = V2TimGroupMemberInfo.fromJson(params['sender']);
                _catchListenerError(() {
                  value.onRecvGroupTextMessage(
                    params['msgID'],
                    params['groupID'],
                    groupSender,
                    params['text'],
                  );
                });
                log(
                  "onRecvGroupTextMessage",
                  {"key": key},
                  json.encode(
                    {
                      "groupID": params['groupID'],
                      "msgID": params['msgID'],
                      "groupSender": groupSender.toLogString(),
                      "text": params['text'],
                    },
                  ),
                );
                break;
            }
          });
        } else if (call.method == ListenerType.initSDKListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          Map<String, dynamic> params = formatJson(data['data']);
          String type = data['type'];
          initSDKListenerList.forEach((key, value) {
            switch (type) {
              case 'onSelfInfoUpdated':
                final userInfo = V2TimUserFullInfo.fromJson(params);
                _catchListenerError(() {
                  value.onSelfInfoUpdated(userInfo);
                });
                log(
                  "onSelfInfoUpdated",
                  {"key": key},
                  json.encode(
                    {
                      "userInfo": userInfo.toLogString(),
                    },
                  ),
                );
                break;
              case 'onConnectFailed':
                _catchListenerError(() {
                  value.onConnectFailed(
                    params['code'],
                    params['desc'],
                  );
                });
                log(
                  "onConnectFailed",
                  {"key": key},
                  json.encode(
                    {
                      "code": params['code'],
                      "desc": params['desc'],
                    },
                  ),
                );
                break;
              case 'onConnecting':
                _catchListenerError(() {
                  value.onConnecting();
                });
                log(
                  "onConnecting",
                  {"key": key},
                  "",
                );
                break;
              case 'onConnectSuccess':
                _catchListenerError(() {
                  value.onConnectSuccess();
                });
                log(
                  "onConnectSuccess",
                  {"key": key},
                  "",
                );
                break;
              case 'onKickedOffline':
                _catchListenerError(() {
                  value.onKickedOffline();
                });
                log(
                  "onKickedOffline",
                  {"key": key},
                  "",
                );
                break;
              case 'onUserSigExpired':
                _catchListenerError(() {
                  value.onUserSigExpired();
                });
                log(
                  "onUserSigExpired",
                  {"key": key},
                  "",
                );
                break;
              case 'onUserStatusChanged':
                List<dynamic> statusList = params['statusList'];
                List<V2TimUserStatus> list = List.empty(growable: true);
                for (var element in statusList) {
                  list.add(V2TimUserStatus.fromJson(element));
                }
                _catchListenerError(() {
                  value.onUserStatusChanged(list);
                });
                log(
                  "onUserStatusChanged",
                  {"key": key},
                  json.encode(list.map((e) => e.toLogString()).toList()),
                );
                break;
              case 'onLog':
                int level = params['level'];
                String log = params['content'];
                _catchListenerError(() {
                  value.onLog(level, log);
                });
                break;
              case "onExperimentalNotify":
                String key = params["key"];
                dynamic param = params["param"];
                _catchListenerError(() {
                  value.onExperimentalNotify(key, param);
                });
                log(
                  "onExperimentalNotify",
                  {"key": key},
                  json.encode({"key": params["key"], "param": params["param"]}),
                );
                break;
              case "onUserInfoChanged":
                List<dynamic> userInfoList = params['userInfoList'];
                List<V2TimUserFullInfo> list = List.empty(growable: true);
                for (var element in userInfoList) {
                  list.add(V2TimUserFullInfo.fromJson(formatJson(element)));
                }
                _catchListenerError(() {
                  value.onUserInfoChanged(list);
                });
                log(
                  "onUserInfoChanged",
                  {"key": key},
                  json.encode(list.map((e) => e.toLogString()).toList()),
                );
                break;
              case "onAllReceiveMessageOptChanged":
                final receiveMessageOptInfo = V2TimReceiveMessageOptInfo.fromJson(params);
                _catchListenerError(() {
                  value.onAllReceiveMessageOptChanged(receiveMessageOptInfo);
                });
                log(
                  "onAllReceiveMessageOptChanged",
                  {"key": key},
                  receiveMessageOptInfo.toLogString(),
                );
                break;
            }
          });
        } else if (call.method == ListenerType.groupListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          String type = data['type'];
          Map<String, dynamic> params = data['data'] == null ? formatJson({}) : formatJson(data['data']);

          String groupID = params['groupID'] ?? '';
          String opReason = params['opReason'] ?? '';
          bool isAgreeJoin = params['isAgreeJoin'] ?? false;
          String customData = params['customData'] ?? '';
          String topicID = params["topicID"] ?? "";
          List<String> topicIDList = params["topicIDList"] == null ? List.empty(growable: true) : List.castFrom(params["topicIDList"]);
          V2TimTopicInfo topicInfo = params["topicInfo"] == null ? V2TimTopicInfo() : V2TimTopicInfo.fromJson(params['topicInfo']);
          Map<String, String> groupAttributeMap = params['groupAttributeMap'] == null ? Map<String, String>.from({}) : Map<String, String>.from(params['groupAttributeMap']);

          List<dynamic> memberListMap = params['memberList'] == null ? List.empty(growable: true) : List.from(params['memberList']);

          List<dynamic> groupMemberChangeInfoListMap = params['groupMemberChangeInfoList'] == null ? List.empty(growable: true) : List.from(params['groupMemberChangeInfoList']);

          List<dynamic> groupChangeInfoListMap = params['groupChangeInfoList'] == null ? List.empty(growable: true) : List.from(params['groupChangeInfoList']);
          List<V2TimGroupChangeInfo> groupChangeInfoList = List.empty(growable: true);
          List<V2TimGroupMemberChangeInfo> groupMemberChangeInfoList = List.empty(growable: true);
          List<V2TimGroupMemberInfo> memberList = List.empty(growable: true);

          if (memberListMap.isNotEmpty) {
            for (var element in memberListMap) {
              memberList.add(V2TimGroupMemberInfo.fromJson(element));
            }
          }
          if (groupMemberChangeInfoListMap.isNotEmpty) {
            for (var element in groupMemberChangeInfoListMap) {
              groupMemberChangeInfoList.add(V2TimGroupMemberChangeInfo.fromJson(element));
            }
          }
          if (groupChangeInfoListMap.isNotEmpty) {
            for (var element in groupChangeInfoListMap) {
              groupChangeInfoList.add(V2TimGroupChangeInfo.fromJson(element));
            }
          }
          late V2TimGroupMemberInfo opUser;
          late V2TimGroupMemberInfo member;
          if (params['opUser'] != null) {
            opUser = V2TimGroupMemberInfo.fromJson(params['opUser']);
          }
          if (params['member'] != null) {
            member = V2TimGroupMemberInfo.fromJson(params['member']);
          }
          groupListenerList.forEach((key, value) {
            switch (type) {
              case 'onMemberEnter':
                _catchListenerError(() {
                  value.onMemberEnter(
                    groupID,
                    memberList,
                  );
                });
                log(
                  "onMemberEnter",
                  {"key": key},
                  json.encode({"groupID": groupID, "memberList": memberList.map((e) => e.toLogString()).toList()}),
                );
                break;
              case 'onMemberLeave':
                _catchListenerError(() {
                  value.onMemberLeave(
                    groupID,
                    member,
                  );
                });
                log(
                  "onMemberLeave",
                  {"key": key},
                  json.encode({"groupID": groupID, "member": member.toLogString()}),
                );
                break;
              case 'onMemberInvited':
                _catchListenerError(() {
                  value.onMemberInvited(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                log(
                  "onMemberInvited",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "member": opUser.toLogString(),
                    "memberList": memberList.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case 'onMemberKicked':
                _catchListenerError(() {
                  value.onMemberKicked(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                log(
                  "onMemberKicked",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "member": opUser.toLogString(),
                    "memberList": memberList.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case 'onMemberInfoChanged':
                _catchListenerError(() {
                  value.onMemberInfoChanged(
                    groupID,
                    groupMemberChangeInfoList,
                  );
                });
                log(
                  "onMemberInfoChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "groupMemberChangeInfoList": groupMemberChangeInfoList.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case 'onGroupCreated':
                _catchListenerError(() {
                  value.onGroupCreated(groupID);
                });
                log(
                  "onGroupCreated",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onGroupDismissed':
                _catchListenerError(() {
                  value.onGroupDismissed(
                    groupID,
                    opUser,
                  );
                });
                log(
                  "onGroupDismissed",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "opUser": opUser.toLogString(),
                  }),
                );
                break;
              case 'onGroupRecycled':
                _catchListenerError(() {
                  value.onGroupRecycled(
                    groupID,
                    opUser,
                  );
                });
                log(
                  "onGroupRecycled",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "opUser": opUser.toLogString(),
                  }),
                );
                break;
              case 'onGroupInfoChanged':
                _catchListenerError(() {
                  value.onGroupInfoChanged(
                    groupID,
                    groupChangeInfoList,
                  );
                });
                log(
                  "onGroupInfoChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "groupChangeInfoList": groupChangeInfoList.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case 'onReceiveJoinApplication':
                _catchListenerError(() {
                  value.onReceiveJoinApplication(
                    groupID,
                    member,
                    opReason,
                  );
                });
                log(
                  "onGroupInfoChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "opReason": opReason,
                    "member": member.toLogString(),
                  }),
                );
                break;
              case 'onApplicationProcessed':
                _catchListenerError(() {
                  value.onApplicationProcessed(
                    groupID,
                    opUser,
                    isAgreeJoin,
                    opReason,
                  );
                });
                log(
                  "onApplicationProcessed",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "isAgreeJoin": isAgreeJoin,
                    "opReason": opReason,
                    "opUser": opUser.toLogString(),
                  }),
                );
                break;
              case 'onGrantAdministrator':
                _catchListenerError(() {
                  value.onGrantAdministrator(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                log(
                  "onGrantAdministrator",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "memberList": memberList.map((e) => e.toLogString()).toList(),
                    "opUser": opUser.toLogString(),
                  }),
                );
                break;
              case 'onRevokeAdministrator':
                _catchListenerError(() {
                  value.onRevokeAdministrator(
                    groupID,
                    opUser,
                    memberList,
                  );
                });
                log(
                  "onRevokeAdministrator",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "memberList": memberList.map((e) => e.toLogString()).toList(),
                    "opUser": opUser.toLogString(),
                  }),
                );
                break;
              case 'onQuitFromGroup':
                _catchListenerError(() {
                  value.onQuitFromGroup(groupID);
                });
                log(
                  "onQuitFromGroup",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onReceiveRESTCustomData':
                _catchListenerError(() {
                  value.onReceiveRESTCustomData(
                    groupID,
                    customData,
                  );
                });
                log(
                  "onReceiveRESTCustomData",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "customData": customData,
                  }),
                );
                break;
              case 'onGroupAttributeChanged':
                _catchListenerError(() {
                  value.onGroupAttributeChanged(
                    groupID,
                    groupAttributeMap,
                  );
                });
                log(
                  "onGroupAttributeChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "groupAttributeMap": groupAttributeMap,
                  }),
                );
                break;
              case "onTopicCreated":
                _catchListenerError(() {
                  value.onTopicCreated(
                    groupID,
                    topicID,
                  );
                });
                log(
                  "onTopicCreated",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "topicID": topicID,
                  }),
                );
                break;
              case "onTopicDeleted":
                _catchListenerError(() {
                  value.onTopicDeleted(
                    groupID,
                    topicIDList,
                  );
                });
                log(
                  "onTopicDeleted",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "topicIDList": topicIDList,
                  }),
                );
                break;
              case "onTopicInfoChanged":
                _catchListenerError(() {
                  value.onTopicInfoChanged(
                    groupID,
                    topicInfo,
                  );
                });
                log(
                  "onTopicInfoChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "topicInfo": topicInfo.toLogString(),
                  }),
                );
                break;
              case "onGroupCounterChanged":
                String key = params["key"] ?? "";
                int vv = params["value"] ?? 0;
                _catchListenerError(() {
                  value.onGroupCounterChanged(
                    groupID,
                    key,
                    vv,
                  );
                });
                log(
                  "onGroupCounterChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "key": key,
                    "vv": vv,
                  }),
                );
                break;
              case "onAllGroupMembersMuted":
                bool isMute = params["isMute"] ?? false;
                _catchListenerError(() {
                  value.onAllGroupMembersMuted(
                    groupID,
                    isMute,
                  );
                });
                log(
                  "onAllGroupMembersMuted",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "isMute": isMute,
                  }),
                );
                break;
              case "onMemberMarkChanged":
                bool enableMark = params["enableMark"] ?? false;
                List<String> memberIDList = List.from(params["memberIDList"] ?? []);
                int markType = params["markType"] ?? 0;

                _catchListenerError(() {
                  value.onMemberMarkChanged(
                    groupID,
                    memberIDList,
                    markType,
                    enableMark,
                  );
                });
                log(
                  "onMemberMarkChanged",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "memberIDList": memberIDList,
                    "markType": markType,
                    "enableMark": enableMark,
                  }),
                );
                break;
            }
          });
        } else if (call.method == ListenerType.advancedMsgListener) {
          Map<String, dynamic> data = formatJson(call.arguments);

          String type = data['type'];
          dynamic params = data['data'] ?? formatJson({});

          switch (type) {
            case 'onRecvNewMessage':
              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvNewMessage(V2TimMessage.fromJson(params));
                });
              });
              log(
                "onRecvNewMessage",
                {},
                json.encode({
                  "message": V2TimMessage.fromJson(params).toLogString(),
                }),
              );
              break;
            case 'onRecvMessageModified':
              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageModified(V2TimMessage.fromJson(params));
                });
              });
              log(
                "onRecvMessageModified",
                {},
                json.encode({
                  "message": V2TimMessage.fromJson(params).toLogString(),
                }),
              );
              break;
            case 'onRecvC2CReadReceipt':
              List<dynamic> dataList = params;
              List<V2TimMessageReceipt> receiptList = List.empty(growable: true);
              for (var element in dataList) {
                receiptList.add(V2TimMessageReceipt.fromJson(element));
              }

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvC2CReadReceipt(receiptList);
                });
              });
              log(
                "onRecvC2CReadReceipt",
                {},
                json.encode({
                  "receiptList": receiptList.map((e) => e.toLogString()).toList(),
                }),
              );
              break;
            case 'onRecvMessageRevoked':
              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageRevoked(params);
                });
              });
              log(
                "onRecvMessageRevoked",
                {},
                json.encode({
                  "params": params,
                }),
              );
              break;
            case 'onSendMessageProgress':
              final message = V2TimMessage.fromJson(params['message']);

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onSendMessageProgress(
                    message,
                    params['progress'],
                  );
                });
              });
              log(
                "onSendMessageProgress",
                {},
                json.encode({
                  "message": message.toLogString(),
                  "progress": params['progress'],
                }),
              );
              break;
            case 'onRecvMessageReadReceipts':
              List<dynamic> dataList = List<dynamic>.from(params);
              List<V2TimMessageReceipt> receiptList = List.empty(growable: true);
              for (var element in dataList) {
                receiptList.add(V2TimMessageReceipt.fromJson(element));
              }

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageReadReceipts(receiptList);
                });
              });
              log(
                "onRecvMessageReadReceipts",
                {},
                json.encode({
                  "receiptList": receiptList.map((e) => e.toLogString()).toList(),
                }),
              );
              break;
            case "onRecvMessageExtensionsChanged":
              Map<String, dynamic> cbdata = Map<String, Object>.from(params);
              String msgID = cbdata["msgID"] ?? "";
              List<dynamic> extensions = List.from(cbdata["extensions"] ?? []);
              List<V2TimMessageExtension> resList = List.empty(growable: true);
              for (var element in extensions) {
                var elem = formatJson(element);
                resList.add(V2TimMessageExtension(
                  extensionKey: elem["extensionKey"] ?? "",
                  extensionValue: elem["extensionValue"] ?? "",
                ));
              }

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageExtensionsChanged(
                    msgID,
                    resList,
                  );
                });
              });
              log(
                "onRecvMessageExtensionsChanged",
                {},
                json.encode({
                  "msgID": msgID,
                  "resList": resList.map((e) => e.toLogString()).toList(),
                }),
              );
              break;
            case "onRecvMessageExtensionsDeleted":
              Map<String, dynamic> cbdata = formatJson(params);
              String msgID = cbdata["msgID"] ?? "";
              List<String> extensionKeys = List<String>.from(cbdata["extensionKeys"] ?? []);

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageExtensionsDeleted(
                    msgID,
                    extensionKeys,
                  );
                });
              });
              log(
                "onRecvMessageExtensionsDeleted",
                {},
                json.encode({
                  "msgID": msgID,
                  "extensionKeys": extensionKeys,
                }),
              );
              break;
            case "onMessageDownloadProgressCallback":
              Map<String, dynamic> cbdata = formatJson(params);

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onMessageDownloadProgressCallback(
                    V2TimMessageDownloadProgress.fromJson(cbdata),
                  );
                });
              });
              log(
                "onMessageDownloadProgressCallback",
                {},
                json.encode({
                  "progress": V2TimMessageDownloadProgress.fromJson(cbdata).toLogString(),
                }),
              );
              break;
            case "onRecvMessageReactionsChanged":
              List<dynamic> changeInfosm = List<dynamic>.from(params["changeInfos"]);
              List<V2TIMMessageReactionChangeInfo> infos = List.empty(growable: true);
              changeInfosm.forEach(((element) {
                infos.add(V2TIMMessageReactionChangeInfo.fromJson(element));
              }));

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageReactionsChanged(infos);
                });
              });
              log(
                "onRecvMessageReactionsChanged",
                {},
                json.encode({
                  "infos": infos.map((e) => e.toLogString()).toList(),
                }),
              );
              break;
            case "onRecvMessageRevokedWithInfo":
              String msgID = params["msgID"];
              V2TimUserFullInfo operateUser = V2TimUserFullInfo.fromJson(params['operateUser'] ?? {});
              String reason = params["reason"];

              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onRecvMessageRevokedWithInfo(msgID, operateUser, reason);
                });
              });
              log(
                "onRecvMessageRevokedWithInfo",
                {},
                json.encode({
                  "msgID": msgID,
                  "operateUser": operateUser.toLogString(),
                  "reason": reason,
                }),
              );
              break;
            case "onGroupMessagePinned":
              String groupID = params["groupID"] ?? "";
              V2TimMessage message = V2TimMessage.fromJson(params['message'] ?? {});
              bool isPinned = params["isPinned"] ?? true;
              V2TimGroupMemberInfo opUser = V2TimGroupMemberInfo.fromJson(params['opUser'] ?? {});
              advancedMsgListenerList.forEach((key, listener) {
                _catchListenerError(() {
                  listener.onGroupMessagePinned(groupID, message, isPinned, opUser);
                });
              });
              log(
                "onGroupMessagePinned",
                {},
                json.encode({
                  "groupID": groupID,
                  "message": message.toLogString(),
                  "isPinned": isPinned,
                  "opUser": opUser.toLogString(),
                }),
              );
              break;
          }
        } else if (call.method == ListenerType.conversationListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          String type = data['type'];

          conversationListenerList.forEach((key, value) {
            switch (type) {
              case 'onSyncServerStart':
                _catchListenerError(() {
                  value.onSyncServerStart();
                });
                log(
                  "onSyncServerStart",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onSyncServerFinish':
                _catchListenerError(() {
                  value.onSyncServerFinish();
                });
                log(
                  "onSyncServerFinish",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onSyncServerFailed':
                _catchListenerError(() {
                  value.onSyncServerFailed();
                });
                log(
                  "onSyncServerFailed",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onNewConversation':
                List<dynamic> params = data['data'] == null ? List.empty(growable: true) : List.from(data['data']);
                List<V2TimConversation> conversationList = List.empty(growable: true);
                for (var element in params) {
                  conversationList.add(V2TimConversation.fromJson(element));
                }
                _catchListenerError(() {
                  value.onNewConversation(conversationList);
                });
                log(
                  "onNewConversation",
                  {"key": key},
                  json.encode({"conversationList": conversationList.map((e) => e.toLogString()).toList()}),
                );
                break;
              case 'onConversationChanged':
                List<dynamic> params = data['data'] == null ? List.empty(growable: true) : List<dynamic>.from(data['data']);
                List<V2TimConversation> conversationList = List.empty(growable: true);
                for (var element in params) {
                  conversationList.add(V2TimConversation.fromJson(element));
                }

                _catchListenerError(() {
                  value.onConversationChanged(conversationList);
                });
                log(
                  "onConversationChanged",
                  {"key": key},
                  json.encode({"conversationList": conversationList.map((e) => e.toLogString()).toList()}),
                );
                break;
              case 'onTotalUnreadMessageCountChanged':
                int params = data['data'] ?? 0;
                _catchListenerError(() {
                  value.onTotalUnreadMessageCountChanged(params);
                });
                log(
                  "onTotalUnreadMessageCountChanged",
                  {"key": key},
                  json.encode({"params": params}),
                );
                break;
              case "onConversationGroupCreated":
                Map<String, dynamic> param = formatJson(data["data"]);
                String groupName = param["groupName"];
                List<V2TimConversation> list = List.empty(growable: true);
                for (var v in List.from(param["conversationList"])) {
                  list.add(V2TimConversation.fromJson(v));
                }
                _catchListenerError(() {
                  value.onConversationGroupCreated(groupName, list);
                });
                log(
                  "onConversationGroupCreated",
                  {"key": key},
                  json.encode({"groupName": groupName, "list": list.map((e) => e.toLogString()).toList()}),
                );
                break;
              case "onConversationGroupDeleted":
                _catchListenerError(() {
                  value.onConversationGroupDeleted(data["data"]);
                });
                log(
                  "onConversationGroupDeleted",
                  {"key": key},
                  json.encode({
                    "data": data["data"],
                  }),
                );
                break;
              case "onConversationGroupNameChanged":
                Map<String, dynamic> param = formatJson(data["data"]);
                _catchListenerError(() {
                  value.onConversationGroupNameChanged(param["oldName"], param["newName"]);
                });
                log(
                  "onConversationGroupNameChanged",
                  {"key": key},
                  json.encode({
                    "oldName": data["oldName"],
                    "newName": data["newName"],
                  }),
                );
                break;
              case "onConversationsAddedToGroup":
                Map<String, dynamic> param = formatJson(data["data"]);
                String groupName = param["groupName"];
                List<V2TimConversation> list = List.empty(growable: true);
                for (var v in List.from(param["conversationList"])) {
                  list.add(V2TimConversation.fromJson(v));
                }
                _catchListenerError(() {
                  value.onConversationsAddedToGroup(groupName, list);
                });
                log(
                  "onConversationsAddedToGroup",
                  {"key": key},
                  json.encode({
                    "groupName": groupName,
                    "list": list.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case "onConversationsDeletedFromGroup":
                Map<String, dynamic> param = formatJson(data["data"]);
                String groupName = param["groupName"];
                List<V2TimConversation> list = List.empty(growable: true);
                for (var v in List.from(param["conversationList"])) {
                  list.add(V2TimConversation.fromJson(v));
                }
                _catchListenerError(() {
                  value.onConversationsDeletedFromGroup(groupName, list);
                });
                log(
                  "onConversationsDeletedFromGroup",
                  {"key": key},
                  json.encode({
                    "groupName": groupName,
                    "list": list.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case "onConversationDeleted":
                List<String> list = List<String>.from(data["data"] ?? []);
                _catchListenerError(() {
                  value.onConversationDeleted(list);
                });
                log(
                  "onConversationDeleted",
                  {"key": key},
                  json.encode({
                    "list": list,
                  }),
                );
                break;
              case "onUnreadMessageCountChangedByFilter":
                Map<String, dynamic> param = formatJson(data["data"]);
                V2TimConversationFilter filter = V2TimConversationFilter.fromJson(param["filter"] ?? {});
                int totalUnreadCount = param["totalUnreadCount"] ?? 0;
                _catchListenerError(() {
                  value.onUnreadMessageCountChangedByFilter(filter, totalUnreadCount);
                });
                log(
                  "onUnreadMessageCountChangedByFilter",
                  {"key": key},
                  json.encode({
                    "filter": filter.toLogString(),
                    "totalUnreadCount": totalUnreadCount,
                  }),
                );
                break;
            }
          });
        } else if (call.method == ListenerType.friendListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          String type = data['type'];
          dynamic params = data['data'] ?? formatJson({});
          friendListenerList.forEach((key, value) {
            switch (type) {
              case "onMutualFollowersListChanged":
                Map<String, dynamic> formatedData = formatJson(params);
                List<V2TimUserFullInfo> usersinfo = List.empty(growable: true);
                List<dynamic> usersinfomap = List<dynamic>.from(formatedData["userInfoList"] ?? []);
                for (int i = 0; i < usersinfomap.length; i++) {
                  usersinfo.add(V2TimUserFullInfo.fromJson(usersinfomap[i]));
                }
                bool isAdd = formatedData["isAdd"] ?? false;
                _catchListenerError(() {
                  value.onMutualFollowersListChanged(
                    usersinfo,
                    isAdd,
                  );
                });
                log(
                  "onMutualFollowersListChanged",
                  {"key": key},
                  json.encode({
                    "usersinfo": usersinfo.map((e) => e.toLogString()).toList(),
                    "isAdd": isAdd,
                  }),
                );
                break;
              case "onMyFollowersListChanged":
                Map<String, dynamic> formatedData = formatJson(params);
                List<V2TimUserFullInfo> usersinfo = List.empty(growable: true);
                List<dynamic> usersinfomap = List<dynamic>.from(formatedData["userInfoList"] ?? []);
                for (int i = 0; i < usersinfomap.length; i++) {
                  usersinfo.add(V2TimUserFullInfo.fromJson(usersinfomap[i]));
                }
                bool isAdd = formatedData["isAdd"] ?? false;
                _catchListenerError(() {
                  value.onMyFollowersListChanged(
                    usersinfo,
                    isAdd,
                  );
                });
                log(
                  "onMyFollowersListChanged",
                  {"key": key},
                  json.encode({
                    "usersinfo": usersinfo.map((e) => e.toLogString()).toList(),
                    "isAdd": isAdd,
                  }),
                );
                break;
              case "onMyFollowingListChanged":
                Map<String, dynamic> formatedData = formatJson(params);
                List<V2TimUserFullInfo> usersinfo = List.empty(growable: true);
                List<dynamic> usersinfomap = List<dynamic>.from(formatedData["userInfoList"] ?? []);
                for (int i = 0; i < usersinfomap.length; i++) {
                  usersinfo.add(V2TimUserFullInfo.fromJson(usersinfomap[i]));
                }
                bool isAdd = formatedData["isAdd"] ?? false;
                _catchListenerError(() {
                  value.onMyFollowingListChanged(
                    usersinfo,
                    isAdd,
                  );
                });
                log(
                  "onMyFollowingListChanged",
                  {"key": key},
                  json.encode({
                    "usersinfo": usersinfo.map((e) => e.toLogString()).toList(),
                    "isAdd": isAdd,
                  }),
                );
                break;
              case "onOfficialAccountDeleted":
                String officialAccountID = params;
                _catchListenerError(() {
                  value.onOfficialAccountDeleted(
                    officialAccountID,
                  );
                });
                log(
                  "onOfficialAccountDeleted",
                  {"key": key},
                  json.encode({
                    "officialAccountID": officialAccountID,
                  }),
                );
                break;
              case "onOfficialAccountInfoChanged":
                _catchListenerError(() {
                  value.onOfficialAccountInfoChanged(
                    V2TimOfficialAccountInfo.fromJson(params),
                  );
                });
                log(
                  "onOfficialAccountInfoChanged",
                  {"key": key},
                  json.encode({
                    "data": V2TimOfficialAccountInfo.fromJson(params).toLogString(),
                  }),
                );
                break;
              case "onOfficialAccountSubscribed":
                _catchListenerError(() {
                  value.onOfficialAccountSubscribed(
                    V2TimOfficialAccountInfo.fromJson(params),
                  );
                });
                log(
                  "onOfficialAccountSubscribed",
                  {"key": key},
                  json.encode({
                    "data": V2TimOfficialAccountInfo.fromJson(params).toLogString(),
                  }),
                );
                break;
              case "onOfficialAccountUnsubscribed":
                String officialAccountID = params;
                _catchListenerError(() {
                  value.onOfficialAccountUnsubscribed(
                    officialAccountID,
                  );
                });
                log(
                  "onOfficialAccountUnsubscribed",
                  {"key": key},
                  json.encode({
                    "officialAccountID": officialAccountID,
                  }),
                );
                break;

              case 'onFriendApplicationListAdded':
                List<dynamic> applicationListMap = params;
                List<V2TimFriendApplication> applicationList = List.empty(growable: true);
                for (var element in applicationListMap) {
                  applicationList.add(V2TimFriendApplication.fromJson(element));
                }
                _catchListenerError(() {
                  value.onFriendApplicationListAdded(applicationList);
                });
                log(
                  "onFriendApplicationListAdded",
                  {"key": key},
                  json.encode({
                    "applicationList": applicationList.map((e) => e.toLogString()).toList(),
                  }),
                );
                break;
              case 'onFriendApplicationListDeleted':
                List<String> userIDList = List.from(params);
                _catchListenerError(() {
                  value.onFriendApplicationListDeleted(userIDList);
                });
                log(
                  "onFriendApplicationListDeleted",
                  {"key": key},
                  json.encode({
                    "userIDList": userIDList,
                  }),
                );
                break;
              case 'onFriendApplicationListRead':
                _catchListenerError(() {
                  value.onFriendApplicationListRead();
                });
                log(
                  "onFriendApplicationListRead",
                  {"key": key},
                  json.encode({}),
                );
                break;
              case 'onFriendListAdded':
                List<dynamic> userMap = List<dynamic>.from(params);
                List<V2TimFriendInfo> users = List.empty(growable: true);
                for (var element in userMap) {
                  users.add(V2TimFriendInfo.fromJson(element));
                }
                _catchListenerError(() {
                  value.onFriendListAdded(users);
                });
                log(
                  "onFriendListAdded",
                  {"key": key},
                  json.encode({"users": users.map((e) => e.toLogString()).toList()}),
                );
                break;
              case 'onFriendListDeleted':
                List<String> userList = List.from(params);
                _catchListenerError(() {
                  value.onFriendListDeleted(userList);
                });
                log(
                  "onFriendListAdded",
                  {"key": key},
                  json.encode({"userList": userList}),
                );
                break;
              case 'onBlackListAdd':
                List<dynamic> infoListMap = List<dynamic>.from(params);
                List<V2TimFriendInfo> infoList = List.empty(growable: true);
                for (var element in infoListMap) {
                  infoList.add(V2TimFriendInfo.fromJson(element));
                }
                _catchListenerError(() {
                  value.onBlackListAdd(infoList);
                });
                log(
                  "onBlackListAdd",
                  {"key": key},
                  json.encode({"infoList": infoList.map((e) => e.toLogString()).toList()}),
                );
                break;
              case 'onBlackListDeleted':
                List<String> userList = List.from(params);
                _catchListenerError(() {
                  value.onBlackListDeleted(userList);
                });
                log(
                  "onBlackListDeleted",
                  {"key": key},
                  json.encode({
                    "userList": userList,
                  }),
                );
                break;
              case 'onFriendInfoChanged':
                List<dynamic> infoListMap = List<dynamic>.from(params);
                List<V2TimFriendInfo> infoList = List.empty(growable: true);
                for (var element in infoListMap) {
                  infoList.add(V2TimFriendInfo.fromJson(element));
                }
                _catchListenerError(() {
                  value.onFriendInfoChanged(infoList);
                });
                log(
                  "onFriendInfoChanged",
                  {"key": key},
                  json.encode({"infoList": infoList.map((e) => e.toLogString()).toList()}),
                );
                break;
            }
          });
        } else if (call.method == 'logFromSwift') {
        } else if (call.method == ListenerType.signalingListener) {
          Map<String, dynamic> d = formatJson(call.arguments);
          String type = d['type'];
          Map<String, dynamic> params = formatJson(d['data']);
          String inviteID = params['inviteID'] ?? '';
          String inviter = params['inviter'] ?? '';
          String groupID = params['groupID'] ?? '';
          List<String>? inviteeList = params['inviteeList'] == null ? null : List.from(params['inviteeList']);
          String data = params['data'] ?? '';
          String invitee = params['invitee'] ?? '';
          signalingListenerList.forEach((key, value) {
            switch (type) {
              case 'onReceiveNewInvitation':
                _catchListenerError(() {
                  value.onReceiveNewInvitation(inviteID, inviter, groupID, inviteeList ?? [], data);
                });
                log(
                  "onReceiveNewInvitation",
                  {"key": key},
                  json.encode({
                    "inviteID": inviteID,
                    "inviter": inviter,
                    "groupID": groupID,
                    "inviteeList": inviteeList ?? [],
                    "data": data,
                  }),
                );
                break;
              case 'onInviteeAccepted':
                _catchListenerError(() {
                  value.onInviteeAccepted(inviteID, invitee, data);
                });
                log(
                  "onInviteeAccepted",
                  {"key": key},
                  json.encode({
                    "inviteID": inviteID,
                    "invitee": invitee,
                    "data": data,
                  }),
                );
                break;
              case 'onInviteeRejected':
                _catchListenerError(() {
                  value.onInviteeRejected(inviteID, invitee, data);
                });
                log(
                  "onInviteeRejected",
                  {"key": key},
                  json.encode({
                    "inviteID": inviteID,
                    "invitee": invitee,
                    "data": data,
                  }),
                );
                break;
              case 'onInvitationCancelled':
                _catchListenerError(() {
                  value.onInvitationCancelled(inviteID, inviter, data);
                });
                log(
                  "onInvitationCancelled",
                  {"key": key},
                  json.encode({
                    "inviteID": inviteID,
                    "inviter": inviter,
                    "data": data,
                  }),
                );
                break;
              case 'onInvitationTimeout':
                _catchListenerError(() {
                  value.onInvitationTimeout(inviteID, inviteeList ?? []);
                });
                log(
                  "onInvitationTimeout",
                  {"key": key},
                  json.encode({
                    "inviteID": inviteID,
                    "inviteeList": inviteeList ?? [],
                  }),
                );
                break;
            }
          });
        } else if (call.method == ListenerType.communityListener) {
          Map<String, dynamic> data = formatJson(call.arguments);
          Map<String, dynamic> params = data['data'] == null ? formatJson({}) : formatJson(data["data"]);
          String type = data['type'];
          communityListenerList.forEach((key, value) {
            switch (type) {
              case "onCreateTopic":
                String groupID = params["groupID"] ?? "";
                String topicID = params["topicID"] ?? "";
                value.onCreateTopic(groupID, topicID);
                log(
                  "onCreateTopic",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "topicID": topicID,
                  }),
                );
                break;
              case "onDeleteTopic":
                String groupID = params["groupID"] ?? "";
                List<String> topicIDList = params["topicIDList"] == null ? [] : List<String>.from(params["topicIDList"]);
                value.onDeleteTopic(groupID, topicIDList);
                log(
                  "onDeleteTopic",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "topicIDList": topicIDList,
                  }),
                );
                break;
              case "onChangeTopicInfo":
                String groupID = params["groupID"] ?? "";

                value.onChangeTopicInfo(groupID, V2TimTopicInfo.fromJson(params["topicInfo"] ?? {}));
                log(
                  "onChangeTopicInfo",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "into": V2TimTopicInfo.fromJson(params["topicInfo"] ?? {}).toLogString(),
                  }),
                );
                break;
              case "onReceiveTopicRESTCustomData":
                String topicID = params["topicID"] ?? "";
                String customData = params["customData"] ?? "";
                value.onReceiveTopicRESTCustomData(topicID, customData);
                log(
                  "onReceiveTopicRESTCustomData",
                  {"key": key},
                  json.encode({
                    "topicID": topicID,
                    "customData": "customData",
                  }),
                );
                break;
              case "onCreatePermissionGroup":
                String groupID = params["groupID"] ?? "";
                value.onCreatePermissionGroup(
                  groupID,
                  V2TimPermissionGroupInfo.fromJson(params["permissionGroupInfo"] ?? {}),
                );
                log(
                  "onCreatePermissionGroup",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "info": V2TimPermissionGroupInfo.fromJson(params["permissionGroupInfo"] ?? {}).toLogString(),
                  }),
                );
                break;
              case "onDeletePermissionGroup":
                String groupID = params["groupID"] ?? "";
                List<String> permissionGroupIDList = params["permissionGroupIDList"] == null ? [] : List<String>.from(params["permissionGroupIDList"]);
                value.onDeletePermissionGroup(groupID, permissionGroupIDList);
                log(
                  "onDeletePermissionGroup",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupIDList": permissionGroupIDList,
                  }),
                );
                break;
              case "onChangePermissionGroupInfo":
                String groupID = params["groupID"] ?? "";
                value.onChangePermissionGroupInfo(groupID, V2TimPermissionGroupInfo.fromJson(params["permissionGroupInfo"] ?? {}));
                log(
                  "onChangePermissionGroupInfo",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupInfo": V2TimPermissionGroupInfo.fromJson(params["permissionGroupInfo"] ?? {}).toLogString(),
                  }),
                );
                break;
              case "onAddMembersToPermissionGroup":
                String groupID = params["groupID"] ?? "";
                String permissionGroupID = params["permissionGroupID"] ?? "";
                List<String> memberIDList = params["memberIDList"] == null ? [] : List<String>.from(params["memberIDList"]);
                value.onAddMembersToPermissionGroup(groupID, permissionGroupID, memberIDList);
                log(
                  "onAddMembersToPermissionGroup",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupID": permissionGroupID,
                    "memberIDList": memberIDList,
                  }),
                );
                break;
              case "onRemoveMembersFromPermissionGroup":
                String groupID = params["groupID"] ?? "";
                String permissionGroupID = params["permissionGroupID"] ?? "";
                List<String> memberIDList = params["memberIDList"] == null ? [] : List<String>.from(params["memberIDList"]);
                value.onRemoveMembersFromPermissionGroup(groupID, permissionGroupID, memberIDList);
                log(
                  "onRemoveMembersFromPermissionGroup",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupID": permissionGroupID,
                    "memberIDList": memberIDList,
                  }),
                );
                break;
              case "onAddTopicPermission":
                String groupID = params["groupID"] ?? "";
                String permissionGroupID = params["permissionGroupID"] ?? "";

                value.onAddTopicPermission(groupID, permissionGroupID, params["topicPermissionMap"] ?? {});
                log(
                  "onAddTopicPermission",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupID": permissionGroupID,
                    "topicPermissionMap": params["topicPermissionMap"] ?? {},
                  }),
                );
                break;
              case "onDeleteTopicPermission":
                String groupID = params["groupID"] ?? "";
                String permissionGroupID = params["permissionGroupID"] ?? "";
                List<String> topicIDList = params["topicIDList"] == null ? [] : List<String>.from(params["topicIDList"]);
                value.onDeleteTopicPermission(groupID, permissionGroupID, topicIDList);
                log(
                  "onDeleteTopicPermission",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupID": permissionGroupID,
                    "topicIDList": topicIDList,
                  }),
                );
                break;
              case "onModifyTopicPermission":
                String groupID = params["groupID"] ?? "";
                String permissionGroupID = params["permissionGroupID"] ?? "";

                value.onModifyTopicPermission(groupID, permissionGroupID, params["topicPermissionMap"] ?? {});
                log(
                  "onModifyTopicPermission",
                  {"key": key},
                  json.encode({
                    "groupID": groupID,
                    "permissionGroupID": permissionGroupID,
                  }),
                );
                break;
            }
          });
        }
      } catch (err) {
        debugPrint("重点关注，回调失败了，数据类型异常。$err ${call.method} ${call.arguments['type']} ${call.arguments['data']}");
      }
    });
  }

  @override
  Future<void> emitUIKitEvent(UIKitEvent event) async {
    initSDKListenerList.forEach((key, value) {
      value.onUIKitEventEmited(event);
    });
  }

  @override
  Future<void> emitPluginEvent(PluginEvent event) async {
    initSDKListenerList.forEach((key, value) {
      value.onPluginEventEmited(event);
    });
  }

  static bool needLog = true;
  @override
  Future<V2TimValueCallback<bool>> initSDK({
    required int sdkAppID,
    required int loglevel,
    required V2TimSDKListener listener,
    required int uiPlatform,
    bool? showImLog,
    List<V2TimPlugins>? plugins,
  }) async {
    final String uuid = Utils.generateUniqueString();
    initSDKListenerList[uuid] = listener;
    MethodChannelTencentCloudChatSdk.needLog = showImLog ?? true;
    String windowsDownloadPath = "";
    if (Platform.isWindows) {
      final Directory tempDir = await getApplicationDocumentsDirectory();
      String tp = tempDir.path;
      var imDirec = Directory("$tp\\TencentCloudChat\\");
      var imConfigDirec = Directory("$tp\\TencentCloudChat\\Config\\");
      var imLogDirec = Directory("$tp\\TencentCloudChat/Log\\");
      var imDownLoadDirec = Directory("$tp\\TencentCloudChat\\DownLoad\\");
      if (!imDirec.existsSync()) {
        imDirec.createSync(recursive: true);
      }
      if (!imConfigDirec.existsSync()) {
        imConfigDirec.createSync(recursive: true);
      }
      if (!imLogDirec.existsSync()) {
        imLogDirec.createSync(recursive: true);
      }
      if (!imDownLoadDirec.existsSync()) {
        imDownLoadDirec.createSync(recursive: true);
      }
      windowsDownloadPath = imDirec.path;
    }
    Map<String, dynamic> param = {
      "sdkAppID": sdkAppID,
      "logLevel": loglevel,
      "listenerUuid": uuid,
      "uiPlatform": uiPlatform,
      "showImLog": showImLog,
      "plugins": plugins?.map((e) => e.index.toString()).toList() ?? [],
      "tempPath": windowsDownloadPath,
    };
    var finalParam = buildTimManagerParam(param);
    Map returnData = await _channel.invokeMethod(
      'initSDK',
      finalParam,
    );
    var formatData = formatJson(returnData);
    var res = V2TimValueCallback<bool>.fromJson(formatData);
    log("initSDK", param, res.toLogString());
    return res;
  }

  log(
    String api,
    Map<dynamic, dynamic> param,
    String resp,
  ) {
    if (MethodChannelTencentCloudChatSdk.needLog) {
      Future.delayed(const Duration(seconds: 1), () {
        try {
          var logs = "【$api】${json.encode(param)}|$resp";
          uikitTrace(trace: logs);
        } catch (_) {}
      });
    }
  }

  @override
  Future<V2TimCallback> unInitSDK() async {
    initSDKListenerList.clear();
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'unInitSDK',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("unInitSDK", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() async {
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getVersion',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getVersion", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() async {
    var resp = V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getServerTime',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getServerTime", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "userSig": userSig,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'login',
          buildTimManagerParam(param),
        ),
      ),
    );
    log("login", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> logout() async {
    var reps = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'logout',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("logout", {}, reps.toLogString());
    return reps;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "text": text,
      "userID": userID,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendC2CTextMessage',
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("sendC2CTextMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "customData": customData,
      "userID": userID,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendC2CCustomMessage',
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );

    log("sendC2CCustomMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    Map<String, dynamic> param = {
      "text": text,
      "groupID": groupID,
      "priority": priority,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendGroupTextMessage",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("sendGroupTextMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    int priority = 0,
  }) async {
    Map<String, dynamic> param = {
      "customData": customData,
      "groupID": groupID,
      "priority": priority,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendGroupCustomMessage",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("sendGroupCustomMessage", param, resp.toLogString());
    return resp;
  }

  /// 获取登录用户
  ///
  @override
  Future<V2TimValueCallback<String>> getLoginUser() async {
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getLoginUser',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getLoginUser", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    var resp = V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getLoginStatus',
          buildTimManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getLoginStatus", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimUserFullInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getUsersInfo",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getUsersInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<V2TimGroupMember>? memberList,
    bool? isSupportTopic,
    int? approveOpt,
    bool? isEnablePermissionGroup,
    int? defaultPermissions,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "groupType": groupType,
      "groupName": groupName,
      "notification": notification,
      "introduction": introduction,
      "faceUrl": faceUrl,
      "isAllMuted": isAllMuted,
      "addOpt": addOpt,
      "memberList": memberList?.map((e) => e.toJson()).toList(),
      "isSupportTopic": isSupportTopic,
      "approveOpt": approveOpt,
      "isEnablePermissionGroup": isEnablePermissionGroup ?? false,
      "defaultPermissions": defaultPermissions ?? 0,
    };
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createGroup",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("createGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "message": message,
      "groupType": groupType,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "joinGroup",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("joinGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "quitGroup",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("quitGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "dismissGroup",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("dismissGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    Map<String, dynamic> param = {
      "nickName": userFullInfo.nickName,
      "faceUrl": userFullInfo.faceUrl,
      "selfSignature": userFullInfo.selfSignature,
      "birthday": userFullInfo.birthday,
      "gender": userFullInfo.gender,
      "allowType": userFullInfo.allowType,
      "customInfo": userFullInfo.customInfo,
      "level": userFullInfo.level,
      "role": userFullInfo.role,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setSelfInfo",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setSelfInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    Map<String, dynamic> p = {
      "api": api,
      "param": param,
    };
    var resp = V2TimValueCallback<Object>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "callExperimentalAPI",
          buildTimManagerParam(
            p,
          ),
        ),
      ),
    );
    log("callExperimentalAPI", p, resp.toLogString());
    return resp;
  }

  @override
  Future<String> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) async {
    final uuid = Utils.generateUniqueString();
    simpleMessageListenerList[uuid] = listener;
    await _channel.invokeMethod("addSimpleMsgListener", buildTimManagerParam({"listenerUuid": uuid}));
    return uuid;
  }

  @override
  Future<void> removeSimpleMsgListener({
    V2TimSimpleMsgListener? listener,
    String? uuid,
  }) async {
    if (uuid != null) {
      simpleMessageListenerList.remove(uuid);
      return _channel.invokeMethod(
        "removeSimpleMsgListener",
        buildTimManagerParam(
          {
            "listenerUuid": uuid,
          },
        ),
      );
    }
    if (listener == null && uuid == null) {
      simpleMessageListenerList.clear();
      return _channel.invokeMethod(
        "removeSimpleMsgListener",
        buildTimManagerParam(
          {
            "listenerUuid": "",
          },
        ),
      );
    }

    if (listener != null) {
      var listenerUuid = "";
      listenerUuid = simpleMessageListenerList.keys.firstWhere((k) => simpleMessageListenerList[k] == listener, orElse: () => "");
      if (listenerUuid.isNotEmpty) {
        simpleMessageListenerList.remove(listenerUuid);
        return _channel.invokeMethod(
          "removeSimpleMsgListener",
          buildTimManagerParam(
            {
              "listenerUuid": listenerUuid,
            },
          ),
        );
      } else {
        return;
      }
    }
  }

  @override
  Future setAPNSListener() {
    return _channel.invokeMethod("setAPNSListener", buildTimManagerParam({}));
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    Map<String, dynamic> param = {
      "nextSeq": nextSeq,
      "count": count,
    };
    var resp = V2TimValueCallback<V2TimConversationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getConversationList",
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getConversationList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<LinkedHashMap<dynamic, dynamic>> getConversationListWithoutFormat({
    required String nextSeq,
    required int count,
  }) async {
    return await _channel.invokeMethod(
      "getConversationList",
      buildConversationManagerParam(
        {
          "nextSeq": nextSeq,
          "count": count,
        },
      ),
    );
  }

  @override
  Future<void> removeConversationListener({
    V2TimConversationListener? listener,
  }) async {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = conversationListenerList.keys.firstWhere(
        (k) => conversationListenerList[k] == listener,
        orElse: () => "",
      );

      if (listenerUuid.isNotEmpty) {
        conversationListenerList.remove(listenerUuid);
      } else {
        return;
      }
    } else {
      conversationListenerList.clear();
    }
    return _channel.invokeMethod("removeConversationListener", buildConversationManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> removeFriendListener({
    V2TimFriendshipListener? listener,
  }) async {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = friendListenerList.keys.firstWhere(
        (k) => friendListenerList[k] == listener,
        orElse: () => "",
      );

      if (listenerUuid.isNotEmpty) {
        friendListenerList.remove(listenerUuid);
      } else {
        return;
      }
    } else {
      friendListenerList.clear();
    }
    return _channel.invokeMethod("removeFriendListener", buildFriendManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> removeGroupListener({
    V2TimGroupListener? listener,
  }) async {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = groupListenerList.keys.firstWhere(
        (k) => groupListenerList[k] == listener,
        orElse: () => "",
      );

      if (listenerUuid.isNotEmpty) {
        groupListenerList.remove(listenerUuid);
      } else {
        return;
      }
    } else {
      groupListenerList.clear();
    }
    return _channel.invokeMethod("removeGroupListener", buildTimManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<void> addConversationListener({
    required V2TimConversationListener listener,
  }) async {
    final String uuid = Utils.generateUniqueString();
    conversationListenerList[uuid] = listener;
    return await _channel.invokeMethod(
      "addConversationListener",
      buildConversationManagerParam(
        {
          "listenerUuid": uuid,
        },
      ),
    );
  }

  @override
  Future<void> addGroupListener({
    required V2TimGroupListener listener,
  }) async {
    final uuid = Utils.generateUniqueString();
    groupListenerList[uuid] = listener;
    await _channel.invokeMethod(
      "addGroupListener",
      buildTimManagerParam(
        {
          "listenerUuid": uuid,
        },
      ),
    );
  }

  @override
  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
  }) async {
    final String uuid = Utils.generateUniqueString();
    friendListenerList[uuid] = listener;
    return await _channel.invokeMethod(
      "addFriendListener",
      buildFriendManagerParam(
        {
          "listenerUuid": uuid,
        },
      ),
    );
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversation>>> getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversation>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getConversationListByConversaionIds",
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getConversationListByConversaionIds", param, resp.toLogString());
    return resp;
  }

  @override
  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  }) async {
    final String uuid = Utils.generateUniqueString();
    conversationListenerList[uuid] = listener;
    return _channel.invokeMethod("setConversationListener", buildConversationManagerParam({"listenerUuid": uuid}));
  }

  @override
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    Map<String, dynamic> param = {
      "conversationID": conversationID,
    };

    var resp = V2TimValueCallback<V2TimConversation>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getConversation',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getConversation", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    Map<String, dynamic> param = {
      "conversationID": conversationID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteConversation",
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteConversation", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText,
  }) async {
    Map<String, dynamic> param = {
      "conversationID": conversationID,
      "draftText": draftText,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setConversationDraft",
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setConversationDraft", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    Map<String, dynamic> param = {
      "conversationID": conversationID,
      "isPinned": isPinned,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "pinConversation",
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("pinConversation", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    var resp = V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getTotalUnreadMessageCount",
          buildConversationManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getTotalUnreadMessageCount", {}, resp.toLogString());
    return resp;
  }

  /* *****-好友关系模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */
  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    var resp = V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendList",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getFriendList", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<void> setFriendListener({
    required V2TimFriendshipListener listener,
  }) async {
    final String listenerUuid = Utils.generateUniqueString();
    friendListenerList[listenerUuid] = listener;
    return _channel.invokeMethod("setFriendListener", buildFriendManagerParam({"listenerUuid": listenerUuid}));
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendsInfo",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getFriendsInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "remark": remark,
      "friendGroup": friendGroup,
      "addWording": addWording,
      "addSource": addSource,
      "addType": addType,
    };
    var resp = V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriend",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addFriend", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "friendRemark": friendRemark,
      "friendCustomInfo": friendCustomInfo,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendInfo",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setFriendInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "deleteType": deleteType,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromFriendList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteFromFriendList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "checkType": checkType,
    };
    var resp = V2TimValueCallback<List<V2TimFriendCheckResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "checkFriend",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("checkFriend", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimFriendApplicationResult>> getFriendApplicationList() async {
    var resp = V2TimValueCallback<V2TimFriendApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendApplicationList",
          buildFriendManagerParam(
            {},
          ),
        ),
      ),
    );
    log("getFriendApplicationList", {}, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "responseType": responseType,
      "type": type,
      "userID": userID,
    };
    var resp = V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptFriendApplication",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("acceptFriendApplication", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "type": type,
      "userID": userID,
    };
    var resp = V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseFriendApplication",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("refuseFriendApplication", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "type": type,
      "userID": userID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendApplication",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteFriendApplication", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setFriendApplicationRead() async {
    Map<String, dynamic> param = {};
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendApplicationRead",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setFriendApplicationRead", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getBlackList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getBlackList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addToBlackList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addToBlackList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromBlackList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteFromBlackList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createFriendGroup",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("createFriendGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    Map<String, dynamic> param = {
      "groupNameList": groupNameList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendGroup>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendGroups",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getFriendGroups", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    Map<String, dynamic> param = {
      "groupNameList": groupNameList,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendGroup",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteFriendGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    Map<String, dynamic> param = {
      "oldName": oldName,
      "newName": newName,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "renameFriendGroup",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("renameFriendGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriendsToFriendGroup",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addFriendsToFriendGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendsFromFriendGroup",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteFriendsFromFriendGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    Map<String, dynamic> param = {
      "searchParam": searchParam.toJson(),
    };
    var resp = V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchFriends",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("searchFriends", param, resp.toLogString());
    return resp;
  }
  /* *****-群组模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getJoinedGroupList",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getJoinedGroupList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<void> setGroupListener({
    required V2TimGroupListener listener,
  }) async {
    final uuid = Utils.generateUniqueString();
    groupListenerList[uuid] = listener;
    return _channel.invokeMethod("setGroupListener", buildTimManagerParam({"listenerUuid": uuid}));
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupIDList": groupIDList,
    };
    var resp = V2TimValueCallback<List<V2TimGroupInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupsInfo",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupsInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    Map<String, dynamic> param = {
      "groupID": info.groupID,
      "groupType": info.groupType,
      "groupName": info.groupName,
      "notification": info.notification,
      "introduction": info.introduction,
      "faceUrl": info.faceUrl,
      "isAllMuted": info.isAllMuted,
      "addOpt": info.groupAddOpt,
      "customInfo": info.customInfo,
      "isSupportTopic": info.isSupportTopic,
      "approveOpt": info.approveOpt,
      "isEnablePermissionGroup": info.isEnablePermissionGroup ?? false,
      "defaultPermissions": info.defaultPermissions ?? 0,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupInfo",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "attributes": attributes,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupAttributes",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupAttributes", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "keys": keys,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteGroupAttributes",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteGroupAttributes", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "keys": keys ?? [],
    };
    var resp = V2TimValueCallback<Map<String, String>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupAttributes",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupAttributes", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupOnlineMemberCount",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupOnlineMemberCount", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "filter": filter,
      "nextSeq": nextSeq,
      "count": count,
      "offset": offset,
    };
    var resp = V2TimValueCallback<V2TimGroupMemberInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMemberList",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupMemberList", param, resp.toLogString());
    return resp;
  }

  @override

  ///获取指定的群成员资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>> getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "memberList": memberList,
    };
    var resp = V2TimValueCallback<List<V2TimGroupMemberFullInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMembersInfo",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupMembersInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "groupID": groupID,
      "nameCard": nameCard ?? "",
      "customInfo": customInfo,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberInfo",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupMemberInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "userID": userID,
      "seconds": seconds,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "muteGroupMember",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("muteGroupMember", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>> inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "userList": userList,
    };
    var resp = V2TimValueCallback<List<V2TimGroupMemberOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteUserToGroup",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("inviteUserToGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    int? duration,
    String? reason,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "memberList": memberList,
      "reason": reason,
      "duration": duration ?? 0,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "kickGroupMember",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("kickGroupMember", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "userID": userID,
      "role": role,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberRole",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupMemberRole", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "userID": userID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "transferGroupOwner",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("transferGroupOwner", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>> getGroupApplicationList() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<V2TimGroupApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupApplicationList",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupApplicationList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
    String? webMessageInstance,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "reason": reason, "fromUser": fromUser, "toUser": toUser, "addTime": addTime, "type": type, "webMessageInstance": webMessageInstance};
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptGroupApplication",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("acceptGroupApplication", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
    String? webMessageInstance,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "reason": reason, "fromUser": fromUser, "toUser": toUser, "addTime": addTime, "type": type, "webMessageInstance": webMessageInstance};
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseGroupApplication",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("refuseGroupApplication", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupApplicationRead() async {
    Map<String, dynamic> param = {};
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupApplicationRead",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupApplicationRead", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    Map<String, dynamic> param = {
      "searchParam": searchParam.toJson(),
    };
    var resp = V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchGroups",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("searchGroups", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    Map<String, dynamic> p = {
      "param": param.toJson(),
    };
    var resp = V2TimValueCallback<V2GroupMemberInfoSearchResult>.fromJson(
      formatJson(await _channel.invokeMethod(
        "searchGroupMembers",
        buildGroupManagerParam(
          p,
        ),
      )),
    );
    log("searchGroupMembers", p, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID};
    var resp = V2TimValueCallback<V2TimGroupInfo>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchGroupByID",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );

    log("searchGroupByID", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "attributes": attributes,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "initGroupAttributes",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("initGroupAttributes", param, resp.toLogString());
    return resp;
  }

  /* *****-消息模块-******** */
  /*
  *      ┌─┐       ┌─┐
  *   ┌──┘ ┴───────┘ ┴──┐
  *   │                 │
  *   │       ───       │
  *   │   >        <    │
  *   │                 │
  *   │   ...  ⌒  ...   │
  *   │                 │
  *   └───┐         ┌───┘
  *       │         │
  *       │         │
  *       │         │
  *       │         └──────────────┐
  *       │                        │
  *       │                        ├─┐
  *       │                        ┌─┘
  *       │                        │
  *       └─┐  ┐  ┌───────┬──┐  ┌──┘
  *         │ ─┤ ─┤       │ ─┤ ─┤
  *         └──┴──┘       └──┴──┘
  *                神兽保佑，不出bug
  *               只是为了区分不同模块
   */

  /// 创建文本消息
  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage({required String text}) async {
    Map<String, dynamic> param = {
      "text": text,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createTextMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createTextMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTargetedGroupMessage({required String id, required List<String> receiverList}) async {
    Map<String, dynamic> param = {"id": id, "receiverList": receiverList};
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createTargetedGroupMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createTargetedGroupMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({
    required String data,
    String desc = "",
    String extension = "",
  }) async {
    Map<String, dynamic> param = {
      "data": data,
      "desc": desc,
      "extension": extension,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createCustomMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createCustomMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage({required String imagePath, dynamic inputElement, String? imageName}) async {
    Map<String, dynamic> param = {"imagePath": imagePath};
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createImageMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createImageMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({
    required String soundPath,
    required int duration,
  }) async {
    Map<String, dynamic> param = {
      "soundPath": soundPath,
      "duration": duration,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createSoundMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createSoundMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({
    required String videoFilePath,
    required String type,
    required int duration,
    required String snapshotPath,
    dynamic inputElement,
  }) async {
    Map<String, dynamic> param = {
      "videoFilePath": videoFilePath,
      "type": type,
      "duration": duration,
      "snapshotPath": snapshotPath,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createVideoMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createVideoMessage", param, resp.toLogString());
    return resp;
  }

  ///发送消息
  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage({
    required String id,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    bool isExcludedFromLastMessage = false,
    bool? isSupportMessageExtension = false,
    bool? isExcludedFromContentModeration = false,
    bool needReadReceipt = false,
    Map<String, dynamic>? offlinePushInfo,
    // 自定义消息需要
    String? cloudCustomData, // 云自定义消息字段，只能在消息发送前添加
    String? localCustomData,
  }) async {
    Map<String, dynamic> param = {
      "id": id,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "isExcludedFromLastMessage": isExcludedFromLastMessage,
      "isSupportMessageExtension": isSupportMessageExtension,
      "isExcludedFromContentModeration": isExcludedFromContentModeration,
      "offlinePushInfo": offlinePushInfo,
      "cloudCustomData": cloudCustomData,
      "localCustomData": localCustomData,
      "needReadReceipt": needReadReceipt,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendMessage", param, resp.toLogString());
    return resp;
  }

  /// 发送文件消息
  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage({required String filePath, required String fileName, dynamic inputElement}) async {
    Map<String, dynamic> param = {
      "filePath": filePath,
      "fileName": fileName,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createFileMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createFileMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({
    required String text,
    required List<String> atUserList,
  }) async {
    Map<String, dynamic> param = {
      "text": text,
      "atUserList": atUserList,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createTextAtMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createTextAtMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
  }) async {
    Map<String, dynamic> param = {"desc": desc, "longitude": longitude, "latitude": latitude};
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createLocationMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createLocationMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({
    required int index,
    required String data,
  }) async {
    Map<String, dynamic> param = {"index": index, "data": data};
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createFaceMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createFaceMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage({
    required List<String> msgIDList,
    required String title,
    required List<String> abstractList,
    required String compatibleText,
    List<String>? webMessageInstanceList,
  }) async {
    Map<String, dynamic> param = {
      "msgIDList": msgIDList,
      "title": title,
      "abstractList": abstractList, // 截取前30个字符
      "compatibleText": compatibleText,
    };
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createMergerMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createMergerMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage({required String msgID, String? webMessageInstance}) async {
    Map<String, dynamic> param = {"msgID": msgID, "webMessageInstance": webMessageInstance};
    var resp = V2TimValueCallback<V2TimMsgCreateInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'createForwardMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createForwardMessage", param, resp.toLogString());
    return resp;
  }
  /*
              "receiver": receiver,
              "groupID": groupID,
              "priority": priority,
              "desc": desc,
              "extension": extension,
              "onlineUserOnly": onlineUserOnly,
              "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
              "offlinePushInfo": offlinePushInfo,
  */

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage({
    required String text,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "text": text,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendTextMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendTextMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage({
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    String desc = "",
    String extension = "",
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "data": data,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "desc": desc,
      "extension": extension,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendCustomMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendCustomMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendImageMessage(
      {required String imagePath,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? fileName,
      Uint8List? fileContent}) async {
    Map<String, dynamic> param = {
      "imagePath": imagePath,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileName": fileName,
      "fileContent": fileContent
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendImageMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendImageMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage({
    required String videoFilePath,
    required String receiver,
    required String type,
    required String snapshotPath,
    required int duration,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
    String? fileName,
    Uint8List? fileContent,
  }) async {
    Map<String, dynamic> param = {
      "videoFilePath": videoFilePath,
      "receiver": receiver,
      "snapshotPath": snapshotPath,
      "duration": duration,
      "type": type,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileName": fileName,
      "fileContent": fileContent
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendVideoMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendVideoMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFileMessage(
      {required String filePath,
      required String fileName,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      Uint8List? fileContent}) async {
    Map<String, dynamic> param = {
      "filePath": filePath,
      "fileName": fileName,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "fileContent": fileContent
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendFileMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendFileMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage({
    required String soundPath,
    required String receiver,
    required String groupID,
    required int duration,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "soundPath": soundPath,
      "receiver": receiver,
      "duration": duration,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "sendSoundMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendSoundMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage({
    required String text,
    required List<String> atUserList,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "text": text,
      "atUserList": atUserList,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendTextAtMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendTextAtMessage", param, resp.toLogString());
    return resp;
  }

  /// 发送地理位置消息
  ///
  @override
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage({
    required String desc,
    required double longitude,
    required double latitude,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "desc": desc,
      "longitude": longitude,
      "latitude": latitude,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendLocationMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendLocationMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage({
    required int index,
    required String data,
    required String receiver,
    required String groupID,
    int priority = 0,
    bool onlineUserOnly = false,
    bool isExcludedFromUnreadCount = false,
    Map<String, dynamic>? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "index": index,
      "data": data,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendFaceMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendFaceMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMergerMessage(
      {required List<String> msgIDList,
      required String title,
      required List<String> abstractList,
      required String compatibleText,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      List<String>? webMessageInstanceList}) async {
    Map<String, dynamic> param = {
      "msgIDList": msgIDList,
      "title": title,
      "abstractList": abstractList,
      "compatibleText": compatibleText,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "webMessageInstanceList": webMessageInstanceList
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendMergerMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendMergerMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setLocalCustomData({
    required String msgID,
    required String localCustomData,
  }) async {
    Map<String, dynamic> param = {
      "localCustomData": localCustomData,
      "msgID": msgID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomData",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setLocalCustomData", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setLocalCustomInt({
    required String msgID,
    required int localCustomInt,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "localCustomInt": localCustomInt,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setLocalCustomInt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setLocalCustomInt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setCloudCustomData({
    required String data,
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "data": data,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setCloudCustomData",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setCloudCustomData", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({
    required String userID,
    required int count,
    String? lastMsgID,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "count": count,
      "lastMsgID": lastMsgID,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CHistoryMessageList",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getC2CHistoryMessageList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    Map<String, dynamic> param = {
      "getType": getType,
      "userID": userID,
      "groupID": groupID,
      'lastMsgSeq': lastMsgSeq,
      "count": count,
      "lastMsgID": lastMsgID,
      "messageTypeList": messageTypeList ?? [],
      "messageSeqList": messageSeqList ?? [],
      "timeBegin": timeBegin,
      "timePeriod": timePeriod,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getHistoryMessageList",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getHistoryMessageList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageTypeList,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    Map<String, dynamic> param = {
      "getType": getType,
      "userID": userID,
      "groupID": groupID,
      'lastMsgSeq': lastMsgSeq,
      "count": count,
      "lastMsgID": lastMsgID,
      "messageTypeList": messageTypeList ?? [],
      "messageSeqList": messageSeqList ?? [],
      "timeBegin": timeBegin,
      "timePeriod": timePeriod,
    };
    var resp = V2TimValueCallback<V2TimMessageListResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getHistoryMessageListV2",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getHistoryMessageListV2", param, resp.toLogString());
    return resp;
  }

  @override
  Future<LinkedHashMap<dynamic, dynamic>> getHistoryMessageListWithoutFormat({
    int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
    String? userID,
    String? groupID,
    int lastMsgSeq = -1,
    required int count,
    String? lastMsgID,
    List<int>? messageSeqList,
    int? timeBegin,
    int? timePeriod,
  }) async {
    Map<String, dynamic> param = {
      "getType": getType,
      "userID": userID,
      "groupID": groupID,
      'lastMsgSeq': lastMsgSeq,
      "count": count,
      "lastMsgID": lastMsgID,
      "messageSeqList": messageSeqList,
      "timeBegin": timeBegin,
      "timePeriod": timePeriod,
    };
    var resp = await _channel.invokeMethod(
      "getHistoryMessageList",
      buildMessageMangerParam(
        param,
      ),
    );
    log("getHistoryMessageList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({
    required String groupID,
    required int count,
    String? lastMsgID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "count": count,
      "lastMsgID": lastMsgID,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupHistoryMessageList",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupHistoryMessageList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> revokeMessage({required String msgID, Object? webMessageInstatnce}) async {
    Map<String, dynamic> param = {"msgID": msgID, "webMessageInstatnce": webMessageInstatnce};
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "revokeMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("revokeMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markC2CMessageAsRead",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("markC2CMessageAsRead", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo,
      String? webMessageInstance}) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "receiver": receiver,
      "groupID": groupID,
      "priority": priority,
      "onlineUserOnly": onlineUserOnly,
      "isExcludedFromUnreadCount": isExcludedFromUnreadCount,
      "offlinePushInfo": offlinePushInfo,
      "webMessageInstance": webMessageInstance
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'sendForwardMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("sendForwardMessage", param, resp.toLogString());
    return resp;
  }

  /*
   注意：reSendMessage的onProgress不会返回id
  */
  @override
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage({required String msgID, bool onlineUserOnly = false, Object? webMessageInstatnce}) async {
    Map<String, dynamic> param = {"msgID": msgID, "onlineUserOnly": onlineUserOnly, "webMessageInstatnce": webMessageInstatnce};
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reSendMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("reSendMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({
    required List<String> userIDList,
    required int opt,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "opt": opt,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setC2CReceiveMessageOpt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setC2CReceiveMessageOpt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>> getC2CReceiveMessageOpt({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getC2CReceiveMessageOpt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getC2CReceiveMessageOpt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({
    required String groupID,
    required int opt,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "opt": opt,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupReceiveMessageOpt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupReceiveMessageOpt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markGroupMessageAsRead",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("markGroupMessageAsRead", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteMessageFromLocalStorage({
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessageFromLocalStorage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteMessageFromLocalStorage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteMessages({required List<String> msgIDs, List<dynamic>? webMessageInstanceList}) async {
    Map<String, dynamic> param = {
      "msgIDs": msgIDs,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessages",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteMessages", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({
    required String data,
    required String groupID,
    required String sender,
  }) async {
    Map<String, dynamic> param = {
      "data": data,
      "groupID": groupID,
      "sender": sender,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertGroupMessageToLocalStorage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("insertGroupMessageToLocalStorage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({
    required String data,
    required String userID,
    required String sender,
  }) async {
    Map<String, dynamic> param = {
      "data": data,
      "userID": userID,
      "sender": sender,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertC2CMessageToLocalStorage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("insertC2CMessageToLocalStorage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({
    required String userID,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "clearC2CHistoryMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("clearC2CHistoryMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "clearGroupHistoryMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("clearGroupHistoryMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    Map<String, dynamic> param = {
      "searchParam": searchParam.toJson(),
    };
    var resp = V2TimValueCallback<V2TimMessageSearchResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchLocalMessages",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("searchLocalMessages", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({
    required List<String> messageIDList,
  }) async {
    Map<String, dynamic> param = {
      "messageIDList": messageIDList,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "findMessages",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("findMessages", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> markAllMessageAsRead() async {
    Map<String, dynamic> param = {};
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod("markAllMessageAsRead", buildMessageMangerParam(param))));
    log("markAllMessageAsRead", param, resp.toLogString());
    return resp;
  }

  @override
  String addUIKitListener({
    required V2TimUIKitListener listener,
  }) {
    final String uuid = Utils.generateUniqueString();
    uikitIKitListener[uuid] = listener;
    return uuid;
  }

  @override
  void removeUIKitListener({
    String? uuid,
  }) {
    if (uuid == null) {
      uikitIKitListener.clear();
    } else {
      if (uikitIKitListener.containsKey(uuid)) {
        uikitIKitListener.remove(uuid);
      }
    }
  }

  @override
  void emitUIKitListener({
    required Map<String, dynamic> data,
  }) {
    uikitIKitListener.forEach((key, value) {
      value.onUiKitEventEmit(data);
    });
  }

  /// 添加高级消息的事件监听器
  ///
  @override
  Future<String> addAdvancedMsgListener({
    required V2TimAdvancedMsgListener listener,
  }) async {
    final String uuid = Utils.generateUniqueString();
    advancedMsgListenerList[uuid] = listener;
    await _channel.invokeMethod("addAdvancedMsgListener", buildMessageMangerParam({"listenerUuid": uuid}));
    return uuid;
  }

  @override

  /// 移除高级消息监听器
  ///
  Future<void> removeAdvancedMsgListener({
    V2TimAdvancedMsgListener? listener,
    String? uuid,
  }) async {
    return await Future.delayed(const Duration(seconds: 1), () async {
      if (uuid != null) {
        advancedMsgListenerList.remove(uuid);
        return await _channel.invokeMethod(
          "removeAdvancedMsgListener",
          buildMessageMangerParam(
            {
              "listenerUuid": uuid,
            },
          ),
        );
      }
      if (listener == null && uuid == null) {
        advancedMsgListenerList.clear();
        return await _channel.invokeMethod(
          "removeAdvancedMsgListener",
          buildMessageMangerParam(
            {
              "listenerUuid": "",
            },
          ),
        );
      }

      if (listener != null) {
        var listenerUuid = "";
        listenerUuid = advancedMsgListenerList.keys.firstWhere((k) => advancedMsgListenerList[k] == listener, orElse: () => "");
        if (listenerUuid.isNotEmpty) {
          advancedMsgListenerList.remove(listenerUuid);
          _channel.invokeMethod("removeAdvancedMsgListener", buildMessageMangerParam({"listenerUuid": listenerUuid}));
        } else {
          return;
        }
      } else {
        advancedMsgListenerList.clear();
        return await _channel.invokeMethod(
          "removeAdvancedMsgListener",
          buildMessageMangerParam(
            {
              "listenerUuid": "",
            },
          ),
        );
      }
    });
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    Map<String, dynamic> param = {
      "messageIDList": messageIDList,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      "sendMessageReadReceipts",
      buildMessageMangerParam(
        param,
      ),
    )));
    log("sendMessageReadReceipts", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({
    required List<String> messageIDList,
  }) async {
    Map<String, dynamic> param = {
      "messageIDList": messageIDList,
    };
    var resp = V2TimValueCallback<List<V2TimMessageReceipt>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMessageReadReceipts",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getMessageReadReceipts", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>> getGroupMessageReadMemberList({
    required String messageID,
    required GetGroupMessageReadMemberListFilter filter,
    int nextSeq = 0,
    int count = 100,
  }) async {
    Map<String, dynamic> param = {
      "messageID": messageID,
      "filter": filter.index,
      "nextSeq": nextSeq,
      "count": count,
    };
    var resp = V2TimValueCallback<V2TimGroupMessageReadMemberList>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMessageReadMemberList",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupMessageReadMemberList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedCommunityList() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(formatJson(await _channel.invokeMethod('getJoinedCommunityList', buildGroupManagerParam(param))));
    log("getJoinedCommunityList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "topicInfo": topicInfo.toJson()};
    var resp = V2TimValueCallback<String>.fromJson(formatJson(await _channel.invokeMethod('createTopicInCommunity', buildGroupManagerParam(param))));
    log("createTopicInCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "topicIDList": topicIDList};
    var resp = V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson(formatJson(await _channel.invokeMethod('deleteTopicFromCommunity', buildGroupManagerParam(param))));
    log("deleteTopicFromCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    Map<String, dynamic> param = {
      "topicInfo": topicInfo.toJson(),
      "groupID": groupID,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod('setTopicInfo', buildGroupManagerParam(param))));
    log("setTopicInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "topicIDList": topicIDList};
    var resp = V2TimValueCallback<List<V2TimTopicInfoResult>>.fromJson(formatJson(await _channel.invokeMethod('getTopicInfoList', buildGroupManagerParam(param))));
    log("getTopicInfoList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({
    required V2TimMessage message,
  }) async {
    Map<String, dynamic> param = {
      "message": message.toJson(),
    };
    var resp = V2TimValueCallback<V2TimMessageChangeInfo>.fromJson(formatJson(await _channel.invokeMethod('modifyMessage', buildMessageMangerParam(param))));
    log("modifyMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> appendMessage({
    required String createMessageBaseId,
    required String createMessageAppendId,
  }) async {
    Map<String, dynamic> param = {
      "createMessageBaseId": createMessageBaseId,
      "createMessageAppendId": createMessageAppendId,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(formatJson(await _channel.invokeMethod('appendMessage', buildMessageMangerParam(param))));
    log("appendMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> params = {
      "userIDList": userIDList,
    };
    var data = formatJson(
      await _channel.invokeMethod(
        'getUserStatus',
        buildTimManagerParam(
          params,
        ),
      ),
    );
    var resp = V2TimValueCallback<List<V2TimUserStatus>>.fromJson(
      data,
    );
    log("getUserStatus", params, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setSelfStatus({
    required String status,
  }) async {
    Map<String, dynamic> param = {
      "status": status,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod('setSelfStatus', buildTimManagerParam(param))));
    log("setSelfStatus", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> checkAbility() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<int>.fromJson(formatJson(await _channel.invokeMethod(
      'checkAbility',
      buildTimManagerParam(
        param,
      ),
    )));
    log("checkAbility", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> subscribeUserStatus({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'subscribeUserStatus',
      buildTimManagerParam(
        param,
      ),
    )));
    log("subscribeUserStatus", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> unsubscribeUserStatus({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'unsubscribeUserStatus',
      buildTimManagerParam(
        param,
      ),
    )));
    log("unsubscribeUserStatus", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "customData": customData,
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(formatJson(await _channel.invokeMethod(
      'setConversationCustomData',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("setConversationCustomData", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationListByFilter({
    required V2TimConversationFilter filter,
    required int nextSeq,
    required int count,
  }) async {
    Map<String, dynamic> param = {
      "filter": filter.toJson(),
      "nextSeq": nextSeq,
      "count": count,
    };
    var resp = V2TimValueCallback<V2TimConversationResult>.fromJson(formatJson(await _channel.invokeMethod(
      'getConversationListByFilter',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("getConversationListByFilter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "markType": markType,
      "enableMark": enableMark,
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(formatJson(await _channel.invokeMethod(
      'markConversation',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("markConversation", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(formatJson(await _channel.invokeMethod(
      'createConversationGroup',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("createConversationGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<List<String>>.fromJson(formatJson(await _channel.invokeMethod(
      'getConversationGroupList',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("getConversationGroupList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'deleteConversationGroup',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("deleteConversationGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    Map<String, dynamic> param = {
      "oldName": oldName,
      "newName": newName,
    };
    var resp = V2TimCallback.fromJson(formatJson(await _channel.invokeMethod(
      'renameConversationGroup',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("renameConversationGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'downloadMergerMessage',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("downloadMergerMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(formatJson(await _channel.invokeMethod(
      'addConversationsToGroup',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("addConversationsToGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> deleteConversationList({
    required List<String> conversationIDList,
    required bool clearMessage,
  }) async {
    Map<String, dynamic> param = {
      "conversationIDList": conversationIDList,
      "clearMessage": clearMessage,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'deleteConversationList',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteConversationList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> subscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    Map<String, dynamic> param = {
      "filter": filter.toJson(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'subscribeUnreadMessageCountByFilter',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("subscribeUnreadMessageCountByFilter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> unsubscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    Map<String, dynamic> param = {
      "filter": filter.toJson(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'unsubscribeUnreadMessageCountByFilter',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("unsubscribeUnreadMessageCountByFilter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> cleanConversationUnreadMessageCount({
    required String conversationID,
    required int cleanTimestamp,
    required int cleanSequence,
  }) async {
    Map<String, dynamic> param = {
      "conversationID": conversationID,
      "cleanTimestamp": cleanTimestamp,
      "cleanSequence": cleanSequence,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'cleanConversationUnreadMessageCount',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("cleanConversationUnreadMessageCount", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<int>> getUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    Map<String, dynamic> param = {
      "filter": filter.toJson(),
    };
    var resp = V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'getUnreadMessageCountByFilter',
          buildConversationManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getUnreadMessageCountByFilter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> convertVoiceToText({
    required String msgID,
    required String language, // "zh (cmn-Hans-CN)" "yue-Hant-HK" "en-US" "ja-JP"
    String? webMessageInstance,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "language": language,
    };
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          'convertVoiceToText',
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("convertVoiceToText", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupName": groupName,
      "conversationIDList": conversationIDList,
    };
    var resp = V2TimValueCallback<List<V2TimConversationOperationResult>>.fromJson(formatJson(await _channel.invokeMethod(
      'deleteConversationsFromGroup',
      buildConversationManagerParam(
        param,
      ),
    )));
    log("deleteConversationsFromGroup", param, resp.toLogString());
    return resp;
  }

  // 信令
  @override
  Future<void> addSignalingListener({
    required V2TimSignalingListener listener,
  }) async {
    final String listenerUuid = Utils.generateUniqueString();
    signalingListenerList[listenerUuid] = listener;
    return _channel.invokeMethod(
      "addSignalingListener",
      buildSignalingManagerParam(
        {
          "listenerUuid": listenerUuid,
        },
      ),
    );
  }

  @override
  Future<void> removeSignalingListener({
    V2TimSignalingListener? listener,
  }) async {
    var listenerUuid = "";
    if (listener != null) {
      listenerUuid = signalingListenerList.keys.firstWhere((k) => signalingListenerList[k] == listener, orElse: () => "");
      if (listenerUuid.isNotEmpty) {
        signalingListenerList.remove(listenerUuid);
      } else {
        return;
      }
    } else {
      signalingListenerList.clear();
    }
    return _channel.invokeMethod(
      "removeSignalingListener",
      buildSignalingManagerParam(
        {
          "listenerUuid": listenerUuid,
        },
      ),
    );
  }

  @override
  Future<V2TimValueCallback<String>> invite({
    required String invitee,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
    OfflinePushInfo? offlinePushInfo,
  }) async {
    Map<String, dynamic> param = {
      "invitee": invitee,
      "data": data,
      "timeout": timeout,
      "onlineUserOnly": onlineUserOnly,
      "offlinePushInfo": offlinePushInfo?.toJson(),
    };
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "invite",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("invite", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> inviteInGroup({
    required String groupID,
    required List<String> inviteeList,
    required String data,
    int timeout = 30,
    bool onlineUserOnly = false,
  }) async {
    Map<String, dynamic> param = {"groupID": groupID, "inviteeList": inviteeList, "data": data, "timeout": timeout, "onlineUserOnly": onlineUserOnly};
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteInGroup",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("inviteInGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> cancel({
    required String inviteID,
    String? data,
  }) async {
    Map<String, dynamic> param = {
      "inviteID": inviteID,
      "data": data,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "cancel",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("cancel", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> accept({
    required String inviteID,
    String? data,
  }) async {
    Map<String, dynamic> param = {
      "inviteID": inviteID,
      "data": data,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "accept",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("accept", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> reject({
    required String inviteID,
    String? data,
  }) async {
    Map<String, dynamic> param = {
      "inviteID": inviteID,
      "data": data,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "reject",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("reject", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimSignalingInfo>> getSignalingInfo({
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
    };
    var resp = V2TimValueCallback<V2TimSignalingInfo>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getSignalingInfo",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getSignalingInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> addInvitedSignaling({
    required V2TimSignalingInfo info,
  }) async {
    Map<String, dynamic> param = {
      "info": info.toJson(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addInvitedSignaling",
          buildSignalingManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addInvitedSignaling", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>> setMessageExtensions({
    required String msgID,
    required List<V2TimMessageExtension> extensions,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "extensions": extensions
          .map(
            (e) => Map.from(
              {
                "key": e.extensionKey,
                "value": e.extensionValue,
              },
            ),
          )
          .toList(),
    };
    var resp = V2TimValueCallback<List<V2TimMessageExtensionResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setMessageExtensions",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setMessageExtensions", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtension>>> getMessageExtensions({
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
    };
    var resp = V2TimValueCallback<List<V2TimMessageExtension>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMessageExtensions",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getMessageExtensions", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>> deleteMessageExtensions({
    required String msgID,
    required List<String> keys,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "keys": keys,
    };
    var resp = V2TimValueCallback<List<V2TimMessageExtensionResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteMessageExtensions",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteMessageExtensions", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageOnlineUrl>> getMessageOnlineUrl({
    required String msgID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
    };
    var resp = V2TimValueCallback<V2TimMessageOnlineUrl>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMessageOnlineUrl",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getMessageOnlineUrl", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> downloadMessage({
    required String msgID,
    required int messageType,
    required int imageType, // 图片类型，仅messageType为图片消息是有效
    required bool isSnapshot, // 是否是视频封面，仅messageType为视频消息是有效
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "messageType": messageType,
      "imageType": imageType,
      "isSnapshot": isSnapshot,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "downloadMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("downloadMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> setGroupCounters({
    required String groupID,
    required Map<String, int> counters,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "counters": counters,
    };
    var resp = V2TimValueCallback<Map<String, int>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupCounters",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("setGroupCounters", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> getGroupCounters({
    required String groupID,
    required List<String> keys,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "keys": keys,
    };
    var resp = V2TimValueCallback<Map<String, int>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupCounters",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getGroupCounters", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> increaseGroupCounter({
    required String groupID,
    required String key,
    required int value,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "key": key,
      "value": value,
    };
    var resp = V2TimValueCallback<Map<String, int>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "increaseGroupCounter",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("increaseGroupCounter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> decreaseGroupCounter({
    required String groupID,
    required String key,
    required int value,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "key": key,
      "value": value,
    };
    var resp = V2TimValueCallback<Map<String, int>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "decreaseGroupCounter",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("decreaseGroupCounter", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> translateText({
    required List<String> texts,
    required String targetLanguage,
    String? sourceLanguage,
  }) async {
    Map<String, dynamic> param = {
      "texts": texts,
      "targetLanguage": targetLanguage,
      "sourceLanguage": sourceLanguage ?? "auto",
    };
    var resp = V2TimValueCallback<Map<String, String>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "translateText",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("translateText", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<String>>> setAvChatRoomCanFindMessage({
    required List<String> avchatroomIDs,
    int eachGroupMessageNums = 20,
  }) async {
    Map<String, dynamic> param = {
      "avchatroomIDs": avchatroomIDs,
      "eachGroupMessageNums": eachGroupMessageNums,
    };
    var resp = V2TimValueCallback<List<String>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setAvChatRoomCanFindMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setAvChatRoomCanFindMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> subscribeUserInfo({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "subscribeUserInfo",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("subscribeUserInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> unsubscribeUserInfo({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "unsubscribeUserInfo",
          buildTimManagerParam(
            param,
          ),
        ),
      ),
    );
    log("unsubscribeUserInfo", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> markGroupMemberList({
    required String groupID,
    required List<String> memberIDList,
    required int markType,
    required bool enableMark,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "memberIDList": memberIDList,
      "markType": markType,
      "enableMark": enableMark,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "markGroupMemberList",
          buildGroupManagerParam(
            param,
          ),
        ),
      ),
    );
    log("markGroupMemberList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setAllReceiveMessageOpt({
    required int opt,
    required int startHour,
    required int startMinute,
    required int startSecond,
    required int duration,
  }) async {
    Map<String, dynamic> param = {
      "opt": opt,
      "startHour": startHour,
      "startMinute": startMinute,
      "startSecond": startSecond,
      "duration": duration,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setAllReceiveMessageOpt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setAllReceiveMessageOpt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setAllReceiveMessageOptWithTimestamp({
    required int opt,
    required int startTimeStamp,
    required int duration,
  }) async {
    Map<String, dynamic> param = {
      "opt": opt,
      "startTimeStamp": startTimeStamp,
      "duration": duration,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setAllReceiveMessageOptWithTimestamp",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("setAllReceiveMessageOptWithTimestamp", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimReceiveMessageOptInfo>> getAllReceiveMessageOpt() async {
    Map<String, dynamic> param = {};
    var resp = V2TimValueCallback<V2TimReceiveMessageOptInfo>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getAllReceiveMessageOpt",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getAllReceiveMessageOpt", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> addMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "reactionID": reactionID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addMessageReaction",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("addMessageReaction", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> removeMessageReaction({
    required String msgID,
    required String reactionID,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "reactionID": reactionID,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "removeMessageReaction",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("removeMessageReaction", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReactionResult>>> getMessageReactions({
    required List<String> msgIDList,
    required int maxUserCountPerReaction,
    List<String>? webMessageInstanceList,
  }) async {
    Map<String, dynamic> param = {
      "msgIDList": msgIDList,
      "maxUserCountPerReaction": maxUserCountPerReaction,
    };
    var resp = V2TimValueCallback<List<V2TimMessageReactionResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMessageReactions",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getMessageReactions", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessageReactionUserResult>> getAllUserListOfMessageReaction({
    required String msgID,
    required String reactionID,
    required int nextSeq,
    required int count,
    String? webMessageInstance,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "reactionID": reactionID,
      "nextSeq": nextSeq,
      "count": count,
    };
    var resp = V2TimValueCallback<V2TimMessageReactionUserResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getAllUserListOfMessageReaction",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getAllUserListOfMessageReaction", param, resp.toLogString());
    return resp;
  }

  @override
  Future<void> uikitTrace({
    required String trace,
  }) async {
    await _channel.invokeMethod(
      "uikitTrace",
      buildTimManagerParam(
        {
          "trace": trace,
        },
      ),
    );
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchCloudMessages({
    required V2TimMessageSearchParam searchParam,
  }) async {
    Map<String, dynamic> param = {
      "searchParam": searchParam.toJson(),
    };
    var resp = V2TimValueCallback<V2TimMessageSearchResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchCloudMessages",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("searchCloudMessages", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> setOfflinePushConfig({
    required double businessID,
    required String token,
    bool isTPNSToken = false,
    bool isVoip = false,
  }) async {
    Map<String, dynamic> param = {
      "ability": Utils.getAbility(),
      "businessID": businessID,
      "token": token,
      "isTPNSToken": isTPNSToken,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          Platform.isIOS ? (isVoip ? "setVOIP" : "setAPNS") : "setOfflinePushConfig",
          buildOfflinePushParam(
            param,
          ),
        ),
      ),
    );
    log(Platform.isIOS ? (isVoip ? "setVOIP" : "setAPNS") : "setOfflinePushConfig", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> doBackground({
    required int unreadCount,
  }) async {
    Map<String, dynamic> param = {
      "ability": Utils.getAbility(),
      "unreadCount": unreadCount,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doBackground",
          buildOfflinePushParam(
            param,
          ),
        ),
      ),
    );
    log("doBackground", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> doForeground() async {
    Map<String, dynamic> param = {
      "ability": Utils.getAbility(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "doForeground",
          buildOfflinePushParam(
            param,
          ),
        ),
      ),
    );
    log("doForeground", param, resp.toLogString());
    return resp;
  }

  /// 订阅公众号
  ///
  @override
  Future<V2TimCallback> subscribeOfficialAccount({
    required String officialAccountID,
  }) async {
    Map<String, dynamic> param = {
      "officialAccountID": officialAccountID,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "subscribeOfficialAccount",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("subscribeOfficialAccount", param, resp.toLogString());
    return resp;
  }

  /// 取消订阅公众号
  ///
  @override
  Future<V2TimCallback> unsubscribeOfficialAccount({
    required String officialAccountID,
  }) async {
    Map<String, dynamic> param = {
      "officialAccountID": officialAccountID,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "unsubscribeOfficialAccount",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("unsubscribeOfficialAccount", param, resp.toLogString());
    return resp;
  }

  /// 获取公众号列表
  ///
  @override
  Future<V2TimValueCallback<List<V2TimOfficialAccountInfoResult>>> getOfficialAccountsInfo({
    required List<String> officialAccountIDList,
  }) async {
    Map<String, dynamic> param = {
      "officialAccountIDList": officialAccountIDList,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<List<V2TimOfficialAccountInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getOfficialAccountsInfo",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getOfficialAccountsInfo", param, resp.toLogString());
    return resp;
  }

  /// 关注用户
  ///
  @override
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> followUser({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<List<V2TimFollowOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "followUser",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("followUser", param, resp.toLogString());
    return resp;
  }

  /// 取消关注用户
  ///
  @override
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> unfollowUser({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<List<V2TimFollowOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "unfollowUser",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("unfollowUser", param, resp.toLogString());
    return resp;
  }

  /// 获取我的关注列表
  ///
  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowingList({
    required String nextCursor,
  }) async {
    Map<String, dynamic> param = {
      "nextCursor": nextCursor,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<V2TimUserInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMyFollowingList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getMyFollowingList", param, resp.toLogString());
    return resp;
  }

  /// 获取关注我的列表
  ///
  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowersList({
    required String nextCursor,
  }) async {
    Map<String, dynamic> param = {
      "nextCursor": nextCursor,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<V2TimUserInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMyFollowersList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getMyFollowersList", param, resp.toLogString());
    return resp;
  }

  /// 获取我的互关列表
  ///
  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMutualFollowersList({
    required String nextCursor,
  }) async {
    Map<String, dynamic> param = {
      "nextCursor": nextCursor,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<V2TimUserInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getMutualFollowersList",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getMutualFollowersList", param, resp.toLogString());
    return resp;
  }

  /// 获取指定用户的 关注/粉丝/互关 数量信息
  ///
  @override
  Future<V2TimValueCallback<List<V2TimFollowInfo>>> getUserFollowInfo({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<List<V2TimFollowInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getUserFollowInfo",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getUserFollowInfo", param, resp.toLogString());
    return resp;
  }

  /// 检查指定用户的关注类型
  ///
  @override
  Future<V2TimValueCallback<List<V2TimFollowTypeCheckResult>>> checkFollowType({
    required List<String> userIDList,
  }) async {
    Map<String, dynamic> param = {
      "userIDList": userIDList,
      "ability": Utils.getAbility(),
    };
    var resp = V2TimValueCallback<List<V2TimFollowTypeCheckResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "checkFollowType",
          buildFriendManagerParam(
            param,
          ),
        ),
      ),
    );
    log("checkFollowType", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> pinGroupMessage({
    required String msgID,
    required String groupID,
    required bool isPinned,
  }) async {
    Map<String, dynamic> param = {
      "msgID": msgID,
      "groupID": groupID,
      "isPinned": isPinned,
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "pinGroupMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("pinGroupMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getPinnedGroupMessageList({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimValueCallback<List<V2TimMessage>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getPinnedGroupMessageList",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("getPinnedGroupMessageList", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorageV2({
    required String groupID,
    required String senderID,
    required String createdMsgID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "senderID": senderID,
      "createdMsgID": createdMsgID,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertGroupMessageToLocalStorageV2",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("insertGroupMessageToLocalStorageV2", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorageV2({
    required String userID,
    required String senderID,
    required String createdMsgID,
  }) async {
    Map<String, dynamic> param = {
      "userID": userID,
      "senderID": senderID,
      "createdMsgID": createdMsgID,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "insertC2CMessageToLocalStorageV2",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("insertC2CMessageToLocalStorageV2", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> createAtSignedGroupMessage({
    required String createdMsgID,
    required List<String> atUserList,
  }) async {
    Map<String, dynamic> param = {
      "atUserList": atUserList,
      "createdMsgID": createdMsgID,
    };
    var resp = V2TimValueCallback<V2TimMessage>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createAtSignedGroupMessage",
          buildMessageMangerParam(
            param,
          ),
        ),
      ),
    );
    log("createAtSignedGroupMessage", param, resp.toLogString());
    return resp;
  }

  @override
  Future<String> addCommunityListener({
    required V2TimCommunityListener listener,
  }) async {
    final String uuid = Utils.generateUniqueString();
    communityListenerList[uuid] = listener;
    await _channel.invokeMethod("addCommunityListener", buildCommunityManagerParam({"listenerUuid": uuid}));
    return uuid;
  }

  @override
  Future<bool> removeCommunityListener({
    String? listenerID,
  }) async {
    if (listenerID != null) {
      communityListenerList.remove(listenerID);
    } else {
      communityListenerList.clear();
    }
    return await _channel.invokeMethod(
      "removeCommunityListener",
      buildCommunityManagerParam(
        {
          "listenerID": listenerID,
        },
      ),
    );
  }

  @override
  Future<V2TimValueCallback<String>> createPermissionGroupInCommunity({
    required V2TimPermissionGroupInfo info,
  }) async {
    Map<String, dynamic> param = {
      "info": info.toJson(),
    };
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createPermissionGroupInCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("createPermissionGroupInCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupOperationResult>>> deletePermissionGroupFromCommunity({
    required String groupID,
    required List<String> permissionGroupIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupIDList": permissionGroupIDList,
    };
    var resp = V2TimValueCallback<List<V2TimPermissionGroupOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deletePermissionGroupFromCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deletePermissionGroupFromCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimCallback> modifyPermissionGroupInfoInCommunity({
    required V2TimPermissionGroupInfo info,
  }) async {
    Map<String, dynamic> param = {
      "info": info.toJson(),
    };
    var resp = V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "modifyPermissionGroupInfoInCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("modifyPermissionGroupInfoInCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>> getJoinedPermissionGroupListInCommunity({
    required String groupID,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
    };
    var resp = V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getJoinedPermissionGroupListInCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getJoinedPermissionGroupListInCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>> getPermissionGroupListInCommunity({
    required String groupID,
    required List<String> permissionGroupIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupIDList": permissionGroupIDList,
    };
    var resp = V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getPermissionGroupListInCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getPermissionGroupListInCommunity", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>> addCommunityMembersToPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> memberList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "memberList": memberList,
    };
    var resp = V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addCommunityMembersToPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addCommunityMembersToPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>> removeCommunityMembersFromPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> memberList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "memberList": memberList,
    };
    var resp = V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "removeCommunityMembersFromPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("removeCommunityMembersFromPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<V2TimPermissionGroupMemberInfoResult>> getCommunityMemberListInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required String nextCursor,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "nextCursor": nextCursor,
    };
    var resp = V2TimValueCallback<V2TimPermissionGroupMemberInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getCommunityMemberListInPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getCommunityMemberListInPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> addTopicPermissionToPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required Map<String, int> topicPermissionMap,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "topicPermissionMap": topicPermissionMap,
    };
    var resp = V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addTopicPermissionToPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("addTopicPermissionToPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> deleteTopicPermissionFromPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> topicIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "topicIDList": topicIDList,
    };
    var resp = V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteTopicPermissionFromPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("deleteTopicPermissionFromPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> modifyTopicPermissionInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required Map<String, int> topicPermissionMap,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "topicPermissionMap": topicPermissionMap,
    };
    var resp = V2TimValueCallback<List<V2TimTopicOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "modifyTopicPermissionInPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("modifyTopicPermissionInPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicPermissionResult>>> getTopicPermissionInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> topicIDList,
  }) async {
    Map<String, dynamic> param = {
      "groupID": groupID,
      "permissionGroupID": permissionGroupID,
      "topicIDList": topicIDList,
    };
    var resp = V2TimValueCallback<List<V2TimTopicPermissionResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getTopicPermissionInPermissionGroup",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("getTopicPermissionInPermissionGroup", param, resp.toLogString());
    return resp;
  }

  @override
  Future<V2TimValueCallback<String>> createCommunity({
    required V2TimGroupInfo info,
    required List<V2TimCreateGroupMemberInfo> memberList,
  }) async {
    Map<String, dynamic> param = {
      "info": info.toJson(),
      "memberList": memberList.map((e) => e.toJson()).toList(),
    };
    var resp = V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createCommunity",
          buildCommunityManagerParam(
            param,
          ),
        ),
      ),
    );
    log("createCommunity", param, resp.toLogString());
    return resp;
  }

  Map<String, dynamic> buildCommunityManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "communityManager";
    try {
      param["ability"] = Utils.getAbility();
      // String stacktrace = StackTrace.current.toString();
      // param["stacktrace"] = stacktrace;
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> buildGroupManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "groupManager";
    try {
      param["ability"] = Utils.getAbility();
      // String stacktrace = StackTrace.current.toString();
      // param["stacktrace"] = stacktrace;
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> buildSignalingManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "signalingManager";
    try {
      param["ability"] = Utils.getAbility();
      // String stacktrace = StackTrace.current.toString();
      // param["stacktrace"] = stacktrace;
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> buildFriendManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "friendshipManager";
    // String stacktrace = StackTrace.current.toString();
    // param["stacktrace"] = stacktrace;
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> buildOfflinePushParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "offlinePushManager";
    return param;
  }

  Map<String, dynamic> buildTimManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "timManager";

    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> buildMessageMangerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "messageManager";
    try {
      param["ability"] = Utils.getAbility();
      // String stacktrace = StackTrace.current.toString();
      // param["stacktrace"] = stacktrace;
    } catch (err) {
      // err
    }
    return param;
  }

  ///@nodoc

  Map<String, dynamic> buildConversationManagerParam(Map<String, dynamic> param) {
    param["TIMManagerName"] = "conversationManager";
    // String stacktrace = StackTrace.current.toString();
    // param["stacktrace"] = stacktrace;
    try {
      param["ability"] = Utils.getAbility();
    } catch (err) {
      // err
    }
    return param;
  }

  Map<String, dynamic> formatJson(Map? jsonSrc) {
    if (jsonSrc != null) {
      return Map<String, dynamic>.from(jsonSrc);
    }
    return Map<String, dynamic>.from({});
  }
}
