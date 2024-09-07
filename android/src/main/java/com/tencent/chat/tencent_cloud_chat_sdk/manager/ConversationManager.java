package com.tencent.chat.tencent_cloud_chat_sdk.manager;

import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;
import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMConversationListFilter;
import com.tencent.imsdk.v2.V2TIMConversationListener;
import com.tencent.imsdk.v2.V2TIMConversationOperationResult;
import com.tencent.imsdk.v2.V2TIMConversationResult;
import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ConversationManager {
    private static List<MethodChannel> channels = new LinkedList<>();
    private static  HashMap<String, V2TIMConversationListener> conversationListenerList= new HashMap();
    public ConversationManager(MethodChannel _channel){
        ConversationManager.channels.add(_channel);
    }
    public static void cleanChannels(){
        channels = new LinkedList<>();
    }
    public  void setConversationListener(MethodCall methodCall, final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(methodCall,result,"listenerUuid");
        int size  = conversationListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer conversationListenerUuidList is empty . add listener.");
            V2TIMManager.getConversationManager().addConversationListener(conversationListerv2);
        }else{
            System.out.println("current adapter layer conversationListenerUuidList size is " + size);
        }
        conversationListenerUuidList.add(listenerUuid);
        result.success("setConversationListener success");
    }
    public void removeConversationListener(MethodCall call,final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(call,result,"listenerUuid");

        if (!listenerUuid.isEmpty()) {

            conversationListenerUuidList.remove(listenerUuid);
            System.out.println("removeGroupListener current message listener size id" + conversationListenerUuidList.size());
            if(conversationListenerUuidList.isEmpty()){
                V2TIMManager.getConversationManager().removeConversationListener(conversationListerv2);
            }
            result.success("removeGroupListener is done");
        } else {
            conversationListenerUuidList.clear();
            V2TIMManager.getConversationManager().removeConversationListener(conversationListerv2);
            result.success("all groupListener is removed");
        }
    }
    public static V2TIMConversationListener conversationListerv2 = new V2TIMConversationListener() {
        @Override
        public void onSyncServerStart() {
            makeConversationListenerEventData("onSyncServerStart",null, "");
        }

        @Override
        public void onSyncServerFinish() {
            makeConversationListenerEventData("onSyncServerFinish",null, "");
        }

        @Override
        public void onSyncServerFailed() {
            makeConversationListenerEventData("onSyncServerFailed",null, "");
        }

        @Override
        public void onNewConversation(List<V2TIMConversation> conversationList) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i = 0;i<conversationList.size();i++){
                list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
            }
            makeConversationListenerEventData("onNewConversation",list, "");
        }

        @Override
        public void onConversationChanged(List<V2TIMConversation> conversationList) {
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i = 0;i<conversationList.size();i++){
                list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
            }
            makeConversationListenerEventData("onConversationChanged",list, "");
        }
        @Override
        public void onTotalUnreadMessageCountChanged(long totalUnreadCount) {
            makeConversationListenerEventData("onTotalUnreadMessageCountChanged",totalUnreadCount, "");
        }

        @Override
        public void onConversationGroupCreated(String groupName, List<V2TIMConversation> conversationList) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupName",groupName);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i = 0;i<conversationList.size();i++){
                list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
            }
            data.put("conversationList",list);
            makeConversationListenerEventData("onConversationGroupCreated",data, "");
        }

        @Override
        public void onConversationGroupDeleted(String groupName) {
            makeConversationListenerEventData("onConversationGroupDeleted",groupName, "");
        }

        @Override
        public void onConversationGroupNameChanged(String oldName, String newName) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("oldName",oldName);
            data.put("newName",newName);
            makeConversationListenerEventData("onConversationGroupNameChanged",data, "");
        }

        @Override
        public void onConversationsAddedToGroup(String groupName, List<V2TIMConversation> conversationList) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupName",groupName);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i = 0;i<conversationList.size();i++){
                list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
            }
            data.put("conversationList",list);
            makeConversationListenerEventData("onConversationsAddedToGroup",data, "");
        }

        @Override
        public void onConversationsDeletedFromGroup(String groupName, List<V2TIMConversation> conversationList) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("groupName",groupName);
            LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String,Object>>();
            for(int i = 0;i<conversationList.size();i++){
                list.add(CommonUtil.convertV2TIMConversationToMap(conversationList.get(i)));
            }
            data.put("conversationList",list);
            makeConversationListenerEventData("onConversationsDeletedFromGroup",data, "");
        }

        @Override
        public void onConversationDeleted(List<String> conversationIDList) {

            makeConversationListenerEventData("onConversationDeleted",conversationIDList, "");
        }

        @Override
        public void onUnreadMessageCountChangedByFilter(V2TIMConversationListFilter filter, long totalUnreadCount) {
            HashMap<String,Object> data = new HashMap<>();
            data.put("filter",CommonUtil.convertV2TIMConversationListFilterToMap(filter));
            data.put("totalUnreadCount",totalUnreadCount);
            makeConversationListenerEventData("onUnreadMessageCountChangedByFilter",data, "");
        }
    };
    private static LinkedList<String> conversationListenerUuidList = new LinkedList<String>();
    public void  addConversationListener(MethodCall call,final MethodChannel.Result result){
        final String listenerUuid = CommonUtil.getParam(call,result,"listenerUuid");
        int size  = conversationListenerUuidList.size();
        if(size == 0){
            System.out.println("current adapter layer conversationListenerUuidList is empty . add listener.");
            V2TIMManager.getConversationManager().addConversationListener(conversationListerv2);
        }else{
            System.out.println("current adapter layer conversationListenerUuidList size is " + size);
        }
        conversationListenerUuidList.add(listenerUuid);
        result.success("addConversationListener success");
    }


    public  void  getConversation(MethodCall methodCall,final  MethodChannel.Result result){
        String conversationID = CommonUtil.getParam(methodCall,result,"conversationID");
        V2TIMManager.getConversationManager().getConversation(conversationID, new V2TIMValueCallback<V2TIMConversation>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMConversation v2TIMConversation) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationToMap(v2TIMConversation));
            }
        });
    }
    private static <T> void  makeConversationListenerEventData(String type,T data, String listenerUuid){
        for (MethodChannel channel : channels) {
            CommonUtil.emitEvent(channel,"conversationListener",type,data, listenerUuid);
        }
    }
    public void getConversationList(MethodCall methodCall, final MethodChannel.Result result){
        String nextSeq = CommonUtil.getParam(methodCall,result,"nextSeq");
        int count = CommonUtil.getParam(methodCall,result,"count");
        V2TIMManager.getConversationManager().getConversationList(Long.parseLong(nextSeq.equals("") ? "0": nextSeq), count, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }

            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationResultToMap(v2TIMConversationResult));
            }
        });
    }
    public void getConversationListByConversaionIds(MethodCall methodCall, final MethodChannel.Result result){
      List<String>  conversationIDList = CommonUtil.getParam(methodCall,result,"conversationIDList");
      V2TIMManager.getConversationManager().getConversationList(conversationIDList, new V2TIMValueCallback<List<V2TIMConversation>>() {
          @Override
          public void onSuccess(List<V2TIMConversation> v2TIMConversations) {
              LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
              for(int i = 0;i<v2TIMConversations.size();i++){
                  list.add(CommonUtil.convertV2TIMConversationToMap(v2TIMConversations.get(i)));
              }
              CommonUtil.returnSuccess(result,list);
          }

          @Override
          public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
          }
      });
    }
    public void pinConversation(MethodCall methodCall, final MethodChannel.Result result){
        String conversationID = CommonUtil.getParam(methodCall,result,"conversationID");
       boolean isPinned = CommonUtil.getParam(methodCall,result,"isPinned");
       V2TIMManager.getConversationManager().pinConversation(conversationID, isPinned, new V2TIMCallback() {
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
    public void getTotalUnreadMessageCount(MethodCall methodCall, final MethodChannel.Result result){
        V2TIMManager.getConversationManager().getTotalUnreadMessageCount(new V2TIMValueCallback<Long>() {
            @Override
            public void onSuccess(Long aLong) {
                CommonUtil.returnSuccess(result,aLong);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversation(MethodCall methodCall, final MethodChannel.Result result) {
        // session id
        String conversationID = CommonUtil.getParam(methodCall, result, "conversationID");
        V2TIMManager.getConversationManager().deleteConversation(conversationID, new V2TIMCallback() {
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
    public void setConversationDraft(MethodCall methodCall, final MethodChannel.Result result) {
        // session id
        String conversationID = CommonUtil.getParam(methodCall, result, "conversationID");
        String draftText = CommonUtil.getParam(methodCall, result, "draftText");
        if(draftText==""){
            draftText = null;
        }
        V2TIMManager.getConversationManager().setConversationDraft(conversationID,draftText, new V2TIMCallback() {
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
    public void setConversationCustomData(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String customData = CommonUtil.getParam(methodCall, result, "customData");
        V2TIMManager.getConversationManager().setConversationCustomData(conversationIDList, customData, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void getConversationListByFilter(MethodCall methodCall, final MethodChannel.Result result) {
        final Map<String,Object> filter = CommonUtil.getParam(methodCall,result,"filter");
        final long nextSeq = new Long((int)CommonUtil.getParam(methodCall,result,"nextSeq"));
        final  int count = CommonUtil.getParam(methodCall,result,"count");
        final V2TIMConversationListFilter filterNative = new V2TIMConversationListFilter();

        if(filter.get("conversationType")!=null){
            filterNative.setConversationType((Integer) filter.get("conversationType"));
        }

        if(filter.get("markType")!=null){
            filterNative.setMarkType((int)filter.get("markType"));
        }
        if(filter.get("conversationGroup")!=null){
            filterNative.setConversationGroup((String) filter.get("conversationGroup"));
        }
        if(filter.get("hasGroupAtInfo")!=null){
            filterNative.setHasGroupAtInfo((Boolean) filter.get("hasGroupAtInfo"));
        }
        if(filter.get("hasUnreadCount")!=null){
            filterNative.setHasUnreadCount((Boolean) filter.get("hasUnreadCount"));
        }
        V2TIMManager.getConversationManager().getConversationListByFilter(filterNative,nextSeq,count, new V2TIMValueCallback<V2TIMConversationResult>() {
            @Override
            public void onSuccess(V2TIMConversationResult v2TIMConversationResult) {
                CommonUtil.returnSuccess(result,CommonUtil.convertV2TIMConversationResultToMap(v2TIMConversationResult));
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });

    }
    public void getUnreadMessageCountByFilter(MethodCall methodCall, final MethodChannel.Result result) {
        final Map<String,Object> filter = CommonUtil.getParam(methodCall,result,"filter");
        final V2TIMConversationListFilter filterNative = new V2TIMConversationListFilter();

        if(filter.get("conversationType")!=null){
            filterNative.setConversationType((Integer) filter.get("conversationType"));
        }

        if(filter.get("markType")!=null){
            filterNative.setMarkType((int)filter.get("markType"));
        }
        if(filter.get("conversationGroup")!=null){
            filterNative.setConversationGroup((String) filter.get("conversationGroup"));
        }
        if(filter.get("hasGroupAtInfo")!=null){
            filterNative.setHasGroupAtInfo((Boolean) filter.get("hasGroupAtInfo"));
        }
        if(filter.get("hasUnreadCount")!=null){
            filterNative.setHasUnreadCount((Boolean) filter.get("hasUnreadCount"));
        }
        V2TIMManager.getConversationManager().getUnreadMessageCountByFilter(filterNative, new V2TIMValueCallback<Long>() {
            @Override
            public void onSuccess(Long aLong) {
                CommonUtil.returnSuccess(result,aLong);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }

    public void deleteConversationList(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        Boolean clearMessage = methodCall.argument("clearMessage");
        V2TIMManager.getConversationManager().deleteConversationList(conversationIDList, clearMessage, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });

    }
    public void subscribeUnreadMessageCountByFilter(MethodCall methodCall, final MethodChannel.Result result) {
        final Map<String,Object> filter = CommonUtil.getParam(methodCall,result,"filter");
        final V2TIMConversationListFilter filterNative = new V2TIMConversationListFilter();

        if(filter.get("conversationType")!=null){
            filterNative.setConversationType((Integer) filter.get("conversationType"));
        }

        if(filter.get("markType")!=null){
            filterNative.setMarkType((int)filter.get("markType"));
        }
        if(filter.get("conversationGroup")!=null){
            filterNative.setConversationGroup((String) filter.get("conversationGroup"));
        }
        if(filter.get("hasGroupAtInfo")!=null){
            filterNative.setHasGroupAtInfo((Boolean) filter.get("hasGroupAtInfo"));
        }
        if(filter.get("hasUnreadCount")!=null){
            filterNative.setHasUnreadCount((Boolean) filter.get("hasUnreadCount"));
        }
        V2TIMManager.getConversationManager().subscribeUnreadMessageCountByFilter(filterNative);
        CommonUtil.returnSuccess(result,null);
    }
    public void unsubscribeUnreadMessageCountByFilter(MethodCall methodCall, final MethodChannel.Result result) {
        final Map<String,Object> filter = CommonUtil.getParam(methodCall,result,"filter");
        final V2TIMConversationListFilter filterNative = new V2TIMConversationListFilter();

        if(filter.get("conversationType")!=null){
            filterNative.setConversationType((Integer) filter.get("conversationType"));
        }

        if(filter.get("markType")!=null){
            filterNative.setMarkType((int)filter.get("markType"));
        }
        if(filter.get("conversationGroup")!=null){
            filterNative.setConversationGroup((String) filter.get("conversationGroup"));
        }
        if(filter.get("hasGroupAtInfo")!=null){
            filterNative.setHasGroupAtInfo((Boolean) filter.get("hasGroupAtInfo"));
        }
        if(filter.get("hasUnreadCount")!=null){
            filterNative.setHasUnreadCount((Boolean) filter.get("hasUnreadCount"));
        }
        V2TIMManager.getConversationManager().unsubscribeUnreadMessageCountByFilter(filterNative);
        CommonUtil.returnSuccess(result,null);
    }
    public void cleanConversationUnreadMessageCount(MethodCall methodCall, final MethodChannel.Result result) {
        String conversationID = CommonUtil.getParam(methodCall, result, "conversationID");
        long cleanTimestamp = new Long((int)(CommonUtil.getParam(methodCall, result, "cleanTimestamp")));
        long cleanSequence = new Long((int)CommonUtil.getParam(methodCall, result, "cleanSequence"));
        V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(conversationID, cleanTimestamp, cleanSequence, new V2TIMCallback() {
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
    public void markConversation(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        Boolean enableMark = CommonUtil.getParam(methodCall, result, "enableMark");
        Number markType = CommonUtil.getParam(methodCall, result, "markType");

         LinkedList<Long> validMarkType = new LinkedList<Long>();
         validMarkType.add(0x1L << 0);
         validMarkType.add(0x1L << 1);
         validMarkType.add(0x1L << 2);
         validMarkType.add(0x1L << 3);
         for(int i = 32;i<64;i++){
             validMarkType.add(0x1L << i);
         }
         long mt = Long.valueOf(markType.longValue());

         if(!validMarkType.contains(mt)){
             CommonUtil.returnError(result,-1,"Illegal markType, markType must be between [0x1l<<0,0x1l<<1,0x1l<<2,0x1l<<3,0x1l<<32,...,0x1l<<63]");
             return;
         }
        V2TIMManager.getConversationManager().markConversation(conversationIDList, mt, enableMark, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });

    }
    public void createConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().createConversationGroup(groupName, conversationIDList, new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void getConversationGroupList(MethodCall methodCall, final MethodChannel.Result result) {
        V2TIMManager.getConversationManager().getConversationGroupList(new V2TIMValueCallback<List<String>>() {
            @Override
            public void onSuccess(List<String> strings) {
                List<String>  list = new LinkedList();
                for(int i = 0;i < strings.size();i++){
                    list.add(strings.get(i));
                }
                System.out.println(list);
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().deleteConversationGroup(groupName, new V2TIMCallback() {
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
    public void renameConversationGroup(MethodCall methodCall, final MethodChannel.Result result) {
        String oldName = CommonUtil.getParam(methodCall, result, "oldName");
        String newName = CommonUtil.getParam(methodCall, result, "newName");
        V2TIMManager.getConversationManager().renameConversationGroup(oldName, newName, new V2TIMCallback() {
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
    public void addConversationsToGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().addConversationsToGroup(groupName,conversationIDList , new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }
    public void deleteConversationsFromGroup(MethodCall methodCall, final MethodChannel.Result result) {
        List<String> conversationIDList = methodCall.argument("conversationIDList");
        String groupName = CommonUtil.getParam(methodCall, result, "groupName");
        V2TIMManager.getConversationManager().deleteConversationsFromGroup( groupName,conversationIDList , new V2TIMValueCallback<List<V2TIMConversationOperationResult>>() {
            @Override
            public void onSuccess(List<V2TIMConversationOperationResult> v2TIMConversationOperationResults) {
                LinkedList<HashMap<String,Object>> list = new LinkedList<HashMap<String, Object>>();
                for(int i = 0;i<v2TIMConversationOperationResults.size();i++){
                    list.add(CommonUtil.convertV2TIMConversationOperationResultToMap(v2TIMConversationOperationResults.get(i)));
                }
                CommonUtil.returnSuccess(result,list);
            }

            @Override
            public void onError(int i, String s) {
                CommonUtil.returnError(result,i,s);
            }
        });
    }



}
