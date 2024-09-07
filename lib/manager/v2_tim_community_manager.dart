import 'package:tencent_cloud_chat_sdk/enum/V2TimCommunityListener.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_callback.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_create_group_member_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_member_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_member_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_permission_group_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_info_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_operation_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_topic_permission_result.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_value_callback.dart';
import 'package:tencent_cloud_chat_sdk/tencent_cloud_chat_sdk_platform_interface.dart';

///{@category Manager}
///
class V2TIMCommunityManager {
  Future<String> addCommunityListener({
    required V2TimCommunityListener listener,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .addCommunityListener(listener: listener);
  }

  Future<bool> removeCommunityListener({
    String? listenerID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .removeCommunityListener(listenerID: listenerID);
  }

  Future<V2TimValueCallback<String>> createCommunity({
    required V2TimGroupInfo info,
    required List<V2TimCreateGroupMemberInfo> memberList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .createCommunity(info: info, memberList: memberList);
  }

  Future<V2TimValueCallback<List<V2TimGroupInfo>>>
      getJoinedCommunityList() async {
    return TencentCloudChatSdkPlatform.instance.getJoinedCommunityList();
  }

  /// 创建话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<String>> createTopicInCommunity({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.createTopicInCommunity(
      groupID: groupID,
      topicInfo: topicInfo,
    );
  }

  /// 删除话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicFromCommunity({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteTopicFromCommunity(groupID: groupID, topicIDList: topicIDList);
  }

  /// 删除话题
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimCallback> setTopicInfo({
    required String groupID,
    required V2TimTopicInfo topicInfo,
  }) async {
    return TencentCloudChatSdkPlatform.instance.setTopicInfo(
      topicInfo: topicInfo,
      groupID: groupID,
    );
  }

  /// 获取话题列表。
  /// 4.0.1及以上版本支持
  /// web版本不支持
  ///
  Future<V2TimValueCallback<List<V2TimTopicInfoResult>>> getTopicInfoList({
    required String groupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getTopicInfoList(groupID: groupID, topicIDList: topicIDList);
  }

  /// 创建权限
  Future<V2TimValueCallback<String>> createPermissionGroupInCommunity({
    required V2TimPermissionGroupInfo info,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .createPermissionGroupInCommunity(info: info);
  }

  /// 删除社群权限
  Future<V2TimValueCallback<List<V2TimPermissionGroupOperationResult>>>
      deletePermissionGroupFromCommunity({
    required String groupID,
    required List<String> permissionGroupIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deletePermissionGroupFromCommunity(
      groupID: groupID,
      permissionGroupIDList: permissionGroupIDList,
    );
  }

  Future<V2TimCallback> modifyPermissionGroupInfoInCommunity({
    required V2TimPermissionGroupInfo info,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .modifyPermissionGroupInfoInCommunity(info: info);
  }

  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>>
      getJoinedPermissionGroupListInCommunity({
    required String groupID,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getJoinedPermissionGroupListInCommunity(groupID: groupID);
  }

  Future<V2TimValueCallback<List<V2TimPermissionGroupInfoResult>>>
      getPermissionGroupListInCommunity({
    required String groupID,
    required List<String> permissionGroupIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getPermissionGroupListInCommunity(
      groupID: groupID,
      permissionGroupIDList: permissionGroupIDList,
    );
  }

  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>>
      addCommunityMembersToPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> memberList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .addCommunityMembersToPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      memberList: memberList,
    );
  }

  Future<V2TimValueCallback<List<V2TimPermissionGroupMemberOperationResult>>>
      removeCommunityMembersFromPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> memberList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .removeCommunityMembersFromPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      memberList: memberList,
    );
  }

  Future<V2TimValueCallback<V2TimPermissionGroupMemberInfoResult>>
      getCommunityMemberListInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required String nextCursor,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getCommunityMemberListInPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      nextCursor: nextCursor,
    );
  }

  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      addTopicPermissionToPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required Map<String, int> topicPermissionMap,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .addTopicPermissionToPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      topicPermissionMap: topicPermissionMap,
    );
  }

  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      deleteTopicPermissionFromPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .deleteTopicPermissionFromPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      topicIDList: topicIDList,
    );
  }

  Future<V2TimValueCallback<List<V2TimTopicOperationResult>>>
      modifyTopicPermissionInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required Map<String, int> topicPermissionMap,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .modifyTopicPermissionInPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      topicPermissionMap: topicPermissionMap,
    );
  }

  Future<V2TimValueCallback<List<V2TimTopicPermissionResult>>>
      getTopicPermissionInPermissionGroup({
    required String groupID,
    required String permissionGroupID,
    required List<String> topicIDList,
  }) async {
    return TencentCloudChatSdkPlatform.instance
        .getTopicPermissionInPermissionGroup(
      groupID: groupID,
      permissionGroupID: permissionGroupID,
      topicIDList: topicIDList,
    );
  }
}
