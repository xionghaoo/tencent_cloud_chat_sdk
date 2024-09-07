import 'dart:collection';

import 'package:tencent_cloud_chat_sdk/enum/V2TimConversationListener.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_filter.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';

/// 会话接口，包含了会话的获取，删除和更新的逻辑
///
/// [setConversationListener] 设置会话监听器
///
/// [getConversationList] 获取会话列表
///
/// [deleteConversation] 获取指定会话
///
/// [setConversationDraft] 删除会话
///
/// {@category Manager}
///
class V2TIMConversationManager {
  Future<void> setConversationListener({
    required V2TimConversationListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .setConversationListener(listener: listener);
  }

  Future<void> addConversationListener({
    required V2TimConversationListener listener,
  }) {
    return TencentCloudChatSdkPlatform.instance
        .addConversationListener(listener: listener);
  }

  Future<void> removeConversationListener(
      {V2TimConversationListener? listener}) {
    return TencentCloudChatSdkPlatform.instance.removeConversationListener(
      listener: listener,
    );
  }

  ///   获取会话列表
  /// ```
  ///   一个会话对应一个聊天窗口，比如跟一个好友的 1v1 聊天，或者一个聊天群，都是一个会话。
  ///   由于历史的会话数量可能很多，所以该接口希望您采用分页查询的方式进行调用。
  ///   该接口拉取的是本地缓存的会话，如果服务器会话有更新，SDK 内部会自动同步，然后在 V2TIMConversationListener 回调告知客户。
  ///   该接口获取的会话列表默认已经按照会话 lastMessage -> timestamp 做了排序，timestamp 越大，会话越靠前。
  ///   如果会话全部拉取完毕，成功回调里面 V2TIMConversationResult 中的 isFinished 获取字段值为 true。
  ///   最多能拉取到最近的5000个会话。
  /// ```
  /// 参数
  ///
  ///```
  /// nextSeq	分页拉取的游标，第一次默认取传 0，后续分页拉传上一次分页拉取成功回调里的 nextSeq
  /// count	分页拉取的个数，一次分页拉取不宜太多，会影响拉取的速度，建议每次拉取 100 个会话
  /// ```
  ///
  Future<V2TimValueCallback<V2TimConversationResult>> getConversationList({
    required String nextSeq,
    required int count,
  }) async {
    return TencentCloudChatSdkPlatform.instance.getConversationList(
      nextSeq: nextSeq,
      count: count,
    );
  }

  /// 获取会话不格式化
  Future<LinkedHashMap<dynamic, dynamic>> getConversationListWithoutFormat({
    required String nextSeq,
    required int count,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getConversationListWithoutFormat(
      nextSeq: nextSeq,
      count: count,
    );
  }

  /// 通过会话ID获取指定会话列表
  ///
  Future<V2TimValueCallback<List<V2TimConversation>>>
      getConversationListByConversaionIds({
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getConversationListByConversaionIds(
            conversationIDList: conversationIDList);
  }

  /// 会话置顶
  ///
  Future<V2TimCallback> pinConversation({
    required String conversationID,
    required bool isPinned,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .pinConversation(conversationID: conversationID, isPinned: isPinned);
  }

  /// 获取会话未读总数
  ///
  Future<V2TimValueCallback<int>> getTotalUnreadMessageCount() async {
    return TencentCloudChatSdkPlatform.instance.getTotalUnreadMessageCount();
  }

  /// 获取指定会话
  ///
  /// 参数
  ///
  /// ```
  /// conversationID	会话唯一 ID，如果是 C2C 单聊，组成方式为 c2c_userID，如果是群聊，组成方式为 group_groupID
  ///
  /// ```
  ///
  Future<V2TimValueCallback<V2TimConversation>> getConversation({
    /*required*/ required String conversationID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getConversation(conversationID: conversationID);
  }

  /// 删除会话
  ///
  /// 请注意:
  ///
  /// ```
  /// 删除会话会在本地删除的同时，在服务器也会同步删除。
  /// 会话内的消息在本地删除的同时，在服务器也会同步删除。
  /// ```
  ///
  Future<V2TimCallback> deleteConversation({
    /*required*/ required String conversationID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteConversation(conversationID: conversationID);
  }

  /// 设置会话草稿
  ///
  /// ```
  /// 只在本地保存，不会存储 Server，不能多端同步，程序卸载重装会失效。
  /// ```
  /// 参数
  ///
  /// ```
  /// draftText	草稿内容, 为 null 则表示取消草稿
  /// ```
  ///
  Future<V2TimCallback> setConversationDraft({
    required String conversationID,
    String? draftText = "",
  }) async {
    return TencentCloudChatSdkPlatform.instance.setConversationDraft(
        conversationID: conversationID, draftText: draftText);
  }

  /// 创建好友分组
  /// 4.0.8及以后版本支持，web不支持
  /// 会话分组最大支持 20 个，不再使用的分组请及时删除。
  ///
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      setConversationCustomData({
    required String customData,
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setConversationCustomData(
        customData: customData, conversationIDList: conversationIDList);
  }

  /// 高级获取会话接口
  ///
  Future<V2TimValueCallback<V2TimConversationResult>>
      getConversationListByFilter({
    required V2TimConversationFilter filter,
    required int nextSeq,
    required int count,
  }) async {
    return TencentCloudChatSdkPlatform.instance.getConversationListByFilter(
      filter: filter,
      nextSeq: nextSeq,
      count: count,
    );
  }

  /// 标记会话
  /// 4.0.8及以后版本支持，web不支持，且应用为旗舰版
  /// 会话分组最大支持 20 个，不再使用的分组请及时删除。
  /// 如果已有标记不能满足您的需求，您可以自定义扩展标记，扩展标记需要满足以下两个条件：
  /// 1、扩展标记值不能和 V2TIMConversation 已有的标记值冲突
  /// 扩展标记值必须是 0x1L << n 的位移值（32 <= n < 64，即 n 必须大于等于 32 并且小于 64），比如自定义 0x1L << 32 标记值表示 "iPhone 在线"
  /// 扩展标记值不能设置为 0x1 << 32，要设置为 0x1L << 32，明确告诉编译器是 64 位的整型常量
  /// flutter中使用markType可参考 V2TimConversationMarkType
  ///
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      markConversation({
    required int markType,
    required bool enableMark,
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.markConversation(
        markType: markType,
        enableMark: enableMark,
        conversationIDList: conversationIDList);
  }

  /// 创建好友分组
  /// 4.0.8及以后版本支持，web不支持
  /// 会话分组最大支持 20 个，不再使用的分组请及时删除。
  ///
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      createConversationGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.createConversationGroup(
        groupName: groupName, conversationIDList: conversationIDList);
  }

  /// 获取会话分组列表
  /// 4.0.8及以后版本支持，web不支持
  ///
  Future<V2TimValueCallback<List<String>>> getConversationGroupList() async {
    return TencentCloudChatSdkPlatform.instance.getConversationGroupList();
  }

  /// 删除会话分组
  /// 4.0.8及以后版本支持，web不支持
  ///
  Future<V2TimCallback> deleteConversationGroup({
    required String groupName,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteConversationGroup(groupName: groupName);
  }

  /// 重命名会话分组
  /// 4.0.8及以后版本支持，web不支持
  ///
  Future<V2TimCallback> renameConversationGroup({
    required String oldName,
    required String newName,
  }) async {
    return TencentCloudChatSdkPlatform.instance.renameConversationGroup(
      oldName: oldName,
      newName: newName,
    );
  }

  /// 添加会话到一个会话分组
  /// 4.0.8及以后版本支持，web不支持
  ///
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      addConversationsToGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.addConversationsToGroup(
      groupName: groupName,
      conversationIDList: conversationIDList,
    );
  }

  /// 从一个会话分组中删除会话
  /// 4.0.8及以后版本支持，web不支持
  ///
  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationsFromGroup({
    required String groupName,
    required List<String> conversationIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance.deleteConversationsFromGroup(
      groupName: groupName,
      conversationIDList: conversationIDList,
    );
  }

  Future<V2TimValueCallback<List<V2TimConversationOperationResult>>>
      deleteConversationList({
    required List<String> conversationIDList,
    required bool clearMessage,
  }) async {
    return TencentCloudChatSdkPlatform.instance.deleteConversationList(
        conversationIDList: conversationIDList, clearMessage: clearMessage);
  }

  Future<V2TimValueCallback<int>> getUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getUnreadMessageCountByFilter(filter: filter);
  }

  Future<V2TimCallback> subscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .subscribeUnreadMessageCountByFilter(filter: filter);
  }

  Future<V2TimCallback> unsubscribeUnreadMessageCountByFilter({
    required V2TimConversationFilter filter,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .unsubscribeUnreadMessageCountByFilter(filter: filter);
  }

  Future<V2TimCallback> cleanConversationUnreadMessageCount({
    required String conversationID,
    required int cleanTimestamp,
    required int cleanSequence,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .cleanConversationUnreadMessageCount(
            conversationID: conversationID,
            cleanTimestamp: cleanTimestamp,
            cleanSequence: cleanSequence);
  }
}
