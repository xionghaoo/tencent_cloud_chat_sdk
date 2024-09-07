import Foundation
import ImSDKForMac_Plus

/// 自定义消息响应实体
class V2TimPermissionGroupInfoResult: V2TIMPermissionGroupInfoResult {

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMPermissionGroupInfoResult) -> [String: Any] {
        var result: [String: Any] = [:];
         result["resultCode"] = info.resultCode;
         result["resultMessage"] = info.resultMsg;
         result["permissionGroupInfo"] = V2TimPermissionGroupInfo.getDict(info: info.info) ;
       
         return result;
    }
    init(dict: [String: Any]) {
        super.init();
            
        //  self.groupID = (dict["groupID"] as? String);
		
		//  if let customData = dict["customData"] as? String {
		//  	self.customData = customData;
		//  }
		//  if let groupPermission = dict["groupPermission"] as? UInt64 {
		//  	self.groupPermission = groupPermission;
		//  }
		//  if let permissionGroupID = dict["permissionGroupID"] as? String {
		//  	self.permissionGroupID = permissionGroupID;
		//  }
		//  if let permissionGroupName = dict["permissionGroupName"] as? String {
		//  	self.permissionGroupName = permissionGroupName;
		//  }
    }
    public static func getListDict(infos: [V2TIMPermissionGroupInfoResult]) -> [[String: Any]] {
       
        var res: [[String: Any]] = []
        for info in infos {
            res.append(V2TimPermissionGroupInfoResult.getDict(info: info))
        }
        return res;
    }
}
