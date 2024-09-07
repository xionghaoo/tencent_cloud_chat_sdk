import Foundation
import ImSDKForMac_Plus

/// 自定义群成员信息实体
class V2GroupMemberInfoEntity: V2TIMGroupMemberInfo {

    convenience init(json: String) {
        self.init(dict: JsonUtil.getDictionaryFromJSONString(jsonString: json))
    }

    init(dict: [String: Any]) {
        super.init();
        self.userID = (dict["userID"] as? String);
        self.nameCard = (dict["nameCard"] as? String);
    }

    /// 根据对象获得字典对象
    public static func getDict(info: V2TIMGroupMemberInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = info.userID;
        result["nickName"] = info.nickName;
        result["friendRemark"] = info.friendRemark;
        result["faceUrl"] = info.faceURL;
        result["nameCard"] = info.nameCard;
        
        result["onlineDevices"] = info.onlineDevices as? [String] ?? [];
        return result;
    }
	

    /// 根据对象获得字典对象
    public static func getDict(simpleInfo: V2TIMGroupMemberInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        result["userID"] = simpleInfo.userID;
        result["nickName"] = simpleInfo.nickName;
        result["friendRemark"] = simpleInfo.friendRemark;
        result["faceUrl"] = simpleInfo.faceURL;
        result["nameCard"] = simpleInfo.nameCard;
        result["onlineDevices"] = simpleInfo.onlineDevices as? [String] ?? [];
        return result;
    }
}



