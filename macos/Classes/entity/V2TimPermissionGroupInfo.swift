import Foundation
import ImSDKForMac_Plus

/// 自定义消息响应实体
class V2TimPermissionGroupInfo: V2TIMPermissionGroupInfo {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMPermissionGroupInfo) -> [String: Any] {
        var result: [String: Any] = [:];
         result["customData"] = info.customData;
         result["groupPermission"] = info.groupPermission;
         result["groupID"] = info.groupID;
         result["permissionGroupID"] = info.permissionGroupID;
         result["permissionGroupName"] = info.permissionGroupName;
         result["memberCount"] = info.memberCount;
         return result;
    }
    init(dict: [String: Any]) {
        super.init();
            
         self.groupID = (dict["groupID"] as? String);
		
		 if let customData = dict["customData"] as? String {
		 	self.customData = customData;
		 }
		 if let groupPermission = dict["groupPermission"] as? UInt64 {
		 	self.groupPermission = groupPermission;
		 }
		 if let permissionGroupID = dict["permissionGroupID"] as? String {
		 	self.permissionGroupID = permissionGroupID;
		 }
		 if let permissionGroupName = dict["permissionGroupName"] as? String {
		 	self.permissionGroupName = permissionGroupName;
		 }
		 
		
    }
}
