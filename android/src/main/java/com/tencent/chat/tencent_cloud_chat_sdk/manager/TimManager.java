package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import android.content.Context;
import android.util.Log;

import com.tencent.chat.tencent_cloud_chat_sdk.util.AbCallback;
import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;
import com.tencent.imsdk.common.IMLog;
import com.tencent.imsdk.v2.V2TIMAdvancedMsgListener;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMGroupChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberChangeInfo;
import com.tencent.imsdk.v2.V2TIMGroupMemberInfo;
import com.tencent.imsdk.v2.V2TIMLogListener;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.imsdk.v2.V2TIMMessageReceipt;
import com.tencent.imsdk.v2.V2TIMReceiveMessageOptInfo;
import com.tencent.imsdk.v2.V2TIMSDKConfig;
import com.tencent.imsdk.v2.V2TIMSDKListener;
import com.tencent.imsdk.v2.V2TIMSimpleMsgListener;
import com.tencent.imsdk.v2.V2TIMTopicInfo;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfo;
import com.tencent.imsdk.v2.V2TIMUserStatus;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import org.json.JSONObject;

import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TimManager {

    public static String TAG = "tencent_im_sdk_plugin";
    private static List<MethodChannel> channels = new LinkedList<>();
    private static HashMap<String, V2TIMSimpleMsgListener> simpleMsgListenerMap = new HashMap<>();
    private static HashMap<String, V2TIMGroupListener> groupListenerMap = new HashMap<>();
    private static HashMap<String, V2TIMSDKListener> initListenerMap = new HashMap<>();
    public static Context context;
    public TimManager(MethodChannel _channel, Context context){
        TimManager.channels.add(_channel);
        TimManager.context = context;
    }
    public static void cleanChannels(){
        channels = new LinkedList<>();
    }
    public void addSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){
//        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
//        final V2TIMSimpleMsgListener listener = new V2TIMSimpleMsgListener(){
//            public void onRecvC2CTextMessage (String msgID, V2TIMUserInfo sender, String text){
//                HashMap<String,Object> res = new HashMap<String,Object>();
//                res.put("msgID",msgID);
//                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
//                res.put("text",text);
//                makeaddSimpleMsgListenerEventData("onRecvC2CTextMessage",res, listenerUuid);
//            }
//
//            public void onRecvC2CCustomMessage (String msgID, V2TIMUserInfo sender, byte[] customData){
//                HashMap<String,Object> res = new HashMap<String,Object>();
//                res.put("msgID",msgID);
//                res.put("sender",CommonUtil.convertV2TIMUserInfotoMap(sender));
//                res.put("customData",customData == null ? "" : new String(customData));
//                makeaddSimpleMsgListenerEventData("onRecvC2CCustomMessage",res, listenerUuid);
//            }
//
//            public void onRecvGroupTextMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, String text){
//                HashMap<String,Object> res = new HashMap<String,Object>();
//                res.put("msgID",msgID);
//                res.put("groupID",groupID);
//                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
//                res.put("text",text);
//                makeaddSimpleMsgListenerEventData("onRecvGroupTextMessage",res, listenerUuid);
//            }
//
//            public void onRecvGroupCustomMessage (String msgID, String groupID, V2TIMGroupMemberInfo sender, byte[] customData){
//                HashMap<String,Object> res = new HashMap<String,Object>();
//                res.put("msgID",msgID);
//                res.put("groupID",groupID);
//                res.put("sender",CommonUtil.convertV2TIMGroupMemberInfoToMap(sender));
//                res.put("customData",customData == null ? "" : new String(customData));
//                makeaddSimpleMsgListenerEventData("onRecvGroupCustomMessage",res, listenerUuid);
//            }
//        };
//        simpleMsgListenerMap.put(listenerUuid, listener);
//        V2TIMManager.getInstance().addSimpleMsgListener(listener);
//        result.success("add simple msg listener success");
        CommonUtil.returnError(result,-1,"addSimpleMsgListener is not support now. use addvanced message listener instead");
    }

    public void getPlatformVersion(MethodCall methodCall, final MethodChannel.Result result){
        result.success("Android " + android.os.Build.VERSION.RELEASE);
    }

    public void getUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().getUserStatus(userIDList, new V2TIMValueCallback<List<V2TIMUserStatus>>() {
            @Override
            public void onSuccess(List<V2TIMUserStatus> v2TIMUserStatuses) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMUserStatuses.size();i++){
                    list.add(CommonUtil.convertV2TIMUserStatusToMap(v2TIMUserStatuses.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void setSelfStatus(MethodCall methodCall, final MethodChannel.Result result){
        String status = methodCall.argument("status");
        V2TIMUserStatus customStatus = new V2TIMUserStatus();
        customStatus.setCustomStatus(status);
        V2TIMManager.getInstance().setSelfStatus(customStatus, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void removeSimpleMsgListener(MethodCall methodCall, MethodChannel.Result result){

        CommonUtil.returnError(result,-1,"removeSimpleMsgListener is not support now. use addvanced message listener instead");
    }
    public void removeGroupListener(MethodCall methodCall, MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");

        if (!listenerUuid.isEmpty()) {

            groupListenerUuidList.remove(listenerUuid);
            System.out.println("removeGroupListener current message listener size id" + groupListenerUuidList.size());
            if(groupListenerUuidList.isEmpty()){
                V2TIMManager.getInstance().removeGroupListener(groupListenerv2);
            }
            result.success("removeGroupListener is done");
        } else {
            groupListenerUuidList.clear();
            V2TIMManager.getInstance().removeGroupListener(groupListenerv2);
            result.success("all groupListener is removed");
        }
    }
    String globaluuid = "";
    V2TIMLogListener logListener = new V2TIMLogListener() {
        @Override
        public void onLog(int logLevel, String logContent) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("level",logLevel);
            data.put("content",logContent);
            if(globaluuid!=""){
                makeEventData("onLog",data, globaluuid);
            }
        }
    };

    public  static  V2TIMSDKListener initListener  = new V2TIMSDKListener(){
        public void onConnecting() {
            makeEventData("onConnecting",null, "");

        }

        public void onConnectSuccess() {
            makeEventData("onConnectSuccess",null, "");
        }

        public void onConnectFailed(int code, String error) {


            HashMap<String,Object> err = new HashMap<String,Object>();
            err.put("code",code);
            err.put("desc",error);
            makeEventData("onConnectFailed",err, "");
        }

        public void onKickedOffline() {
            makeEventData("onKickedOffline",null, "");


        }

        public void onUserSigExpired() {
            makeEventData("onUserSigExpired",null, "");

        }

        public void onSelfInfoUpdated(V2TIMUserFullInfo info) {
            makeEventData("onSelfInfoUpdated",CommonUtil.convertV2TIMUserFullInfoToMap(info), "");

        }
        public void onUserStatusChanged(List<V2TIMUserStatus> statusList){

            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int j = 0;j<statusList.size();j++){
                list.add(CommonUtil.convertV2TIMUserStatusToMap(statusList.get(j)));
            }
            Map<String,Object> data = new HashMap<String,Object>();
            data.put("statusList",list);
            makeEventData("onUserStatusChanged",data, "");
        }

        @Override
        public void onAllReceiveMessageOptChanged(V2TIMReceiveMessageOptInfo receiveMessageOptInfo) {
            makeEventData("onAllReceiveMessageOptChanged",CommonUtil.convertV2TIMReceiveMessageOptInfoToMap(receiveMessageOptInfo), "");
        }

        @Override
        public void onExperimentalNotify(String key, Object param) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("key",key);
            data.put("param",param);
            makeEventData("onExperimentalNotify",data,"");

        }

        @Override
        public void onUserInfoChanged(List<V2TIMUserFullInfo> userInfoList) {

            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int j = 0;j<userInfoList.size();j++){
                list.add(CommonUtil.convertV2TIMUserFullInfoToMap(userInfoList.get(j)));
            }
            Map<String,Object> data = new HashMap<String,Object>();
            data.put("userInfoList",list);
            makeEventData("onUserInfoChanged",data, "");
        }
    };
    public static boolean isAddedInitListener = false;

    public static List<String> initListenerUUID = new LinkedList<>();
    public void initSDK(final MethodCall methodCall, final MethodChannel.Result result) {
        int sdkAppID =  methodCall.argument("sdkAppID");
        int logLevel =  methodCall.argument("logLevel");
        int uiPlatform =  methodCall.argument("uiPlatform");
        final String listenerUuid = methodCall.argument("listenerUuid");
        final boolean showImLog = methodCall.argument("showImLog");
        List<String> plugins = methodCall.argument("plugins");

        if(!plugins.isEmpty()){

        }

        globaluuid = listenerUuid;
        // Global configuration
        
//        V2TIMManager.getInstance().callExperimentalAPI("setTestEnvironment", true, null);
        V2TIMManager.getInstance().callExperimentalAPI("setUIPlatform",uiPlatform, null);
        // The main thread initializes the SDK
//        if (SessionWrapper.isMainProcess(context)) {

        V2TIMSDKConfig config = new V2TIMSDKConfig();


        if(showImLog){
//            config.setLogListener(logListener);
        }
        config.setLogLevel(logLevel);

        Boolean res = false;

        // 先移除，再添加
        V2TIMManager.getInstance().removeIMSDKListener(initListener);
        V2TIMManager.getInstance().addIMSDKListener(initListener);


        try{
            res = V2TIMManager.getInstance().initSDK(context,sdkAppID,config);

        }catch (Exception e){

        };
        initListenerUUID.add(listenerUuid);
        System.out.println("important message: current download dir is "+ context.getFilesDir().getPath());
        CommonUtil.returnSuccess(result,res);

    }
    private static  <T> void  makeEventData(String type,T data, String listenerUuid){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"initSDKListener",type,data, listenerUuid);
        }

    }
    private <T> void  makeaddSimpleMsgListenerEventData(String type,T data, String listenerID){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"simpleMsgListener",type,data,listenerID);
        }

    }
    private static  <T> void  makeaddGroupListenerEventData(String type,T data, String listenerUuid){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"groupListener",type,data, listenerUuid);
        }
    }
    public void unInitSDK(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getInstance().unInitSDK();
        CommonUtil.returnSuccess(result,null);
    }
    public void login(final MethodCall methodCall, final MethodChannel.Result result) {

        String userID = CommonUtil.getParam(methodCall, result, "userID");
        String userSig = CommonUtil.getParam(methodCall, result, "userSig");
        // login operation
        V2TIMManager.getInstance().login(userID, userSig, new V2TIMCallback(){
            public void onError (int code, String desc){
                CommonUtil.returnError(result,code,desc);
            }
            public void onSuccess (){
                // 登录
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    // 安卓仅仅保证不报错
    public void setAPNSListener(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,"add setAPNSListener success");
    }
    public void getVersion(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,V2TIMManager.getInstance().getVersion());
    }
    public void getServerTime(MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.returnSuccess(result,V2TIMManager.getInstance().getServerTime());

    }

    public void logout(MethodCall methodCall, final MethodChannel.Result result) {
        V2TIMManager.getInstance().logout(new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    public void getLoginUser(MethodCall methodCall, final MethodChannel.Result result) {
        String user = V2TIMManager.getInstance().getLoginUser();
        CommonUtil.returnSuccess(result,user);

    }
    public void getLoginStatus(MethodCall methodCall, final MethodChannel.Result result) {
        int user = V2TIMManager.getInstance().getLoginStatus();
        CommonUtil.returnSuccess(result,user);
    }
    public void sendC2CTextMessage(MethodCall methodCall, final MethodChannel.Result result) {
        String text = this.getParam(methodCall, result, "text");
        String userID = this.getParam(methodCall, result, "userID");

        String mesage = V2TIMManager.getInstance().sendC2CTextMessage(text, userID, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {

                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendC2CCustomMessage(MethodCall methodCall, final MethodChannel.Result result) {
        String customData = this.getParam(methodCall, result, "customData");
        String userID = this.getParam(methodCall, result, "userID");
        byte[] customDataBytes = customData.getBytes();
        V2TIMManager.getInstance().sendC2CCustomMessage(customDataBytes, userID, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendGroupTextMessage(MethodCall methodCall, final MethodChannel.Result result){
        String text = CommonUtil.getParam(methodCall,result,"text");
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int priority = CommonUtil.getParam(methodCall,result,"priority");
        V2TIMManager.getInstance().sendGroupTextMessage(text, groupID, priority, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public void sendGroupCustomMessage(MethodCall methodCall, final MethodChannel.Result result){
        String customData = CommonUtil.getParam(methodCall,result,"customData");
        String groupID = CommonUtil.getParam(methodCall,result,"groupID");
        int priority = CommonUtil.getParam(methodCall,result,"priority");
        V2TIMManager.getInstance().sendGroupCustomMessage(customData.getBytes(), groupID, priority, new V2TIMValueCallback<V2TIMMessage>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMMessage v2TIMMessage) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMMessageToMap(v2TIMMessage));
            }
        });
    }
    public static V2TIMGroupListener groupListenerv2 =  new V2TIMGroupListener() {
        @Override
        public void onMemberEnter(String groupID, List<V2TIMGroupMemberInfo> memberList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<memberList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
            }
            data.put("memberList",list);
            makeaddGroupListenerEventData("onMemberEnter",data,"");
        }

        @Override
        public void onMemberLeave(String groupID, V2TIMGroupMemberInfo member) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
            makeaddGroupListenerEventData("onMemberLeave",data,"");
        }

        @Override
        public void onMemberInvited(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<memberList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
            }
            data.put("memberList",list);
            makeaddGroupListenerEventData("onMemberInvited",data,"");
        }

        @Override
        public void onMemberKicked(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<memberList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
            }
            data.put("memberList",list);
            makeaddGroupListenerEventData("onMemberKicked",data,"");
        }

        @Override
        public void onMemberInfoChanged(String groupID, List<V2TIMGroupMemberChangeInfo> v2TIMGroupMemberChangeInfoList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<v2TIMGroupMemberChangeInfoList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberChangeInfoToMap(v2TIMGroupMemberChangeInfoList.get(i)));
            }
            data.put("groupMemberChangeInfoList",list);
            makeaddGroupListenerEventData("onMemberInfoChanged",data,"");
        }

        @Override
        public void onGroupCreated(String groupID) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            makeaddGroupListenerEventData("onGroupCreated",data,"");
        }

        @Override
        public void onGroupDismissed(String groupID, V2TIMGroupMemberInfo opUser) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            makeaddGroupListenerEventData("onGroupDismissed",data,"");
        }

        @Override
        public void onGroupRecycled(String groupID, V2TIMGroupMemberInfo opUser) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            makeaddGroupListenerEventData("onGroupRecycled",data,"");
        }

        @Override
        public void onGroupInfoChanged(String groupID, List<V2TIMGroupChangeInfo> changeInfos) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<changeInfos.size();i++){
                list.add(CommonUtil.convertV2TIMGroupChangeInfoToMap(changeInfos.get(i)));
            }
            data.put("groupChangeInfoList",list);
            makeaddGroupListenerEventData("onGroupInfoChanged",data,"");
        }

        @Override
        public void onReceiveJoinApplication(String groupID, V2TIMGroupMemberInfo member, String opReason) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("member",CommonUtil.convertV2TIMGroupMemberInfoToMap(member));
            data.put("opReason",opReason);
            makeaddGroupListenerEventData("onReceiveJoinApplication",data,"");
        }

        @Override
        public void onApplicationProcessed(String groupID, V2TIMGroupMemberInfo opUser, boolean isAgreeJoin, String opReason) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            data.put("isAgreeJoin",isAgreeJoin);
            data.put("opReason",opReason);
            makeaddGroupListenerEventData("onApplicationProcessed",data,"");
        }

        @Override
        public void onGrantAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<memberList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
            }
            data.put("memberList",list);
            makeaddGroupListenerEventData("onGrantAdministrator",data,"");
        }

        @Override
        public void onRevokeAdministrator(String groupID, V2TIMGroupMemberInfo opUser, List<V2TIMGroupMemberInfo> memberList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("opUser",CommonUtil.convertV2TIMGroupMemberInfoToMap(opUser));
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for (int i = 0;i<memberList.size();i++){
                list.add(CommonUtil.convertV2TIMGroupMemberInfoToMap(memberList.get(i)));
            }
            data.put("memberList",list);
            makeaddGroupListenerEventData("onRevokeAdministrator",data,"");
        }

        @Override
        public void onQuitFromGroup(String groupID) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);

            makeaddGroupListenerEventData("onQuitFromGroup",data,"");
        }

        @Override
        public void onReceiveRESTCustomData(String groupID, byte[] customData) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("customData",customData == null ? "" : new String(customData));
            makeaddGroupListenerEventData("onReceiveRESTCustomData",data,"");
        }

        @Override
        public void onGroupAttributeChanged(String groupID, Map<String, String> groupAttributeMap) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("groupAttributeMap",groupAttributeMap);
            makeaddGroupListenerEventData("onGroupAttributeChanged",data,"");
        }

        @Override
        public void onTopicCreated(String groupID, String topicID) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("topicID",topicID);
            makeaddGroupListenerEventData("onTopicCreated",data,"");
        }

        @Override
        public void onTopicDeleted(String groupID, List<String> topicIDList) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("topicIDList",topicIDList);
            makeaddGroupListenerEventData("onTopicDeleted",data,"");
        }

        @Override
        public void onTopicInfoChanged(String groupID, V2TIMTopicInfo topicInfo) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("topicInfo",CommonUtil.convertV2TIMTopicInfoToMap(topicInfo));
            makeaddGroupListenerEventData("onTopicInfoChanged",data,"");
        }
        @Override
        public void onGroupCounterChanged (String groupID, String key, long newValue) {
            HashMap<String,Object> data = new HashMap<String,Object>();
            data.put("groupID",groupID);
            data.put("key",key);
            data.put("value",newValue);
            makeaddGroupListenerEventData("onGroupCounterChanged",data,"");
        }

    };
    private static LinkedList<String> groupListenerUuidList = new LinkedList<String>();
    public void addGroupListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        int size  = groupListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer groupListenerUuidList is empty . add listener.");
            V2TIMManager.getInstance().addGroupListener(groupListenerv2);
        }else{
            System.out.println("current adapter layer groupListenerUuidList size is " + size);
        }
        groupListenerUuidList.add(listenerUuid);
        result.success("addGroupListener success");
    }
    public void setGroupListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        int size  = groupListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer groupListenerUuidList is empty . add listener.");
            V2TIMManager.getInstance().addGroupListener(groupListenerv2);
        }else{
            System.out.println("current adapter layer groupListenerUuidList size is " + size);
        }
        groupListenerUuidList.add(listenerUuid);
        result.success("addGroupListener success");
    }
    public void createGroup(final MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                String groupType = methodCall.argument("groupType");
                String groupID = methodCall.argument("groupID");
                String groupName = methodCall.argument("groupName");
                V2TIMManager.getInstance().createGroup(groupType, groupID, groupName, new V2TIMValueCallback<String>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }
                    @Override
                    public void onSuccess(String s) {
                        CommonUtil.returnSuccess(result,s);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }
    public void joinGroup(final MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                String groupID = methodCall.argument("groupID");
                String message = methodCall.argument("message");
                V2TIMManager.getInstance().joinGroup(groupID, message, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });


    }
    public void quitGroup(final MethodCall methodCall, final MethodChannel.Result result) {
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                // 群ID
                String groupID = methodCall.argument("groupID");

                V2TIMManager.getInstance().quitGroup(groupID, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void dismissGroup(MethodCall methodCall, final MethodChannel.Result result){
        String groupID = this.getParam(methodCall,result,"groupID");
        V2TIMManager.getInstance().dismissGroup(groupID, new V2TIMCallback() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }
        });
    }
    public void getUsersInfo(final MethodCall methodCall, final MethodChannel.Result result){

        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().getUsersInfo(userIDList, new V2TIMValueCallback<List<V2TIMUserFullInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMUserFullInfo> v2TIMUserFullInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for(int i = 0;i<v2TIMUserFullInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMUserFullInfoToMap(v2TIMUserFullInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });

    }
    public void setSelfInfo(final MethodCall methodCall, final MethodChannel.Result result) {
        final String nickName = methodCall.argument("nickName");
        final  String faceUrl = methodCall.argument("faceUrl");
        final  String selfSignature = methodCall.argument("selfSignature");
        final Integer gender = methodCall.argument("gender");
        final Integer allowType = methodCall.argument("allowType");
        final Integer birthday = methodCall.argument("birthday");
        final Integer level = methodCall.argument("level");
        final Integer role = methodCall.argument("role");
        final HashMap<String,String> customInfoString = methodCall.argument("customInfo");

        final V2TIMUserFullInfo userFullInfo = new V2TIMUserFullInfo();

        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                if(nickName!=null){
                    userFullInfo.setNickname(nickName);
                }
                if(faceUrl!=null){
                    userFullInfo.setFaceUrl(faceUrl);
                }
                if(selfSignature!=null){
                    userFullInfo.setSelfSignature(selfSignature);
                }
                if(gender!=null){
                    userFullInfo.setGender(gender);
                }
                if(birthday!=null){
                    userFullInfo.setBirthday(birthday);
                }
                if(allowType!=null){
                    userFullInfo.setAllowType(allowType);
                }
                if(level!=null){
                    userFullInfo.setLevel(level);
                }
                if(role!=null){
                    userFullInfo.setRole(role);
                }
                HashMap<String, byte[]> newCustomHashMap = userFullInfo.getCustomInfo();
                if(CommonUtil.getParam(methodCall,result,"customInfo")!=null){
                    if(!customInfoString.isEmpty()){
                        Iterator<String> iterator = customInfoString.keySet().iterator();
                        while (iterator.hasNext()) {
                            String key = iterator.next();
                            String value = customInfoString.get(key);
                            newCustomHashMap.put(key,value.getBytes());
                        }
                    }
                    userFullInfo.setCustomInfo(newCustomHashMap);
                }
                System.out.println(userFullInfo);
                V2TIMManager.getInstance().setSelfInfo(userFullInfo, new V2TIMCallback() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess() {
                        CommonUtil.returnSuccess(result,null);
                    }
                });
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });

    }
    public void callExperimentalAPI(MethodCall methodCall, final MethodChannel.Result result){
        String api = methodCall.argument("api");
        Object param = methodCall.argument("param");
        V2TIMManager.getInstance().callExperimentalAPI(api, param, new V2TIMValueCallback<Object>() {

            @Override
            public void onSuccess(Object o) {
                CommonUtil.returnSuccess(result,o);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void checkAbility(MethodCall methodCall, final MethodChannel.Result result){
        CommonUtil.checkAbility(methodCall, new AbCallback() {
            @Override
            public void onAbSuccess() {
                CommonUtil.returnSuccess(result,1);
            }

            @Override
            public void onAbError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void subscribeUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().subscribeUserStatus(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void unsubscribeUserStatus(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().unsubscribeUserStatus(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void subscribeUserInfo(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().subscribeUserInfo(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void unsubscribeUserInfo(MethodCall methodCall, final MethodChannel.Result result){
        List<String> userIDList = methodCall.argument("userIDList");
        V2TIMManager.getInstance().unsubscribeUserInfo(userIDList, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void uikitTrace(MethodCall methodCall, final MethodChannel.Result result){
        String trace = methodCall.argument("trace");
        try {
            final JSONObject param = new JSONObject();
            param.put("logLevel", 5);
            param.put("fileName", "IMFlutterUIKit");
            param.put("logContent", trace);
            Thread  thread = new Thread(){
                @Override
                public void run() {
                    super.run();
                    V2TIMManager.getInstance().callExperimentalAPI("writeLog", param.toString(), new V2TIMValueCallback<Object>() {
                        @Override
                        public void onError(int code, String desc) {
                            result.success("");
                        }

                        @Override
                        public void onSuccess(Object object) {
                            result.success("");
                        }
                    });

                }
            };
            thread.start();

        } catch (Exception e) {
            result.success("");
            e.printStackTrace();
        }
    }

    private <T> T getParam(MethodCall methodCall, MethodChannel.Result result, String param) {
        T par = methodCall.argument(param);
        if (par == null) {
            Log.w(TAG, "init: Cannot find parameter `" + param + "` or `" + param + "` is null!");
            throw new RuntimeException("Cannot find parameter `" + param + "` or `" + param + "` is null!");
        }
        return par;
    }
}
