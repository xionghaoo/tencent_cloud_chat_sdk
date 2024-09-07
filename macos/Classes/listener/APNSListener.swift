//
//  APNSListener.swift
//  tencent_im_sdk_plugin
//
//  Created by xingchenhe on 2020/12/18.
//

import Foundation
import ImSDKForMac_Plus

class APNSListener: NSObject, V2TIMAPNSListener {
	public static var count: UInt32 = 0;
	
	public func onSetAPPUnreadCount() -> UInt32 {
        print("im sdk set unreadcount :")
        print(SDKManager.uc)
        return SDKManager.uc
	}
	
}
