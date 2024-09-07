package com.tencent.chat.tencent_cloud_chat_sdk;

import android.app.Application;
import android.content.Context;

import androidx.annotation.NonNull;

import com.tencent.chat.tencent_cloud_chat_sdk.manager.CommunityManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.ConversationManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.FriendshipManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.GroupManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.MessageManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.OfflinePushManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.SignalingManager;
import com.tencent.chat.tencent_cloud_chat_sdk.manager.TimManager;
import com.tencent.chat.tencent_cloud_chat_sdk.util.CommonUtil;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TencentCloudChatSdkPlugin */
public class TencentCloudChatSdkPlugin implements FlutterPlugin, MethodCallHandler {

  public static String TAG = "tencent_cloud_chat_sdk";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  /**
   * global context
   */
  public static Context context;


  /**
   * Communication pipeline with Flutter
   */
  private static List<MethodChannel> channels = new LinkedList<>();
  private static MessageManager messageManager;
  private static GroupManager groupManager;
  private static SignalingManager signalingManager;
  private static ConversationManager conversationManager;
  private static FriendshipManager friendshipManager;
  private static OfflinePushManager offlinePushManager;

  private static CommunityManager communityManager;
  public static TimManager timManager;

  private static List<String> Plugins = new LinkedList<String>();


  public TencentCloudChatSdkPlugin() {

  }

  private TencentCloudChatSdkPlugin(Context context, MethodChannel channel) {
  }

  private static Application mApplication;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tencent_cloud_chat_sdk");
    TencentCloudChatSdkPlugin.context = flutterPluginBinding.getApplicationContext();
    TencentCloudChatSdkPlugin.channels.add(channel);
    TencentCloudChatSdkPlugin.messageManager = new MessageManager(channel);
    TencentCloudChatSdkPlugin.groupManager =new GroupManager(channel);
    TencentCloudChatSdkPlugin.signalingManager = new SignalingManager(channel);
    TencentCloudChatSdkPlugin.conversationManager = new ConversationManager(channel);
    TencentCloudChatSdkPlugin.friendshipManager = new FriendshipManager(channel);
    TencentCloudChatSdkPlugin.offlinePushManager = new OfflinePushManager(channel);
    TencentCloudChatSdkPlugin.communityManager = new CommunityManager(channel);
    TencentCloudChatSdkPlugin.timManager = new TimManager(channel, flutterPluginBinding.getApplicationContext());
    CommonUtil.context = flutterPluginBinding.getApplicationContext();
    mApplication = (Application) flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    String TIMManagerName = CommonUtil.getParam(call, result, "TIMManagerName");
    String apiname = call.method;

    Field field = null;
    Method method = null;
    try {
      field = TencentCloudChatSdkPlugin.class.getDeclaredField(TIMManagerName);
      method = field.get(new Object()).getClass().getDeclaredMethod(apiname, MethodCall.class, Result.class);
      method.invoke(field.get(new Object()), call, result);
      try {
        call.<HashMap<String,Object>>arguments().remove("stacktrace");
        call.<HashMap<String,Object>>arguments().put("method",apiname);
        CommonUtil.writeLog(call.<HashMap<String,Object>>arguments().toString(),false);
      }catch (Exception e){
        System.out.println("print log error");
      }
    } catch (Exception e) {
      System.out.println("cant find method error:" + apiname);
      e.printStackTrace();
      CommonUtil.writeLog("flutter invoke native method fail "+e.toString(),false);
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    for (MethodChannel channel : channels) {

      channel.setMethodCallHandler(null);
    }
    channels = new LinkedList<>();
    MessageManager.cleanChannels();
    TimManager.cleanChannels();
    GroupManager.cleanChannels();
    OfflinePushManager.cleanChannels();
    FriendshipManager.cleanChannels();
    SignalingManager.cleanChannels();
    ConversationManager.cleanChannels();
  }
}
