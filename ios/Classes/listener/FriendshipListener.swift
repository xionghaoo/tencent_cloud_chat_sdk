//
//  FriendsshipListener.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/18.
//

import Foundation
import ImSDK_Plus
import Flutter
class FriendshipListener: NSObject, V2TIMFriendshipListener {
    let listenerUuid:String;
    init(listenerUid: String) {
        listenerUuid = listenerUid;
    }
	
	public func onFriendApplicationListAdded(_ applicationList: [V2TIMFriendApplication]!) {
		var data: [[String: Any]] = [];
		for item in applicationList {
			data.append(V2FriendApplicationEntity.getDict(info: item));
		}
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendApplicationListAdded, method: "friendListener", data: data, listenerUuid: listenerUuid)
	}
	
	public func onFriendApplicationListDeleted(_ userIDList: [Any]!) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendApplicationListDeleted, method: "friendListener", data: userIDList, listenerUuid: listenerUuid)
	}
	
	public func onFriendApplicationListRead() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendApplicationListRead, method: "friendListener", data: nil, listenerUuid: listenerUuid)
	}
	
	public func onFriendListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendListAdded, method: "friendListener", data: data, listenerUuid: listenerUuid)
	}
	
	public func onFriendListDeleted(_ userIDList: [Any]!) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendListDeleted, method: "friendListener", data: userIDList, listenerUuid: listenerUuid)
	}
	
	
	public func onBlackListAdded(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onBlackListAdd, method: "friendListener", data: data, listenerUuid: listenerUuid)
	}
	
	public func onBlackListDeleted(_ userIDList: [Any]!) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onBlackListDeleted, method: "friendListener", data: userIDList, listenerUuid: listenerUuid)
	}
	
	public func onFriendProfileChanged(_ infoList: [V2TIMFriendInfo]!) {
		var data: [[String: Any]] = [];
		for item in infoList {
			data.append(V2FriendInfoEntity.getDict(info: item));
		}
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onFriendInfoChanged, method: "friendListener", data: data, listenerUuid: listenerUuid)
	}
    public func onOfficialAccountDeleted(_ officialAccountID: String!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onOfficialAccountDeleted, method: "friendListener", data: officialAccountID, listenerUuid: listenerUuid)
    }
    public func onOfficialAccountSubscribed(_ officialAccountInfo: V2TIMOfficialAccountInfo!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onOfficialAccountSubscribed, method: "friendListener", data: OfficialAccountInfo.getDict(info: officialAccountInfo), listenerUuid: listenerUuid)
    }
    public func onOfficialAccountUnsubscribed(_ officialAccountID: String!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onOfficialAccountUnsubscribed, method: "friendListener", data: officialAccountID, listenerUuid: listenerUuid)
    }
    public func onOfficialAccountInfoChanged(_ officialAccountInfo: V2TIMOfficialAccountInfo!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onOfficialAccountInfoChanged, method: "friendListener", data: OfficialAccountInfo.getDict(info: officialAccountInfo), listenerUuid: listenerUuid)
    }
    public func onMyFollowersListChanged(_ userInfoList: [V2TIMUserFullInfo]!, isAdd: Bool) {
        var ret: [String: Any] = [:];
                
        ret["isAdd"] = isAdd;
        var res: [[String: Any]] = []
        for item in userInfoList ?? [] {
            res.append(V2UserFullInfoEntity.getDict(info: item));
        }
        ret["userInfoList"] = res;
        
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onMyFollowersListChanged, method: "friendListener", data: ret, listenerUuid: listenerUuid)
    }
    public func onMutualFollowersListChanged(_ userInfoList: [V2TIMUserFullInfo]!, isAdd: Bool) {
        var ret: [String: Any] = [:];
                
        ret["isAdd"] = isAdd;
        var res: [[String: Any]] = []
        for item in userInfoList ?? [] {
            res.append(V2UserFullInfoEntity.getDict(info: item));
        }
        ret["userInfoList"] = res;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onMutualFollowersListChanged, method: "friendListener", data: ret, listenerUuid: listenerUuid)
    }
    public  func onMyFollowingListChanged(userInfoList: [V2TIMUserFullInfo]!, isAdd: Bool) {
        var ret: [String: Any] = [:];
                
        ret["isAdd"] = isAdd;
        var res: [[String: Any]] = []
        for item in userInfoList ?? [] {
            res.append(V2UserFullInfoEntity.getDict(info: item));
        }
        ret["userInfoList"] = res;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onMyFollowingListChanged, method: "friendListener", data: ret, listenerUuid: listenerUuid)
    }
}
