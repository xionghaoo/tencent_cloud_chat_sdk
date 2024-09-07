import 'dart:collection';

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
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
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockTencentCloudChatSdkPlatform with MockPlatformInterfaceMixin implements TencentCloudChatSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<V2TimCallback> accept({required String inviteID, String? data}) {
    //  implement accept
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> acceptFriendApplication({required int responseType, required int type, required String userID}) {
    //  implement acceptFriendApplication
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> acceptGroupApplication({required String groupID, String? reason, required String fromUser, required String toUser, int? addTime, int? type, String? webMessageInstance}) {
    //  implement acceptGroupApplication
    throw UnimplementedError();
  }

  @override
  Future<String> addAdvancedMsgListener({required V2TimAdvancedMsgListener listener, String? listenerUuid}) {
    //  implement addAdvancedMsgListener
    throw UnimplementedError();
  }

  @override
  Future<void> addConversationListener({required V2TimConversationListener listener, String? listenerUuid}) {
    //  implement addConversationListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> addConversationsToGroup({required String groupName, required List<String> conversationIDList}) {
    //  implement addConversationsToGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({required String userID, String? remark, String? friendGroup, String? addWording, String? addSource, required int addType}) {
    //  implement addFriend
    throw UnimplementedError();
  }

  @override
  Future<void> addFriendListener({required V2TimFriendshipListener listener, String? listenerUuid}) {
    //  implement addFriendListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addFriendsToFriendGroup({required String groupName, required List<String> userIDList}) {
    //  implement addFriendsToFriendGroup
    throw UnimplementedError();
  }

  @override
  Future<void> addGroupListener({required V2TimGroupListener listener, String? listenerUuid}) {
    //  implement addGroupListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> addInvitedSignaling({required V2TimSignalingInfo info}) {
    //  implement addInvitedSignaling
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> addMessageReaction({required String msgID, required String reactionID}) {
    //  implement addMessageReaction
    throw UnimplementedError();
  }

  @override
  Future<void> addSignalingListener({String? listenerUuid, required V2TimSignalingListener listener}) {
    //  implement addSignalingListener
    throw UnimplementedError();
  }

  @override
  Future<String> addSimpleMsgListener({
    required V2TimSimpleMsgListener listener,
  }) {
    //  implement addSimpleMsgListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({required List<String> userIDList}) {
    //  implement addToBlackList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> appendMessage({required String createMessageBaseId, required String createMessageAppendId}) {
    //  implement appendMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({required String api, Object? param}) {
    //  implement callExperimentalAPI
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> cancel({required String inviteID, String? data}) {
    //  implement cancel
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> checkAbility() {
    //  implement checkAbility
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({required List<String> userIDList, required int checkType}) {
    //  implement checkFriend
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> cleanConversationUnreadMessageCount({required String conversationID, required int cleanTimestamp, required int cleanSequence}) {
    //  implement cleanConversationUnreadMessageCount
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> clearC2CHistoryMessage({required String userID}) {
    //  implement clearC2CHistoryMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> clearGroupHistoryMessage({required String groupID}) {
    //  implement clearGroupHistoryMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> convertVoiceToText({
    required String msgID,
    required String language,
    String? webMessageInstance,
  }) {
    //  implement convertVoiceToText
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> createConversationGroup({required String groupName, required List<String> conversationIDList}) {
    //  implement createConversationGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createCustomMessage({required String data, String desc = "", String extension = ""}) {
    //  implement createCustomMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFaceMessage({required int index, required String data}) {
    //  implement createFaceMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createFileMessage({required String filePath, required String fileName, inputElement}) {
    //  implement createFileMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createForwardMessage({required String msgID, String? webMessageInstance}) {
    //  implement createForwardMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> createFriendGroup({required String groupName, List<String>? userIDList}) {
    //  implement createFriendGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> createGroup(
      {String? groupID,
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
  }) {
    //  implement createGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createImageMessage({required String imagePath, inputElement, String? imageName}) {
    //  implement createImageMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createLocationMessage({required String desc, required double longitude, required double latitude}) {
    //  implement createLocationMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createMergerMessage({required List<String> msgIDList, required String title, required List<String> abstractList, required String compatibleText, List<String>? webMessageInstanceList}) {
    //  implement createMergerMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createSoundMessage({required String soundPath, required int duration}) {
    //  implement createSoundMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTargetedGroupMessage({required String id, required List<String> receiverList}) {
    //  implement createTargetedGroupMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextAtMessage({required String text, required List<String> atUserList}) {
    //  implement createTextAtMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createTextMessage({required String text}) {
    //  implement createTextMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> createTopicInCommunity({required String groupID, required V2TimTopicInfo topicInfo}) {
    //  implement createTopicInCommunity
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMsgCreateInfoResult>> createVideoMessage({required String videoFilePath, required String type, required int duration, required String snapshotPath, inputElement}) {
    //  implement createVideoMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> decreaseGroupCounter({required String groupID, required String key, required int value}) {
    //  implement decreaseGroupCounter
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteConversation({required String conversationID}) {
    //  implement deleteConversation
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteConversationGroup({required String groupName}) {
    //  implement deleteConversationGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> deleteConversationList({required List<String> conversationIDList, required bool clearMessage}) {
    //  implement deleteConversationList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> deleteConversationsFromGroup({required String groupName, required List<String> conversationIDList}) {
    //  implement deleteConversationsFromGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteFriendApplication({required int type, required String userID}) {
    //  implement deleteFriendApplication
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteFriendGroup({required List<String> groupNameList}) {
    //  implement deleteFriendGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFriendsFromFriendGroup({required String groupName, required List<String> userIDList}) {
    //  implement deleteFriendsFromFriendGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFromBlackList({required List<String> userIDList}) {
    //  implement deleteFromBlackList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> deleteFromFriendList({required List<String> userIDList, required int deleteType}) {
    //  implement deleteFromFriendList
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteGroupAttributes({required String groupID, required List<String> keys}) {
    //  implement deleteGroupAttributes
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>> deleteMessageExtensions({required String msgID, required List<String> keys}) {
    //  implement deleteMessageExtensions
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteMessageFromLocalStorage({required String msgID}) {
    //  implement deleteMessageFromLocalStorage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> deleteMessages({required List<String> msgIDs, List? webMessageInstanceList}) {
    //  implement deleteMessages
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> deleteTopicFromCommunity({required String groupID, required List<String> topicIDList}) {
    //  implement deleteTopicFromCommunity
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> dismissGroup({required String groupID}) {
    //  implement dismissGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> downloadMergerMessage({required String msgID}) {
    //  implement downloadMergerMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> downloadMessage({required String msgID, required int messageType, required int imageType, required bool isSnapshot}) {
    //  implement downloadMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> findMessages({required List<String> messageIDList}) {
    //  implement findMessages
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimReceiveMessageOptInfo>> getAllReceiveMessageOpt() {
    //  implement getAllReceiveMessageOpt
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageReactionUserResult>> getAllUserListOfMessageReaction({
    required String msgID,
    required String reactionID,
    required int nextSeq,
    required int count,
    String? webMessageInstance,
  }) {
    //  implement getAllUserListOfMessageReaction
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() {
    //  implement getBlackList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getC2CHistoryMessageList({required String userID, required int count, String? lastMsgID}) {
    //  implement getC2CHistoryMessageList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimReceiveMessageOptInfo>>> getC2CReceiveMessageOpt({required List<String> userIDList}) {
    //  implement getC2CReceiveMessageOpt
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimConversation>> getConversation({required String conversationID}) {
    //  implement getConversation
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<String>>> getConversationGroupList() {
    //  implement getConversationGroupList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({required String nextSeq, required int count}) {
    //  implement getConversationList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversation>>> getConversationListByConversaionIds({required List<String> conversationIDList}) {
    //  implement getConversationListByConversaionIds
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationListByFilter({required V2TimConversationFilter filter, required int nextSeq, required int count}) {
    //  implement getConversationListByFilter
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendApplicationResult>> getFriendApplicationList() {
    //  implement getFriendApplicationList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({List<String>? groupNameList}) {
    //  implement getFriendGroups
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() {
    //  implement getFriendList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({required List<String> userIDList}) {
    //  implement getFriendsInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>> getGroupApplicationList() {
    //  implement getGroupApplicationList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({required String groupID, List<String>? keys}) {
    //  implement getGroupAttributes
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> getGroupCounters({required String groupID, required List<String> keys}) {
    //  implement getGroupCounters
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getGroupHistoryMessageList({required String groupID, required int count, String? lastMsgID}) {
    //  implement getGroupHistoryMessageList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({required String groupID, required int filter, required String nextSeq, int count = 15, int offset = 0}) {
    //  implement getGroupMemberList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>> getGroupMembersInfo({required String groupID, required List<String> memberList}) {
    //  implement getGroupMembersInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMessageReadMemberList>> getGroupMessageReadMemberList({required String messageID, required GetGroupMessageReadMemberListFilter filter, int nextSeq = 0, int count = 100}) {
    //  implement getGroupMessageReadMemberList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({required String groupID}) {
    //  implement getGroupOnlineMemberCount
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({required List<String> groupIDList}) {
    //  implement getGroupsInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getHistoryMessageList(
      {int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
      String? userID,
      String? groupID,
      int lastMsgSeq = -1,
      required int count,
      String? lastMsgID,
      List<int>? messageTypeList,
      List<int>? messageSeqList,
      int? timeBegin,
      int? timePeriod}) {
    //  implement getHistoryMessageList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageListResult>> getHistoryMessageListV2(
      {int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG,
      String? userID,
      String? groupID,
      int lastMsgSeq = -1,
      required int count,
      String? lastMsgID,
      List<int>? messageTypeList,
      List<int>? messageSeqList,
      int? timeBegin,
      int? timePeriod}) {
    //  implement getHistoryMessageListV2
    throw UnimplementedError();
  }

  @override
  Future<LinkedHashMap> getHistoryMessageListWithoutFormat(
      {int getType = HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG, String? userID, String? groupID, int lastMsgSeq = -1, required int count, String? lastMsgID, List<int>? messageSeqList, int? timeBegin, int? timePeriod}) {
    //  implement getHistoryMessageListWithoutFormat
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedCommunityList() {
    //  implement getJoinedCommunityList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() {
    //  implement getJoinedGroupList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() {
    //  implement getLoginStatus
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> getLoginUser() {
    //  implement getLoginUser
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtension>>> getMessageExtensions({required String msgID}) {
    //  implement getMessageExtensions
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageOnlineUrl>> getMessageOnlineUrl({required String msgID}) {
    //  implement getMessageOnlineUrl
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReactionResult>>> getMessageReactions({
    required List<String> msgIDList,
    required int maxUserCountPerReaction,
    List<String>? webMessageInstanceList,
  }) {
    //  implement getMessageReactions
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageReceipt>>> getMessageReadReceipts({required List<String> messageIDList}) {
    //  implement getMessageReadReceipts
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() {
    //  implement getServerTime
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimSignalingInfo>> getSignalingInfo({required String msgID}) {
    //  implement getSignalingInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({required String groupID, required List<String> topicIDList}) {
    //  implement getTopicInfoList
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() {
    //  implement getTotalUnreadMessageCount
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<int>> getUnreadMessageCountByFilter({required V2TimConversationFilter filter}) {
    //  implement getUnreadMessageCountByFilter
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserStatus>>> getUserStatus({required List<String> userIDList}) {
    //  implement getUserStatus
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({required List<String> userIDList}) {
    //  implement getUsersInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() {
    //  implement getVersion
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> increaseGroupCounter({required String groupID, required String key, required int value}) {
    //  implement increaseGroupCounter
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> initGroupAttributes({required String groupID, required Map<String, String> attributes}) {
    //  implement initGroupAttributes
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<bool>> initSDK({required int sdkAppID, required int loglevel, String? listenerUuid, V2TimSDKListener? listener, required int uiPlatform, bool? showImLog, List<V2TimPlugins>? plugins}) {
    //  implement initSDK
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorage({required String data, required String userID, required String sender}) {
    //  implement insertC2CMessageToLocalStorage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorage({required String data, required String groupID, required String sender}) {
    //  implement insertGroupMessageToLocalStorage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> invite({required String invitee, required String data, int timeout = 30, bool onlineUserOnly = false, OfflinePushInfo? offlinePushInfo}) {
    //  implement invite
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> inviteInGroup({required String groupID, required List<String> inviteeList, required String data, int timeout = 30, bool onlineUserOnly = false}) {
    //  implement inviteInGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>> inviteUserToGroup({required String groupID, required List<String> userList}) {
    //  implement inviteUserToGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> joinGroup({required String groupID, required String message, String? groupType}) {
    //  implement joinGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> kickGroupMember({required String groupID, required List<String> memberList, int? duration, String? reason}) {
    //  implement kickGroupMember
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> login({required String userID, required String userSig}) {
    //  implement login
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> logout() {
    //  implement logout
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> markAllMessageAsRead() {
    //  implement markAllMessageAsRead
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> markC2CMessageAsRead({required String userID}) {
    //  implement markC2CMessageAsRead
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> markConversation({required int markType, required bool enableMark, required List<String> conversationIDList}) {
    //  implement markConversation
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> markGroupMemberList({required String groupID, required List<String> memberIDList, required int markType, required bool enableMark}) {
    //  implement markGroupMemberList
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> markGroupMessageAsRead({required String groupID}) {
    //  implement markGroupMessageAsRead
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageChangeInfo>> modifyMessage({required V2TimMessage message}) {
    //  implement modifyMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> muteGroupMember({required String groupID, required String userID, required int seconds}) {
    //  implement muteGroupMember
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> pinConversation({required String conversationID, required bool isPinned}) {
    //  implement pinConversation
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> quitGroup({required String groupID}) {
    //  implement quitGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> reSendMessage({required String msgID, bool onlineUserOnly = false, Object? webMessageInstatnce}) {
    //  implement reSendMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> refuseFriendApplication({required int type, required String userID}) {
    //  implement refuseFriendApplication
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> refuseGroupApplication({required String groupID, String? reason, required String fromUser, required String toUser, required int addTime, required int type, String? webMessageInstance}) {
    //  implement refuseGroupApplication
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> reject({required String inviteID, String? data}) {
    //  implement reject
    throw UnimplementedError();
  }

  @override
  Future<void> removeAdvancedMsgListener({String? uuid, V2TimAdvancedMsgListener? listener}) {
    //  implement removeAdvancedMsgListener
    throw UnimplementedError();
  }

  @override
  Future<void> removeConversationListener({
    V2TimConversationListener? listener,
  }) {
    //  implement removeConversationListener
    throw UnimplementedError();
  }

  @override
  Future<void> removeFriendListener({V2TimFriendshipListener? listener}) {
    //  implement removeFriendListener
    throw UnimplementedError();
  }

  @override
  Future<void> removeGroupListener({String? listenerUuid, V2TimGroupListener? listener}) {
    //  implement removeGroupListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> removeMessageReaction({required String msgID, required String reactionID}) {
    //  implement removeMessageReaction
    throw UnimplementedError();
  }

  @override
  Future<void> removeSignalingListener({V2TimSignalingListener? listener}) {
    //  implement removeSignalingListener
    throw UnimplementedError();
  }

  @override
  Future<void> removeSimpleMsgListener({
    V2TimSimpleMsgListener? listener,
    String? uuid,
  }) {
    //  implement removeSimpleMsgListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> renameConversationGroup({required String oldName, required String newName}) {
    //  implement renameConversationGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> renameFriendGroup({required String oldName, required String newName}) {
    //  implement renameFriendGroup
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> revokeMessage({required String msgID, Object? webMessageInstatnce}) {
    //  implement revokeMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchCloudMessages({required V2TimMessageSearchParam searchParam}) {
    //  implement searchCloudMessages
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> searchFriends({required V2TimFriendSearchParam searchParam}) {
    //  implement searchFriends
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimGroupInfo>> searchGroupByID({required String groupID}) {
    //  implement searchGroupByID
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({required V2TimGroupMemberSearchParam param}) {
    //  implement searchGroupMembers
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({required V2TimGroupSearchParam searchParam}) {
    //  implement searchGroups
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessageSearchResult>> searchLocalMessages({required V2TimMessageSearchParam searchParam}) {
    //  implement searchLocalMessages
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({required String customData, required String userID}) {
    //  implement sendC2CCustomMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({required String text, required String userID}) {
    //  implement sendC2CTextMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendCustomMessage(
      {required String data,
      required String receiver,
      required String groupID,
      int priority = 0,
      String desc = "",
      String extension = "",
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendCustomMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendFaceMessage(
      {required int index, required String data, required String receiver, required String groupID, int priority = 0, bool onlineUserOnly = false, bool isExcludedFromUnreadCount = false, Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendFaceMessage
    throw UnimplementedError();
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
      Uint8List? fileContent}) {
    //  implement sendFileMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendForwardMessage(
      {required String msgID, required String receiver, required String groupID, int priority = 0, bool onlineUserOnly = false, bool isExcludedFromUnreadCount = false, Map<String, dynamic>? offlinePushInfo, String? webMessageInstance}) {
    //  implement sendForwardMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({required String customData, required String groupID, int priority = 0}) {
    //  implement sendGroupCustomMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({required String text, required String groupID, int priority = 0}) {
    //  implement sendGroupTextMessage
    throw UnimplementedError();
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
      Uint8List? fileContent}) {
    //  implement sendImageMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendLocationMessage(
      {required String desc,
      required double longitude,
      required double latitude,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendLocationMessage
    throw UnimplementedError();
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
      List<String>? webMessageInstanceList}) {
    //  implement sendMergerMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendMessage(
      {required String id,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool needReadReceipt = false,
      bool isExcludedFromUnreadCount = false,
      bool isExcludedFromLastMessage = false,
      bool? isSupportMessageExtension = false,
      bool? isExcludedFromContentModeration = false,
      Map<String, dynamic>? offlinePushInfo,
      String? cloudCustomData,
      String? localCustomData}) {
    //  implement sendMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> sendMessageReadReceipts({required List<String> messageIDList}) {
    //  implement sendMessageReadReceipts
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendSoundMessage(
      {required String soundPath, required String receiver, required String groupID, required int duration, int priority = 0, bool onlineUserOnly = false, bool isExcludedFromUnreadCount = false, Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendSoundMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextAtMessage(
      {required String text,
      required List<String> atUserList,
      required String receiver,
      required String groupID,
      int priority = 0,
      bool onlineUserOnly = false,
      bool isExcludedFromUnreadCount = false,
      Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendTextAtMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendTextMessage(
      {required String text, required String receiver, required String groupID, int priority = 0, bool onlineUserOnly = false, bool isExcludedFromUnreadCount = false, Map<String, dynamic>? offlinePushInfo}) {
    //  implement sendTextMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendVideoMessage(
      {required String videoFilePath,
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
      Uint8List? fileContent}) {
    //  implement sendVideoMessage
    throw UnimplementedError();
  }

  @override
  Future setAPNSListener() {
    //  implement setAPNSListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setAllReceiveMessageOpt({required int opt, required int startHour, required int startMinute, required int startSecond, required int duration}) {
    //  implement setAllReceiveMessageOpt
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setAllReceiveMessageOptWithTimestamp({required int opt, required int startTimeStamp, required int duration}) {
    //  implement setAllReceiveMessageOptWithTimestamp
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<String>>> setAvChatRoomCanFindMessage({required List<String> avchatroomIDs, int eachGroupMessageNums = 20}) {
    //  implement setAvChatRoomCanFindMessage
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setC2CReceiveMessageOpt({required List<String> userIDList, required int opt}) {
    //  implement setC2CReceiveMessageOpt
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setCloudCustomData({required String data, required String msgID}) {
    //  implement setCloudCustomData
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>> setConversationCustomData({required String customData, required List<String> conversationIDList}) {
    //  implement setConversationCustomData
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setConversationDraft({required String conversationID, String? draftText}) {
    //  implement setConversationDraft
    throw UnimplementedError();
  }

  @override
  Future<void> setConversationListener({required V2TimConversationListener listener, String? listenerUuid}) {
    //  implement setConversationListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setFriendApplicationRead() {
    //  implement setFriendApplicationRead
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setFriendInfo({required String userID, String? friendRemark, Map<String, String>? friendCustomInfo}) {
    //  implement setFriendInfo
    throw UnimplementedError();
  }

  @override
  Future<void> setFriendListener({required V2TimFriendshipListener listener, String? listenerUuid}) {
    //  implement setFriendListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupApplicationRead() {
    //  implement setGroupApplicationRead
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupAttributes({required String groupID, required Map<String, String> attributes}) {
    //  implement setGroupAttributes
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, int>>> setGroupCounters({required String groupID, required Map<String, int> counters}) {
    //  implement setGroupCounters
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupInfo({required V2TimGroupInfo info}) {
    //  implement setGroupInfo
    throw UnimplementedError();
  }

  @override
  Future<void> setGroupListener({required V2TimGroupListener listener, String? listenerUuid}) {
    //  implement setGroupListener
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({required String groupID, required String userID, String? nameCard, Map<String, String>? customInfo}) {
    //  implement setGroupMemberInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({required String groupID, required String userID, required int role}) {
    //  implement setGroupMemberRole
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setGroupReceiveMessageOpt({required String groupID, required int opt}) {
    //  implement setGroupReceiveMessageOpt
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setLocalCustomData({required String msgID, required String localCustomData}) {
    //  implement setLocalCustomData
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setLocalCustomInt({required String msgID, required int localCustomInt}) {
    //  implement setLocalCustomInt
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessageExtensionResult>>> setMessageExtensions({required String msgID, required List<V2TimMessageExtension> extensions}) {
    //  implement setMessageExtensions
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setSelfInfo({required V2TimUserFullInfo userFullInfo}) {
    //  implement setSelfInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setSelfStatus({required String status}) {
    //  implement setSelfStatus
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setTopicInfo({required String groupID, required V2TimTopicInfo topicInfo}) {
    //  implement setTopicInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> subscribeUnreadMessageCountByFilter({required V2TimConversationFilter filter}) {
    //  implement subscribeUnreadMessageCountByFilter
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> subscribeUserInfo({required List<String> userIDList}) {
    //  implement subscribeUserInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> subscribeUserStatus({required List<String> userIDList}) {
    //  implement subscribeUserStatus
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> transferGroupOwner({required String groupID, required String userID}) {
    //  implement transferGroupOwner
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<Map<String, String>>> translateText({required List<String> texts, required String targetLanguage, String? sourceLanguage}) {
    //  implement translateText
    throw UnimplementedError();
  }

  @override
  Future<void> uikitTrace({required String trace}) {
    //  implement uikitTrace
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> unInitSDK() {
    //  implement unInitSDK
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> unsubscribeUnreadMessageCountByFilter({required V2TimConversationFilter filter}) {
    //  implement unsubscribeUnreadMessageCountByFilter
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> unsubscribeUserInfo({required List<String> userIDList}) {
    //  implement unsubscribeUserInfo
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> unsubscribeUserStatus({required List<String> userIDList}) {
    //  implement unsubscribeUserStatus
    throw UnimplementedError();
  }

  @override
  addNativeCallback() {
    throw UnimplementedError();
  }

  @override
  Future<void> emitPluginEvent(PluginEvent event) {
    throw UnimplementedError();
  }

  @override
  Future<void> emitUIKitEvent(UIKitEvent event) {
    throw UnimplementedError();
  }

  @override
  Future<LinkedHashMap> getConversationListWithoutFormat({required String nextSeq, required int count}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> doBackground({required int unreadCount}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> doForeground() {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> setOfflinePushConfig({required double businessID, required String token, bool isTPNSToken = false, bool isVoip = false}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFollowTypeCheckResult>>> checkFollowType({required List<String> userIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> followUser({required List<String> userIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMutualFollowersList({required String nextCursor}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowingList({required String nextCursor}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimOfficialAccountInfoResult>>> getOfficialAccountsInfo({required List<String> officialAccountIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFollowInfo>>> getUserFollowInfo({required List<String> userIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> subscribeOfficialAccount({required String officialAccountID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimFollowOperationResult>>> unfollowUser({required List<String> userIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> unsubscribeOfficialAccount({required String officialAccountID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimUserInfoResult>> getMyFollowersList({required String nextCursor}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimMessage>>> getPinnedGroupMessageList({required String groupID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> pinGroupMessage({required String msgID, required String groupID, required bool isPinned}) {
    throw UnimplementedError();
  }

  @override
  String addUIKitListener({
    required V2TimUIKitListener listener,
  }) {
    throw UnimplementedError();
  }

  @override
  void removeUIKitListener({String? uuid}) {
    throw UnimplementedError();
  }

  @override
  void emitUIKitListener({required Map<String, dynamic> data}) {
    throw UnimplementedError();
  }
  
  @override
  Future<V2TimValueCallback<V2TimMessage>> createAtSignedGroupMessage({required String createdMsgID, required List<String> atUserList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertC2CMessageToLocalStorageV2({required String userID, required String senderID, required String createdMsgID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> insertGroupMessageToLocalStorageV2({required String groupID, required String senderID, required String createdMsgID}) {
    throw UnimplementedError();
  }

  @override
  Future<String> addCommunityListener({required V2TimCommunityListener listener}) {
    throw UnimplementedError();
  }

  @override
  Future<bool> removeCommunityListener({String? listenerID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> createPermissionGroupInCommunity({required V2TimPermissionGroupInfo info}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupOperationResult>>> deletePermissionGroupFromCommunity({required String groupID, required List<String> permissionGroupIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimCallback> modifyPermissionGroupInfoInCommunity({required V2TimPermissionGroupInfo info}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>> addCommunityMembersToPermissionGroup({required String groupID, required String permissionGroupID, required List<String> memberList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> addTopicPermissionToPermissionGroup({required String groupID, required String permissionGroupID, required Map<String, int> topicPermissionMap}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> deleteTopicPermissionFromPermissionGroup({required String groupID, required String permissionGroupID, required List<String> topicIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<V2TimPermissionGroupMemberInfoResult>> getCommunityMemberListInPermissionGroup({required String groupID, required String permissionGroupID, required String nextCursor}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>> getJoinedPermissionGroupListInCommunity({required String groupID}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>> getPermissionGroupListInCommunity({required String groupID, required List<String> permissionGroupIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicPermissionResult>>> getTopicPermissionInPermissionGroup({required String groupID, required String permissionGroupID, required List<String> topicIDList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>> modifyTopicPermissionInPermissionGroup({required String groupID, required String permissionGroupID, required Map<String, int> topicPermissionMap}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>> removeCommunityMembersFromPermissionGroup({required String groupID, required String permissionGroupID, required List<String> memberList}) {
    throw UnimplementedError();
  }

  @override
  Future<V2TimValueCallback<String>> createCommunity({required V2TimGroupInfo info, required List<V2TimCreateGroupMemberInfo> memberList}) {
    throw UnimplementedError();
  }
}

void main() {
  final TencentCloudChatSdkPlatform initialPlatform = TencentCloudChatSdkPlatform.instance;

  test('$MethodChannelTencentCloudChatSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTencentCloudChatSdk>());
  });

  test('getPlatformVersion', () async {
    MockTencentCloudChatSdkPlatform fakePlatform = MockTencentCloudChatSdkPlatform();
    TencentCloudChatSdkPlatform.instance = fakePlatform;
  });
}
