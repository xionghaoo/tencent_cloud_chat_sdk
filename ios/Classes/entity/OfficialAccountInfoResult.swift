import ImSDK_Plus
class OfficialAccountInfoResult: V2TIMOfficialAccountInfoResult {
    public static func getDict(info: V2TIMOfficialAccountInfoResult) -> [String: Any] {
        var result: [String: Any] = [:];
        
        result["resultInfo"] = info.resultInfo;
        result["resultCode"] = info.resultCode;
        result["officialAccountInfo"] = OfficialAccountInfo.getDict(info: info.officialAccountInfo);

        return result;
    }
}
