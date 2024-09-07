package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMFollowInfo;
import com.tencent.imsdk.v2.V2TIMFollowOperationResult;
import com.tencent.imsdk.v2.V2TIMFollowTypeCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendAddApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplication;
import com.tencent.imsdk.v2.V2TIMFriendApplicationResult;
import com.tencent.imsdk.v2.V2TIMFriendCheckResult;
import com.tencent.imsdk.v2.V2TIMFriendGroup;
import com.tencent.imsdk.v2.V2TIMFriendInfo;
import com.tencent.imsdk.v2.V2TIMFriendInfoResult;
import com.tencent.imsdk.v2.V2TIMFriendOperationResult;
import com.tencent.imsdk.v2.V2TIMFriendSearchParam;
import com.tencent.imsdk.v2.V2TIMFriendshipListener;
import com.tencent.imsdk.v2.V2TIMGroupMemberSearchParam;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfo;
import com.tencent.imsdk.v2.V2TIMOfficialAccountInfoResult;
import com.tencent.imsdk.v2.V2TIMUserFullInfo;
import com.tencent.imsdk.v2.V2TIMUserInfoResult;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;


public class FriendshipManager {
    private static List<MethodChannel> channels = new LinkedList<>();
    private static  HashMap<String, V2TIMFriendshipListener> friendshipListenerList= new HashMap();
    public FriendshipManager(MethodChannel _channel){
        FriendshipManager.channels.add(_channel);
    }

