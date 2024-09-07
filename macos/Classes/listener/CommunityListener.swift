//
//  APNSListener.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2024/05/22.
//

import Foundation
import ImSDKForMac_Plus


class CommunityListener: NSObject, V2TIMCommunityListener {
    let listenerUuid:String;

    init(listenerUid:String) {
        listenerUuid = listenerUid;
    }
    public func onCreateTopic(_ groupID: String!, topicID: String!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["topicID"] = topicID;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onCreateTopic, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onDeleteTopic(_ groupID: String!, topicIDList: [String]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["topicIDList"] = topicIDList;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onDeleteTopic, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onChangeTopicInfo(_ groupID: String!, topicInfo: V2TIMTopicInfo!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["topicInfo"] = V2TIMTopicInfoEntity.getDict(info: topicInfo);
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onChangeTopicInfo, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onReceiveTopicRESTCustomData(_ topicID: String!, data: Data!) {
        var d : [String: Any] = [: ];
        d["customData"] =  String(data: data, encoding: String.Encoding.utf8)
        d["topicID"] = topicID;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onReceiveTopicRESTCustomData, method: "communityListener", data: d, listenerUuid: listenerUuid)
    }
    public func onCreatePermissionGroup(_ groupID: String!, permissionGroupInfo: V2TIMPermissionGroupInfo!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupInfo"] = V2TimPermissionGroupInfo.getDict(info: permissionGroupInfo);
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onCreatePermissionGroup, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onDeletePermissionGroup(_ groupID: String!, permissionGroupIDList: [String]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupIDList"] = permissionGroupIDList;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onDeletePermissionGroup, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onChangePermissionGroupInfo(_ groupID: String!, permissionGroupInfo: V2TIMPermissionGroupInfo!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupInfo"] = V2TimPermissionGroupInfo.getDict(info: permissionGroupInfo);
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onChangePermissionGroupInfo, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    public func onDeleteTopicPermission(_ groupID: String!, permissionGroupID: String!, topicIDList: [String]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupID"] = permissionGroupID;
        data["topicIDList"] = topicIDList;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onDeleteTopicPermission, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    func onAddTopicPermission(_ groupID: String!, permissionGroupID: String!, topicPermissionMap: [String : NSNumber]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupID"] = permissionGroupID;
        data["topicPermissionMap"] = topicPermissionMap;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onAddTopicPermission, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    func onModifyTopicPermission(_ groupID: String!, permissionGroupID: String!, topicPermissionMap: [String : NSNumber]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupID"] = permissionGroupID;
        data["topicPermissionMap"] = topicPermissionMap;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onModifyTopicPermission, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    func onAddMembers(toPermissionGroup groupID: String!, permissionGroupID: String!, memberIDList: [String]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupID"] = permissionGroupID;
        data["memberIDList"] = memberIDList;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onAddMembersToPermissionGroup, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    func onRemoveMembers(fromPermissionGroup groupID: String!, permissionGroupID: String!, memberIDList: [String]!) {
        var data : [String: Any] = [: ];
        data["groupID"] = groupID;
        data["permissionGroupID"] = permissionGroupID;
        data["memberIDList"] = memberIDList;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onRemoveMembersFromPermissionGroup, method: "communityListener", data: data, listenerUuid: listenerUuid)
    }
    
}
