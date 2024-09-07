//
//  ConversationListener.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/18.
//

import Foundation
import ImSDK_Plus
import Hydra
import Flutter
class ConversationListener: NSObject, V2TIMConversationListener {
    let listenerUuid:String;

	init(listenerUid:String) {
		listenerUuid = listenerUid;
	}
	/// 会话刷新
	public func onConversationChanged(_ conversationList: [V2TIMConversation]!) {
	// 	var cs: [[String: Any]] = [];
		
	// 	for item in conversationList {
	// 		cs.append(V2ConversationEntity.getDict(info: item));
	// 	}
	// 	TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationChanged, method: "conversationListener", data: cs)
		
	async({
			_ -> Int in
            var cs: [[String: Any]] = [];
			for item in conversationList {
				cs.append(V2ConversationEntity.getDict(info: item));
			}
        
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationChanged, method: "conversationListener", data: cs, listenerUuid: self.listenerUuid)
			return 1
		}).then({
			value in
		})
		
	}
	
	/// 新会话
	public func onNewConversation(_ conversationList: [V2TIMConversation]!) {
        
        async({
                _ -> Int in
                var cs: [[String: Any]] = [];
                for item in conversationList {
                    cs.append(V2ConversationEntity.getDict(info: item));
                }
            TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onNewConversation, method: "conversationListener", data: cs, listenerUuid: self.listenerUuid)
                return 1
            }).then({
                value in
            })
        
//		var cs: [[String: Any]] = [];
//		for item in conversationList {
//			cs.append(V2ConversationEntity.getDict(info: item));
//		}
//		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onNewConversation, method: "conversationListener", data: cs, listenerUuid: listenerUuid)
	}

	/// 同步服务开始
	public func onSyncServerStart() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onSyncServerStart, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 同步服务完成
	public func onSyncServerFinish() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onSyncServerFinish, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 同步服务失败
	public func onSyncServerFailed() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onSyncServerFailed, method: "conversationListener", data: nil, listenerUuid: listenerUuid)
	}
	// 未读数改变
	public func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onTotalUnreadMessageCountChanged, method: "conversationListener", data: totalUnreadCount, listenerUuid: listenerUuid)
	}
    
    
    
    public func onConversationGroupDeleted(_ groupName: String!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationGroupDeleted, method: "conversationListener", data: groupName, listenerUuid: listenerUuid)
    }
    public func onConversationGroupCreated(_ groupName: String!, conversationList: [V2TIMConversation]!) {
        
        async({
                _ -> Int in
                var cs: [[String: Any]] = [];
            var dd: [String:Any] = [:];
                for item in conversationList {
                    cs.append(V2ConversationEntity.getDict(info: item));
                }
            dd["groupName"] = groupName;
            dd["conversationList"] = cs;
            TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationGroupCreated, method: "conversationListener", data: dd, listenerUuid: self.listenerUuid)
                return 1
            }).then({
                value in
            })
    }
    public func onConversationsAdded(toGroup groupName: String!, conversationList: [V2TIMConversation]!) {
        async({
                _ -> Int in
                var cs: [[String: Any]] = [];
            var dd: [String:Any] = [:];
                for item in conversationList {
                    cs.append(V2ConversationEntity.getDict(info: item));
                }
            dd["groupName"] = groupName;
            dd["conversationList"] = cs;
            TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationsAddedToGroup, method: "conversationListener", data: dd, listenerUuid: self.listenerUuid)
                return 1
            }).then({
                value in
            })
    }
    public func onConversationsDeleted(fromGroup groupName: String!, conversationList: [V2TIMConversation]!) {
        async({
                _ -> Int in
                var cs: [[String: Any]] = [];
            var dd: [String:Any] = [:];
                for item in conversationList {
                    cs.append(V2ConversationEntity.getDict(info: item));
                }
            dd["groupName"] = groupName;
            dd["conversationList"] = cs;
            TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationsDeletedFromGroup, method: "conversationListener", data: dd, listenerUuid: self.listenerUuid)
                return 1
            }).then({
                value in
            })
    }
    public func onConversationGroupNameChanged(_ oldName: String!, newName: String!) {
        var dd: [String:Any] = [:];
        dd["oldName"] = oldName
        dd["newName"] = newName
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationGroupNameChanged, method: "conversationListener", data: dd, listenerUuid: listenerUuid)
    }
    public func onConversationDeleted(_ conversationIDList: [String]!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConversationDeleted, method: "conversationListener", data: conversationIDList, listenerUuid: listenerUuid)
    }
    public func onUnreadMessageCountChanged(by filter: V2TIMConversationListFilter!, totalUnreadCount: UInt64) {
        var dd: [String:Any] = [:];
        dd["totalUnreadCount"] = totalUnreadCount
        var fil: [String:Any] = [:];
        fil["conversationGroup"] = filter.conversationGroup;
        fil["hasGroupAtInfo"] = filter.hasGroupAtInfo;
        fil["hasUnreadCount"] = filter.hasUnreadCount;
        fil["markType"] = filter.markType;
        fil["conversationType"] = filter.type.rawValue;
        dd["filter"] = fil
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onUnreadMessageCountChangedByFilter, method: "conversationListener", data: dd, listenerUuid: listenerUuid)
    }
}
