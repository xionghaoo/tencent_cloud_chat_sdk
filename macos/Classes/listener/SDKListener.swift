//
//  SDKListener.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/18.
//

import Foundation
import ImSDKForMac_Plus

class SDKListener: NSObject, V2TIMSDKListener {
    let listenerUuid:String;
    init(listenerUid:String) {
        listenerUuid = listenerUid;
    }
	/// 连接中
	public func onConnecting() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConnecting, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 网络连接成功
	public func onConnectSuccess() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConnectSuccess, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 网络连接失败
	public func onConnectFailed(_ code: Int32, err: String!) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onConnectFailed, method: "initSDKListener", data: [
			"code": code,
            "desc": err!,
		], listenerUuid: listenerUuid)
	}
	
	/// 踢下线通知
	public func onKickedOffline() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onKickedOffline, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 用户登录的 userSig 过期（用户需要重新获取 userSig 后登录）
	public func onUserSigExpired() {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onUserSigExpired, method: "initSDKListener", data: nil, listenerUuid: listenerUuid)
	}
	
	/// 当前用户的资料发生了更新
	public func onSelfInfoUpdated(_ Info: V2TIMUserFullInfo!) {
		TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onSelfInfoUpdated, method: "initSDKListener", data: V2UserFullInfoEntity.getDict(info: Info), listenerUuid: listenerUuid)
	}
    public func onUserStatusChanged(_ statusList: [V2TIMUserStatus]!){
        var data:[String:Any] = [:];
        var res: [[String: Any]] = []
        statusList?.forEach({ status in
            var item: [String: Any] = [:]
            item["customStatus"] = status.customStatus ?? "";
            item["statusType"] = status.statusType.rawValue;
            item["userID"] = status.userID;
            res.append(item)
        })
        data["statusList"] = res;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onUserStatusChanged, method: "initSDKListener", data: data, listenerUuid: listenerUuid)
    }
    public func onUserInfoChanged(_ userInfoList: [V2TIMUserFullInfo]!) {
        var data:[String:Any] = [:];
        var res: [[String: Any]] = []
        userInfoList?.forEach({ info in
            
            res.append(V2UserFullInfoEntity.getDict(info: info))
        })
        data["userInfoList"] = res;
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onUserInfoChanged, method: "initSDKListener", data: data, listenerUuid: listenerUuid)
    }
    public func onExperimentalNotify(_ key: String!, param: NSObject!) {
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onExperimentalNotify, method: "initSDKListener", data: [
            "key": key as Any,
            "param": param as Any,
        ], listenerUuid: listenerUuid)
    }
    public func onAllReceiveMessageOptChanged(_ receiveMessageOptInfo: V2TIMReceiveMessageOptInfo!) {
        var data: [String: Any] = [:]
        data["c2CReceiveMessageOpt"] = receiveMessageOptInfo.receiveOpt.rawValue;
        data["allReceiveMessageOpt"] = receiveMessageOptInfo.receiveOpt.rawValue;
        data["duration"] = receiveMessageOptInfo.duration;
        data["startHour"] = receiveMessageOptInfo.startHour;
        data["startMinute"] = receiveMessageOptInfo.startMinute;
        data["startSecond"] = receiveMessageOptInfo.startSecond;
        data["startTimeStamp"] = receiveMessageOptInfo.startTimeStamp;
        data["userID"] = receiveMessageOptInfo.userID;
        
        TencentCloudChatSdkPlugin.invokeListener(type: ListenerType.onAllReceiveMessageOptChanged, method: "initSDKListener", data: data, listenerUuid: listenerUuid)
    }
}
