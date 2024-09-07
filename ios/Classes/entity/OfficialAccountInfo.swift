import ImSDK_Plus
class OfficialAccountInfo: V2TIMOfficialAccountInfo {
    public static func getDict(info: V2TIMOfficialAccountInfo) -> [String: Any] {
        var result: [String: Any] = [:];
        
        
       
        result["createTime"] = info.createTime;
        result["customData"] = info.customData;
        result["faceUrl"] = info.faceUrl;
        result["officialAccountID"] = info.officialAccountID;
        result["officialAccountName"] = info.officialAccountName;
        result["organization"] = info.organization;
        result["ownerUserID"] = info.ownerUserID;
        result["subscribeTime"] = info.subscribeTime;
        result["subscriberCount"] = info.subscriberCount;
        result["introduction"] = info.introduction;
        return result;
    }
}