    public static void cleanChannels(){
        channels = new LinkedList<>();
    }
    public void setFriendListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        int size  = friendListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer friendListenerUuidList is empty . add listener.");
            V2TIMManager.getFriendshipManager().addFriendListener(friendshipListenerv2);
        }else{
            System.out.println("current adapter layer friendListenerUuidList size is " + size);
        }
        friendListenerUuidList.add(listenerUuid);
        result.success("setFriendListener success");
    }
    public static  V2TIMFriendshipListener friendshipListenerv2 = new V2TIMFriendshipListener() {
        @Override
        public void onFriendApplicationListAdded(List<V2TIMFriendApplication> applicationList) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i= 0;i<applicationList.size();i++){
                list.add(CommonUtil.convertV2TIMFriendApplicationToMap(applicationList.get(i)));
            }

            makeFriendListenerEventData("onFriendApplicationListAdded",list,"");
        }

        @Override
        public void onFriendApplicationListDeleted(List<String> userIDList) {

            makeFriendListenerEventData("onFriendApplicationListDeleted",userIDList,"");
        }

        @Override
        public void onFriendApplicationListRead() {
            makeFriendListenerEventData("onFriendApplicationListRead",null,"");
        }

        @Override
        public void onFriendListAdded(List<V2TIMFriendInfo> users) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i= 0;i<users.size();i++){
                list.add(CommonUtil.convertV2TIMFriendInfoToMap(users.get(i)));
            }
            makeFriendListenerEventData("onFriendListAdded",list,"");
        }

        @Override
        public void onFriendListDeleted(List<String> userList) {
            makeFriendListenerEventData("onFriendListDeleted",userList,"");
        }

        @Override
        public void onBlackListAdd(List<V2TIMFriendInfo> infoList) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i= 0;i<infoList.size();i++){
                list.add(CommonUtil.convertV2TIMFriendInfoToMap(infoList.get(i)));
            }
            makeFriendListenerEventData("onBlackListAdd",list,"");
        }

        @Override
        public void onBlackListDeleted(List<String> userList) {
            makeFriendListenerEventData("onBlackListDeleted",userList,"");
        }

        @Override
        public void onFriendInfoChanged(List<V2TIMFriendInfo> infoList) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i= 0;i<infoList.size();i++){
                list.add(CommonUtil.convertV2TIMFriendInfoToMap(infoList.get(i)));
            }
            makeFriendListenerEventData("onFriendInfoChanged",list,"");
        }

        @Override
        public void onMutualFollowersListChanged(List<V2TIMUserFullInfo> userInfoList, boolean isAdd) {
            Map<String,Object> res = new HashMap<>();
            res.put("isAdd",isAdd);
            res.put("userInfoList",CommonUtil.convertV2TIMUserFullInfoListToMap(userInfoList));
            makeFriendListenerEventData("onMutualFollowersListChanged", res,"");
        }

        @Override
        public void onMyFollowersListChanged(List<V2TIMUserFullInfo> userInfoList, boolean isAdd) {

            Map<String,Object> res = new HashMap<>();
            res.put("isAdd",isAdd);
            res.put("userInfoList",CommonUtil.convertV2TIMUserFullInfoListToMap(userInfoList));
            makeFriendListenerEventData("onMyFollowersListChanged",res,"");
        }

        @Override
        public void onMyFollowingListChanged(List<V2TIMUserFullInfo> userInfoList, boolean isAdd) {
            Map<String,Object> res = new HashMap<>();
            res.put("isAdd",isAdd);
            res.put("userInfoList",CommonUtil.convertV2TIMUserFullInfoListToMap(userInfoList));
            makeFriendListenerEventData("onMyFollowingListChanged",res,"");
        }

        @Override
        public void onOfficialAccountDeleted(String officialAccountID) {
            makeFriendListenerEventData("onOfficialAccountDeleted",officialAccountID,"");
        }

        @Override
        public void onOfficialAccountInfoChanged(V2TIMOfficialAccountInfo officialAccountInfo) {
            makeFriendListenerEventData("onOfficialAccountInfoChanged",CommonUtil.convertV2TIMOfficialAccountInfoToMap(officialAccountInfo),"");
        }

        @Override
        public void onOfficialAccountSubscribed(V2TIMOfficialAccountInfo officialAccountInfo) {
            makeFriendListenerEventData("onOfficialAccountSubscribed",CommonUtil.convertV2TIMOfficialAccountInfoToMap(officialAccountInfo),"");
        }

        @Override
        public void onOfficialAccountUnsubscribed(String officialAccountID) {
            makeFriendListenerEventData("onOfficialAccountUnsubscribed",officialAccountID,"");
        }
    };
    private static LinkedList<String> friendListenerUuidList = new LinkedList<String>();
    public void addFriendListener (MethodCall methodCall, final MethodChannel.Result result){

        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        int size  = friendListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer friendListenerUuidList is empty . add listener.");
            V2TIMManager.getFriendshipManager().addFriendListener(friendshipListenerv2);
        }else{
            System.out.println("current adapter layer friendListenerUuidList size is " + size);
        }
        friendListenerUuidList.add(listenerUuid);
        result.success("addFriendListener success");
    }
    public void removeFriendListener(MethodCall call,final MethodChannel.Result result){

        final String listenerUuid = CommonUtil.getParam(call,result,"listenerUuid");

        if (!listenerUuid.isEmpty()) {

            friendListenerUuidList.remove(listenerUuid);
            System.out.println("removeGroupListener current message listener size id" + friendListenerUuidList.size());
            if(friendListenerUuidList.isEmpty()){
                V2TIMManager.getFriendshipManager().removeFriendListener(friendshipListenerv2);
            }
            result.success("removeGroupListener is done");
        } else {
            friendListenerUuidList.clear();
            V2TIMManager.getFriendshipManager().removeFriendListener(friendshipListenerv2);
            result.success("all groupListener is removed");
        }
    }
    private static  <T> void  makeFriendListenerEventData(String type,T data, String listenerUuid){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"friendListener",type,data, listenerUuid);
        }

    }
    public void getFriendList(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getFriendshipManager().getFriendList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendInfoToMap(v2TIMFriendInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void getFriendsInfo(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().getFriendsInfo(userIDList, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendInfoResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendInfoResultToMap(v2TIMFriendInfoResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void setFriendInfo(MethodCall methodCall,final MethodChannel.Result result){
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        String friendRemark = CommonUtil.getParam(methodCall,result,"friendRemark");
        HashMap<String, String> customHashMap = CommonUtil.getParam(methodCall,result,"friendCustomInfo");
        V2TIMFriendInfo info = new V2TIMFriendInfo();
        info.setUserID(userID);
        if(friendRemark!=null){
            info.setFriendRemark(friendRemark);
        }
        if(CommonUtil.getParam(methodCall,result,"friendCustomInfo")!=null){
            HashMap<String, byte[]> newCustomHashMap = new HashMap<>();
            if(!customHashMap.isEmpty()){
                for(String key : customHashMap.keySet() ){
                    String value = customHashMap.get(key);
                    newCustomHashMap.put(key,value.getBytes());
                }
                info.setFriendCustomInfo(newCustomHashMap);
            }
        }
        V2TIMManager.getFriendshipManager().setFriendInfo(info, new V2TIMCallback() {
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
    public void addFriend(MethodCall methodCall,final MethodChannel.Result result){
        String userID = CommonUtil.getParam(methodCall,result,"userID");
        String remark = CommonUtil.getParam(methodCall,result,"remark");
        String friendGroup = CommonUtil.getParam(methodCall,result,"friendGroup");
        String addWording = CommonUtil.getParam(methodCall,result,"addWording");
        String addSource = CommonUtil.getParam(methodCall,result,"addSource");
        int addType = CommonUtil.getParam(methodCall,result,"addType");
        V2TIMFriendAddApplication info = new V2TIMFriendAddApplication(userID);
        info.setUserID(userID);
        if(remark!=null){
            info.setFriendRemark(remark);
        }
        if(friendGroup!=null){
            info.setFriendGroup(friendGroup);
        }
        if(addWording!=null){
            info.setAddWording(addWording);
        }
        if(addSource!=null){
            info.setAddSource(addSource);
        }
        if(CommonUtil.getParam(methodCall,result,"addType")!=null){
            info.setAddType(addType);
        }
        V2TIMManager.getFriendshipManager().addFriend(info, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
            }
        });
    }
    public void deleteFromFriendList(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        int deleteType = CommonUtil.getParam(methodCall,result,"deleteType");
        V2TIMManager.getFriendshipManager().deleteFromFriendList(userIDList, deleteType, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void checkFriend(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        int checkType = CommonUtil.getParam(methodCall,result,"checkType");


        V2TIMManager.getFriendshipManager().checkFriend(userIDList, checkType, new V2TIMValueCallback<List<V2TIMFriendCheckResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendCheckResult> v2TIMFriendCheckResults) {
                List <HashMap<String,Object>> ress = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMFriendCheckResults.size();i++){
                    ress.add(CommonUtil.convertV2TIMFriendCheckResultToMap(v2TIMFriendCheckResults.get(i)));
                }
                CommonUtil.returnSuccess(result,ress);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getFriendApplicationList(MethodCall methodCall,final MethodChannel.Result result){
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFriendApplicationResultToMap(v2TIMFriendApplicationResult));
            }
        });
    }
    public void acceptFriendApplication(MethodCall methodCall,final MethodChannel.Result result){
        final int responseType = CommonUtil.getParam(methodCall,result,"responseType");
        final String userID = CommonUtil.getParam(methodCall,result,"userID");
        final int type = CommonUtil.getParam(methodCall,result,"type");
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
               List<V2TIMFriendApplication> list =  v2TIMFriendApplicationResult.getFriendApplicationList();
                V2TIMFriendApplication app = null;
                System.out.println("当前所有申请:"+list.size()+",userID:"+userID+",responseType:"+responseType+",type:"+type);
               for(int i =0;i<list.size();i++){
                   System.out.println(list.get(i).getUserID()+","+list.get(i).getType());
                   if(list.get(i).getUserID().equals(userID) && list.get(i).getType() == type){
                       app = list.get(i);
                       break;
                   }
               }
               if(app == null){
                   CommonUtil.returnError(result,-1,"application get error");
                   return;
               }
                V2TIMManager.getFriendshipManager().acceptFriendApplication(app, responseType, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                        CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
                    }
                });
            }
        });

    }
    public void refuseFriendApplication(MethodCall methodCall,final MethodChannel.Result result){
        final String userID = CommonUtil.getParam(methodCall,result,"userID");
        final int type = CommonUtil.getParam(methodCall,result,"type");
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                List<V2TIMFriendApplication> list =  v2TIMFriendApplicationResult.getFriendApplicationList();
                 V2TIMFriendApplication app = new V2TIMFriendApplication();
                for(int i =0;i<list.size();i++){
                    if(list.get(i).getUserID().equals(userID) && list.get(i).getType() == type){
                        app = list.get(i);
                        break;
                    }
                }
                V2TIMManager.getFriendshipManager().refuseFriendApplication(app, new V2TIMValueCallback<V2TIMFriendOperationResult>() {
                    @Override
                    public void onError(int i, String s) {
                        CommonUtil.returnError(result,i,s);
                    }

                    @Override
                    public void onSuccess(V2TIMFriendOperationResult v2TIMFriendOperationResult) {
                        CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResult));
                    }
                });
            }
        });
    }
    public void deleteFriendApplication(MethodCall methodCall,final MethodChannel.Result result){
        final String userID = CommonUtil.getParam(methodCall,result,"userID");
        final int type = CommonUtil.getParam(methodCall,result,"type");
        V2TIMManager.getFriendshipManager().getFriendApplicationList(new V2TIMValueCallback<V2TIMFriendApplicationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMFriendApplicationResult v2TIMFriendApplicationResult) {
                List<V2TIMFriendApplication> list =  v2TIMFriendApplicationResult.getFriendApplicationList();
                V2TIMFriendApplication app;
                for(int i =0;i<list.size();i++){
                    if(list.get(i).getUserID().equals(userID) && list.get(i).getType() == type){
                        app = list.get(i);
                        V2TIMManager.getFriendshipManager().deleteFriendApplication(app, new V2TIMCallback() {
                            @Override
                            public void onError(int i, String s) {
                                CommonUtil.returnError(result,i,s);
                            }

                            @Override
                            public void onSuccess() {
                                CommonUtil.returnSuccess(result,null);
                            }
                        });
                        break;
                    }
                }
            }
        });
    }
    public void setFriendApplicationRead(MethodCall methodCall,final MethodChannel.Result result){
        V2TIMManager.getFriendshipManager().setFriendApplicationRead(new V2TIMCallback() {
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
    public void addToBlackList(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().addToBlackList(userIDList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void deleteFromBlackList(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().deleteFromBlackList(userIDList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void getBlackList(MethodCall methodCall,final MethodChannel.Result result){
        V2TIMManager.getFriendshipManager().getBlackList(new V2TIMValueCallback<List<V2TIMFriendInfo>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendInfo> v2TIMFriendInfos) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendInfos.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendInfoToMap(v2TIMFriendInfos.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void createFriendGroup(MethodCall methodCall,final MethodChannel.Result result){
        String groupName = CommonUtil.getParam(methodCall,result,"groupName");
        List< String > userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().createFriendGroup(groupName, userIDList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void getFriendGroups(MethodCall methodCall,final MethodChannel.Result result){
        List< String > groupNameList = CommonUtil.getParam(methodCall,result,"groupNameList");
        V2TIMManager.getFriendshipManager().getFriendGroups(groupNameList, new V2TIMValueCallback<List<V2TIMFriendGroup>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendGroup> v2TIMFriendGroups) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendGroups.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendGroupToMap(v2TIMFriendGroups.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void deleteFriendGroup(MethodCall methodCall,final MethodChannel.Result result){
        List< String > groupNameList = CommonUtil.getParam(methodCall,result,"groupNameList");
        V2TIMManager.getFriendshipManager().deleteFriendGroup(groupNameList, new V2TIMCallback() {
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
    public void renameFriendGroup(MethodCall methodCall,final MethodChannel.Result result){
        String oldName = CommonUtil.getParam(methodCall,result,"oldName");
        String newName = CommonUtil.getParam(methodCall,result,"newName");
        V2TIMManager.getFriendshipManager().renameFriendGroup(oldName, newName, new V2TIMCallback() {
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
    public void addFriendsToFriendGroup(MethodCall methodCall,final MethodChannel.Result result){
        String groupName = CommonUtil.getParam(methodCall,result,"groupName");
        List< String > userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().addFriendsToFriendGroup(groupName, userIDList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void deleteFriendsFromFriendGroup(MethodCall methodCall,final MethodChannel.Result result){
        String groupName =  CommonUtil.getParam(methodCall,result,"groupName");
        List< String > userIDList  = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().deleteFriendsFromFriendGroup(groupName, userIDList, new V2TIMValueCallback<List<V2TIMFriendOperationResult>>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(List<V2TIMFriendOperationResult> v2TIMFriendOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
                for (int i = 0;i<v2TIMFriendOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMFriendOperationResultToMap(v2TIMFriendOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }
        });
    }
    public void searchFriends(MethodCall methodCall,final MethodChannel.Result result){
        HashMap<String,Object> param =  CommonUtil.getParam(methodCall,result,"searchParam");
        V2TIMFriendSearchParam  searchParam = new V2TIMFriendSearchParam();
        if(param.get("keywordList")!=null){
            searchParam.setKeywordList((List<String>) param.get("keywordList"));
        }

        if(param.get("isSearchUserID")!=null){
            searchParam.setSearchUserID((Boolean) param.get("isSearchUserID"));
        }
        if(param.get("isSearchNickName")!=null){
            searchParam.setSearchNickName((Boolean) param.get("isSearchNickName"));
        }
        if(param.get("isSearchRemark")!=null){
            searchParam.setSearchRemark((Boolean) param.get("isSearchRemark"));
        }
        V2TIMManager.getFriendshipManager().searchFriends(searchParam, new V2TIMValueCallback<List<V2TIMFriendInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMFriendInfoResult> v2TIMFriendInfoResults) {
                LinkedList<HashMap<String,Object>> infoList = new LinkedList<>();
                for(int i = 0;i<v2TIMFriendInfoResults.size();i++){
                    infoList.add(CommonUtil.convertV2TIMFriendInfoResultToMap(v2TIMFriendInfoResults.get(i)));
                }
                CommonUtil.returnSuccess(result,infoList);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void subscribeOfficialAccount(MethodCall methodCall,final MethodChannel.Result result){
        String officialAccountID = CommonUtil.getParam(methodCall,result,"officialAccountID");
        V2TIMManager.getFriendshipManager().subscribeOfficialAccount(officialAccountID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void unsubscribeOfficialAccount(MethodCall methodCall,final MethodChannel.Result result){

        String officialAccountID = CommonUtil.getParam(methodCall,result,"officialAccountID");
        V2TIMManager.getFriendshipManager().unsubscribeOfficialAccount(officialAccountID, new V2TIMCallback() {
            @Override
            public void onSuccess() {
                CommonUtil.returnSuccess(result,null);
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getOfficialAccountsInfo(MethodCall methodCall,final MethodChannel.Result result){

        List<String> officialAccountIDList = CommonUtil.getParam(methodCall,result,"officialAccountIDList");
        V2TIMManager.getFriendshipManager().getOfficialAccountsInfo(officialAccountIDList, new V2TIMValueCallback<List<V2TIMOfficialAccountInfoResult>>() {
            @Override
            public void onSuccess(List<V2TIMOfficialAccountInfoResult> v2TIMOfficialAccountInfoResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMOfficialAccountInfoResultListToMap(v2TIMOfficialAccountInfoResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void followUser(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().followUser(userIDList, new V2TIMValueCallback<List<V2TIMFollowOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMFollowOperationResult> v2TIMFollowOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFollowOperationResultListToMap(v2TIMFollowOperationResults));

            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void unfollowUser(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().unfollowUser(userIDList, new V2TIMValueCallback<List<V2TIMFollowOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMFollowOperationResult> v2TIMFollowOperationResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFollowOperationResultListToMap(v2TIMFollowOperationResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getMyFollowingList(MethodCall methodCall,final MethodChannel.Result result){
        String nextCursor = CommonUtil.getParam(methodCall,result,"nextCursor");
        V2TIMManager.getFriendshipManager().getMyFollowingList(nextCursor, new V2TIMValueCallback<V2TIMUserInfoResult>() {
            @Override
            public void onSuccess(V2TIMUserInfoResult v2TIMUserInfoResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMUserInfoResultToMap(v2TIMUserInfoResult));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getMyFollowersList(MethodCall methodCall,final MethodChannel.Result result){
        String nextCursor = CommonUtil.getParam(methodCall,result,"nextCursor");
        V2TIMManager.getFriendshipManager().getMyFollowersList(nextCursor, new V2TIMValueCallback<V2TIMUserInfoResult>() {
            @Override
            public void onSuccess(V2TIMUserInfoResult v2TIMUserInfoResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMUserInfoResultToMap(v2TIMUserInfoResult));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    
    public void getMutualFollowersList(MethodCall methodCall,final MethodChannel.Result result){
        String nextCursor = CommonUtil.getParam(methodCall,result,"nextCursor");
        V2TIMManager.getFriendshipManager().getMutualFollowersList(nextCursor, new V2TIMValueCallback<V2TIMUserInfoResult>() {
            @Override
            public void onSuccess(V2TIMUserInfoResult v2TIMUserInfoResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMUserInfoResultToMap(v2TIMUserInfoResult));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void getUserFollowInfo(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().getUserFollowInfo(userIDList, new V2TIMValueCallback<List<V2TIMFollowInfo>>() {
            @Override
            public void onSuccess(List<V2TIMFollowInfo> v2TIMFollowInfos) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFollowInfoListToMap(v2TIMFollowInfos));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }
    public void checkFollowType(MethodCall methodCall,final MethodChannel.Result result){
        List<String> userIDList = CommonUtil.getParam(methodCall,result,"userIDList");
        V2TIMManager.getFriendshipManager().checkFollowType(userIDList, new V2TIMValueCallback<List<V2TIMFollowTypeCheckResult>>() {
            @Override
            public void onSuccess(List<V2TIMFollowTypeCheckResult> v2TIMFollowTypeCheckResults) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMFollowTypeCheckResultListToMap(v2TIMFollowTypeCheckResults));
            }

            @Override
            public void onError(int code, String desc) {
                CommonUtil.returnError(result,code,desc);
            }
        });
    }


}
