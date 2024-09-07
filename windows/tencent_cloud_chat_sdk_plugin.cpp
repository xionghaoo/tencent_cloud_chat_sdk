#include "tencent_cloud_chat_sdk_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include "include/chat/V2TIMManager.h"
#include "include/chat/V2TIMGroupManager.h"
#include "include/chat/V2TIMConversationManager.h"
#include "include/chat/V2TIMBuffer.h"
#include "include/chat/V2TIMCallback.h"
#include "include/chat/V2TIMCommon.h"
#include "include/chat/V2TIMCommunity.h"
#include "include/chat/V2TIMCommunityManager.h"
#include "include/chat/V2TIMConversation.h"
#include "include/chat/V2TIMDefine.h"
#include "include/chat/V2TIMErrorCode.h"
#include "include/chat/V2TIMFriendship.h"
#include "include/chat/V2TIMFriendshipManager.h"
#include "include/chat/V2TIMGroup.h"
#include "include/chat/V2TIMListener.h"
#include "include/chat/V2TIMMessage.h"
#include "include/chat/V2TIMMessageManager.h"
#include "include/chat/V2TIMOfficialAccount.h"
#include "include/chat/V2TIMOfflinePushManager.h"
#include "include/chat/V2TIMSignaling.h"
#include "include/chat/V2TIMSignalingManager.h"
#include "include/chat/V2TIMString.h"
#include "iostream"
#include <fstream>
#include <filesystem>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <sstream>
#include <random>
#include <codecvt>
#include <thread>

namespace tencent_cloud_chat_sdk
{
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>, std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>> _channel;
    std::string globalTempPath = "";
    std::map<std::string, V2TIMMessage> createdMessageMap = {};
    std::map<std::string, bool> downloading = {};
    int globalSDKAPPID = 0;
    std::string globalUserID = "";
    

    flutter::EncodableValue FormatTIMCallback(int code, std::string desc)
    {
        auto res = flutter::EncodableMap();
        res[flutter::EncodableValue("code")] = flutter::EncodableValue(code);
        res[flutter::EncodableValue("desc")] = flutter::EncodableValue(desc);
        return flutter::EncodableValue(res);
    }
    flutter::EncodableValue FormatTIMValueCallback(int code, std::string desc, flutter::EncodableValue data)
    {
        
        
        auto res = flutter::EncodableMap();
        res[flutter::EncodableValue("code")] = flutter::EncodableValue(code);
        res[flutter::EncodableValue("data")] = data;
        res[flutter::EncodableValue("desc")] = flutter::EncodableValue(desc == "" ? "OK" : desc);
        return flutter::EncodableValue(res);
    }

    void sendMessageToDart(std::string method, std::string type, flutter::EncodableValue data, std::vector<std::string> uuid)
    {

        auto res = flutter::EncodableMap();
        res[flutter::EncodableValue("type")] = flutter::EncodableValue(type);
        res[flutter::EncodableValue("data")] = data;
        res[flutter::EncodableValue("listenerUuid")] = flutter::EncodableValue("");
        res[flutter::EncodableValue("method")] = flutter::EncodableValue(method);
        _channel->InvokeMethod(method, std::make_unique<flutter::EncodableValue>(flutter::EncodableValue(res)));
    }
    class ConvertDataUtils
    {
    public:
        static std::string generateRandomString()
        {
            const std::string characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            const int length = 32;

            std::random_device rd;
            std::mt19937 generator(rd());
            std::uniform_int_distribution<size_t> distribution(0, characters.length() - 1);

            std::string randomString;
            for (int i = 0; i < length; ++i)
            {
                randomString += characters[distribution(generator)];
            }

            return randomString;
        }
        
        static std::string V2TIMBuffer2String(const uint8_t *data,size_t size)
        {
            if (data == nullptr)
            {
                return "";
            }
            return ConvertDataUtils::validateString(std::string(reinterpret_cast<const char*>(data), size));
        }

        static V2TIMBuffer string2Buffer(std::string data)
        {
            V2TIMBuffer v = { reinterpret_cast<const uint8_t*>(data.c_str()),data.size() };
            return v;
        }

        static flutter::EncodableList convertV2TIMStringVector2Map(V2TIMStringVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                auto item = info[i].CString();
                res.push_back(flutter::EncodableValue(ConvertDataUtils::validateString(item)));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMGroupAttributeMap2Map(V2TIMGroupAttributeMap info)
        {
            auto keys = info.AllKeys();
            auto res = flutter::EncodableMap();
            size_t ksize = keys.Size();
            for (size_t i = 0; i < ksize; i++)
            {
                res[flutter::EncodableValue(keys[i].CString())] = flutter::EncodableValue(ConvertDataUtils::validateString(info.Get(keys[i]).CString()));
            }
            return res;
        }

        static flutter::EncodableList convertV2TIMFriendInfoVector2Map(V2TIMFriendInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMFriendInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMFriendInfo2Map(V2TIMFriendInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("friendAddTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.friendAddTime));
            res[flutter::EncodableValue("friendGroups")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(info.friendGroups));
            res[flutter::EncodableValue("friendRemark")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.friendRemark.CString()));
            res[flutter::EncodableValue("userProfile")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserFullInfo2Map(info.userFullInfo));
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            res[flutter::EncodableValue("friendCustomInfo")] = flutter::EncodableValue(ConvertDataUtils::convertCustomInfo(info.friendCustomInfo));
            return res;
        }
        static flutter::EncodableList convertV2TIMFriendOperationResultVector2Map(V2TIMFriendOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMFriendOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMFriendCheckResult2Map(V2TIMFriendCheckResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultType")] = flutter::EncodableValue(static_cast<int>(info.relationType));
            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);
            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            return res;
        }
        static flutter::EncodableList convertV2TIMFriendCheckResultVector2Map(V2TIMFriendCheckResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMFriendCheckResult2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMFriendOperationResult2Map(V2TIMFriendOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);
            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());

            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            return res;
        }

        static flutter::EncodableList convertV2TIMFriendApplicationVector2Map(V2TIMFriendApplicationVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMFriendApplication2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMFriendApplication2Map(V2TIMFriendApplication info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("addTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.addTime));
            res[flutter::EncodableValue("addSource")] = flutter::EncodableValue(info.addSource.CString());
            res[flutter::EncodableValue("addWording")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.addWording.CString()));
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.faceUrl.CString()));
            res[flutter::EncodableValue("nickname")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.nickName.CString()));
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.type));
            return res;
        }
        static flutter::EncodableMap convertV2TIMTopicInfoResult2Map(V2TIMTopicInfoResult info)
        {

            auto res = flutter::EncodableMap();
            
            res[flutter::EncodableValue("errorCode")] = flutter::EncodableValue(info.errorCode);
            res[flutter::EncodableValue("errorMsg")] = flutter::EncodableValue(info.errorMsg.CString());
            res[flutter::EncodableValue("topicInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMTopicInfo2Map(info.topicInfo));
            return res;
        }
        static flutter::EncodableMap convertV2TIMTopicInfo2Map(V2TIMTopicInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("createTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.createTime));
            res[flutter::EncodableValue("selfMuteTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.selfMuteTime));
            res[flutter::EncodableValue("customString")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.customString.CString()));
            res[flutter::EncodableValue("draftText")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.draftText.CString()));
            res[flutter::EncodableValue("introduction")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.introduction.CString()));
            res[flutter::EncodableValue("notification")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.notification.CString()));
            res[flutter::EncodableValue("topicFaceUrl")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.topicFaceURL.CString()));
            res[flutter::EncodableValue("topicID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.topicID.CString()));
            res[flutter::EncodableValue("topicName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.topicName.CString()));
            res[flutter::EncodableValue("unreadCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.unreadCount));
            res[flutter::EncodableValue("defaultPermissions")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.defaultPermissions));
            res[flutter::EncodableValue("recvOpt")] = flutter::EncodableValue(static_cast<int>(info.recvOpt));
            res[flutter::EncodableValue("isAllMuted")] = flutter::EncodableValue(info.isAllMuted);
            if (info.lastMessage != nullptr)
            {
                res[flutter::EncodableValue("lastMessage")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(info.lastMessage));
            }
            flutter::EncodableList galist = flutter::EncodableList();
            auto groupAtList = info.groupAtInfoList;
            size_t galsize = groupAtList.Size();
            for (size_t j = 0; j < galsize; j++)
            {
                auto item = groupAtList[j];

                auto itemMap = flutter::EncodableMap();
                itemMap[flutter::EncodableValue("seq")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(item.seq));
                itemMap[flutter::EncodableValue("atType")] = flutter::EncodableValue(static_cast<int>(item.atType));
                galist.push_back(itemMap);
            }
            res[flutter::EncodableValue("groupAtInfoList")] = flutter::EncodableValue(galist);
            return res;
        }
        static flutter::EncodableList convertV2TIMGroupChangeInfoVector2Map(V2TIMGroupChangeInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMGroupChangeInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMGroupChangeInfo2Map(V2TIMGroupChangeInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("boolValue")] = flutter::EncodableValue(info.boolValue);
            res[flutter::EncodableValue("intValue")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.intValue));
            res[flutter::EncodableValue("key")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.key.CString()));
            res[flutter::EncodableValue("value")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.value.CString()));
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.type));
            return res;
        }
        static flutter::EncodableList convertV2TIMGroupMemberChangeInfoVector2Map(V2TIMGroupMemberChangeInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMGroupMemberChangeInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMGroupMemberChangeInfo2Map(V2TIMGroupMemberChangeInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("muteTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.muteTime));
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            return res;
        }
        static flutter::EncodableList convertV2TIMGroupMemberInfoVector2Map(V2TIMGroupMemberInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableList convertV2TIMMessageReceiptVectorr2Map(V2TIMMessageReceiptVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMMessageReceipt2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMMessageReceipt2Map(V2TIMMessageReceipt info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("isPeerRead")] = flutter::EncodableValue(info.isPeerRead);
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupID.CString()));
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.msgID.CString()));
            res[flutter::EncodableValue("timestamp")] = flutter::EncodableValue(info.timestamp);
            res[flutter::EncodableValue("unreadCount")] = flutter::EncodableValue(info.unreadCount);
            res[flutter::EncodableValue("readCount")] = flutter::EncodableValue(info.readCount);
            return res;
        }
        static flutter::EncodableList convertV2TIMMessageExtensionVector2Map(V2TIMMessageExtensionVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMMessageExtension2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMFriendApplicationResult2Map(V2TIMFriendApplicationResult info)
        {

            auto res = flutter::EncodableMap();
            
            res[flutter::EncodableValue("friendApplicationList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendApplicationVector2Map(info.applicationList));
            res[flutter::EncodableValue("unreadCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.unreadCount));
            return res;
        }

        static flutter::EncodableList convertV2TIMFriendGroupVector2Map(V2TIMFriendGroupVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {

                res.push_back(ConvertDataUtils::convertV2TIMFriendGroup2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMFriendGroup2Map(V2TIMFriendGroup info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("friendList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(info.friendList));
            res[flutter::EncodableValue("groupName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupName.CString()));
            res[flutter::EncodableValue("userCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.userCount));
            return res;
        }
        static flutter::EncodableMap V2TIMSignalingInfo2Map(V2TIMSignalingInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("actionType")] = flutter::EncodableValue(static_cast<int>(info.actionType));

            res[flutter::EncodableValue("data")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.data.CString()));
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupID.CString()));
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.inviteID.CString()));
            res[flutter::EncodableValue("inviter")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.inviter.CString()));
            res[flutter::EncodableValue("timeout")] = flutter::EncodableValue(info.timeout);

            res[flutter::EncodableValue("inviteeList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(info.inviteeList));
            return res;
        }

        // CC End
        //
         static std::string Wide2UTF8(const std::wstring& strWide) {
             
             int intLength = static_cast<int>(strWide.size());
             int utf_size = WideCharToMultiByte(CP_UTF8, 0, strWide.c_str(), intLength,
                 NULL, 0, NULL, NULL);

             std::unique_ptr<char[]> buffer(new char[utf_size + 1]);
             if (!buffer) {
                 return "";
             }

             WideCharToMultiByte(CP_UTF8, 0, strWide.c_str(), intLength,
                 buffer.get(), utf_size, NULL,
                 NULL);
             buffer[utf_size] = '\0';

             return buffer.get();
         }
        // static std::string convertToUTF8(const std::string& input) {
        //     auto tem = ConvertToWideString(input);
            
        //     return Wide2UTF8(tem);
        // }
       
         static std::wstring ConvertToWideString(const std::string& input) {
             int wideStrLen = MultiByteToWideChar(CP_UTF8, 0, input.c_str(), -1, nullptr, 0);
             std::wstring wideString(wideStrLen, L'\0');
             MultiByteToWideChar(CP_UTF8, 0, input.c_str(), -1, &wideString[0], wideStrLen);
             return wideString;
         }
        // static std::string escapeSpecialCharacters(const std::string& input) {
        //     std::string output;
        //     for (char c : input) {
        //         switch (c) {
        //         case '\"':
        //             output += "\\\"";
        //             break;
        //         case '\'':
        //             output += "\\\'";
        //             break;
        //         case '\\':
        //             output += "\\\\";
        //             break;
        //         case '\n':
        //             output += "\\n";
        //             break;
        //         case '\r':
        //             output += "\\r";
        //             break;
        //         case '\t':
        //             output += "\\t";
        //             break;
        //         case '\b':
        //             output += "\\b";
        //             break;
        //         default:
        //             output += c;
        //             break;
        //         }
        //     }
        //     return input;
        // }
         
         
          
    static flutter::EncodableMap V2TIMPermissionGroupMemberInfoResulto2Map(V2TIMPermissionGroupMemberInfoResult info)
         {

             auto res = flutter::EncodableMap();
             res[flutter::EncodableValue("nextCursor")] = flutter::EncodableValue(info.nextCursor.CString());

             res[flutter::EncodableValue("memberInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(info.memberInfoList));
             

             return res;
         }
         static flutter::EncodableMap V2TIMPermissionGroupInfo2Map(V2TIMPermissionGroupInfo info)
         {

             auto res = flutter::EncodableMap();
             
             res[flutter::EncodableValue("customData")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.customData.CString()));
             res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(info.groupID.CString());

             res[flutter::EncodableValue("permissionGroupName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.permissionGroupName.CString()));
             res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(info.permissionGroupID.CString());

             res[flutter::EncodableValue("groupPermission")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.groupPermission));
             res[flutter::EncodableValue("memberCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.memberCount));

             return res;
         }
        static flutter::EncodableList V2TIMConversationOperationResultVector2Map(V2TIMConversationOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMConversationOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMConversationOperationResult2Map(V2TIMConversationOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.resultInfo.CString()));
            res[flutter::EncodableValue("conversationID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.conversationID.CString()));

            return res;
        }
        static flutter::EncodableList V2TIMTopicPermissionResultVector2Map(V2TIMTopicPermissionResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMTopicPermissionResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMTopicPermissionResult2Map(V2TIMTopicPermissionResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("topicID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.topicID.CString()));
            res[flutter::EncodableValue("resultMessage")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.resultMsg.CString()));
            res[flutter::EncodableValue("topicPermission")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.topicPermission));

            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupID.CString()));
            res[flutter::EncodableValue("germissionGroupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.permissionGroupID.CString()));

            return res;
        }
        
        static flutter::EncodableList V2TIMPermissionGroupMemberOperationResultVector2Map(V2TIMPermissionGroupMemberOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMPermissionGroupMemberOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMPermissionGroupMemberOperationResult2Map(V2TIMPermissionGroupMemberOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("memberID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.memberID.CString()));

            return res;
        }
        
        static flutter::EncodableList V2TIMPermissionGroupOperationResultVector2Map(V2TIMPermissionGroupOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMPermissionGroupOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMPermissionGroupOperationResult2Map(V2TIMPermissionGroupOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);
            
            res[flutter::EncodableValue("resultMessage")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.resultMsg.CString()));
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.permissionGroupID.CString()));

            return res;
        }
        static flutter::EncodableList V2TIMPermissionGroupInfoResultVector2Map(V2TIMPermissionGroupInfoResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMPermissionGroupInfoResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMPermissionGroupInfoResult2Map(V2TIMPermissionGroupInfoResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("resultMessage")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.resultMsg.CString()));
            res[flutter::EncodableValue("permissionGroupInfo")] = flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupInfo2Map(info.info));

            return res;
        }
        
        static flutter::EncodableList V2TIMGroupInfoResultVector2Map(V2TIMGroupInfoResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMGroupInfoResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMGroupInfoResult2Map(V2TIMGroupInfoResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);
            
            res[flutter::EncodableValue("groupInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupInfo2Map(info.info));
            res[flutter::EncodableValue("resultMsg")] = flutter::EncodableValue(info.resultMsg.CString());

            return res;
        }
        static flutter::EncodableMap V2TimMessageOnlineUrl2Map(V2TIMMessage info)
        {

            auto res = flutter::EncodableMap();

            // res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            // res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());
            // res[flutter::EncodableValue("conversationID")] = flutter::EncodableValue(info.conversationID.CString());

            return res;
        }

        static flutter::EncodableList V2TIMMessageReactionResultVector2Map(V2TIMMessageReactionResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMMessageReactionResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMMessageReactionResult2Map(V2TIMMessageReactionResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());
            res[flutter::EncodableValue("messageID")] = flutter::EncodableValue(info.msgID.CString());

            res[flutter::EncodableValue("reactionList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReactionVector2Map(info.reactionList));

            return res;
        }
        static flutter::EncodableMap V2TIMStringToV2TIMStringMap2Map(V2TIMStringToV2TIMStringMap info)
        {

            auto res = flutter::EncodableMap();

            auto keys = info.AllKeys();
            auto ksize = keys.Size();

            for (size_t i = 0; i < ksize; i++)
            {
                auto item = keys[i];
                auto v = info.Get(item);
                res[flutter::EncodableValue(ConvertDataUtils::validateString(item.CString()))] = flutter::EncodableValue(ConvertDataUtils::validateString(v.CString()));
            }

            return res;
        }
        static flutter::EncodableMap V2TIMMessageReactionUserResult2Map(V2TIMMessageReactionUserResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("isFinished")] = flutter::EncodableValue(info.isFinished);

            res[flutter::EncodableValue("nextSeq")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.nextSeq));

            res[flutter::EncodableValue("userInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserInfoVector2Map(info.userInfoList));

            return res;
        }
        static flutter::EncodableList V2TIMMessageExtensionResultVector2Map(V2TIMMessageExtensionResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMMessageExtensionResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMMessageExtensionResult2Map(V2TIMMessageExtensionResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);

            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());

            res[flutter::EncodableValue("extension")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageExtension2Map(info.extension));

            return res;
        }
        static flutter::EncodableList V2TIMMessageSearchResultItemVector2Map(V2TIMMessageSearchResultItemVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMMessageSearchResultItem2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMMessageSearchResultItem2Map(V2TIMMessageSearchResultItem info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("conversationID")] = flutter::EncodableValue(info.conversationID.CString());

            res[flutter::EncodableValue("messageCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.messageCount));

            res[flutter::EncodableValue("messageList")] = flutter::EncodableValue(ConvertDataUtils::V2TIMMessageVector2Map(info.messageList));

            return res;
        }
        static flutter::EncodableMap V2TIMGroupMessageReadMemberList2Map(V2TIMGroupMessageReadMemberList info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("isFinished")] = flutter::EncodableValue(info.isFinished);

            res[flutter::EncodableValue("nextSeq")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.nextSeq));

            res[flutter::EncodableValue("memberInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(info.members));

            return res;
        }
        static flutter::EncodableList V2TIMReceiveMessageOptInfoVector2Map(V2TIMReceiveMessageOptInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMReceiveMessageOptInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMReceiveMessageOptInfo2Map(V2TIMReceiveMessageOptInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));

            res[flutter::EncodableValue("startHour")] = flutter::EncodableValue(info.startHour);
            res[flutter::EncodableValue("startMinute")] = flutter::EncodableValue(info.startMinute);
            res[flutter::EncodableValue("startSecond")] = flutter::EncodableValue(info.startSecond);

            res[flutter::EncodableValue("duration")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.duration));
            res[flutter::EncodableValue("startTimeStamp")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.startTimeStamp));

            res[flutter::EncodableValue("receiveOpt")] = flutter::EncodableValue(static_cast<int>(info.receiveOpt));

            return res;
        }
        static flutter::EncodableMap V2TIMMessageSearchResult2Map(V2TIMMessageSearchResult info)
        {

            auto res = flutter::EncodableMap();

            info.messageSearchResultItems;

            res[flutter::EncodableValue("searchCursor")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.searchCursor.CString()));

            res[flutter::EncodableValue("totalCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.totalCount));

            res[flutter::EncodableValue("messageSearchResultItems")] = flutter::EncodableValue(ConvertDataUtils::V2TIMMessageSearchResultItemVector2Map(info.messageSearchResultItems));

            return res;
        }
        static flutter::EncodableList V2TIMMessageVector2Map(V2TIMMessageVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMMessage2Map(&info[i]));
            }
            return res;
        }

        static flutter::EncodableList V2TIMGroupMemberOperationResultVector2Map(V2TIMGroupMemberOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMGroupMemberOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMGroupMemberOperationResult2Map(V2TIMGroupMemberOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("memberID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));

            res[flutter::EncodableValue("result")] = flutter::EncodableValue(static_cast<int>(info.result));

            return res;
        }
        static flutter::EncodableMap V2TIMGroupMemberInfoResult2Map(V2TIMGroupMemberInfoResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("memberInfoList")] = flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMemberFullInfoVector2Map(info.memberInfoList));

            res[flutter::EncodableValue("nextSeq")] = flutter::EncodableValue(std::to_string(ConvertDataUtils::convertUint642Int(info.nextSequence)));

            return res;
        }
        static flutter::EncodableMap V2TIMStringToInt64Map2Map(V2TIMStringToInt64Map info)
        {

            auto keys = info.AllKeys();
            auto ksize = keys.Size();
            auto res = flutter::EncodableMap();
            for (size_t i = 0; i < ksize; i++)
            {
                auto item = keys[i];
                int64_t v = info.Get(item);
                res[flutter::EncodableValue(ConvertDataUtils::validateString(item.CString()))] = flutter::EncodableValue(v);
            }
            return res;
        }
        static flutter::EncodableMap V2TIMStringToUInt64Map2Map(V2TIMStringToUint64Map info)
        {

            auto keys = info.AllKeys();
            auto ksize = keys.Size();
            auto res = flutter::EncodableMap();
            for (size_t i = 0; i < ksize; i++)
            {
                auto item = keys[i];
                int64_t v = info.Get(item);
                res[flutter::EncodableValue(ConvertDataUtils::validateString(item.CString()))] = flutter::EncodableValue(v);
            }
            return res;
        }
        static flutter::EncodableList V2TIMGroupMemberFullInfoVector2Map(V2TIMGroupMemberFullInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMGroupMemberFullInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMGroupMemberFullInfo2Map(V2TIMGroupMemberFullInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.userID.CString()));
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.faceURL.CString()));
            res[flutter::EncodableValue("friendRemark")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.friendRemark.CString()));
            res[flutter::EncodableValue("nameCard")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.nameCard.CString()));
            res[flutter::EncodableValue("nickName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.nickName.CString()));

            res[flutter::EncodableValue("role")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.role));
            res[flutter::EncodableValue("muteUntil")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.muteUntil));

            res[flutter::EncodableValue("joinTime")] = flutter::EncodableValue(info.joinTime);
            res[flutter::EncodableValue("isOnline")] = flutter::EncodableValue(info.isOnline);

            res[flutter::EncodableValue("customInfo")] = flutter::EncodableValue(ConvertDataUtils::convertCustomInfo(info.customInfo));
            res[flutter::EncodableValue("onlineDevices")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(info.onlineDevices));
            return res;
        }
        static flutter::EncodableMap V2TIMGroupSearchGroupMembersMap2Map(V2TIMGroupSearchGroupMembersMap info)
        {

            auto keys = info.AllKeys();
            auto ksize = keys.Size();
            auto res = flutter::EncodableMap();
            for (size_t i = 0; i < ksize; i++)
            {
                auto item = keys[i];
                res[flutter::EncodableValue(ConvertDataUtils::validateString(item.CString()))] = flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMemberFullInfoVector2Map(info.Get(item)));
            }
            return res;
        }
        static flutter::EncodableList V2TIMGroupApplicationVector2Map(V2TIMGroupApplicationVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::V2TIMGroupApplicationVector2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap V2TIMGroupApplicationVector2Map(V2TIMGroupApplication info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("addTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.addTime));

            res[flutter::EncodableValue("fromUser")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.fromUser.CString()));
            res[flutter::EncodableValue("fromUserFaceUrl")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.fromUserFaceUrl.CString()));
            res[flutter::EncodableValue("fromUserNickName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.fromUserNickName.CString()));
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupID.CString()));
            res[flutter::EncodableValue("handledMsg")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.handledMsg.CString()));
            res[flutter::EncodableValue("requestMsg")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.requestMsg.CString()));
            res[flutter::EncodableValue("toUser")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.toUser.CString()));

            res[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.applicationType));
            res[flutter::EncodableValue("handleResult")] = flutter::EncodableValue(static_cast<int>(info.handleResult));
            res[flutter::EncodableValue("handleStatus")] = flutter::EncodableValue(static_cast<int>(info.handleStatus));

            return res;
        }
        static flutter::EncodableList V2TIMTopicOperationResultVector2Map(V2TIMTopicOperationResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMTopicOperationResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMTopicOperationResult2Map(V2TIMTopicOperationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("errorCode")] = flutter::EncodableValue(info.errorCode);
            res[flutter::EncodableValue("topicInfo")] = flutter::EncodableValue(info.topicID.CString());
            res[flutter::EncodableValue("errorMsg")] = flutter::EncodableValue(info.errorMsg.CString());

            return res;
        }
        static flutter::EncodableMap V2TIMGroupApplicationResult2Map(V2TIMGroupApplicationResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("unreadCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.unreadCount));
            res[flutter::EncodableValue("groupApplicationList")] = flutter::EncodableValue(ConvertDataUtils::V2TIMGroupApplicationVector2Map(info.applicationList));

            return res;
        }
        static flutter::EncodableList V2TIMTopicInfoResultVector2Map(V2TIMTopicInfoResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMTopicInfoResult2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMFriendGroup2Map(V2TIMGroupAttributeMap info)
        {

            auto res = flutter::EncodableMap();
            auto keys = info.AllKeys();
            auto ksize = keys.Size();
            for (size_t i = 0; i < ksize; i++)
            {
                auto item = info.Get(keys[i]);
                res[flutter::EncodableValue(keys[i].CString())] = flutter::EncodableValue(item.CString());
            }

            return res;
        }
        static flutter::EncodableMap convertV2TIMGroupInfo2Map(V2TIMGroupInfo info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("isAllMuted")] = flutter::EncodableValue(info.allMuted);
            res[flutter::EncodableValue("createTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.createTime));
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.faceURL.CString()));
            res[flutter::EncodableValue("groupAddOpt")] = flutter::EncodableValue(static_cast<int>(info.groupAddOpt));
            res[flutter::EncodableValue("groupName")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupName.CString()));
            res[flutter::EncodableValue("approveOpt")] = flutter::EncodableValue(static_cast<int>(info.groupApproveOpt));
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.groupID.CString()));
            auto gt = info.groupType;
            auto workgt = V2TIMString{ "Private"};
            auto workNow = V2TIMString{ "Work" };
            V2TIMString finalgt;
            if (gt.operator==(workgt)) {
                finalgt = workNow;
            }
            else {
                finalgt = gt;
            }
            
            res[flutter::EncodableValue("groupType")] = flutter::EncodableValue(ConvertDataUtils::validateString(finalgt.CString()));
            res[flutter::EncodableValue("introduction")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.introduction.CString()));
            res[flutter::EncodableValue("isSupportTopic")] = flutter::EncodableValue(info.isSupportTopic);
            res[flutter::EncodableValue("joinTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.joinTime));
            res[flutter::EncodableValue("lastInfoTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.lastInfoTime));
            res[flutter::EncodableValue("lastMessageTime")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.lastMessageTime));
            res[flutter::EncodableValue("memberCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.memberCount));
            res[flutter::EncodableValue("memberMaxCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.memberMaxCount));
            res[flutter::EncodableValue("onlineCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.onlineCount));
            res[flutter::EncodableValue("notification")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.notification.CString()));
            res[flutter::EncodableValue("recvOpt")] = flutter::EncodableValue(static_cast<int>(info.recvOpt));
            res[flutter::EncodableValue("role")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.role));
            res[flutter::EncodableValue("owner")] = flutter::EncodableValue(ConvertDataUtils::validateString(info.owner.CString()));
            res[flutter::EncodableValue("customInfo")] = flutter::EncodableValue(ConvertDataUtils::convertCustomInfo(info.customInfo));
            // TODO 521
            res[flutter::EncodableValue("isEnablePermissionGroup")] = flutter::EncodableValue(info.enablePermissionGroup);
            res[flutter::EncodableValue("memberMaxCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.memberMaxCount));
            res[flutter::EncodableValue("defaultPermissions")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.defaultPermissions));
            return res;
        }
        static flutter::EncodableList converV2TIMGroupInfoVector2Map(V2TIMGroupInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMGroupInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMFriendInfoResult2Map(V2TIMFriendInfoResult info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("friendInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfo2Map(info.friendInfo));
            res[flutter::EncodableValue("relation")] = flutter::EncodableValue(static_cast<int>(info.relation));
            res[flutter::EncodableValue("resultCode")] = flutter::EncodableValue(info.resultCode);
            res[flutter::EncodableValue("resultInfo")] = flutter::EncodableValue(info.resultInfo.CString());

            return res;
        }
        static flutter::EncodableList convertV2TIMFriendInfoResultVector2Map(V2TIMFriendInfoResultVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMFriendInfoResult2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMMessageExtension2Map(V2TIMMessageExtension info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("extensionKey")] = flutter::EncodableValue(info.extensionKey.CString());
            res[flutter::EncodableValue("extensionValue")] = flutter::EncodableValue(info.extensionValue.CString());

            return res;
        }
        static flutter::EncodableList convertV2TIMMessageReactionChangeInfoVector2Map(V2TIMMessageReactionChangeInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMMessageReactionChangeInfo2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMMessageReactionChangeInfo2Map(V2TIMMessageReactionChangeInfo info)
        {

            auto res = flutter::EncodableMap();
            

            res[flutter::EncodableValue("messageID")] = flutter::EncodableValue(info.msgID.CString());
            res[flutter::EncodableValue("reactionList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReactionVector2Map(info.reactionList));

            return res;
        }
        static flutter::EncodableList convertV2TIMMessageReactionVector2Map(V2TIMMessageReactionVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMMessageReaction2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMMessageReaction2Map(V2TIMMessageReaction info)
        {

            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("reactedByMyself")] = flutter::EncodableValue(info.reactedByMyself);
            res[flutter::EncodableValue("reactionID")] = flutter::EncodableValue(info.reactionID.CString());
            res[flutter::EncodableValue("totalUserCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.totalUserCount));
            res[flutter::EncodableValue("partialUserList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserInfoVector2Map(info.partialUserList));
            return res;
        }
        static flutter::EncodableMap convertV2TIMGroupMemberInfo2Map(V2TIMGroupMemberInfo info)
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(info.faceURL.CString());
            res[flutter::EncodableValue("friendRemark")] = flutter::EncodableValue(info.friendRemark.CString());
            res[flutter::EncodableValue("nameCard")] = flutter::EncodableValue(info.nameCard.CString());
            res[flutter::EncodableValue("nickName")] = flutter::EncodableValue(info.nickName.CString());
            flutter::EncodableList onlineDevices = flutter::EncodableList();
            for (size_t i = 0; i < info.onlineDevices.Size(); i++)
            {
                onlineDevices.push_back(info.onlineDevices[i].CString());
            }
            res[flutter::EncodableValue("onlineDevices")] = flutter::EncodableValue(onlineDevices);
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());
            return res;
        }

        static flutter::EncodableList convertV2TIMUserStatusVector2Map(V2TIMUserStatusVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMUserStatus2Map(info[i]));
            }
            return res;
        }

        static flutter::EncodableMap convertV2TIMReceiveMessageOptInfo2Map(V2TIMReceiveMessageOptInfo info)
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("duration")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.duration));
            res[flutter::EncodableValue("receiveOpt")] = flutter::EncodableValue(static_cast<int>(info.receiveOpt));
            res[flutter::EncodableValue("startHour")] = flutter::EncodableValue(info.startHour);
            res[flutter::EncodableValue("startMinute")] = flutter::EncodableValue(info.startMinute);
            res[flutter::EncodableValue("startSecond")] = flutter::EncodableValue(info.startSecond);
            res[flutter::EncodableValue("startTimeStamp")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.startTimeStamp));
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());
            return res;
        }
        static flutter::EncodableMap convertV2TIMUserStatus2Map(V2TIMUserStatus info)
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("customStatus")] = flutter::EncodableValue(info.customStatus.CString());
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());
            res[flutter::EncodableValue("statusType")] = flutter::EncodableValue(static_cast<int>(info.statusType));
            flutter::EncodableList onlineDevices = flutter::EncodableList();
            for (size_t i = 0; i < info.onlineDevices.Size(); i++)
            {
                onlineDevices.push_back(info.onlineDevices[i].CString());
            }
            res[flutter::EncodableValue("onlineDevices")] = flutter::EncodableValue(onlineDevices);
            return res;
        }
        static flutter::EncodableMap convertV2TIMConversationListFilter2Map(V2TIMConversationListFilter info)
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("conversationGroup")] = flutter::EncodableValue(info.conversationGroup.CString());
            res[flutter::EncodableValue("filterType")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.filterType));
            res[flutter::EncodableValue("hasGroupAtInfo")] = flutter::EncodableValue(info.hasGroupAtInfo);
            res[flutter::EncodableValue("hasUnreadCount")] = flutter::EncodableValue(info.hasUnreadCount);
            res[flutter::EncodableValue("markType")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.markType));
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.type));
            return res;
        }
        static flutter::EncodableMap convertCustomInfo(V2TIMCustomInfo info)
        {
            auto customInfo = flutter::EncodableMap();
            auto res = flutter::EncodableMap();
            auto keys = info.AllKeys();

            for (size_t i = 0; i < keys.Size(); i++)
            {
                auto key = keys[i].CString();
                auto value = info.Get(keys[i]).Data();
                auto size = info.Get(keys[i]).Size();
                res[flutter::EncodableValue(key)] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(value, size));
            }
            return res;
        }
        static int32_t convertUint322Int(uint32_t value)
        {
            return static_cast<int32_t>(value);
        }
        static int64_t convertUint642Int(uint64_t value)
        {
            return static_cast<int64_t>(value);
        }
        static flutter::EncodableMap convertV2TIMUserFullInfo2Map(V2TIMUserFullInfo info)
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("allowType")] = flutter::EncodableValue(static_cast<int>(info.allowType));
            res[flutter::EncodableValue("birthday")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.birthday));

            res[flutter::EncodableValue("customInfo")] = flutter::EncodableValue(ConvertDataUtils::convertCustomInfo(info.customInfo));
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(info.faceURL.CString());

            res[flutter::EncodableValue("gender")] = flutter::EncodableValue(static_cast<int>(info.gender));
            res[flutter::EncodableValue("level")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.level));
            res[flutter::EncodableValue("nickName")] = flutter::EncodableValue(info.nickName.CString());
            res[flutter::EncodableValue("role")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(info.role));
            res[flutter::EncodableValue("selfSignature")] = flutter::EncodableValue(info.selfSignature.CString());
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());

            return res;
        }
        static flutter::EncodableList convertV2TIMUserFullInfoVector2Map(V2TIMUserFullInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMUserFullInfo2Map(info[i]));
            }
            return res;
        }
        static flutter::EncodableMap convertV2TIMUserInfo2Map(V2TIMUserInfo info)
        {
            auto res = flutter::EncodableMap();

            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(info.faceURL.CString());

            res[flutter::EncodableValue("nickName")] = flutter::EncodableValue(info.nickName.CString());
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());

            return res;
        }
        static flutter::EncodableList convertV2TIMUserInfoVector2Map(V2TIMUserInfoVector info)
        {
            size_t infosize = info.Size();
            flutter::EncodableList res = flutter::EncodableList();
            for (size_t i = 0; i < infosize; i++)
            {
                res.push_back(ConvertDataUtils::convertV2TIMUserInfo2Map(info[i]));
            }
            return res;
        }
        static std::string escapeString(const std::string& str) {
            std::string escapedStr;

            for (char c : str) {
                switch (c) {
                case '\"':
                    escapedStr += "\\\"";
                    break;
                case '\'':
                    escapedStr += "\\\'";
                    break;
                case '\\':
                    escapedStr += "\\\\";
                    break;
                case '\t':
                    escapedStr += "\\t";
                    break;
                case '\r':
                    escapedStr += "\\r";
                    break;
                case '\n':
                    escapedStr += "\\n";
                    break;
                default:
                    escapedStr += c;
                    break;
                }
            }

            return escapedStr;
        }
        static std::string validateString(std::string input) {
            return  ConvertDataUtils::Wide2UTF8(ConvertDataUtils::ConvertToWideString(input));
        }
        static flutter::EncodableList stringVetorToList(V2TIMStringVector data)
        {
            auto res = flutter::EncodableList();
            auto size = data.Size();
            for (size_t i = 0; i < size; i++)
            {
                auto item = data[i];
                
                res.push_back(flutter::EncodableValue(ConvertDataUtils::validateString(item.CString())));
            }
            return res;
        }
        static flutter::EncodableMap converofflinePushInfo2Map(V2TIMOfflinePushInfo info)
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("AndroidFCMChannelID")] = flutter::EncodableValue(info.AndroidFCMChannelID.CString());
            res[flutter::EncodableValue("AndroidHuaWeiCategory")] = flutter::EncodableValue(info.AndroidHuaWeiCategory.CString());
            res[flutter::EncodableValue("AndroidOPPOChannelID")] = flutter::EncodableValue(info.AndroidOPPOChannelID.CString());
            res[flutter::EncodableValue("AndroidSound")] = flutter::EncodableValue(info.AndroidSound.CString());
            res[flutter::EncodableValue("AndroidVIVOCategory")] = flutter::EncodableValue(info.AndroidVIVOCategory.CString());
            res[flutter::EncodableValue("AndroidVIVOClassification")] = flutter::EncodableValue(info.AndroidVIVOClassification);
            res[flutter::EncodableValue("AndroidXiaoMiChannelID")] = flutter::EncodableValue(info.AndroidXiaoMiChannelID.CString());
            res[flutter::EncodableValue("desc")] = flutter::EncodableValue(info.desc.CString());
            res[flutter::EncodableValue("disablePush")] = flutter::EncodableValue(info.disablePush);
            res[flutter::EncodableValue("ext")] = flutter::EncodableValue(info.ext.CString());
            res[flutter::EncodableValue("ignoreIOSBadge")] = flutter::EncodableValue(info.ignoreIOSBadge);
            res[flutter::EncodableValue("iOSPushType")] = flutter::EncodableValue(static_cast<int>(info.iOSPushType));
            res[flutter::EncodableValue("iOSSound")] = flutter::EncodableValue(info.iOSSound.CString());
            res[flutter::EncodableValue("title")] = flutter::EncodableValue(info.title.CString());
            
            res[flutter::EncodableValue("androidHuaWeiImage")] = flutter::EncodableValue(info.AndroidHuaWeiImage.CString());
            res[flutter::EncodableValue("androidHonorImage")] = flutter::EncodableValue(info.AndroidHonorImage.CString());
            res[flutter::EncodableValue("androidFCMImage")] = flutter::EncodableValue(info.AndroidFCMImage.CString());
            res[flutter::EncodableValue("iOSImage")] = flutter::EncodableValue(info.iOSImage.CString());

            return res;
        }
        static flutter::EncodableMap convertTextElemValue(V2TIMTextElem *elem)
        {
            auto data = flutter::EncodableMap();
            data[flutter::EncodableValue("text")] = flutter::EncodableValue(elem->text.CString());
            return data;
        }
        static flutter::EncodableMap convertCustomElemValue(V2TIMCustomElem *elem)
        {
            auto data = flutter::EncodableMap();
            data[flutter::EncodableValue("data")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(elem->data.Data(),elem->data.Size()));
            data[flutter::EncodableValue("desc")] = flutter::EncodableValue(elem->desc.CString());
            data[flutter::EncodableValue("extension")] = flutter::EncodableValue(elem->extension.CString());

            return data;
        }
        static flutter::EncodableMap convertFaceElemValue(V2TIMFaceElem *elem)
        {
            auto data = flutter::EncodableMap();
            data[flutter::EncodableValue("data")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(elem->data.Data(), elem->data.Size()));
            data[flutter::EncodableValue("index")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->index));

            return data;
        }
        static flutter::EncodableMap convertFileElemValue(V2TIMFileElem *elem)
        {
            auto data = flutter::EncodableMap();

            data[flutter::EncodableValue("fileName")] = flutter::EncodableValue(elem->filename.CString());
            data[flutter::EncodableValue("path")] = flutter::EncodableValue(elem->path.CString());
            data[flutter::EncodableValue("fileSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(elem->fileSize));
            data[flutter::EncodableValue("UUID")] = flutter::EncodableValue(elem->uuid.CString());
            std::string localUrl = (globalTempPath + "DownLoad\\"+ std::to_string(globalSDKAPPID)+ "\\" + globalUserID + "\\" + (elem->uuid.CString()) + "\\" + elem->filename.CString());
            
            if (ConvertDataUtils::fileExists(localUrl))
            {
                data[flutter::EncodableValue("localUrl")] = flutter::EncodableValue(localUrl.c_str());
            }
            return data;
        }
        static flutter::EncodableMap convertGroupTipsElemValue(V2TIMGroupTipsElem *elem)
        {
            auto data = flutter::EncodableMap();

            data[flutter::EncodableValue("groupChangeInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupChangeInfoVector2Map(elem->groupChangeInfoList));
            data[flutter::EncodableValue("memberChangeInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberChangeInfoVector2Map(elem->memberChangeInfoList));
            data[flutter::EncodableValue("memberCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->memberCount));
            data[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(elem->memberList));
            data[flutter::EncodableValue("opMember")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(elem->opMember));
            data[flutter::EncodableValue("groupID")] = flutter::EncodableValue(elem->groupID.CString());
            data[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(elem->type));
            return data;
        }
        static flutter::EncodableMap convertImageElemValue(V2TIMImageElem *elem)
        {
            auto data = flutter::EncodableMap();
            auto imageList = elem->imageList;
            auto resList = flutter::EncodableList();
            auto isize = imageList.Size();
            for (size_t i = 0; i < isize; i++)
            {
                int dartImageType = 0;
                
                auto item = imageList[i];
                if (item.type == V2TIMImageType::V2TIM_IMAGE_TYPE_ORIGIN) {
                    dartImageType = 0;
                }
                else if (item.type == V2TIMImageType::V2TIM_IMAGE_TYPE_THUMB) {
                    dartImageType = 1;
                }
                else if (item.type == V2TIMImageType::V2TIM_IMAGE_TYPE_LARGE) {
                    dartImageType = 2;
                }
                auto dataItem = flutter::EncodableMap();
                dataItem[flutter::EncodableValue("height")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(item.height));
                dataItem[flutter::EncodableValue("width")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(item.width));
                dataItem[flutter::EncodableValue("size")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(item.height));
                dataItem[flutter::EncodableValue("UUID")] = flutter::EncodableValue(item.uuid.CString());
                dataItem[flutter::EncodableValue("url")] = flutter::EncodableValue(item.url.CString());
                dataItem[flutter::EncodableValue("type")] = flutter::EncodableValue(dartImageType);
                std::string localUrl = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "image_" + std::to_string(static_cast<int>(item.type)) + std::to_string(item.size) + std::to_string(item.width) + std::to_string(item.height) + "_" + item.uuid.CString());
                if (ConvertDataUtils::fileExists(localUrl))
                {
                    dataItem[flutter::EncodableValue("localUrl")] = flutter::EncodableValue(localUrl.c_str());
                }
                resList.push_back(dataItem);
            }
            data[flutter::EncodableValue("path")] = flutter::EncodableValue(elem->path.CString());
            data[flutter::EncodableValue("imageList")] = flutter::EncodableValue(resList);
            return data;
        }
        static flutter::EncodableMap convertLocationElemValue(V2TIMLocationElem *elem)
        {
            auto data = flutter::EncodableMap();

            data[flutter::EncodableValue("latitude")] = flutter::EncodableValue(elem->latitude);
            data[flutter::EncodableValue("longitude")] = flutter::EncodableValue(elem->longitude);
            data[flutter::EncodableValue("desc")] = flutter::EncodableValue(elem->desc.CString());
            return data;
        }
        static flutter::EncodableMap convertMergeElemValue(V2TIMMergerElem* elem)
        {
            auto data = flutter::EncodableMap();
            auto list = elem->abstractList;
            for (size_t i = 0; i < list.Size(); i++)
            {
                auto dd = ConvertDataUtils::ConvertToWideString(list[i].CString());
            }
            data[flutter::EncodableValue("isLayersOverLimit")] = flutter::EncodableValue(elem->layersOverLimit);
            data[flutter::EncodableValue("title")] = flutter::EncodableValue(ConvertDataUtils::validateString(elem->title.CString()));
            data[flutter::EncodableValue("abstractList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(elem->abstractList));
            return data;
        }
        
        static flutter::EncodableMap convertSoundElemValue(V2TIMSoundElem *elem)
        {
            auto data = flutter::EncodableMap();

            data[flutter::EncodableValue("duration")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->duration));
            data[flutter::EncodableValue("path")] = flutter::EncodableValue(elem->path.CString());
            data[flutter::EncodableValue("dataSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(elem->dataSize));
            data[flutter::EncodableValue("UUID")] = flutter::EncodableValue(elem->uuid.CString());
            std::string localUrl = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "sound_" + elem->uuid.CString());
            if (ConvertDataUtils::fileExists(localUrl))
            {
                data[flutter::EncodableValue("localUrl")] = flutter::EncodableValue(localUrl.c_str());
            }
            return data;
        }
        static flutter::EncodableMap convertVideoElemValue(V2TIMVideoElem *elem)
        {
            auto data = flutter::EncodableMap();

            data[flutter::EncodableValue("duration")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->duration));
            data[flutter::EncodableValue("snapshotHeight")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->snapshotHeight));
            data[flutter::EncodableValue("snapshotWidth")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(elem->snapshotWidth));
            data[flutter::EncodableValue("snapshotPath")] = flutter::EncodableValue(elem->snapshotPath.CString());
            data[flutter::EncodableValue("videoPath")] = flutter::EncodableValue(elem->videoPath.CString());
            data[flutter::EncodableValue("snapshotSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(elem->snapshotSize));
            data[flutter::EncodableValue("videoSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(elem->videoSize));
            data[flutter::EncodableValue("snapshotUUID")] = flutter::EncodableValue(elem->snapshotUUID.CString());
            data[flutter::EncodableValue("UUID")] = flutter::EncodableValue(elem->videoUUID.CString());
            data[flutter::EncodableValue("videoType")] = flutter::EncodableValue(elem->videoType.CString());
            std::string localSnapshotUrl = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_" + elem->snapshotUUID.CString());
            std::string localVideoUrl = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_" + elem->videoUUID.CString());
            if (ConvertDataUtils::fileExists(localSnapshotUrl))
            {
                data[flutter::EncodableValue("localSnapshotUrl")] = flutter::EncodableValue(localSnapshotUrl.c_str());
            }
            if (ConvertDataUtils::fileExists(localVideoUrl))
            {
                data[flutter::EncodableValue("localVideoUrl")] = flutter::EncodableValue(localVideoUrl.c_str());
            }
            return data;
        }
        //
        static void convertElemValue(V2TIMElemVector info, flutter::EncodableMap &res)
        {

            auto size = info.Size();

            for (size_t i = 0; i < size; i++)
            {
                auto item = info[i];
                res[flutter::EncodableValue("elemType")] = flutter::EncodableValue(static_cast<int>(item->elemType));
                if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_TEXT)
                {
                    V2TIMTextElem *elem = static_cast<V2TIMTextElem *>(item);

                    res[flutter::EncodableValue("textElem")] = ConvertDataUtils::convertTextElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_CUSTOM)
                {
                    V2TIMCustomElem *elem = static_cast<V2TIMCustomElem *>(item);

                    res[flutter::EncodableValue("customElem")] = ConvertDataUtils::convertCustomElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_FACE)
                {
                    V2TIMFaceElem *elem = static_cast<V2TIMFaceElem *>(item);

                    res[flutter::EncodableValue("faceElem")] = ConvertDataUtils::convertFaceElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_FILE)
                {
                    V2TIMFileElem *elem = static_cast<V2TIMFileElem *>(item);

                    res[flutter::EncodableValue("fileElem")] = ConvertDataUtils::convertFileElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_GROUP_TIPS)
                {
                    V2TIMGroupTipsElem *elem = static_cast<V2TIMGroupTipsElem *>(item);
                    res[flutter::EncodableValue("groupTipsElem")] = ConvertDataUtils::convertGroupTipsElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_IMAGE)
                {
                    V2TIMImageElem *elem = static_cast<V2TIMImageElem *>(item);
                    res[flutter::EncodableValue("imageElem")] = ConvertDataUtils::convertImageElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_LOCATION)
                {
                    V2TIMLocationElem *elem = static_cast<V2TIMLocationElem *>(item);
                    res[flutter::EncodableValue("locationElem")] = ConvertDataUtils::convertLocationElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_MERGER)
                {
                      V2TIMMergerElem* elem = static_cast<V2TIMMergerElem*>(item);
                      res[flutter::EncodableValue("mergerElem")] = ConvertDataUtils::convertMergeElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_NONE)
                {
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_SOUND)
                {
                    V2TIMSoundElem *elem = static_cast<V2TIMSoundElem *>(item);
                    res[flutter::EncodableValue("soundElem")] = ConvertDataUtils::convertSoundElemValue(elem);
                    break;
                }
                else if (item->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_VIDEO)
                {
                    V2TIMVideoElem *elem = static_cast<V2TIMVideoElem *>(item);
                    res[flutter::EncodableValue("videoElem")] = ConvertDataUtils::convertVideoElemValue(elem);
                    break;
                }
            }
        }
        static flutter::EncodableMap convertV2TIMMessage2Map(V2TIMMessage *message)
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("cloudCustomData")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(message->cloudCustomData.Data(), message->cloudCustomData.Size()));

            ConvertDataUtils::convertElemValue(message->elemList, res);
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(message->faceURL.CString());
            res[flutter::EncodableValue("friendRemark")] = flutter::EncodableValue(message->friendRemark.CString());
            res[flutter::EncodableValue("groupAtUserList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(message->groupAtUserList));
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(message->groupID.CString());
            res[flutter::EncodableValue("hasRiskContent")] = flutter::EncodableValue(message->hasRiskContent);
            res[flutter::EncodableValue("isBroadcastMessage")] = flutter::EncodableValue(message->isBroadcastMessage);
            res[flutter::EncodableValue("isExcludedFromContentModeration")] = flutter::EncodableValue(message->isExcludedFromContentModeration);
            res[flutter::EncodableValue("isExcludedFromLastMessage")] = flutter::EncodableValue(message->isExcludedFromLastMessage);
            res[flutter::EncodableValue("isExcludedFromUnreadCount")] = flutter::EncodableValue(message->isExcludedFromUnreadCount);
            res[flutter::EncodableValue("isPeerRead")] = flutter::EncodableValue(message->IsPeerRead());
            res[flutter::EncodableValue("isRead")] = flutter::EncodableValue(message->IsRead());
            res[flutter::EncodableValue("isSelf")] = flutter::EncodableValue(message->isSelf);
            res[flutter::EncodableValue("localCustomData")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(message->GetLocalCustomData().Data(), message->GetLocalCustomData().Size()));
            res[flutter::EncodableValue("localCustomInt")] = flutter::EncodableValue(message->GetLocalCustomInt());
            if (message->msgID.operator==(V2TIMString{ "-0-0" })) {
                res[flutter::EncodableValue("msgID")] = flutter::EncodableValue("");
            }
            else {
                res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(message->msgID.CString());
            }
           
            res[flutter::EncodableValue("nameCard")] = flutter::EncodableValue(message->nameCard.CString());
            res[flutter::EncodableValue("needReadReceipt")] = flutter::EncodableValue(message->needReadReceipt);
            res[flutter::EncodableValue("nickName")] = flutter::EncodableValue(message->nickName.CString());
            res[flutter::EncodableValue("offlinePushInfo")] = flutter::EncodableValue(ConvertDataUtils::converofflinePushInfo2Map(message->offlinePushInfo));
            res[flutter::EncodableValue("priority")] = flutter::EncodableValue(static_cast<int>(message->priority));
            res[flutter::EncodableValue("random")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(message->random));
            res[flutter::EncodableValue("revokeReason")] = flutter::EncodableValue(message->revokeReason.CString());
            res[flutter::EncodableValue("revokerInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserFullInfo2Map(message->revokerInfo));
            res[flutter::EncodableValue("sender")] = flutter::EncodableValue(message->sender.CString());
            res[flutter::EncodableValue("seq")] = flutter::EncodableValue(std::to_string(ConvertDataUtils::convertUint642Int(message->seq)));
            res[flutter::EncodableValue("status")] = flutter::EncodableValue(static_cast<int>(message->status));
            res[flutter::EncodableValue("supportMessageExtension")] = flutter::EncodableValue(message->supportMessageExtension);
            if (message->timestamp == 0) {
                 res[flutter::EncodableValue("timestamp")] = flutter::EncodableValue(std::time(0));
            }
            else {
                res[flutter::EncodableValue("timestamp")] = flutter::EncodableValue(message->timestamp);
            }
            
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(message->userID.CString());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue("");
            return res;
        }

        static flutter::EncodableMap convertV2TIMConversation2Map(const V2TIMConversation &info)
        {
            flutter::EncodableList glist = flutter::EncodableList();
            auto groupList = info.conversationGroupList;
            size_t glsize = groupList.Size();
            for (size_t i = 0; i < glsize; i++)
            {
                auto item = groupList[i];
                glist.push_back(flutter::EncodableValue(item.CString()));
            }
            flutter::EncodableList galist = flutter::EncodableList();
            auto groupAtList = info.groupAtInfolist;
            size_t galsize = groupAtList.Size();
            for (size_t j = 0; j < galsize; j++)
            {
                auto item = groupAtList[j];

                auto itemMap = flutter::EncodableMap();
                itemMap[flutter::EncodableValue("seq")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(item.seq));
                itemMap[flutter::EncodableValue("atType")] = flutter::EncodableValue(static_cast<int>(item.atType));
                galist.push_back(itemMap);
            }
            auto markList = info.markList;
            flutter::EncodableList mklist = flutter::EncodableList();
            size_t msize = markList.Size();
            for (size_t k = 0; k < msize; k++)
            {
                auto item = markList[k];
                mklist.push_back(ConvertDataUtils::convertUint642Int(item));
            }
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("c2cReadTimestamp")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.c2cReadTimestamp));
            res[flutter::EncodableValue("conversationID")] = flutter::EncodableValue(info.conversationID.CString());
            res[flutter::EncodableValue("customData")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(info.customData.Data(), info.customData.Size()));
            res[flutter::EncodableValue("draftText")] = flutter::EncodableValue(info.draftText.CString());
            res[flutter::EncodableValue("draftTimestamp")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.draftTimestamp));
            res[flutter::EncodableValue("faceUrl")] = flutter::EncodableValue(info.faceUrl.CString());
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(info.groupID.CString());
            res[flutter::EncodableValue("groupReadSequence")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.groupReadSequence));
            auto gt = info.groupType;
            auto workgt = V2TIMString{ "Private" };
            auto workNow = V2TIMString{ "Work" };
            V2TIMString finalgt;
            if (gt.operator==(workgt)) {
                finalgt = workNow;
            }
            else {
                finalgt = gt;
            }
            res[flutter::EncodableValue("groupType")] = flutter::EncodableValue(finalgt.CString());
            res[flutter::EncodableValue("isPinned")] = flutter::EncodableValue(info.isPinned);
            if (info.lastMessage != nullptr)
            {
                res[flutter::EncodableValue("lastMessage")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(info.lastMessage));
            }
            res[flutter::EncodableValue("orderkey")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(info.orderKey));
            res[flutter::EncodableValue("recvOpt")] = flutter::EncodableValue(static_cast<int>(info.recvOpt));
            res[flutter::EncodableValue("showName")] = flutter::EncodableValue(info.showName.CString());
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(static_cast<int>(info.type));
            res[flutter::EncodableValue("unreadCount")] = flutter::EncodableValue(info.unreadCount);
            res[flutter::EncodableValue("userID")] = flutter::EncodableValue(info.userID.CString());
            res[flutter::EncodableValue("conversationGroupList")] = flutter::EncodableValue(glist);
            res[flutter::EncodableValue("groupAtInfoList")] = flutter::EncodableValue(galist);
            res[flutter::EncodableValue("markList")] = flutter::EncodableValue(mklist);
            return res;
        }
        static flutter::EncodableList convertV2TIMConversationList2Map(const V2TIMConversationVector &info)
        {
            flutter::EncodableList list = flutter::EncodableList();
            size_t isize = info.Size();
            for (size_t i = 0; i < isize; i++)
            {
                list.push_back(ConvertDataUtils::convertV2TIMConversation2Map(info[i]));
            }
            return list;
        }
        static flutter::EncodableMap convertV2TIMConversationResult2Map(const V2TIMConversationResult &info)
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("isFinished")] = flutter::EncodableValue(info.isFinished);
            res[flutter::EncodableValue("nextSeq")] = flutter::EncodableValue(std::to_string(ConvertDataUtils::convertUint642Int(info.nextSeq)));
            res[flutter::EncodableValue("conversationList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(info.conversationList));
            return res;
        }
        static bool copyFile(const std::string &sourcePath, const std::string &destinationPath)
        {
            std::wstring wideOldName = ConvertDataUtils::ConvertToWideString(sourcePath);
            std::wstring wideNewName = ConvertDataUtils::ConvertToWideString(destinationPath);

            if (MoveFileW(wideOldName.c_str(), wideNewName.c_str())) {
                return true;
            }
            else {
                std::cout << "copyFile fail" << std::endl;
                return false;
            }
        }
        static bool deleteFile(const std::string &filePath)
        {
            std::wstring wideFilePath(filePath.begin(), filePath.end());

            if (DeleteFileW(wideFilePath.c_str())) {
                return true;
            }
            else {
                std::cout << "delete file error" << std::endl;
                return false;
            }
            return true;
        }
        static bool fileExists(const std::string& filePath) {
            return std::filesystem::exists(ConvertDataUtils::ConvertToWideString(filePath));
        }
    };
    class CommonCallback : public V2TIMCallback
    {
    public:
        CommonCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess() override
        {
            
            if (stringData.empty()) {
                _result->Success(FormatTIMCallback(0, ""));
            }
            else {
                _result->Success(FormatTIMValueCallback(0, "",flutter::EncodableValue(stringData)));
            }
        }
        void OnError(int error_code, const V2TIMString &desc) override
        {
            _result->Success(FormatTIMCallback(error_code, desc.CString()));
        }
        void setStringData(std::string data) {
            stringData = data;
        }

    private:
        std::string stringData = "";
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommV2TIMConversationResultValueCallback : public V2TIMValueCallback<V2TIMConversationResult>
    {
    public:
        CommV2TIMConversationResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMConversationResult &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationResult2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    std::map<V2TIMString, V2TIMMessage> mergemessageCache = {};
    class V2TIMMessageVectorValueCallbackReturn : public V2TIMValueCallback<V2TIMMessageVector>
    {
    public:
        V2TIMMessageVectorValueCallbackReturn(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, int type, int count, bool isMergeMessage)
        {
            _result = std::move(result);
            _type = type;
            _count = count;
            _isMerge = isMergeMessage;
        }
        void OnSuccess(const V2TIMMessageVector &value) override
        {
            if (_isMerge) {
                for (size_t i = 0; i < value.Size(); i++)
                {
                    auto msg = value[i];
                    mergemessageCache.insert(std::make_pair(msg.msgID, msg));
                }
            }
            if (_type == 6)
            {
                flutter::EncodableMap res = flutter::EncodableMap();
                res[flutter::EncodableValue("isFinished")] = flutter::EncodableValue(value.Size() < _count);
                res[flutter::EncodableValue("messageList")] = flutter::EncodableValue(ConvertDataUtils::V2TIMMessageVector2Map(value));
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
            }
            else
            {
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageVector2Map(value))));
            }
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        int _type;
        int _count;
        bool _isMerge;
    };
    class CommV2TIMConversationValueCallback : public V2TIMValueCallback<V2TIMConversation>
    {
    public:
        CommV2TIMConversationValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMConversation &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversation2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommUint64ValueCallback : public V2TIMValueCallback<uint64_t>
    {
    public:
        CommUint64ValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const uint64_t &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertUint642Int(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommV2TIMFriendInfoVectorValueCallback : public V2TIMValueCallback<V2TIMFriendInfoVector>
    {
    public:
        CommV2TIMFriendInfoVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendInfoVector &value) override
        {
            
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfoVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMFriendOperationResultValueCallback : public V2TIMValueCallback<V2TIMFriendOperationResult>
    {
    public:
        V2TIMFriendOperationResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendOperationResult &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendOperationResult2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };

    class V2TIMSendCallbackValueCallback : public V2TIMSendCallback
    {
    public:
        V2TIMSendCallbackValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, V2TIMMessage message, std::string id, std::vector<std::string> uuids)
        {
            _result = std::move(result);
            _message = message;
            _id = id;
            _uuids = uuids;
        }
        void OnProgress(uint32_t progress) override
        {

            auto res = flutter::EncodableMap();
            auto messageMap = ConvertDataUtils::convertV2TIMMessage2Map(&_message);
            messageMap[flutter::EncodableValue("id")] = flutter::EncodableValue(_id);
            res[flutter::EncodableValue("message")] = flutter::EncodableValue(messageMap);
            res[flutter::EncodableValue("progress")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(progress));
            sendMessageToDart("advancedMsgListener", "onSendMessageProgress", flutter::EncodableValue(res), _uuids);
        }
        void OnSuccess(const V2TIMMessage &value) override
        {
            auto messageMap = ConvertDataUtils::convertV2TIMMessage2Map(const_cast<V2TIMMessage *>(&value));
            messageMap[flutter::EncodableValue("id")] = flutter::EncodableValue(_id);
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(messageMap)));
            createdMessageMap.erase(_id);
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            auto createdMessageIt = createdMessageMap.find(_id);
            if (createdMessageIt!= createdMessageMap.end()) {
                auto msg = createdMessageIt->second;
                auto messageMap = ConvertDataUtils::convertV2TIMMessage2Map(const_cast<V2TIMMessage*>(&msg));
                messageMap[flutter::EncodableValue("id")] = flutter::EncodableValue(_id);
                _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue(messageMap)));
            }
            else {
                _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
            }
            
            createdMessageMap.erase(_id);
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        V2TIMMessage _message;
        std::string _id;
        std::vector<std::string> _uuids;
    };

    class V2TIMFriendApplicationResultValueCallback : public V2TIMValueCallback<V2TIMFriendApplicationResult>
    {
    public:
        V2TIMFriendApplicationResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, int type, const flutter::EncodableMap *param)
        {
            _result = std::move(result);
            _type = type;
            if (param != nullptr)
            {
                _param = *param;
            }
        }
        void OnSuccess(const V2TIMFriendApplicationResult &value) override
        {
            if (_type == 0)
            {
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendApplicationResult2Map(value))));
                return;
            }
            else if (_type == 1)
            {
                acceptFriendApplication(value);
                return;
            }
            else if (_type == 2)
            {
                refuseFriendApplication(value);
                return;
            }
            else if (_type == 3)
            {
                deleteFriendApplication(value);
            }
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
        void acceptFriendApplication(const V2TIMFriendApplicationResult &value)
        {
            auto responseType_it = _param.find(flutter::EncodableValue("responseType"));
            auto type_it = _param.find(flutter::EncodableValue("type"));
            auto userID_it = _param.find(flutter::EncodableValue("userID"));
            int responseType = 0;
            if (responseType_it != _param.end())
            {
                flutter::EncodableValue fvalue = responseType_it->second;
                if (!fvalue.IsNull())
                {
                    responseType = std::get<int>(fvalue);
                }
            }
            int type = 0;
            if (type_it != _param.end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<int>(fvalue);
                }
            }
            std::string userID = "";
            if (userID_it != _param.end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendApplication appli = V2TIMFriendApplication();
            for (size_t i = 0; i < value.applicationList.Size(); i++)
            {
                auto item = value.applicationList[i];
                int atype = static_cast<int>(item.type);
                bool istypeq = atype == type;
                bool isuseridq = item.userID.operator==(V2TIMString{ userID.c_str() });
                if (istypeq && isuseridq)
                {
                    appli = item;
                    break;
                }
            }
            V2TIMFriendOperationResultValueCallback *callback = new V2TIMFriendOperationResultValueCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->AcceptFriendApplication(appli, static_cast<V2TIMFriendAcceptType>(responseType), callback);
        }
        void refuseFriendApplication(const V2TIMFriendApplicationResult &value)
        {
            auto type_it = _param.find(flutter::EncodableValue("type"));
            auto userID_it = _param.find(flutter::EncodableValue("userID"));

            int type = 0;
            if (type_it != _param.end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<int>(fvalue);
                }
            }
            std::string userID = "";
            if (userID_it != _param.end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendApplication appli = V2TIMFriendApplication();
            for (size_t i = 0; i < value.applicationList.Size(); i++)
            {
                auto item = value.applicationList[i];
                int atype = static_cast<int>(item.type);
                bool istypeq = atype == type;
                bool isuseridq = item.userID.operator==(V2TIMString{ userID.c_str() });
                if (istypeq && isuseridq)
                {
                    appli = item;
                    break;
                }
            }
            V2TIMFriendOperationResultValueCallback *callback = new V2TIMFriendOperationResultValueCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->RefuseFriendApplication(appli, callback);
        }
        void deleteFriendApplication(const V2TIMFriendApplicationResult &value)
        {
            auto type_it = _param.find(flutter::EncodableValue("type"));
            auto userID_it = _param.find(flutter::EncodableValue("userID"));

            int type = 0;
            if (type_it != _param.end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<int>(fvalue);
                }
            }
            std::string userID = "";
            if (userID_it != _param.end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendApplication appli = V2TIMFriendApplication();
            for (size_t i = 0; i < value.applicationList.Size(); i++)
            {
                auto item = value.applicationList[i];
                int atype = static_cast<int>(item.type);
                bool istypeq = atype == type;
                bool isuseridq = item.userID.operator==(V2TIMString{ userID.c_str() });
                if (istypeq && isuseridq)
                {
                    appli = item;
                    break;
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->DeleteFriendApplication(appli, callback);
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        int _type;
         flutter::EncodableMap _param = flutter::EncodableMap();
    };

    // Call  

    // 
    class V2TIMTopicPermissionResultVectorCallback : public V2TIMValueCallback<V2TIMTopicPermissionResultVector> {
    public:
        V2TIMTopicPermissionResultVectorCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);

        }
        void OnSuccess(const V2TIMTopicPermissionResultVector& value) override {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMTopicPermissionResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString& error_message) override {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMPermissionGroupMemberInfoResultValueCallback : public V2TIMValueCallback<V2TIMPermissionGroupMemberInfoResult> {
    public:
        V2TIMPermissionGroupMemberInfoResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);

        }
        void OnSuccess(const V2TIMPermissionGroupMemberInfoResult& value) override {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupMemberInfoResulto2Map(value))));
        }
        void OnError(int error_code, const V2TIMString& error_message) override {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMPermissionGroupMemberOperationResultVectorValueCallback : public V2TIMValueCallback<V2TIMPermissionGroupMemberOperationResultVector> {
    public:
        V2TIMPermissionGroupMemberOperationResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);

        }
        void OnSuccess(const V2TIMPermissionGroupMemberOperationResultVector& value) override {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupMemberOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString& error_message) override {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMPermissionGroupInfoResultVectorValueCallback : public V2TIMValueCallback<V2TIMPermissionGroupInfoResultVector> {
    public:
        V2TIMPermissionGroupInfoResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);

        }
        void OnSuccess(const V2TIMPermissionGroupInfoResultVector& value) override {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupInfoResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString& error_message) override {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMPermissionGroupOperationResultVectorValueCallback : public V2TIMValueCallback<V2TIMPermissionGroupOperationResultVector> {
    public:
        V2TIMPermissionGroupOperationResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
            
        }
        void OnSuccess(const V2TIMPermissionGroupOperationResultVector& value) override {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString& error_message) override {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupInfoResultVectorValueCallback : public V2TIMValueCallback<V2TIMGroupInfoResultVector>
    {
    public:
        V2TIMGroupInfoResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result,bool isSet,const flutter::EncodableMap* _arguments)
        {
            _result = std::move(result);
            _isSet = isSet;
            if (_arguments != nullptr) {
                arguments = *_arguments;
            }
        }
        void OnSuccess(const V2TIMGroupInfoResultVector& value) override
        {
            if(!_isSet){
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupInfoResultVector2Map(value))));
            }
            else {
                if (!value.Empty()) {
                    auto infores = value[0];
                    if (infores.resultCode == 0) {
                        setGroupInfo(infores.info);
                    }
                    else {
                        _result->Success(FormatTIMValueCallback(-1, "get group info error", flutter::EncodableValue()));
                    }
                }
                else {
                    _result->Success(FormatTIMValueCallback(-1, "get group info error", flutter::EncodableValue()));
                }
                
            }
            
        }
        void OnError(int error_code, const V2TIMString& error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
        void setGroupInfo(const V2TIMGroupInfo& value) {
            auto groupType_it = arguments.find(flutter::EncodableValue("groupType"));
            auto groupName_it = arguments.find(flutter::EncodableValue("groupName"));
            auto notification_it = arguments.find(flutter::EncodableValue("notification"));
            auto introduction_it = arguments.find(flutter::EncodableValue("introduction"));
            auto faceUrl_it = arguments.find(flutter::EncodableValue("faceUrl"));
            auto isAllMuted_it = arguments.find(flutter::EncodableValue("isAllMuted"));
            auto groupAddOpt_it = arguments.find(flutter::EncodableValue("addOpt"));
            auto customInfo_it = arguments.find(flutter::EncodableValue("customInfo"));
            auto isSupportTopic_it = arguments.find(flutter::EncodableValue("isSupportTopic"));
            auto approveOpt_it = arguments.find(flutter::EncodableValue("approveOpt"));
            auto isEnablePermissionGroup_it = arguments.find(flutter::EncodableValue("isEnablePermissionGroup"));
            auto defaultPermissions_it = arguments.find(flutter::EncodableValue("defaultPermissions"));
            V2TIMGroupInfo info = value;
            uint32_t flag = 0x00;
            if (groupName_it != arguments.end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    info.groupName = V2TIMString{ std::get<std::string>(fvalue).c_str() };
                    flag |=  0x01;
                }
            }
            if (groupType_it != arguments.end())
            {
                flutter::EncodableValue fvalue = groupType_it->second;
                if (!fvalue.IsNull())
                {
                    std::string gt = std::get<std::string>(fvalue);
                    if (gt == "Work") {
                        gt = "Private";
                    }
                    info.groupType = V2TIMString{ gt.c_str() };
                }
            }
            if (notification_it != arguments.end())
            {
                flutter::EncodableValue fvalue = notification_it->second;
                if (!fvalue.IsNull())
                {
                    info.notification = V2TIMString{ std::get<std::string>(fvalue).c_str() };
                    flag |= 0x01 << 1;
                }
            }
            if (introduction_it != arguments.end())
            {
                flutter::EncodableValue fvalue = introduction_it->second;
                if (!fvalue.IsNull())
                {
                    info.introduction = V2TIMString{ std::get<std::string>(fvalue).c_str() };
                    flag |=  0x01 << 2;
                }
            }
            if (faceUrl_it != arguments.end())
            {
                flutter::EncodableValue fvalue = faceUrl_it->second;
                if (!fvalue.IsNull())
                {
                    info.faceURL = V2TIMString{ std::get<std::string>(fvalue).c_str() };
                    flag |=  0x01 << 3;
                }
            }
            if (isAllMuted_it != arguments.end())
            {
                flutter::EncodableValue fvalue = isAllMuted_it->second;
                if (!fvalue.IsNull())
                {
                    info.allMuted = std::get<bool>(fvalue);
                    flag |=  0x01 << 8;
                }
            }
            if (isSupportTopic_it != arguments.end())
            {
                flutter::EncodableValue fvalue = isSupportTopic_it->second;
                if (!fvalue.IsNull())
                {
                    info.isSupportTopic = std::get<bool>(fvalue);
                }
            }
            
            if (isEnablePermissionGroup_it != arguments.end())
            {
                flutter::EncodableValue fvalue = isEnablePermissionGroup_it->second;
                if (!fvalue.IsNull())
                {
                    auto isEnablePermissionGroup = std::get<bool>(fvalue);
                    info.enablePermissionGroup = isEnablePermissionGroup;
                    flag |= 0x1 << 13;
                }
            }
            if (defaultPermissions_it != arguments.end())
            {
                flutter::EncodableValue fvalue = defaultPermissions_it->second;
                if (!fvalue.IsNull())
                {
                  auto  defaultPermissions = std::get<int>(fvalue);
                  info.defaultPermissions = defaultPermissions;
                  flag |= 0x1 << 14;
                }
            }
            if (groupAddOpt_it != arguments.end())
            {
                flutter::EncodableValue fvalue = groupAddOpt_it->second;
                if (!fvalue.IsNull())
                {
                    info.groupAddOpt = static_cast<V2TIMGroupAddOpt>(std::get<int>(fvalue));
                    flag |=  0x01 << 4;
                }
            }
            if (approveOpt_it != arguments.end())
            {
                flutter::EncodableValue fvalue = approveOpt_it->second;
                if (!fvalue.IsNull())
                {
                    info.groupApproveOpt = static_cast<V2TIMGroupAddOpt>(std::get<int>(fvalue));
                    flag |= 0x01 << 12;
                }
            }
            if (customInfo_it != arguments.end())
            {
                flutter::EncodableValue fvalue = customInfo_it->second;
                if (!fvalue.IsNull())
                {
                    flutter::EncodableMap infomap = std::get<flutter::EncodableMap>(customInfo_it->second);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = infomap.begin(); iter != infomap.end(); iter++)

                    {
                        std::string data = std::get<std::string>(iter->second);
                        ctiminfo.Insert(V2TIMString{ std::get<std::string>(iter->first).c_str() }, ConvertDataUtils::string2Buffer(data));
                    }
                    info.customInfo = ctiminfo;
                    flag |= 0x01 << 9;
                }
            }
            info.modifyFlag = flag;
            CommonCallback* callback = new CommonCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupInfo(info, callback);
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        bool _isSet = false;
        flutter::EncodableMap arguments = flutter::EncodableMap();
    };
    class GetMessageOnlineSnapUrlValueCallback : public V2TIMValueCallback<V2TIMString>
    {
    public:
        GetMessageOnlineSnapUrlValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, V2TIMVideoElem *videoElem, flutter::EncodableMap basicData)
        {
            _result = std::move(result);
            _videoElem = videoElem;
            _basicData = basicData;
        }
        void OnSuccess(const V2TIMString &value) override
        {
            auto res = flutter::EncodableMap();
            if (_videoElem->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_VIDEO)
            {

                _basicData[flutter::EncodableValue("snapshotUrl")] = flutter::EncodableValue(value.CString());
                res[flutter::EncodableValue("videoElem")] = flutter::EncodableValue(_basicData);
            }
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        V2TIMVideoElem *_videoElem;
        flutter::EncodableMap _basicData = flutter::EncodableMap();
    };
    class GetMessageOnlineUrlValueCallback : public V2TIMValueCallback<V2TIMString>
    {
    public:
        GetMessageOnlineUrlValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, V2TIMElem* element)
        {
            _result = std::move(result);
            _element = element;
        }
        void OnSuccess(const V2TIMString &value) override
        {
            auto res = flutter::EncodableMap();
            if (_element->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_FILE)
            {
                V2TIMFileElem *elem = static_cast<V2TIMFileElem *>(_element);
                auto basicData = ConvertDataUtils::convertFileElemValue(elem);
                basicData[flutter::EncodableValue("url")] = flutter::EncodableValue(value.CString());
                res[flutter::EncodableValue("fileElem")] = flutter::EncodableValue(basicData);
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
            }
            else if (_element->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_SOUND)
            {
                V2TIMSoundElem *elem = static_cast<V2TIMSoundElem *>(_element);
                auto basicData = ConvertDataUtils::convertSoundElemValue(elem);
                basicData[flutter::EncodableValue("url")] = flutter::EncodableValue(value.CString());
                res[flutter::EncodableValue("soundElem")] = flutter::EncodableValue(basicData);
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
            }
            else if (_element->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_VIDEO)
            {
                V2TIMVideoElem *elem = static_cast<V2TIMVideoElem *>(_element);
                auto basicData = ConvertDataUtils::convertVideoElemValue(elem);
                basicData[flutter::EncodableValue("videoUrl")] = flutter::EncodableValue(value.CString());
                GetMessageOnlineSnapUrlValueCallback *callback = new GetMessageOnlineSnapUrlValueCallback(std::move(_result), elem, basicData);
                elem->GetSnapshotUrl(callback);
            }
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        V2TIMElem* _element;
    };
    class WindowsV2TIMDownloadCallback : public V2TIMDownloadCallback
    {
    public:
        WindowsV2TIMDownloadCallback(std::string msgID, int type, bool isSnapshot, std::string finalpath, std::string temppath, std::vector<std::string> uuids)
        {
            _msgID = msgID;
            _type = type;
            _path = finalpath;
            _isSnapshot = isSnapshot;
            _uuids = uuids;
            _tempPath = temppath;
        }
        void OnDownLoadProgress(uint64_t currentSize, uint64_t totalSize) override
        {

            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("isFinish")] = flutter::EncodableValue(false);
            res[flutter::EncodableValue("isError")] = flutter::EncodableValue(false);
            res[flutter::EncodableValue("currentSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(currentSize));
            res[flutter::EncodableValue("totalSize")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(totalSize));
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(_msgID.c_str());
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(_type);
            res[flutter::EncodableValue("isSnapshot")] = flutter::EncodableValue(_isSnapshot);
            res[flutter::EncodableValue("path")] = flutter::EncodableValue(_path);
            res[flutter::EncodableValue("errorCode")] = flutter::EncodableValue(0);
            res[flutter::EncodableValue("errorDesc")] = flutter::EncodableValue("");
            sendMessageToDart("advancedMsgListener", "onMessageDownloadProgressCallback", flutter::EncodableValue(res), _uuids);
        }

        void OnSuccess() override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("isFinish")] = flutter::EncodableValue(true);
            res[flutter::EncodableValue("isError")] = flutter::EncodableValue(false);
            res[flutter::EncodableValue("currentSize")] = flutter::EncodableValue(1);
            res[flutter::EncodableValue("totalSize")] = flutter::EncodableValue(1);
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(_msgID.c_str());
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(_type);
            res[flutter::EncodableValue("isSnapshot")] = flutter::EncodableValue(_isSnapshot);
            res[flutter::EncodableValue("path")] = flutter::EncodableValue(_path);
            res[flutter::EncodableValue("errorCode")] = flutter::EncodableValue(0);
            res[flutter::EncodableValue("errorDesc")] = flutter::EncodableValue("");
            // change file name from temp to final
            ConvertDataUtils::copyFile(_tempPath, _path);


            // remove downloading key
            downloading.erase(_tempPath);

            sendMessageToDart("advancedMsgListener", "onMessageDownloadProgressCallback", flutter::EncodableValue(res), _uuids);
        }

        void OnError(int error_code, const V2TIMString &error_message) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("isFinish")] = flutter::EncodableValue(false);
            res[flutter::EncodableValue("isError")] = flutter::EncodableValue(false);
            res[flutter::EncodableValue("currentSize")] = flutter::EncodableValue(1);
            res[flutter::EncodableValue("totalSize")] = flutter::EncodableValue(1);
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(_msgID.c_str());
            res[flutter::EncodableValue("type")] = flutter::EncodableValue(_type);
            res[flutter::EncodableValue("isSnapshot")] = flutter::EncodableValue(_isSnapshot);
            res[flutter::EncodableValue("path")] = flutter::EncodableValue(_path);
            res[flutter::EncodableValue("errorCode")] = flutter::EncodableValue(error_code);
            res[flutter::EncodableValue("errorDesc")] = flutter::EncodableValue(error_message.CString());
            // delete temp
            ConvertDataUtils::deleteFile(_tempPath);
            // remove downloading key
            downloading.erase(_tempPath);
            sendMessageToDart("advancedMsgListener", "onMessageDownloadProgressCallback", flutter::EncodableValue(res), _uuids);
        }

    private:
        std::string _msgID = "";
        int _type = 0;
        bool _isSnapshot = false;
        std::string _path = "";
        std::string _tempPath = "";
        std::vector<std::string> _uuids = {};
    };
    class V2TIMMessageCompleteCallback : public V2TIMCompleteCallback<V2TIMMessage>
    {
    public:
        V2TIMMessageCompleteCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnComplete(int error_code, const V2TIMString &error_message, const V2TIMMessage &value) override
        {
            if (error_code == 0)
            {
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map((const_cast<V2TIMMessage *>(&value))))));
            }
            else
            {
                _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
            }
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMStringVectorValueCallback : public V2TIMValueCallback<V2TIMStringVector>
    {
    public:
        V2TIMStringVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMStringVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::stringVetorToList(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMConversationOperationResultVectorValueCallback : public V2TIMValueCallback<V2TIMConversationOperationResultVector>
    {
    public:
        V2TIMConversationOperationResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMConversationOperationResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMConversationOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMUserStatusVectorValueCallback : public V2TIMValueCallback<V2TIMUserStatusVector>
    {
    public:
        V2TIMUserStatusVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMUserStatusVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserStatusVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMStringToV2TIMStringMapValueCallback : public V2TIMValueCallback<V2TIMStringToV2TIMStringMap>
    {
    public:
        V2TIMStringToV2TIMStringMapValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMStringToV2TIMStringMap &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMStringToV2TIMStringMap2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageReactionUserResultValueCallback : public V2TIMValueCallback<V2TIMMessageReactionUserResult>
    {
    public:
        V2TIMMessageReactionUserResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageReactionUserResult &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageReactionUserResult2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageReactionResultVectorValueCallback : public V2TIMValueCallback<V2TIMMessageReactionResultVector>
    {
    public:
        V2TIMMessageReactionResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageReactionResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageReactionResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageExtensionVectorValueCallback : public V2TIMValueCallback<V2TIMMessageExtensionVector>
    {
    public:
        V2TIMMessageExtensionVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageExtensionVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageExtensionVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageExtensionResultVectorValueCallback : public V2TIMValueCallback<V2TIMMessageExtensionResultVector>
    {
    public:
        V2TIMMessageExtensionResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageExtensionResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageExtensionResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupMessageReadMemberListValueCallback : public V2TIMValueCallback<V2TIMGroupMessageReadMemberList>
    {
    public:
        V2TIMGroupMessageReadMemberListValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupMessageReadMemberList &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMessageReadMemberList2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageReceiptVectorValueCallback : public V2TIMValueCallback<V2TIMMessageReceiptVector>
    {
    public:
        V2TIMMessageReceiptVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageReceiptVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReceiptVectorr2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageSearchResultValueCallback : public V2TIMValueCallback<V2TIMMessageSearchResult>
    {
    public:
        V2TIMMessageSearchResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessageSearchResult &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageSearchResult2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMMessageValueCallback : public V2TIMValueCallback<V2TIMMessage>
    {
    public:
        V2TIMMessageValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMMessage &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map((const_cast<V2TIMMessage *>(&value))))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };

    class V2TIMReceiveMessageOptInfoValueCallback : public V2TIMValueCallback<V2TIMReceiveMessageOptInfo>
    {
    public:
        V2TIMReceiveMessageOptInfoValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMReceiveMessageOptInfo &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMReceiveMessageOptInfo2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMReceiveMessageOptInfoVectorValueCallback : public V2TIMValueCallback<V2TIMReceiveMessageOptInfoVector>
    {
    public:
        V2TIMReceiveMessageOptInfoVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMReceiveMessageOptInfoVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMReceiveMessageOptInfoVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMTopicInfoResultVectorValueCallback : public V2TIMValueCallback<V2TIMTopicInfoResultVector>
    {
    public:
        V2TIMTopicInfoResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMTopicInfoResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMTopicInfoResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMTopicOperationResultVectorValueCallback : public V2TIMValueCallback<V2TIMTopicOperationResultVector>
    {
    public:
        V2TIMTopicOperationResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMTopicOperationResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMTopicOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupApplicationResultValueCallback : public V2TIMValueCallback<V2TIMGroupApplicationResult>
    {
    public:
        V2TIMGroupApplicationResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, int type, const flutter::EncodableMap *param)
        {
            _result = std::move(result);
            _type = type;
            if (param != nullptr)
            {
                arguments = *param;
            }
        }
        void OnSuccess(const V2TIMGroupApplicationResult &value) override
        {
            if (_type == 0)
            {
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupApplicationResult2Map(value))));
                return;
            }
            else if (_type == 1)
            {
                acceptGroupApplication(value);
                return;
            }
            else if (_type == 2)
            {
                refuseGroupApplication(value);
                return;
            }
            else if (_type == 3)
            {
            }
        }
        void acceptGroupApplication(const V2TIMGroupApplicationResult &value)
        {
            auto groupID_it = arguments.find(flutter::EncodableValue("groupID"));
            auto reason_it = arguments.find(flutter::EncodableValue("reason"));
            auto fromUser_it = arguments.find(flutter::EncodableValue("fromUser"));
            auto toUser_it = arguments.find(flutter::EncodableValue("toUser"));
            // auto addTime_it = arguments.find(flutter::EncodableValue("addTime"));
            auto type_it = arguments.find(flutter::EncodableValue("type"));
            std::string groupID = "";
            if (groupID_it != arguments.end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string reason = "";
            if (reason_it != arguments.end())
            {
                flutter::EncodableValue fvalue = reason_it->second;
                if (!fvalue.IsNull())
                {
                    reason = std::get<std::string>(fvalue);
                }
            }

            std::string fromUser = "";
            if (fromUser_it != arguments.end())
            {
                flutter::EncodableValue fvalue = fromUser_it->second;
                if (!fvalue.IsNull())
                {
                    fromUser = std::get<std::string>(fvalue);
                }
            }

            std::string toUser = "";
            if (toUser_it != arguments.end())
            {
                flutter::EncodableValue fvalue = toUser_it->second;
                if (!fvalue.IsNull())
                {
                    toUser = std::get<std::string>(fvalue);
                }
            }

            // int addTime = 0;
            // if (addTime_it != arguments.end())
            // {
            //     flutter::EncodableValue fvalue = addTime_it->second;
            //     if (!fvalue.IsNull())
            //     {
            //         addTime = std::get<int>(fvalue);
            //     }
            // }

            int type = 0;
            if (type_it != arguments.end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<int>(fvalue);
                }
            }
            V2TIMGroupApplication appli = V2TIMGroupApplication();
            for (size_t i = 0; i < value.applicationList.Size(); i++)
            {
                auto item = value.applicationList[i];
                int appType = static_cast<int>(item.applicationType);
                if (appType == type && item.fromUser.operator==(V2TIMString{ fromUser.c_str() })&& item.toUser.operator==(V2TIMString{ toUser.c_str() })&& item.groupID.operator==(V2TIMString{ groupID.c_str() }))
                {
                    appli = item;
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetGroupManager()->AcceptGroupApplication(appli, V2TIMString{reason.c_str()}, callback);
        }
        void refuseGroupApplication(const V2TIMGroupApplicationResult &value)
        {
            auto groupID_it = arguments.find(flutter::EncodableValue("groupID"));
            auto reason_it = arguments.find(flutter::EncodableValue("reason"));
            auto fromUser_it = arguments.find(flutter::EncodableValue("fromUser"));
            auto toUser_it = arguments.find(flutter::EncodableValue("toUser"));
            // auto addTime_it = arguments.find(flutter::EncodableValue("addTime"));
            auto type_it = arguments.find(flutter::EncodableValue("type"));
            std::string groupID = "";
            if (groupID_it != arguments.end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string reason = "";
            if (reason_it != arguments.end())
            {
                flutter::EncodableValue fvalue = reason_it->second;
                if (!fvalue.IsNull())
                {
                    reason = std::get<std::string>(fvalue);
                }
            }

            std::string fromUser = "";
            if (fromUser_it != arguments.end())
            {
                flutter::EncodableValue fvalue = fromUser_it->second;
                if (!fvalue.IsNull())
                {
                    fromUser = std::get<std::string>(fvalue);
                }
            }

            std::string toUser = "";
            if (toUser_it != arguments.end())
            {
                flutter::EncodableValue fvalue = toUser_it->second;
                if (!fvalue.IsNull())
                {
                    toUser = std::get<std::string>(fvalue);
                }
            }

            // int addTime = 0;
            // if (addTime_it != arguments.end())
            // {
            //     flutter::EncodableValue fvalue = addTime_it->second;
            //     if (!fvalue.IsNull())
            //     {
            //         addTime = std::get<int>(fvalue);
            //     }
            // }

            int type = 0;
            if (type_it != arguments.end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<int>(fvalue);
                }
            }
            V2TIMGroupApplication appli = V2TIMGroupApplication();
            for (size_t i = 0; i < value.applicationList.Size(); i++)
            {
                auto item = value.applicationList[i];
                int appType = static_cast<int>(item.applicationType);
                if (appType == type && item.fromUser.operator==(V2TIMString{ fromUser.c_str() })&& item.toUser.operator==(V2TIMString{ toUser.c_str() })&& item.groupID.operator==(V2TIMString{ groupID.c_str() }))
                {
                    appli = item;
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(_result));
            V2TIMManager::GetInstance()->GetGroupManager()->RefuseGroupApplication(appli, V2TIMString{reason.c_str()}, callback);
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        int _type;
        flutter::EncodableMap arguments = flutter::EncodableMap();
    };
    class V2TIMGroupMemberOperationResultVectorValueCallback : public V2TIMValueCallback<V2TIMGroupMemberOperationResultVector>
    {
    public:
        V2TIMGroupMemberOperationResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupMemberOperationResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMemberOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupSearchGroupMembersMapValueCallback : public V2TIMValueCallback<V2TIMGroupSearchGroupMembersMap>
    {
    public:
        V2TIMGroupSearchGroupMembersMapValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupSearchGroupMembersMap &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupSearchGroupMembersMap2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupMemberFullInfoVectorValueCallback : public V2TIMValueCallback<V2TIMGroupMemberFullInfoVector>
    {
    public:
        V2TIMGroupMemberFullInfoVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupMemberFullInfoVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMemberFullInfoVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMStringToInt64MapValueCallback : public V2TIMValueCallback<V2TIMStringToInt64Map>
    {
    public:
        V2TIMStringToInt64MapValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMStringToInt64Map &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMStringToInt64Map2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupMemberInfoResultValueCallback : public V2TIMValueCallback<V2TIMGroupMemberInfoResult>
    {
    public:
        V2TIMGroupMemberInfoResultValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupMemberInfoResult &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMGroupMemberInfoResult2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class Uint32TValueCallback : public V2TIMValueCallback<uint32_t>
    {
    public:
        Uint32TValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const uint32_t &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertUint322Int(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupAttributeMapValueCallback : public V2TIMValueCallback<V2TIMGroupAttributeMap>
    {
    public:
        V2TIMGroupAttributeMapValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupAttributeMap &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupAttributeMap2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMGroupInfoVectorValueCallback : public V2TIMValueCallback<V2TIMGroupInfoVector>
    {
    public:
        V2TIMGroupInfoVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMGroupInfoVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::converV2TIMGroupInfoVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMFriendInfoResultVectorValueCallback : public V2TIMValueCallback<V2TIMFriendInfoResultVector>
    {
    public:
        V2TIMFriendInfoResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendInfoResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfoResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMFriendOperationResultVectortValueCallback : public V2TIMValueCallback<V2TIMFriendOperationResultVector>
    {
    public:
        V2TIMFriendOperationResultVectortValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendOperationResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendOperationResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class V2TIMFriendGroupVectorValueCallback : public V2TIMValueCallback<V2TIMFriendGroupVector>
    {
    public:
        V2TIMFriendGroupVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendGroupVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendGroupVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };

    class V2TIMFriendCheckResultVectorValueCallback : public V2TIMValueCallback<V2TIMFriendCheckResultVector>
    {
    public:
        V2TIMFriendCheckResultVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMFriendCheckResultVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendCheckResultVector2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommV2TIMConversationVectorValueCallback : public V2TIMValueCallback<V2TIMConversationVector>
    {
    public:
        CommV2TIMConversationVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMConversationVector &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(value))));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommV2TIMBaseObjectValueCallback : public V2TIMValueCallback<V2TIMBaseObject>
    {
    public:
        CommV2TIMBaseObjectValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMBaseObject &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };
    class CommV2TIMUserFullInfoVectorValueCallback : public V2TIMValueCallback<V2TIMUserFullInfoVector>
    {
    public:
        CommV2TIMUserFullInfoVectorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, bool isSet,const flutter::EncodableMap* _arguments)
        {
            _result = std::move(result);
            _isSet = isSet;
            if (_arguments!=nullptr) {
                arguments = *_arguments;
            }
            
        }
        void OnSuccess(const V2TIMUserFullInfoVector &value) override
        {
            
            if (!_isSet) {
                size_t vsize = value.Size();
                auto list = flutter::EncodableList();
                for (size_t i = 0; i < vsize; i++)
                {
                    auto item = value[i];
                    list.push_back(ConvertDataUtils::convertV2TIMUserFullInfo2Map(item));
                }
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(list)));
            }
            else {
                setSelfInfo(value);
            }

            
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
        void setSelfInfo(const V2TIMUserFullInfoVector& value) {
            
            auto nickName_it = arguments.find(flutter::EncodableValue("nickName"));
            auto faceUrl_it = arguments.find(flutter::EncodableValue("faceUrl"));
            auto selfSignature_it = arguments.find(flutter::EncodableValue("selfSignature"));
            auto gender_it = arguments.find(flutter::EncodableValue("gender"));
            auto allowType_it = arguments.find(flutter::EncodableValue("allowType"));
            auto customInfo_it = arguments.find(flutter::EncodableValue("customInfo"));
            auto level_it = arguments.find(flutter::EncodableValue("level"));
            auto role_it = arguments.find(flutter::EncodableValue("role"));
            auto birthday_it = arguments.find(flutter::EncodableValue("birthday"));
            std::string nickName = "--";
            if (nickName_it != arguments.end())
            {
                flutter::EncodableValue fvalue = nickName_it->second;
                if (!fvalue.IsNull())
                {

                    nickName = std::get<std::string>(fvalue);
                }
            }
            std::string faceUrl = "--";
            if (faceUrl_it != arguments.end())
            {
                flutter::EncodableValue fvalue = faceUrl_it->second;
                if (!fvalue.IsNull())
                {
                    faceUrl = std::get<std::string>(fvalue);
                }
            }
            std::string selfSignature = "--";
            if (selfSignature_it != arguments.end())
            {
                flutter::EncodableValue fvalue = selfSignature_it->second;
                if (!fvalue.IsNull())
                {

                    selfSignature = std::get<std::string>(fvalue);
                }
            }
            int gender = -1;
            if (gender_it != arguments.end())
            {
                flutter::EncodableValue fvalue = gender_it->second;
                if (!fvalue.IsNull())
                {
                    gender = std::get<int>(fvalue);
                }
            }
            int allowType = -1;
            if (allowType_it != arguments.end())
            {
                flutter::EncodableValue fvalue = allowType_it->second;
                if (!fvalue.IsNull())
                {
                    allowType = std::get<int>(fvalue);
                }
            }
            int level = -1;
            if (level_it != arguments.end())
            {
                flutter::EncodableValue fvalue = level_it->second;
                if (!fvalue.IsNull())
                {
                    level = std::get<int>(fvalue);
                }
            }
            int role = -1;
            if (role_it != arguments.end())
            {
                flutter::EncodableValue fvalue = role_it->second;
                if (!fvalue.IsNull())
                {
                    role = std::get<int>(fvalue);
                }
            }
            int birthday = -1;
            if (birthday_it != arguments.end())
            {
                flutter::EncodableValue fvalue = birthday_it->second;
                if (!fvalue.IsNull())
                {
                    birthday = std::get<int>(fvalue);
                }
            }

            V2TIMUserFullInfo info = value[0];
            int32_t flag = 0;
            flutter::EncodableMap customInfo;
            if (customInfo_it != arguments.end())
            {
                flutter::EncodableValue fvalue = customInfo_it->second;
                if (!fvalue.IsNull())
                {
                    flutter::EncodableMap infomap = std::get<flutter::EncodableMap>(customInfo_it->second);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = infomap.begin(); iter != infomap.end(); iter++)

                    {
                        std::string data = std::get<std::string>(iter->second);
                        ctiminfo.Insert(V2TIMString{ std::get<std::string>(iter->first).c_str() }, ConvertDataUtils::string2Buffer(data));
                    }
                    info.customInfo = ctiminfo;
                    flag = flag | 11;
                }
            }
            if (allowType != -1)
            {
                info.allowType = static_cast<V2TIMFriendAllowType>(allowType);
                flag = flag | 10;
            }
            if (birthday != -1)
            {
                info.birthday = birthday;
                flag = flag | 4;
            }
            if (faceUrl != "--")
            {
                info.faceURL = V2TIMString{ faceUrl.c_str() };
                flag = flag | 2;
            }
            if (gender != -1)
            {
                info.gender = static_cast<V2TIMGender>(gender);
                flag = flag | 3;
            }
            if (level != -1)
            {
                info.level = level;
                flag = flag | 8;
            }

            if (nickName != "--")
            {
                info.nickName = V2TIMString{ nickName.c_str() };
                flag = flag | 1;
            }
            if (role != -1)
            {
                info.role = role;
                flag = flag | 9;
            }
            if (selfSignature != "--")
            {
                info.selfSignature = V2TIMString{ selfSignature.c_str() };
                flag = flag | 7;
            }
            info.modifyFlag = flag;

            CommonCallback* callback = new CommonCallback(std::move(_result));

            V2TIMManager::GetInstance()->SetSelfInfo(info, callback);
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        bool _isSet = false;
        flutter::EncodableMap arguments = flutter::EncodableMap();
    };
    class CommV2TIMStringValueCallback : public V2TIMValueCallback<V2TIMString>
    {
    public:
        CommV2TIMStringValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
        {
            _result = std::move(result);
        }
        void OnSuccess(const V2TIMString &value) override
        {

            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(value.CString())));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
    };

    // windows listeners
    class WindowsV2TIMFriendshipListener : public V2TIMFriendshipListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        void OnFriendApplicationListAdded(const V2TIMFriendApplicationVector &applicationList) override
        {
            sendMessageToDart("friendListener", "onFriendApplicationListAdded", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendApplicationVector2Map(applicationList)), this->getUuids());
        }

        void OnFriendApplicationListDeleted(const V2TIMStringVector &userIDList) override
        {

            sendMessageToDart("friendListener", "onFriendApplicationListDeleted", flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(userIDList)), this->getUuids());
        }

        void OnFriendApplicationListRead() override
        {
            sendMessageToDart("friendListener", "onFriendApplicationListRead", flutter::EncodableValue(), this->getUuids());
        }

        void OnFriendListAdded(const V2TIMFriendInfoVector &userIDList) override
        {
            sendMessageToDart("friendListener", "onFriendListAdded", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfoVector2Map(userIDList)), this->getUuids());
        }

        void OnFriendListDeleted(const V2TIMStringVector &userIDList) override
        {
            sendMessageToDart("friendListener", "onFriendListDeleted", flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(userIDList)), this->getUuids());
        }

        void OnBlackListAdded(const V2TIMFriendInfoVector &infoList) override
        {
            sendMessageToDart("friendListener", "onBlackListAdd", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfoVector2Map(infoList)), this->getUuids());
        }

        void OnBlackListDeleted(const V2TIMStringVector &userIDList) override
        {
            sendMessageToDart("friendListener", "onBlackListDeleted", flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(userIDList)), this->getUuids());
        }

        void OnFriendInfoChanged(const V2TIMFriendInfoVector &infoList) override
        {
            sendMessageToDart("friendListener", "onFriendInfoChanged", flutter::EncodableValue(ConvertDataUtils::convertV2TIMFriendInfoVector2Map(infoList)), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMGroupListenerListener : public V2TIMGroupListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        virtual void OnMemberEnter(const V2TIMString &groupID, const V2TIMGroupMemberInfoVector &memberList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(memberList));
            sendMessageToDart("groupListener", "onMemberEnter", flutter::EncodableValue(res), this->getUuids());
        }

        void OnMemberLeave(const V2TIMString &groupID, const V2TIMGroupMemberInfo &member) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("member")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(member));
            sendMessageToDart("groupListener", "onMemberLeave", flutter::EncodableValue(res), this->getUuids());
        }

        void OnMemberInvited(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser, const V2TIMGroupMemberInfoVector &memberList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            res[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(memberList));
            sendMessageToDart("groupListener", "onMemberInvited", flutter::EncodableValue(res), this->getUuids());
        }

        void OnMemberKicked(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser, const V2TIMGroupMemberInfoVector &memberList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            res[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(memberList));
            sendMessageToDart("groupListener", "onMemberKicked", flutter::EncodableValue(res), this->getUuids());
        }

        void OnMemberInfoChanged(const V2TIMString &groupID, const V2TIMGroupMemberChangeInfoVector &v2TIMGroupMemberChangeInfoList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("groupMemberChangeInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberChangeInfoVector2Map(v2TIMGroupMemberChangeInfoList));
            sendMessageToDart("groupListener", "onMemberInfoChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnAllGroupMembersMuted(const V2TIMString &groupID, bool isMute) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("isMute")] = flutter::EncodableValue(isMute);
            sendMessageToDart("groupListener", "onAllGroupMembersMuted", flutter::EncodableValue(res), this->getUuids());
        }

        void OnMemberMarkChanged(const V2TIMString &groupID, const V2TIMStringVector &memberIDList, uint32_t markType, bool enableMark) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("memberIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(memberIDList));
            res[flutter::EncodableValue("markType")] = flutter::EncodableValue(ConvertDataUtils::convertUint322Int(markType));
            res[flutter::EncodableValue("enableMark")] = flutter::EncodableValue(enableMark);
            sendMessageToDart("groupListener", "onMemberMarkChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupCreated(const V2TIMString &groupID) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            sendMessageToDart("groupListener", "onGroupCreated", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupDismissed(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("groupListener", "onGroupDismissed", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupRecycled(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("groupListener", "onGroupRecycled", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupInfoChanged(const V2TIMString &groupID, const V2TIMGroupChangeInfoVector &changeInfos) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("groupChangeInfoList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupChangeInfoVector2Map(changeInfos));
            sendMessageToDart("groupListener", "onGroupInfoChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupAttributeChanged(const V2TIMString &groupID, const V2TIMGroupAttributeMap &groupAttributeMap) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("groupAttributeMap")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupAttributeMap2Map(groupAttributeMap));
            sendMessageToDart("groupListener", "onGroupAttributeChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGroupCounterChanged(const V2TIMString &groupID, const V2TIMString &key, int64_t newValue) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("key")] = flutter::EncodableValue(key.CString());
            res[flutter::EncodableValue("value")] = flutter::EncodableValue(newValue);
            sendMessageToDart("groupListener", "onGroupCounterChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnReceiveJoinApplication(const V2TIMString &groupID, const V2TIMGroupMemberInfo &member, const V2TIMString &opReason) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opReason")] = flutter::EncodableValue(opReason.CString());
            res[flutter::EncodableValue("member")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(member));
            sendMessageToDart("groupListener", "onReceiveJoinApplication", flutter::EncodableValue(res), this->getUuids());
        }

        void OnApplicationProcessed(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser, bool isAgreeJoin, const V2TIMString &opReason) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("opReason")] = flutter::EncodableValue(opReason.CString());
            res[flutter::EncodableValue("isAgreeJoin")] = flutter::EncodableValue(isAgreeJoin);
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("groupListener", "onApplicationProcessed", flutter::EncodableValue(res), this->getUuids());
        }

        void OnGrantAdministrator(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser, const V2TIMGroupMemberInfoVector &memberList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(memberList));
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("groupListener", "onGrantAdministrator", flutter::EncodableValue(res), this->getUuids());
        }

        void OnRevokeAdministrator(const V2TIMString &groupID, const V2TIMGroupMemberInfo &opUser, const V2TIMGroupMemberInfoVector &memberList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("memberList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfoVector2Map(memberList));
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("groupListener", "onRevokeAdministrator", flutter::EncodableValue(res), this->getUuids());
        }

        void OnQuitFromGroup(const V2TIMString &groupID) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            sendMessageToDart("groupListener", "onQuitFromGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void OnReceiveRESTCustomData(const V2TIMString &groupID, const V2TIMBuffer &customData) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("customData")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(customData.Data(), customData.Size()));
            sendMessageToDart("groupListener", "onReceiveRESTCustomData", flutter::EncodableValue(res), this->getUuids());
        }

        void OnTopicCreated(const V2TIMString &groupID, const V2TIMString &topicID) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicID")] = flutter::EncodableValue(topicID.CString());
            sendMessageToDart("groupListener", "onTopicCreated", flutter::EncodableValue(res), this->getUuids());
        }

        void OnTopicDeleted(const V2TIMString &groupID, const V2TIMStringVector &topicIDList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(topicIDList));
            sendMessageToDart("groupListener", "onTopicDeleted", flutter::EncodableValue(res), this->getUuids());
        }

        void OnTopicChanged(const V2TIMString &groupID, const V2TIMTopicInfo &topicInfo) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMTopicInfo2Map(topicInfo));
            sendMessageToDart("groupListener", "onTopicChanged", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMConversationListener : public V2TIMConversationListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        void OnSyncServerStart() override
        {
            sendMessageToDart("conversationListener", "onSyncServerStart", flutter::EncodableValue(), this->getUuids());
        }

        void OnSyncServerFinish() override
        {
            sendMessageToDart("conversationListener", "onSyncServerFinish", flutter::EncodableValue(), this->getUuids());
        }

        void OnSyncServerFailed() override
        {
            sendMessageToDart("conversationListener", "onSyncServerFailed", flutter::EncodableValue(), this->getUuids());
        }

        void OnNewConversation(const V2TIMConversationVector &conversationList) override
        {
            sendMessageToDart("conversationListener", "onNewConversation", flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(conversationList)), this->getUuids());
        }

        void OnConversationChanged(const V2TIMConversationVector &conversationList) override
        {
            sendMessageToDart("conversationListener", "onConversationChanged", flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(conversationList)), this->getUuids());
        }

        void OnConversationDeleted(const V2TIMStringVector &conversationIDList) override
        {
            size_t idsize = conversationIDList.Size();
            flutter::EncodableList resList = flutter::EncodableList();
            for (size_t i = 0; i < idsize; i++)
            {
                resList.push_back(flutter::EncodableValue(conversationIDList[i].CString()));
            }
            sendMessageToDart("conversationListener", "onConversationDeleted", flutter::EncodableValue(resList), this->getUuids());
        }

        void OnTotalUnreadMessageCountChanged(uint64_t totalUnreadCount) override
        {
            sendMessageToDart("conversationListener", "onTotalUnreadMessageCountChanged", flutter::EncodableValue(ConvertDataUtils::convertUint642Int(totalUnreadCount)), this->getUuids());
        }

        void OnUnreadMessageCountChangedByFilter(const V2TIMConversationListFilter &filter, uint64_t totalUnreadCount) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("filter")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationListFilter2Map(filter));
            res[flutter::EncodableValue("totalUnreadCount")] = flutter::EncodableValue(ConvertDataUtils::convertUint642Int(totalUnreadCount));
            sendMessageToDart("conversationListener", "onUnreadMessageCountChangedByFilter", flutter::EncodableValue(res), this->getUuids());
        }

        void OnConversationGroupCreated(const V2TIMString &groupName, const V2TIMConversationVector &conversationList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupName")] = flutter::EncodableValue(groupName.CString());
            res[flutter::EncodableValue("conversationList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(conversationList));
            sendMessageToDart("conversationListener", "onConversationGroupCreated", flutter::EncodableValue(res), this->getUuids());
        }

        void OnConversationGroupDeleted(const V2TIMString &groupName) override
        {
            sendMessageToDart("conversationListener", "onConversationGroupDeleted", flutter::EncodableValue(groupName.CString()), this->getUuids());
        }

        void OnConversationGroupNameChanged(const V2TIMString &oldName, const V2TIMString &newName) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("oldName")] = flutter::EncodableValue(oldName.CString());
            res[flutter::EncodableValue("newName")] = flutter::EncodableValue(newName.CString());
            sendMessageToDart("conversationListener", "onConversationGroupNameChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnConversationsAddedToGroup(const V2TIMString &groupName, const V2TIMConversationVector &conversationList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupName")] = flutter::EncodableValue(groupName.CString());
            res[flutter::EncodableValue("conversationList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(conversationList));
            sendMessageToDart("conversationListener", "onConversationsAddedToGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void OnConversationsDeletedFromGroup(const V2TIMString &groupName, const V2TIMConversationVector &conversationList) override
        {
            flutter::EncodableMap res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupName")] = flutter::EncodableValue(groupName.CString());
            res[flutter::EncodableValue("conversationList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMConversationList2Map(conversationList));
            sendMessageToDart("conversationListener", "onConversationsDeletedFromGroup", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMSDKListener : public V2TIMSDKListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void OnConnecting() override
        {
            sendMessageToDart("initSDKListener", "onConnecting", flutter::EncodableValue(), this->getUuids());
        }
        void OnConnectSuccess() override
        {
            sendMessageToDart("initSDKListener", "onConnectSuccess", flutter::EncodableValue(), this->getUuids());
        }
        void OnConnectFailed(int error_code, const V2TIMString &error_message) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("code")] = flutter::EncodableValue(error_code);
            res[flutter::EncodableValue("desc")] = flutter::EncodableValue(error_message.CString());
            sendMessageToDart("initSDKListener", "onConnectFailed", flutter::EncodableValue(res), this->getUuids());
        }
        void OnKickedOffline() override
        {
            sendMessageToDart("initSDKListener", "onKickedOffline", flutter::EncodableValue(), this->getUuids());
        }
        void OnUserSigExpired() override
        {
            sendMessageToDart("initSDKListener", "onUserSigExpired", flutter::EncodableValue(), this->getUuids());
        }
        void OnSelfInfoUpdated(const V2TIMUserFullInfo &info) override
        {
            sendMessageToDart("initSDKListener", "onSelfInfoUpdated", flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserFullInfo2Map(info)), this->getUuids());
        }
        void OnUserStatusChanged(const V2TIMUserStatusVector &userStatusList) override
        {
            
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("statusList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserStatusVector2Map(userStatusList));
            sendMessageToDart("initSDKListener", "onUserStatusChanged", flutter::EncodableValue(res), this->getUuids());
        }
        void OnUserInfoChanged(const V2TIMUserFullInfoVector &userInfoList) override
        {
            sendMessageToDart("initSDKListener", "onUserInfoChanged", flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserFullInfoVector2Map(userInfoList)), this->getUuids());
        }
        void OnAllReceiveMessageOptChanged(const V2TIMReceiveMessageOptInfo &receiveMessageOptInfo) override
        {
            sendMessageToDart("initSDKListener", "onAllReceiveMessageOptChanged", flutter::EncodableValue(ConvertDataUtils::convertV2TIMReceiveMessageOptInfo2Map(receiveMessageOptInfo)), this->getUuids());
        }
        void onExperimentalNotify(const V2TIMString &key, const V2TIMString &param) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("key")] = flutter::EncodableValue(key.CString());
            res[flutter::EncodableValue("param")] = flutter::EncodableValue(param.CString());
            sendMessageToDart("initSDKListener", "onExperimentalNotify", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMAdvancedMsgListener : public V2TIMAdvancedMsgListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        void OnRecvNewMessage(const V2TIMMessage &message) override
        {
            // TODO add avchatroom message cache
            sendMessageToDart("advancedMsgListener", "onRecvNewMessage", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(const_cast<V2TIMMessage *>(&message))), this->getUuids());
        }

        void OnRecvC2CReadReceipt(const V2TIMMessageReceiptVector &receiptList) override
        {
            sendMessageToDart("advancedMsgListener", "onRecvC2CReadReceipt", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReceiptVectorr2Map(receiptList)), this->getUuids());
        }

        void OnRecvMessageReadReceipts(const V2TIMMessageReceiptVector &receiptList) override
        {
            sendMessageToDart("advancedMsgListener", "onRecvMessageReadReceipts", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReceiptVectorr2Map(receiptList)), this->getUuids());
        }

        void OnRecvMessageRevoked(const V2TIMString &msgID, const V2TIMUserFullInfo &operateUser, const V2TIMString &reason) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(msgID.CString());
            res[flutter::EncodableValue("operateUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMUserFullInfo2Map(operateUser));
            res[flutter::EncodableValue("reason")] = flutter::EncodableValue(reason.CString());
            sendMessageToDart("advancedMsgListener", "onRecvMessageRevokedWithInfo", flutter::EncodableValue(res), this->getUuids());
        }

        void OnRecvMessageModified(const V2TIMMessage &message) override
        {
            sendMessageToDart("advancedMsgListener", "onRecvMessageModified", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(const_cast<V2TIMMessage *>(&message))), this->getUuids());
        }

        void OnRecvMessageExtensionsChanged(const V2TIMString &msgID, const V2TIMMessageExtensionVector &extensions) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(msgID.CString());
            res[flutter::EncodableValue("extensions")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageExtensionVector2Map(extensions));
            sendMessageToDart("advancedMsgListener", "onRecvMessageExtensionsChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnRecvMessageExtensionsDeleted(const V2TIMString &msgID, const V2TIMStringVector &extensionKeys) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("msgID")] = flutter::EncodableValue(msgID.CString());
            res[flutter::EncodableValue("extensionKeys")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(extensionKeys));
            sendMessageToDart("advancedMsgListener", "onRecvMessageExtensionsDeleted", flutter::EncodableValue(res), this->getUuids());
        }

        void OnRecvMessageReactionsChanged(const V2TIMMessageReactionChangeInfoVector &changeInfos) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("changeInfos")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessageReactionChangeInfoVector2Map(changeInfos));
            sendMessageToDart("advancedMsgListener", "onRecvMessageReactionsChanged", flutter::EncodableValue(res), this->getUuids());
        }

        void OnRecvMessageRevoked(const V2TIMString &msgID) override
        {
            sendMessageToDart("advancedMsgListener", "onRecvMessageRevoked", flutter::EncodableValue(msgID.CString()), this->getUuids());
        }
        void OnGroupMessagePinned(const V2TIMString& groupID,
            const V2TIMMessage& message,
            bool 	isPinned,
            const V2TIMGroupMemberInfo& opUser
        ) override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("isPinned")] = flutter::EncodableValue(isPinned);
            res[flutter::EncodableValue("message")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(const_cast<V2TIMMessage*>(&message)));
            res[flutter::EncodableValue("opUser")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMGroupMemberInfo2Map(opUser));
            sendMessageToDart("advancedMsgListener", "onGroupMessagePinned", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMSignalingListener : public V2TIMSignalingListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        void OnReceiveNewInvitation(const V2TIMString &inviteID, const V2TIMString &inviter, const V2TIMString &groupID, const V2TIMStringVector &inviteeList, const V2TIMString &data) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("inviter")] = flutter::EncodableValue(inviter.CString());
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("inviteeList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(inviteeList));
            res[flutter::EncodableValue("data")] = flutter::EncodableValue(data.CString());
            sendMessageToDart("signalingListener", "onReceiveNewInvitation", flutter::EncodableValue(res), this->getUuids());
        }

        void OnInviteeAccepted(const V2TIMString &inviteID, const V2TIMString &invitee, const V2TIMString &data) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("invitee")] = flutter::EncodableValue(invitee.CString());
            res[flutter::EncodableValue("data")] = flutter::EncodableValue(data.CString());
            sendMessageToDart("signalingListener", "onInviteeAccepted", flutter::EncodableValue(res), this->getUuids());
        }

        void OnInviteeRejected(const V2TIMString &inviteID, const V2TIMString &invitee, const V2TIMString &data) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("invitee")] = flutter::EncodableValue(invitee.CString());
            res[flutter::EncodableValue("data")] = flutter::EncodableValue(data.CString());
            sendMessageToDart("signalingListener", "onInviteeRejected", flutter::EncodableValue(res), this->getUuids());
        }

        void OnInvitationCancelled(const V2TIMString &inviteID, const V2TIMString &inviter, const V2TIMString &data) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("inviter")] = flutter::EncodableValue(inviter.CString());
            res[flutter::EncodableValue("data")] = flutter::EncodableValue(data.CString());
            sendMessageToDart("signalingListener", "onInvitationCancelled", flutter::EncodableValue(res), this->getUuids());
        }

        void OnInvitationTimeout(const V2TIMString &inviteID, const V2TIMStringVector &inviteeList) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("inviteeList")] = flutter::EncodableValue(ConvertDataUtils::stringVetorToList(inviteeList));
            sendMessageToDart("signalingListener", "onInvitationTimeout", flutter::EncodableValue(res), this->getUuids());
        }

        void OnInvitationModified(const V2TIMString &inviteID, const V2TIMString &data) override
        {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("inviteID")] = flutter::EncodableValue(inviteID.CString());
            res[flutter::EncodableValue("data")] = flutter::EncodableValue(data.CString());
            sendMessageToDart("signalingListener", "onInvitationModified", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    class WindowsV2TIMCommunityListener : public V2TIMCommunityListener
    {
    public:
        void setUuid(std::string uuid)
        {
            _uuid.push_back(uuid);
        }
        void cleanUuid()
        {
            _uuid.clear();
        }
        std::vector<std::string> getUuids()
        {
            return _uuid;
        }
        size_t uuidSize()
        {
            return _uuid.size();
        }
        void removeUuid(std::string uid)
        {
            std::vector<std::string>::iterator i;
            for (i = _uuid.begin(); i != _uuid.end();)
            {
                if (*i == uid)
                {
                    i = _uuid.erase(i);
                }
                else
                {
                    i++;
                }
            }
        }
        void  OnCreateTopic(const V2TIMString& groupID, const V2TIMString& topicID) override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicID")] = flutter::EncodableValue(topicID.CString());
            sendMessageToDart("communityListener", "onCreateTopic", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnDeleteTopic(const V2TIMString& groupID, const V2TIMStringVector& topicIDList)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(topicIDList));
            sendMessageToDart("communityListener", "onDeleteTopic", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnChangeTopicInfo(const V2TIMString& groupID, const V2TIMTopicInfo& topicInfo)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("topicInfo")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMTopicInfo2Map(topicInfo));
            sendMessageToDart("communityListener", "onChangeTopicInfo", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnReceiveTopicRESTCustomData(const V2TIMString& topicID, const V2TIMBuffer& customData)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("customData")] = flutter::EncodableValue(ConvertDataUtils::V2TIMBuffer2String(customData.Data(), customData.Size()));
            res[flutter::EncodableValue("topicID")] = flutter::EncodableValue(topicID.CString());
            sendMessageToDart("communityListener", "onReceiveTopicRESTCustomData", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnCreatePermissionGroup(const V2TIMString& groupID, const V2TIMPermissionGroupInfo& permissionGroupInfo)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupInfo")] = flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupInfo2Map(permissionGroupInfo));
            sendMessageToDart("communityListener", "onCreatePermissionGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void OnDeletePermissionGroup(const V2TIMString &groupID, const V2TIMStringVector &permissionGroupIDList) override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(permissionGroupIDList));
            sendMessageToDart("communityListener", "onDeletePermissionGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnChangePermissionGroupInfo(const V2TIMString& groupID, const V2TIMPermissionGroupInfo& permissionGroupInfo)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupInfo")] = flutter::EncodableValue(ConvertDataUtils::V2TIMPermissionGroupInfo2Map(permissionGroupInfo));
            sendMessageToDart("communityListener", "onChangePermissionGroupInfo", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnAddMembersToPermissionGroup(const V2TIMString& groupID, const V2TIMString& permissionGroupID, const V2TIMStringVector& memberIDList)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(permissionGroupID.CString());
            res[flutter::EncodableValue("memberIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(memberIDList));
            sendMessageToDart("communityListener", "onAddMembersToPermissionGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnRemoveMembersFromPermissionGroup(const V2TIMString& groupID, const V2TIMString& permissionGroupID, const V2TIMStringVector& memberIDList)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(permissionGroupID.CString());
            res[flutter::EncodableValue("memberIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(memberIDList));
            sendMessageToDart("communityListener", "onRemoveMembersFromPermissionGroup", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnAddTopicPermission(const V2TIMString& groupID, const V2TIMString& permissionGroupID, const V2TIMStringToUint64Map& topicPermissionMap)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(permissionGroupID.CString());
            res[flutter::EncodableValue("topicPermissionMap")] = flutter::EncodableValue(ConvertDataUtils::V2TIMStringToUInt64Map2Map(topicPermissionMap));
            sendMessageToDart("communityListener", "onAddTopicPermission", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnDeleteTopicPermission(const V2TIMString& groupID, const V2TIMString& permissionGroupID, const V2TIMStringVector& topicIDList)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(permissionGroupID.CString());
            res[flutter::EncodableValue("topicIDList")] = flutter::EncodableValue(ConvertDataUtils::convertV2TIMStringVector2Map(topicIDList));
            sendMessageToDart("communityListener", "onDeleteTopicPermission", flutter::EncodableValue(res), this->getUuids());
        }

        void  OnModifyTopicPermission(const V2TIMString& groupID, const V2TIMString& permissionGroupID, const V2TIMStringToUint64Map& topicPermissionMap)override {
            auto res = flutter::EncodableMap();
            res[flutter::EncodableValue("groupID")] = flutter::EncodableValue(groupID.CString());
            res[flutter::EncodableValue("permissionGroupID")] = flutter::EncodableValue(permissionGroupID.CString());
            res[flutter::EncodableValue("topicPermissionMap")] = flutter::EncodableValue(ConvertDataUtils::V2TIMStringToUInt64Map2Map(topicPermissionMap));
            sendMessageToDart("communityListener", "onModifyTopicPermission", flutter::EncodableValue(res), this->getUuids());
        }

    private:
        std::vector<std::string> _uuid = {};
    };
    // static
    void TencentCloudChatSdkPlugin::RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar)
    {
        auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(registrar->messenger(), "tencent_cloud_chat_sdk", &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<TencentCloudChatSdkPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));

        _channel = std::move(channel);
    }

    TencentCloudChatSdkPlugin::TencentCloudChatSdkPlugin() {}

    TencentCloudChatSdkPlugin::~TencentCloudChatSdkPlugin() {}

    WindowsV2TIMSDKListener *sdkListener = new WindowsV2TIMSDKListener();
    WindowsV2TIMConversationListener *conversationListenr = new WindowsV2TIMConversationListener();
    WindowsV2TIMGroupListenerListener *groupListener = new WindowsV2TIMGroupListenerListener();
    WindowsV2TIMFriendshipListener *friendListener = new WindowsV2TIMFriendshipListener();
    WindowsV2TIMAdvancedMsgListener *messageListener = new WindowsV2TIMAdvancedMsgListener();
    WindowsV2TIMSignalingListener *signalListener = new WindowsV2TIMSignalingListener();
    WindowsV2TIMCommunityListener* communityListener = new WindowsV2TIMCommunityListener();

    class V2TIMMessageVetorValueCallback : public V2TIMValueCallback<V2TIMMessageVector>
    {
    public:
        V2TIMMessageVetorValueCallback(std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result, int type, const flutter::EncodableMap *param, std::map<std::string, V2TIMMessage> *createdMsgMap)
        {
            _result = std::move(result);
            _type = type;
            if (param != nullptr)
            {
                _param = *param;
            }
            _createMsgMap = createdMsgMap;
        }
        void OnSuccess(const V2TIMMessageVector &value) override
        {
            if (_type == 0)
            {
                createForwardMessage(value);
                return;
            }
            else if (_type == 1)
            {
                createMergerMessage(value);
                return;
            }

            else if (_type == 3)
            {
                setLocalCustomData(value);
                return;
            }
            else if (_type == 4)
            {
                setLocalCustomInt(value);
                return;
            }
            else if (_type == 5)
            {
                getHistoryMessageList(value);
                return;
            }
            else if (_type == 6)
            {
                getHistoryMessageList(value);
                return;
            }
            else if (_type == 7)
            {
                revokeMessage(value);
                return;
            }
            else if (_type == 8)
            {
                deleteMessageFromLocalStorage(value);
                return;
            }
            else if (_type == 9)
            {
                deleteMessages(value);
                return;
            }
            else if (_type == 10)
            {
                findMessages(value);
                return;
            }
            else if (_type == 11)
            {
                sendMessageReadReceipts(value);
                return;
            }
            else if (_type == 12)
            {
                getMessageReadReceipts(value);
                return;
            }
            else if (_type == 13)
            {
                getGroupMessageReadMemberList(value);
                return;
            }
            else if (_type == 14)
            {
                modifyMessage(value);
                return;
            }
            else if (_type == 15)
            {
                downloadMergerMessage(value);
                return;
            }
            else if (_type == 16)
            {
                convertVoiceToText(value);
                return;
            }
            else if (_type == 17)
            {
                getSignalingInfo(value);
                return;
            }
            else if (_type == 18)
            {
                setMessageExtensions(value);
                return;
            }
            else if (_type == 19)
            {
                getMessageExtensions(value);
                return;
            }
            else if (_type == 20)
            {
                deleteMessageExtensions(value);
                return;
            }
            else if (_type == 21)
            {
                getMessageOnlineUrl(value);
                return;
            }
            else if (_type == 22)
            {
                
                downloadMessage(value);
                return;
            }else if (_type == 23)
            {
                addMessageReaction(value);
                return;
            }else if (_type == 24)
            {
                removeMessageReaction(value);
                return;
            }else if (_type == 25)
            {
                getMessageReactions(value);
                return;
            }else if (_type == 26)
            {
                getAllUserListOfMessageReaction(value);
                return;
            }
            else if (_type == 27) {
                pinGroupMessage(value);
                return;
            }
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        void OnError(int error_code, const V2TIMString &error_message) override
        {
            _result->Success(FormatTIMValueCallback(error_code, error_message.CString(), flutter::EncodableValue()));
        }
        void pinGroupMessage(V2TIMMessageVector messages) {
            auto groupID_it = _param.find(flutter::EncodableValue("groupID"));
            auto isPinned_it = _param.find(flutter::EncodableValue("isPinned"));
            std::string groupID = "";

            if (groupID_it != _param.end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            bool isPinned = false;

            if (isPinned_it != _param.end())
            {
                flutter::EncodableValue fvalue = isPinned_it->second;
                if (!fvalue.IsNull())
                {
                    isPinned = std::get<bool>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                 CommonCallback* callback = new CommonCallback(std::move(_result));
                 V2TIMManager::GetInstance()->GetMessageManager()->PinGroupMessage(V2TIMString{ groupID.c_str() }, messages[0], isPinned, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
            
        }
        void addMessageReaction(V2TIMMessageVector messages){
            auto reactionID_it = _param.find(flutter::EncodableValue("reactionID"));
            std::string reactionID = "";

            if (reactionID_it != _param.end())
            {
                flutter::EncodableValue fvalue = reactionID_it->second;
                if (!fvalue.IsNull())
                {
                    reactionID = std::get<std::string>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                CommonCallback* callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->AddMessageReaction(messages[0], V2TIMString{ reactionID.c_str()}, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void removeMessageReaction(V2TIMMessageVector messages){
            auto reactionID_it = _param.find(flutter::EncodableValue("reactionID"));
            std::string reactionID = "";

            if (reactionID_it != _param.end())
            {
                flutter::EncodableValue fvalue = reactionID_it->second;
                if (!fvalue.IsNull())
                {
                    reactionID = std::get<std::string>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                CommonCallback* callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->RemoveMessageReaction(messages[0], V2TIMString{ reactionID.c_str() }, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getMessageReactions(V2TIMMessageVector messages){
            auto maxUserCountPerReaction_it = _param.find(flutter::EncodableValue("maxUserCountPerReaction"));
            int maxUserCountPerReaction = 0;
            if (maxUserCountPerReaction_it != _param.end())
            {
                flutter::EncodableValue fvalue = maxUserCountPerReaction_it->second;
                if (!fvalue.IsNull())
                {
                    maxUserCountPerReaction = std::get<int>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                V2TIMMessageReactionResultVectorValueCallback* callback = new V2TIMMessageReactionResultVectorValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->GetMessageReactions(messages, maxUserCountPerReaction, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getAllUserListOfMessageReaction(V2TIMMessageVector messages){
            auto reactionID_it = _param.find(flutter::EncodableValue("reactionID"));
            auto nextSeq_it = _param.find(flutter::EncodableValue("nextSeq"));
            auto count_it = _param.find(flutter::EncodableValue("count"));
            std::string reactionID = "";

            if (reactionID_it != _param.end())
            {
                flutter::EncodableValue fvalue = reactionID_it->second;
                if (!fvalue.IsNull())
                {
                    reactionID = std::get<std::string>(fvalue);
                }
            }
            int nextSeq = 0;
            if (nextSeq_it != _param.end())
            {
                flutter::EncodableValue fvalue = nextSeq_it->second;
                if (!fvalue.IsNull())
                {
                    nextSeq = std::get<int>(fvalue);
                }
            }
            int count = 0;
            if (count_it != _param.end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                V2TIMMessageReactionUserResultValueCallback* callback = new V2TIMMessageReactionUserResultValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->GetAllUserListOfMessageReaction(messages[0], V2TIMString{ reactionID.c_str()} ,nextSeq,count, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        
        void getHistoryMessageList(V2TIMMessageVector messages)
        {
            auto getType_it = _param.find(flutter::EncodableValue("getType"));
            auto userID_it = _param.find(flutter::EncodableValue("userID"));
            auto groupID_it = _param.find(flutter::EncodableValue("groupID"));
            auto lastMsgSeq_it = _param.find(flutter::EncodableValue("lastMsgSeq"));
            auto count_it = _param.find(flutter::EncodableValue("count"));
            auto lastMsgID_it = _param.find(flutter::EncodableValue("lastMsgID"));
            auto messageTypeList_it = _param.find(flutter::EncodableValue("messageTypeList"));
            auto messageSeqList_it = _param.find(flutter::EncodableValue("messageSeqList"));
            auto timeBegin_it = _param.find(flutter::EncodableValue("timeBegin"));
            auto timePeriod_it = _param.find(flutter::EncodableValue("timePeriod"));
            V2TIMMessageListGetOption opt = V2TIMMessageListGetOption();
            int getType = 0;
            if (getType_it != _param.end())
            {
                flutter::EncodableValue fvalue = getType_it->second;
                if (!fvalue.IsNull())
                {
                    getType = std::get<int>(fvalue);
                    opt.getType = static_cast<V2TIMMessageGetType>(getType);
                }
            }

            std::string userID = "";
            if (userID_it != _param.end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                    if (!userID.empty()) {
                        opt.userID = V2TIMString{ userID.c_str() };
                    }
                    
                }
            }

            std::string groupID = "";
            if (groupID_it != _param.end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                    if (!groupID.empty()) {
                        opt.groupID = V2TIMString{ groupID.c_str() };
                    }
                }
            }

            int lastMsgSeq = -1;
            if (lastMsgSeq_it != _param.end())
            {
                flutter::EncodableValue fvalue = lastMsgSeq_it->second;
                if (!fvalue.IsNull())
                {
                    lastMsgSeq = std::get<int>(fvalue);
                    if (lastMsgSeq != -1) {
                        opt.lastMsgSeq = lastMsgSeq;
                    }
                }
            }

            int count = -1;
            if (count_it != _param.end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                    opt.count = count;
                }
            }

            flutter::EncodableList messageTypeList = {};
            if (messageTypeList_it != _param.end())
            {

                messageTypeList = std::get<flutter::EncodableList>(messageTypeList_it->second);
            }

            V2TIMElemTypeVector uids = {};
            size_t usize = messageTypeList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<int>(messageTypeList[i]);
                uids.PushBack(static_cast<V2TIMElemType>(uid));
            }
            opt.messageTypeList = uids;
            flutter::EncodableList messageSeqList = {};
            if (messageSeqList_it != _param.end())
            {

                messageSeqList = std::get<flutter::EncodableList>(messageSeqList_it->second);
            }

            V2TIMUInt64Vector uid2s = {};
            size_t u2size = messageSeqList.size();
            for (size_t i = 0; i < u2size; i++)
            {
                auto uid = std::get<int>(messageSeqList[i]);
                uid2s.PushBack(uid);
            }
            opt.messageSeqList = uid2s;
            int timeBegin = 0;
            if (timeBegin_it != _param.end())
            {
                flutter::EncodableValue fvalue = timeBegin_it->second;
                if (!fvalue.IsNull())
                {
                    timeBegin = std::get<int>(fvalue);
                    opt.getTimeBegin = timeBegin;
                }
            }

            int timePeriod = 0;
            if (timePeriod_it != _param.end())
            {
                flutter::EncodableValue fvalue = timePeriod_it->second;
                if (!fvalue.IsNull())
                {
                    timePeriod = std::get<int>(fvalue);
                    opt.getTimePeriod = timePeriod;
                }
            }
            if (!messages.Empty())
            {
                opt.lastMsg = &messages[0];
            }

            V2TIMMessageVectorValueCallbackReturn *callback = new V2TIMMessageVectorValueCallbackReturn(std::move(_result), _type, count,false);
            V2TIMManager::GetInstance()->GetMessageManager()->GetHistoryMessageList(opt, callback);
        }
        void setLocalCustomData(V2TIMMessageVector messages)
        {
            auto localCustomData_it = _param.find(flutter::EncodableValue("localCustomData"));

            std::string localCustomData = "";
            if (localCustomData_it != _param.end())
            {
                flutter::EncodableValue fvalue = localCustomData_it->second;
                if (!fvalue.IsNull())
                {
                    localCustomData = std::get<std::string>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                messages[0].cloudCustomData = ConvertDataUtils::string2Buffer(localCustomData);
            }
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        void setLocalCustomInt(V2TIMMessageVector messages)
        {
            auto localCustomInt_it = _param.find(flutter::EncodableValue("localCustomInt"));

            int localCustomInt = -1;
            if (localCustomInt_it != _param.end())
            {
                flutter::EncodableValue fvalue = localCustomInt_it->second;
                if (!fvalue.IsNull())
                {
                    localCustomInt = std::get<int>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                CommonCallback* callback = new CommonCallback(std::move(_result));
               messages[0].SetLocalCustomInt(localCustomInt,callback);
               return;
            }
            _result->Success(FormatTIMValueCallback(-1, "message is not found", flutter::EncodableValue()));
        }
        void createMergerMessage(V2TIMMessageVector messages)
        {
            auto title_it = _param.find(flutter::EncodableValue("title"));
            auto abstractList_it = _param.find(flutter::EncodableValue("abstractList"));
            auto compatibleText_it = _param.find(flutter::EncodableValue("compatibleText"));

            std::string title = "";
            if (title_it != _param.end())
            {
                flutter::EncodableValue fvalue = title_it->second;
                if (!fvalue.IsNull())
                {
                    title = std::get<std::string>(fvalue);
                }
            }
            std::string compatibleText = "";
            if (compatibleText_it != _param.end())
            {
                flutter::EncodableValue fvalue = compatibleText_it->second;
                if (!fvalue.IsNull())
                {
                    compatibleText = std::get<std::string>(fvalue);
                }
            }

            flutter::EncodableList abstractList = {};
            if (abstractList_it != _param.end())
            {
                flutter::EncodableValue fvalue = abstractList_it->second;

                abstractList = std::get<flutter::EncodableList>(fvalue);
            }

            V2TIMStringVector uid2s = {};
            size_t u2size = abstractList.size();
            for (size_t i = 0; i < u2size; i++)
            {
                
                auto s = std::get<std::string>(abstractList[i]);
                auto wide = ConvertDataUtils::ConvertToWideString(s);
                auto validateString = ConvertDataUtils::validateString(s);
                uid2s.PushBack(V2TIMString{ validateString.c_str() });
            }
            auto createdMessage = V2TIMManager::GetInstance()->GetMessageManager()->CreateMergerMessage(messages, V2TIMString{title.c_str()}, uid2s, V2TIMString{compatibleText.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            _createMsgMap->insert(std::make_pair(id, createdMessage));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&createdMessage);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        void createForwardMessage(V2TIMMessageVector messages)
        {
            V2TIMMessage message = messages[0];
            auto createdMessage = V2TIMManager::GetInstance()->GetMessageManager()->CreateForwardMessage(message);

            std::string id = ConvertDataUtils::generateRandomString();
            _createMsgMap->insert(std::make_pair(id, createdMessage));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&createdMessage);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        void findMessages(V2TIMMessageVector messages)
        {
            _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMMessageVector2Map(messages))));
        }
        void revokeMessage(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                CommonCallback *callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->RevokeMessage(messages[0], callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void deleteMessageFromLocalStorage(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                CommonCallback* callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->DeleteMessages(messages, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void deleteMessages(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                CommonCallback *callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->DeleteMessages(messages, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void sendMessageReadReceipts(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                CommonCallback *callback = new CommonCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->SendMessageReadReceipts(messages, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getMessageReadReceipts(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                V2TIMMessageReceiptVectorValueCallback *callback = new V2TIMMessageReceiptVectorValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->GetMessageReadReceipts(messages, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getGroupMessageReadMemberList(V2TIMMessageVector messages)
        {
            auto filter_it = _param.find(flutter::EncodableValue("filter"));
            auto nextSeq_it = _param.find(flutter::EncodableValue("nextSeq"));
            auto count_it = _param.find(flutter::EncodableValue("count"));

            int filter = 0;
            if (filter_it != _param.end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    filter = std::get<int>(fvalue);
                }
            }

            int nextSeq = 0;
            if (nextSeq_it != _param.end())
            {
                flutter::EncodableValue fvalue = nextSeq_it->second;
                if (!fvalue.IsNull())
                {
                    nextSeq = std::get<int>(fvalue);
                }
            }

            int count = 10;
            if (count_it != _param.end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                }
            }
            if (!messages.Empty())
            {
                V2TIMGroupMessageReadMemberListValueCallback *callback = new V2TIMGroupMessageReadMemberListValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->GetGroupMessageReadMemberList(messages[0], static_cast<V2TIMGroupMessageReadMembersFilter>(filter), nextSeq, count, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void modifyMessage(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                auto message_it = _param.find(flutter::EncodableValue("message"));

                flutter::EncodableValue fvalue = message_it->second;
                if (!fvalue.IsNull())
                {
                    auto messageMap = std::get<flutter::EncodableMap>(fvalue);

                    auto cloudCustomData_it = messageMap.find(flutter::EncodableValue("cloudCustomData"));
                    auto localCustomInt_it = messageMap.find(flutter::EncodableValue("localCustomInt"));
                    auto localCustomData_it = messageMap.find(flutter::EncodableValue("localCustomData"));
                    auto textElem_it = messageMap.find(flutter::EncodableValue("textElem"));
                    auto customElem_it = messageMap.find(flutter::EncodableValue("customElem"));

                    if (cloudCustomData_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = cloudCustomData_it->second;
                        if (!vv.IsNull())
                        {
                            messages[0].cloudCustomData = ConvertDataUtils::string2Buffer(std::get<std::string>(vv));
                        }
                    }
                    if (localCustomInt_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = localCustomInt_it->second;
                        if (!vv.IsNull())
                        {
                            messages[0].SetLocalCustomInt(std::get<int>(vv),nullptr);
                        }
                    }
                    if (localCustomData_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = localCustomData_it->second;
                        if (!vv.IsNull())
                        {
                            messages[0].SetLocalCustomData(ConvertDataUtils::string2Buffer(std::get<std::string>(vv)), nullptr);
                        }
                    }
                    if (textElem_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = textElem_it->second;

                        if (!vv.IsNull())
                        {
                            V2TIMTextElem *textelem = new V2TIMTextElem();
                            auto textMap = std::get<flutter::EncodableMap>(vv);
                            auto text_it = textMap.find(flutter::EncodableValue("text"));
                            if (messages[0].elemList.Size() == 1 && messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_TEXT)
                            {
                                textelem = static_cast<V2TIMTextElem *>(messages[0].elemList[0]);
                            }
                            if (text_it != textMap.end())
                            {
                                flutter::EncodableValue tvv = text_it->second;
                                if (!tvv.IsNull())
                                {

                                    textelem->text = V2TIMString{std::get<std::string>(tvv).c_str()};
                                }
                            }
                            messages[0].elemList[0] = textelem;
                        }
                    }
                    if (customElem_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = customElem_it->second;
                        if (!vv.IsNull())
                        {
                            auto customMap = std::get<flutter::EncodableMap>(vv);
                            auto data_it = customMap.find(flutter::EncodableValue("data"));
                            auto desc_it = customMap.find(flutter::EncodableValue("desc"));
                            auto extension_it = customMap.find(flutter::EncodableValue("extension"));
                            V2TIMCustomElem *customElem = new V2TIMCustomElem();
                            if (messages[0].elemList.Size() == 1 && messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_CUSTOM)
                            {
                                customElem = static_cast<V2TIMCustomElem *>(messages[0].elemList[0]);
                            }
                            if (data_it != customMap.end())
                            {
                                flutter::EncodableValue tvv = data_it->second;
                                if (!tvv.IsNull())
                                {
                                    customElem->data = ConvertDataUtils::string2Buffer(std::get<std::string>(tvv));
                                }
                            }
                            if (desc_it != customMap.end())
                            {
                                flutter::EncodableValue tvv = desc_it->second;
                                if (!tvv.IsNull())
                                {
                                    customElem->desc = V2TIMString{std::get<std::string>(tvv).c_str()};
                                }
                            }
                            if (extension_it != customMap.end())
                            {
                                flutter::EncodableValue tvv = extension_it->second;
                                if (!tvv.IsNull())
                                {
                                    customElem->extension = V2TIMString{std::get<std::string>(tvv).c_str()};
                                }
                            }
                            messages[0].elemList[0] = customElem;
                        }
                    }
                }

                V2TIMMessageCompleteCallback *callback = new V2TIMMessageCompleteCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->ModifyMessage(messages[0], callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void downloadMergerMessage(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                if (messages[0].elemList.Size() > 0)
                {
                    if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_MERGER)
                    {
                        V2TIMMessageVectorValueCallbackReturn *callback = new V2TIMMessageVectorValueCallbackReturn(std::move(_result), 5, 10,true);
                        V2TIMMergerElem *elem = static_cast<V2TIMMergerElem *>(messages[0].elemList[0]);

                        elem->DownloadMergerMessage(callback);
                    }
                    else
                    {
                        _result->Success(FormatTIMValueCallback(-1, "this message is not a merge elem", flutter::EncodableValue()));
                    }
                }
                else
                {
                    _result->Success(FormatTIMValueCallback(-1, "elemList not found", flutter::EncodableValue()));
                }
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void convertVoiceToText(V2TIMMessageVector messages)
        {

            if (!messages.Empty())
            {
                auto language_it = _param.find(flutter::EncodableValue("language"));
                std::string language = "";
                if (language_it != _param.end())
                {
                    flutter::EncodableValue fvalue = language_it->second;
                    if (!fvalue.IsNull())
                    {
                        language = std::get<std::string>(fvalue);
                    }
                }
                if (messages[0].elemList.Size() > 0)
                {
                    if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_SOUND)
                    {
                        CommV2TIMStringValueCallback *callback = new CommV2TIMStringValueCallback(std::move(_result));
                        V2TIMSoundElem *elem = static_cast<V2TIMSoundElem *>(messages[0].elemList[0]);

                        elem->ConvertVoiceToText(V2TIMString{language.c_str()}, callback);
                    }
                    else
                    {
                        _result->Success(FormatTIMValueCallback(-1, "this message is not a voice elem", flutter::EncodableValue()));
                    }
                }
                else
                {
                    _result->Success(FormatTIMValueCallback(-1, "elemList not found", flutter::EncodableValue()));
                }
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getSignalingInfo(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                V2TIMSignalingInfo info = V2TIMManager::GetInstance()->GetSignalingManager()->GetSignalingInfo(messages[0]);
                _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::V2TIMSignalingInfo2Map(info))));
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void setMessageExtensions(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                auto extensions_it = _param.find(flutter::EncodableValue("extensions"));
                V2TIMMessageExtensionVector list = {};
                flutter::EncodableValue fvalue = extensions_it->second;
                if (!fvalue.IsNull())
                {
                    auto extList = std::get<flutter::EncodableList>(fvalue);

                    size_t lsize = extList.size();
                    for (size_t i = 0; i < lsize; i++)
                    {
                        auto item = std::get<flutter::EncodableMap>(extList[i]);
                        auto key_it = item.find(flutter::EncodableValue("key"));
                        auto value_it = item.find(flutter::EncodableValue("value"));
                        V2TIMMessageExtension ext = V2TIMMessageExtension();
                        if (key_it != item.end())
                        {
                            flutter::EncodableValue vv = key_it->second;
                            if (!vv.IsNull())
                            {
                                ext.extensionKey = V2TIMString{std::get<std::string>(vv).c_str()};
                            }
                        }
                        if (value_it != item.end())
                        {
                            flutter::EncodableValue vv = value_it->second;
                            if (!vv.IsNull())
                            {
                                ext.extensionValue = V2TIMString{std::get<std::string>(vv).c_str()};
                            }
                        }
                        list.PushBack(ext);
                    }
                }
                V2TIMMessageExtensionResultVectorValueCallback *callback = new V2TIMMessageExtensionResultVectorValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->SetMessageExtensions(messages[0], list, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getMessageExtensions(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                V2TIMMessageExtensionVectorValueCallback *callback = new V2TIMMessageExtensionVectorValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->GetMessageExtensions(messages[0], callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void deleteMessageExtensions(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                auto keys_it = _param.find(flutter::EncodableValue("keys"));
                flutter::EncodableList keys = {};
                if (keys_it != _param.end())
                {

                    keys = std::get<flutter::EncodableList>(keys_it->second);
                }
                V2TIMStringVector uids = {};
                size_t usize = keys.size();
                for (size_t i = 0; i < usize; i++)
                {
                    auto uid = std::get<std::string>(keys[i]).c_str();
                    uids.PushBack(V2TIMString{uid});
                }
                V2TIMMessageExtensionResultVectorValueCallback *callback = new V2TIMMessageExtensionResultVectorValueCallback(std::move(_result));
                V2TIMManager::GetInstance()->GetMessageManager()->DeleteMessageExtensions(messages[0], uids, callback);
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void getMessageOnlineUrl(V2TIMMessageVector messages)
        {
            if (!messages.Empty())
            {
                auto cumessage = messages[0];
                if (cumessage.elemList.Size() > 0)
                {
                    auto elem = cumessage.elemList[0];
                    if (elem->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_FILE)
                    {
                        V2TIMFileElem *file = static_cast<V2TIMFileElem *>(elem);
                        GetMessageOnlineUrlValueCallback *callback = new GetMessageOnlineUrlValueCallback(std::move(_result), elem);
                        file->GetUrl(callback);
                    }
                    else if (elem->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_SOUND)
                    {
                        V2TIMSoundElem *sound = static_cast<V2TIMSoundElem *>(elem);
                        GetMessageOnlineUrlValueCallback *callback = new GetMessageOnlineUrlValueCallback(std::move(_result), elem);
                        sound->GetUrl(callback);
                    }
                    else if (elem->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_VIDEO)
                    {
                        V2TIMVideoElem *video = static_cast<V2TIMVideoElem *>(elem);
                        GetMessageOnlineUrlValueCallback *callback = new GetMessageOnlineUrlValueCallback(std::move(_result), elem);
                        video->GetVideoUrl(callback);
                    }
                    else
                    {
                        _result->Success(FormatTIMValueCallback(-1, "this message dont need to get online url", flutter::EncodableValue()));
                    }
                }
                else
                {
                    _result->Success(FormatTIMValueCallback(-1, "elemList not found", flutter::EncodableValue()));
                }
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }
        void downloadMessage(V2TIMMessageVector messages)
        {
            auto messageType_it = _param.find(flutter::EncodableValue("messageType"));
            auto imageType_it = _param.find(flutter::EncodableValue("imageType"));
            auto isSnapshot_it = _param.find(flutter::EncodableValue("isSnapshot"));
            auto msgID_it = _param.find(flutter::EncodableValue("msgID"));
            std::string msgID = "";
            if (msgID_it != _param.end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessage cachedMessage = V2TIMMessage{};
            std::map<V2TIMString, V2TIMMessage> ::iterator msgit;
            std::map<V2TIMString, V2TIMMessage> ::iterator msgitend;
            msgit = mergemessageCache.begin();
            msgitend = mergemessageCache.end();

            while (msgit != msgitend)
            {
                if (msgit->first.operator==(V2TIMString{ msgID.c_str()})) {
                    auto mmsg = msgit->second;
                    cachedMessage = mmsg;
                }
            }
            int messageType = 0;
            if (messageType_it != _param.end())
            {
                flutter::EncodableValue fvalue = messageType_it->second;
                if (!fvalue.IsNull())
                {
                    messageType = std::get<int>(fvalue);
                }
            }
            int imageType = 0;
            if (imageType_it != _param.end())
            {
                flutter::EncodableValue fvalue = imageType_it->second;
                if (!fvalue.IsNull())
                {
                    imageType = std::get<int>(fvalue);
                }
            }
            bool isSnapshot = false;
            if (isSnapshot_it != _param.end())
            if (messages.Empty()) {
                if (cachedMessage.msgID.operator==(V2TIMString{ msgID.c_str() })) {
                    messages.PushBack(cachedMessage);
                }
            }
            if (!messages.Empty())
            {
                if (messages[0].elemList.Size() == 0)
                {
                    _result->Success(FormatTIMValueCallback(-1, "elemList not found", flutter::EncodableValue()));
                }
                else
                {
                    if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_IMAGE)
                    {
                        V2TIMImageElem *imageElem = static_cast<V2TIMImageElem *>(messages[0].elemList[0]);
                        V2TIMImageVector imageList = imageElem->imageList;
                        int cppImageType = 1;
                        for (size_t i = 0; i < imageList.Size(); i++)
                        {
                            
                            if (imageType == 0) {
                                cppImageType = 1;
                            }else if(imageType == 1){
                                cppImageType = 2;
                            }else if(imageType == 2){
                                cppImageType = 4;
                            }

                            if (imageList[i].type == static_cast<V2TIMImageType>(cppImageType))
                            {
                                auto imageSize = std::to_string(imageList[i].size);
                                auto it = std::to_string(static_cast<int>(imageList[i].type));
                                auto imageWidth = std::to_string(imageList[i].width);
                                auto imageHeight = std::to_string(imageList[i].height);
                                auto uuid = imageList[i].uuid.CString();

                                std::string downloadtempfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "image_" + it + imageSize + imageWidth + imageHeight + "_temp_" + uuid);
                                std::string downloadfinalfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "image_" + it + imageSize + imageWidth + imageHeight + "_" + uuid);
                                if (downloading.find(downloadtempfilepath) != downloading.end()) {
                                    _result->Success(FormatTIMValueCallback(-1, "the file id downloading", flutter::EncodableValue()));
                                    return;
                                }
                                if (ConvertDataUtils::fileExists(downloadfinalfilepath))
                                {
                                    _result->Success(FormatTIMValueCallback(-1, "this file is allready download", flutter::EncodableValue()));
                                    return;
                                }
                                downloading.insert(std::pair(downloadtempfilepath,true));
                                WindowsV2TIMDownloadCallback *callback = new WindowsV2TIMDownloadCallback( messages[0].msgID.CString(), imageType, isSnapshot, downloadfinalfilepath, downloadtempfilepath, messageListener->getUuids());
                                imageList[i].DownloadImage(V2TIMString{downloadtempfilepath.c_str()}, callback);
                                break;
                            }
                        }
                        _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
                    }
                    else if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_VIDEO)
                    {
                        V2TIMVideoElem *videoElem = static_cast<V2TIMVideoElem *>(messages[0].elemList[0]);
                        std::string snapshotUUID = videoElem->snapshotUUID.CString();
                        std::string videoUUID = videoElem->videoUUID.CString();

                        std::string downloadtempfilepath = "";
                        std::string downloadfinalfilepath = "";

                        if (isSnapshot)
                        {
                            downloadtempfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_temp_" + snapshotUUID);
                            downloadfinalfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_" + snapshotUUID);
                            if (downloading.find(downloadtempfilepath) != downloading.end()) {
                                _result->Success(FormatTIMValueCallback(-1, "the file id downloading", flutter::EncodableValue()));
                                return;
                            }
                            if (ConvertDataUtils::fileExists(downloadfinalfilepath))
                            {
                                _result->Success(FormatTIMValueCallback(-1, "this file is allready download", flutter::EncodableValue()));
                                return;
                            }
                            downloading.insert(std::pair(downloadtempfilepath, true));
                            WindowsV2TIMDownloadCallback *callback = new WindowsV2TIMDownloadCallback( messages[0].msgID.CString(), messageType, isSnapshot, downloadfinalfilepath, downloadtempfilepath, tencent_cloud_chat_sdk::messageListener->getUuids());
                            videoElem->DownloadSnapshot(V2TIMString{downloadtempfilepath.c_str()}, callback);
                        }
                        else
                        {
                            downloadtempfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_temp_" + videoUUID);
                            downloadfinalfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "video_" + videoUUID);
                            if (downloading.find(downloadtempfilepath) != downloading.end()) {
                                _result->Success(FormatTIMValueCallback(-1, "the file id downloading", flutter::EncodableValue()));
                                return;
                            }
                            if (ConvertDataUtils::fileExists(downloadfinalfilepath))
                            {
                                _result->Success(FormatTIMValueCallback(-1, "this file is allready download", flutter::EncodableValue()));
                                return;
                            }
                            downloading.insert(std::pair(downloadtempfilepath, true));
                            WindowsV2TIMDownloadCallback *callback = new WindowsV2TIMDownloadCallback( messages[0].msgID.CString(), messageType, isSnapshot, downloadfinalfilepath, downloadtempfilepath, tencent_cloud_chat_sdk::messageListener->getUuids());
                            videoElem->DownloadVideo(V2TIMString{downloadtempfilepath.c_str()}, callback);
                        }
                        _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
                    }
                    else if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_SOUND)
                    {
                        V2TIMSoundElem *soundElem = static_cast<V2TIMSoundElem *>(messages[0].elemList[0]);
                        std::string uuid = soundElem->uuid.CString();

                        std::string downloadtempfilepath = "";
                        std::string downloadfinalfilepath = "";

                        downloadtempfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "sound_temp" + uuid);
                        downloadfinalfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + "sound_" + uuid);
                        if (downloading.find(downloadtempfilepath) != downloading.end()) {
                            _result->Success(FormatTIMValueCallback(-1, "the file id downloading", flutter::EncodableValue()));
                            return;
                        }
                        if (ConvertDataUtils::fileExists(downloadfinalfilepath))
                        {
                            _result->Success(FormatTIMValueCallback(-1, "this file is allready download", flutter::EncodableValue()));
                            return;
                        }
                        downloading.insert(std::pair(downloadtempfilepath, true));
                        WindowsV2TIMDownloadCallback *callback = new WindowsV2TIMDownloadCallback( messages[0].msgID.CString(), messageType, isSnapshot, downloadfinalfilepath, downloadtempfilepath, tencent_cloud_chat_sdk::messageListener->getUuids());
                        soundElem->DownloadSound(V2TIMString{downloadtempfilepath.c_str()}, callback);
                        _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
                    }
                    else if (messages[0].elemList[0]->elemType == V2TIMElemType::V2TIM_ELEM_TYPE_FILE)
                    {

                        V2TIMFileElem *fileElem = static_cast<V2TIMFileElem *>(messages[0].elemList[0]);
                        std::string uuid = fileElem->uuid.CString();

                        std::string fileName = fileElem->filename.CString();
                        std::string downloadtempfilepath = "";
                        std::string downloadfinalfilepath = "";
                        
                        downloadtempfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + uuid + "\\temp_"+ fileName);
                        downloadfinalfilepath = (globalTempPath + "DownLoad\\" + std::to_string(globalSDKAPPID) + "\\" + globalUserID + "\\" + uuid + "\\" + fileName);
                        
                        if (downloading.find(downloadtempfilepath) != downloading.end()) {
                            _result->Success(FormatTIMValueCallback(-1, "the file id downloading", flutter::EncodableValue()));
                            return;
                        }
                        if (ConvertDataUtils::fileExists(downloadfinalfilepath))
                        {
                            _result->Success(FormatTIMValueCallback(-1, "this file is allready download", flutter::EncodableValue()));
                            return;
                        }
                        downloading.insert(std::pair(downloadtempfilepath, true));
                        WindowsV2TIMDownloadCallback *callback = new WindowsV2TIMDownloadCallback( messages[0].msgID.CString(), messageType, isSnapshot, downloadfinalfilepath, downloadtempfilepath, messageListener->getUuids());
                        fileElem->DownloadFile(V2TIMString{downloadtempfilepath.c_str()}, callback);
                        _result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
                    }
                    else
                    {
                        _result->Success(FormatTIMValueCallback(-1, "current message dont need  download", flutter::EncodableValue()));
                    }
                }
            }
            else
            {
                _result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
            }
        }

    private:
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> _result;
        int _type;
        flutter::EncodableMap _param = flutter::EncodableMap();
        std::map<std::string, V2TIMMessage> *_createMsgMap;
    };

    void TencentCloudChatSdkPlugin::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue> &method_call, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {

        const auto *arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
        if (method_call.method_name().compare("getPlatformVersion") == 0)
        {
            std::ostringstream version_stream;
            version_stream << "Windows ";
            if (IsWindows10OrGreater())
            {
                version_stream << "10+";
            }
            else if (IsWindows8OrGreater())
            {
                version_stream << "8";
            }
            else if (IsWindows7OrGreater())
            {
                version_stream << "7";
            }

            result->Success(flutter::EncodableValue(version_stream.str()));
        }
        else if (method_call.method_name().compare("initSDK") == 0)
        {
            auto sdkappid_it = arguments->find(flutter::EncodableValue("sdkAppID"));
            auto logLevel_it = arguments->find(flutter::EncodableValue("logLevel"));
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            auto tempPath_it = arguments->find(flutter::EncodableValue("tempPath"));
            int sdkappid = 0;
            int logLevel = 0;
            int uiPlatform = 27;
            std::string listenerUuid = "";
            std::string tempPath = "";

            if (sdkappid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = sdkappid_it->second;
                if (!fvalue.IsNull())
                {
                    sdkappid = std::get<int>(fvalue);
                }
            }
            if (logLevel_it != arguments->end())
            {
                flutter::EncodableValue fvalue = logLevel_it->second;
                if (!fvalue.IsNull())
                {
                    logLevel = std::get<int>(fvalue);
                }
            }

            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (tempPath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = tempPath_it->second;
                if (!fvalue.IsNull())
                {
                    tempPath = std::get<std::string>(fvalue);
                    globalTempPath = tempPath;
                }
            }
            std::string confDirec = "Config";
            std::string logDirec = "Log";
            std::string cp = tempPath + confDirec;
            std::string lp = tempPath + logDirec;
            std::cout << "TencentCloudChat:Current Log Path is:" << cp << " \n"
                      << std::endl;

            V2TIMString confPath = V2TIMString{cp.c_str()};
            V2TIMString logPath = V2TIMString{lp.c_str()};
            V2TIMSDKConfig confg = {

            };

            confg.initPath = confPath;
            confg.logPath = logPath;
            confg.logLevel = static_cast<V2TIMLogLevel>(logLevel);
            V2TIMManager::GetInstance()->CallExperimentalAPI(V2TIMString{"setUIPlatform"}, &uiPlatform, nullptr);

            if (sdkListener->uuidSize() > 0)
            {
                V2TIMManager::GetInstance()->RemoveSDKListener(sdkListener);
                sdkListener->cleanUuid();
            }

            sdkListener->setUuid(listenerUuid);

            V2TIMManager::GetInstance()->AddSDKListener(sdkListener);

            bool initres = V2TIMManager::GetInstance()->InitSDK(static_cast<uint32_t>(sdkappid), confg);
            
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(initres)));
            globalSDKAPPID = sdkappid;
        }
        else if (method_call.method_name().compare("login") == 0)
        {
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto userSig_it = arguments->find(flutter::EncodableValue("userSig"));
            std::string userID;
            if (userID_it != arguments->end())
            {
                userID = std::get<std::string>(userID_it->second);
            }
            std::string userSig;
            if (userSig_it != arguments->end())
            {
                userSig = std::get<std::string>(userSig_it->second);
            }

            V2TIMString useridimString = {userID.c_str()};
            V2TIMString userSigimString = {userSig.c_str()};

            CommonCallback *callback = new CommonCallback(std::move(result));

            V2TIMManager::GetInstance()->Login(useridimString, userSigimString, callback);
            globalUserID = userID;
        }
        else if (method_call.method_name().compare("unInitSDK") == 0)
        {

            V2TIMManager::GetInstance()->UnInitSDK();

            result->Success(FormatTIMCallback(0, ""));
        }
        else if (method_call.method_name().compare("getVersion") == 0)
        {

            V2TIMString version = V2TIMManager::GetInstance()->GetVersion();

            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(version.CString())));
        }
        else if (method_call.method_name().compare("getServerTime") == 0)
        {

            int64_t time = V2TIMManager::GetInstance()->GetServerTime();

            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(time)));
        }
        else if (method_call.method_name().compare("logout") == 0)
        {
            CommonCallback *callback = new CommonCallback(std::move(result));

            V2TIMManager::GetInstance()->Logout(callback);
        }
        else if (method_call.method_name().compare("sendC2CTextMessage") == 0)
        {

            result->Success(FormatTIMValueCallback(-1, "sendC2CTextMessage has deprecated since 3.6.0. use create text text message instead", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendC2CCustomMessage") == 0)
        {

            result->Success(FormatTIMValueCallback(-1, "sendC2CCustomMessage has deprecated since 3.6.0. use create text text message instead", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendGroupTextMessage") == 0)
        {

            result->Success(FormatTIMValueCallback(-1, "sendGroupTextMessage has deprecated since 3.6.0. use create text text message instead", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendGroupCustomMessage") == 0)
        {

            result->Success(FormatTIMValueCallback(-1, "sendGroupCustomMessage has deprecated since 3.6.0. use create text text message instead", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getLoginUser") == 0)
        {

            V2TIMString user = V2TIMManager::GetInstance()->GetLoginUser();

            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(user.CString())));
        }
        else if (method_call.method_name().compare("getLoginStatus") == 0)
        {

            V2TIMLoginStatus status = V2TIMManager::GetInstance()->GetLoginStatus();

            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(static_cast<int>(status))));
        }
        else if (method_call.method_name().compare("getUsersInfo") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommV2TIMUserFullInfoVectorValueCallback *callback = new CommV2TIMUserFullInfoVectorValueCallback(std::move(result),false,arguments);
            V2TIMManager::GetInstance()->GetUsersInfo(uids, callback);
        }

        if (method_call.method_name().compare("createGroup") == 0)
        {

            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto groupType_it = arguments->find(flutter::EncodableValue("groupType"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            auto notification_it = arguments->find(flutter::EncodableValue("notification"));
            auto introduction_it = arguments->find(flutter::EncodableValue("introduction"));
            auto faceUrl_it = arguments->find(flutter::EncodableValue("faceUrl"));
            auto isAllMuted_it = arguments->find(flutter::EncodableValue("isAllMuted"));
            auto addOpt_it = arguments->find(flutter::EncodableValue("addOpt"));
            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            auto isSupportTopic_it = arguments->find(flutter::EncodableValue("isSupportTopic"));
            auto approveOpt_it = arguments->find(flutter::EncodableValue("approveOpt"));
            auto isEnablePermissionGroup_it = arguments->find(flutter::EncodableValue("isEnablePermissionGroup"));
            auto defaultPermissions_it = arguments->find(flutter::EncodableValue("defaultPermissions"));
            
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string groupType = "";
            if (groupType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupType_it->second;
                if (!fvalue.IsNull())
                {
                    groupType = std::get<std::string>(fvalue);
                    if(groupType == "Wrok") {
                        groupType = "Private";
                    }
                }
            }
            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            std::string notification;
            if (notification_it != arguments->end())
            {
                flutter::EncodableValue fvalue = notification_it->second;
                if (!fvalue.IsNull())
                {
                    notification = std::get<std::string>(fvalue);
                }
            }
            std::string introduction;
            if (introduction_it != arguments->end())
            {
                flutter::EncodableValue fvalue = introduction_it->second;
                if (!fvalue.IsNull())
                {
                    introduction = std::get<std::string>(fvalue);
                }
            }
            std::string faceUrl;
            if (faceUrl_it != arguments->end())
            {
                flutter::EncodableValue fvalue = faceUrl_it->second;
                if (!fvalue.IsNull())
                {
                    faceUrl = std::get<std::string>(fvalue);
                }
            }
            bool isAllMuted = false;
            if (isAllMuted_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isAllMuted_it->second;
                if (!fvalue.IsNull())
                {
                    isAllMuted = std::get<bool>(fvalue);
                }
            }
            int addOpt = -1;
            if (addOpt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = addOpt_it->second;
                if (!fvalue.IsNull())
                {
                    addOpt = std::get<int>(fvalue);
                }
            }
            flutter::EncodableList memberList = {};
            V2TIMCreateGroupMemberInfoVector memberListVec = {};
            if (memberList_it != arguments->end())
            {

                memberList = std::get<flutter::EncodableList>(memberList_it->second);

                size_t msize = memberList.size();
                for (size_t i = 0; i < msize; i++)
                {
                    flutter::EncodableMap item = std::get<flutter::EncodableMap>(memberList[i]);

                    auto userId_it = item.find(flutter::EncodableValue("userID"));

                    auto role_it = item.find(flutter::EncodableValue("role"));
                    std::string userId = "";
                    if (userId_it != item.end())
                    {
                        userId = std::get<std::string>(userId_it->second);
                    }
                    int role = 200;
                    if (role_it != item.end())
                    {
                        role = std::get<int>(role_it->second);
                    }

                    V2TIMCreateGroupMemberInfo minfo;
                    minfo.role = role;
                    minfo.userID = V2TIMString{userId.c_str()};
                    memberListVec.PushBack(minfo);
                }
            }
            bool isSupportTopic = false;
            if (isSupportTopic_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isSupportTopic_it->second;
                if (!fvalue.IsNull())
                {
                    isSupportTopic = std::get<bool>(fvalue);
                }
            }
            bool isEnablePermissionGroup = false;
            if (isEnablePermissionGroup_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isEnablePermissionGroup_it->second;
                if (!fvalue.IsNull())
                {
                    isEnablePermissionGroup = std::get<bool>(fvalue);
                }
            }

            int approveOpt = -1;
            if (approveOpt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = approveOpt_it->second;
                if (!fvalue.IsNull())
                {
                    approveOpt = std::get<int>(fvalue);
                }
            }
            int defaultPermissions = -1;
            if (defaultPermissions_it != arguments->end())
            {
                flutter::EncodableValue fvalue = defaultPermissions_it->second;
                if (!fvalue.IsNull())
                {
                    defaultPermissions = std::get<int>(fvalue);
                }
            }
            V2TIMGroupInfo ginfo;

            ginfo.allMuted = isAllMuted;
            ginfo.faceURL = V2TIMString{faceUrl.c_str()};
            if (addOpt != -1)
            {
                ginfo.groupAddOpt = static_cast<V2TIMGroupAddOpt>(addOpt);
            }
            if (approveOpt != -1)
            {
                ginfo.groupApproveOpt = static_cast<V2TIMGroupAddOpt>(approveOpt);
            }

            ginfo.groupID = V2TIMString{groupID.c_str()};
            ginfo.groupName = V2TIMString{groupName.c_str()};
            ginfo.groupType = V2TIMString{groupType.c_str()};
            ginfo.introduction = V2TIMString{introduction.c_str()};
            ginfo.notification = V2TIMString{notification.c_str()};
            ginfo.isSupportTopic = isSupportTopic;
            ginfo.enablePermissionGroup = isEnablePermissionGroup;
            ginfo.defaultPermissions = defaultPermissions;

            CommV2TIMStringValueCallback *callback = new CommV2TIMStringValueCallback(std::move(result));

            V2TIMManager::GetInstance()->GetGroupManager()->CreateGroup(ginfo, memberListVec, callback);
        }
        else if (method_call.method_name().compare("joinGroup") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto groupType_it = arguments->find(flutter::EncodableValue("groupType"));
            auto message_it = arguments->find(flutter::EncodableValue("message"));
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            std::string groupType = "";
            if (groupType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupType_it->second;
                if (!fvalue.IsNull())
                {
                    groupType = std::get<std::string>(fvalue);
                }
            }
            std::string message = "";
            if (message_it != arguments->end())
            {
                flutter::EncodableValue fvalue = message_it->second;
                if (!fvalue.IsNull())
                {
                    message = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->JoinGroup(V2TIMString{groupID.c_str()}, V2TIMString{message.c_str()}, callback);
        }
        else if (method_call.method_name().compare("quitGroup") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->QuitGroup(V2TIMString{groupID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("dismissGroup") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->DismissGroup(V2TIMString{groupID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("setGroupInfo") == 0) {
                
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            



            
            V2TIMStringVector uids = {};
            

            
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    uids.PushBack(V2TIMString{ std::get<std::string>(fvalue).c_str() });
                }
            }
            V2TIMGroupInfoResultVectorValueCallback* callback = new V2TIMGroupInfoResultVectorValueCallback(std::move(result), true, arguments);
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupsInfo(uids,callback);
            
        }
        else if (method_call.method_name().compare("setSelfInfo") == 0)
        {

            

            auto userid =  V2TIMManager::GetInstance()->GetLoginUser();
            V2TIMStringVector uids = {};
            uids.PushBack(userid);
            CommV2TIMUserFullInfoVectorValueCallback* callback = new CommV2TIMUserFullInfoVectorValueCallback(std::move(result),true,arguments);
            V2TIMManager::GetInstance()->GetUsersInfo(uids,callback);
            
        }
        if (method_call.method_name().compare("callExperimentalAPI") == 0)
        {
            auto api_it = arguments->find(flutter::EncodableValue("api"));
            auto param_it = arguments->find(flutter::EncodableValue("param"));
            std::string api = "";
            if (api_it != arguments->end())
            {
                flutter::EncodableValue fvalue = api_it->second;
                if (!fvalue.IsNull())
                {
                    api = std::get<std::string>(fvalue);
                }
            }
            std::string param = "";
            if (param_it != arguments->end())
            {
                flutter::EncodableValue fvalue = param_it->second;
                if (!fvalue.IsNull())
                {
                    param = std::get<std::string>(fvalue);
                }
            }
            V2TIMString p = V2TIMString{ param.c_str() };
            V2TIMManager::GetInstance()->CallExperimentalAPI(V2TIMString{ api.c_str()}, &p, nullptr);

            result->Success(FormatTIMValueCallback(0, "success", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("addSimpleMsgListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "addSimpleMsgListener is not support on windows. use addAdvancedMessageListener instead .", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeSimpleMsgListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "removeSimpleMsgListener is not support on windows. use removeAdvancedMessageListener instead .", flutter::EncodableValue()));
        }

        if (method_call.method_name().compare("setAPNSListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setAPNSListener is not support on windows. ", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getConversationList") == 0)
        {
            auto nextSeq_it = arguments->find(flutter::EncodableValue("nextSeq"));
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            std::string nextSeq = "0";
            if (nextSeq_it != arguments->end())
            {
                flutter::EncodableValue fvalue = nextSeq_it->second;
                if (!fvalue.IsNull())
                {
                    nextSeq = std::get<std::string>(fvalue);
                }
            }
            int count = 10;
            if (count_it != arguments->end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                }
            }
            uint64_t seq;
            try
            {
                seq = std::strtoull(nextSeq.c_str(), NULL, 0);
            }
            catch (const std::exception &)
            {
                seq = 0;
            }
            CommV2TIMConversationResultValueCallback *callback = new CommV2TIMConversationResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetConversationList(seq, count, callback);
        }
        else if (method_call.method_name().compare("removeConversationListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                conversationListenr->cleanUuid();
                V2TIMManager::GetInstance()->GetConversationManager()->RemoveConversationListener(NULL);
            }
            else
            {
                conversationListenr->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeFriendListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                friendListener->cleanUuid();
                V2TIMManager::GetInstance()->GetFriendshipManager()->RemoveFriendListener(NULL);
            }
            else
            {
                friendListener->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeGroupListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                groupListener->cleanUuid();
                V2TIMManager::GetInstance()->GetConversationManager()->RemoveConversationListener(NULL);
            }
            else
            {
                groupListener->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("addConversationListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (conversationListenr->getUuids().size() == 0)
            {
                conversationListenr->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->GetConversationManager()->AddConversationListener(conversationListenr);
            }
            else
            {
                conversationListenr->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("addGroupListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (groupListener->getUuids().size() == 0)
            {
                groupListener->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->AddGroupListener(groupListener);
            }
            else
            {
                groupListener->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("addFriendListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (friendListener->getUuids().size() == 0)
            {
                friendListener->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->GetFriendshipManager()->AddFriendListener(friendListener);
            }
            else
            {
                friendListener->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getConversationListByConversaionIds") == 0)
        {

            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));

            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommV2TIMConversationVectorValueCallback *callback = new CommV2TIMConversationVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetConversationList(uids, callback);
        }
        else if (method_call.method_name().compare("setConversationListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setConversationListener is not support on windows platform. use addConversationListener instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getConversation") == 0)
        {

            auto conversationID_it = arguments->find(flutter::EncodableValue("conversationID"));
            std::string conversationID = "";
            if (conversationID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = conversationID_it->second;
                if (!fvalue.IsNull())
                {
                    conversationID = std::get<std::string>(fvalue);
                }
            }
            CommV2TIMConversationValueCallback *callback = new CommV2TIMConversationValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetConversation(V2TIMString{conversationID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("deleteConversation") == 0)
        {
            auto conversationID_it = arguments->find(flutter::EncodableValue("conversationID"));
            std::string conversationID = "";
            if (conversationID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = conversationID_it->second;
                if (!fvalue.IsNull())
                {
                    conversationID = std::get<std::string>(fvalue);
                }
            }

            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->DeleteConversation(V2TIMString{conversationID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("setConversationDraft") == 0)
        {
            auto conversationID_it = arguments->find(flutter::EncodableValue("conversationID"));
            auto draftText_it = arguments->find(flutter::EncodableValue("draftText"));

            std::string conversationID = "";
            if (conversationID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = conversationID_it->second;
                if (!fvalue.IsNull())
                {
                    conversationID = std::get<std::string>(fvalue);
                }
            }
            std::string draftText = "";
            if (draftText_it != arguments->end())
            {
                flutter::EncodableValue fvalue = draftText_it->second;
                if (!fvalue.IsNull())
                {
                    draftText = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->SetConversationDraft(V2TIMString{conversationID.c_str()}, V2TIMString{draftText.c_str()}, callback);
        }
        else if (method_call.method_name().compare("pinConversation") == 0)
        {

            auto conversationID_it = arguments->find(flutter::EncodableValue("conversationID"));
            auto isPinned_it = arguments->find(flutter::EncodableValue("isPinned"));

            std::string conversationID = "";
            if (conversationID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = conversationID_it->second;
                if (!fvalue.IsNull())
                {
                    conversationID = std::get<std::string>(fvalue);
                }
            }
            bool isPinned = false;
            if (isPinned_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isPinned_it->second;
                if (!fvalue.IsNull())
                {
                    isPinned = std::get<bool>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->PinConversation(V2TIMString{conversationID.c_str()}, isPinned, callback);
        }
        else if (method_call.method_name().compare("getTotalUnreadMessageCount") == 0)
        {
            CommUint64ValueCallback *callback = new CommUint64ValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetTotalUnreadMessageCount(callback);
        }
        else if (method_call.method_name().compare("getFriendList") == 0)
        {
            CommV2TIMFriendInfoVectorValueCallback *callback = new CommV2TIMFriendInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendList(callback);
        }
        else if (method_call.method_name().compare("setFriendListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setFriendListener is not support on windows platform. use addFriendListener instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("addFriend") == 0)
        {
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto remark_it = arguments->find(flutter::EncodableValue("remark"));
            auto friendGroup_it = arguments->find(flutter::EncodableValue("friendGroup"));
            auto addWording_it = arguments->find(flutter::EncodableValue("addWording"));
            auto addSource_it = arguments->find(flutter::EncodableValue("addSource"));
            auto addType_it = arguments->find(flutter::EncodableValue("addType"));

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            int addType = 0;
            if (addType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = addType_it->second;
                if (!fvalue.IsNull())
                {
                    addType = std::get<int>(fvalue);
                }
            }
            std::string remark = "";
            if (remark_it != arguments->end())
            {
                flutter::EncodableValue fvalue = remark_it->second;
                if (!fvalue.IsNull())
                {
                    remark = std::get<std::string>(fvalue);
                }
            }
            std::string friendGroup = "";
            if (friendGroup_it != arguments->end())
            {
                flutter::EncodableValue fvalue = friendGroup_it->second;
                if (!fvalue.IsNull())
                {
                    friendGroup = std::get<std::string>(fvalue);
                }
            }
            std::string addWording = "";
            if (addWording_it != arguments->end())
            {
                flutter::EncodableValue fvalue = addWording_it->second;
                if (!fvalue.IsNull())
                {
                    addWording = std::get<std::string>(fvalue);
                }
            }
            std::string addSource = "";
            if (addSource_it != arguments->end())
            {
                flutter::EncodableValue fvalue = addSource_it->second;
                if (!fvalue.IsNull())
                {
                    addSource = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendAddApplication application = V2TIMFriendAddApplication();
            application.userID = V2TIMString{userID.c_str()};
            application.addType = static_cast<V2TIMFriendType>(addType);
            application.addSource = V2TIMString{addSource.c_str()};
            application.addWording = V2TIMString{addWording.c_str()};
            application.friendGroup = V2TIMString{friendGroup.c_str()};
            application.friendRemark = V2TIMString{remark.c_str()};
            V2TIMFriendOperationResultValueCallback *callback = new V2TIMFriendOperationResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->AddFriend(application, callback);
        }
        else if (method_call.method_name().compare("setFriendInfo") == 0)
        {

            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto friendRemark_it = arguments->find(flutter::EncodableValue("friendRemark"));
            auto friendCustomInfo_it = arguments->find(flutter::EncodableValue("friendCustomInfo"));
            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            int flag = 0;
            V2TIMFriendInfo info = V2TIMFriendInfo();
            std::string friendRemark = "--";
            if (friendRemark_it != arguments->end())
            {
                flutter::EncodableValue fvalue = friendRemark_it->second;
                if (!fvalue.IsNull())
                {
                    friendRemark = std::get<std::string>(fvalue);
                }
            }

            if (friendCustomInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = friendCustomInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto friendCustomInfoMap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = friendCustomInfoMap.begin(); iter != friendCustomInfoMap.end(); iter++)

                    {
                        std::string data = std::get<std::string>(iter->second);
                        ctiminfo.Insert(V2TIMString{std::get<std::string>(iter->first).c_str()}, ConvertDataUtils::string2Buffer(data));
                    }
                    info.friendCustomInfo = ctiminfo;
                    flag = flag | 2;
                }
            }

            info.userID = V2TIMString{userID.c_str()};
            if (info.friendRemark != "--")
            {
                info.friendRemark = V2TIMString{friendRemark.c_str()};
                flag = flag | 1;
            }
            info.modifyFlag = flag;

            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->SetFriendInfo(info, callback);
        }
        else if (method_call.method_name().compare("deleteFromFriendList") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto deleteType_it = arguments->find(flutter::EncodableValue("deleteType"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            int deleteType = 0;
            if (deleteType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = deleteType_it->second;
                if (!fvalue.IsNull())
                {
                    deleteType = std::get<int>(fvalue);
                }
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->DeleteFromFriendList(uids, static_cast<V2TIMFriendType>(deleteType), callback);
        }
        else if (method_call.method_name().compare("checkFriend") == 0)
        {

            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto checkType_it = arguments->find(flutter::EncodableValue("checkType"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            int checkType = 0;
            if (checkType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = checkType_it->second;
                if (!fvalue.IsNull())
                {
                    checkType = std::get<int>(fvalue);
                }
            }
            V2TIMFriendCheckResultVectorValueCallback *callback = new V2TIMFriendCheckResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->CheckFriend(uids, static_cast<V2TIMFriendType>(checkType), callback);
        }
        else if (method_call.method_name().compare("getFriendApplicationList") == 0)
        {
            V2TIMFriendApplicationResultValueCallback *callback = new V2TIMFriendApplicationResultValueCallback(std::move(result), 0, arguments);
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendApplicationList(callback);
        }
        else if (method_call.method_name().compare("acceptFriendApplication") == 0)
        {

            V2TIMFriendApplicationResultValueCallback *callback = new V2TIMFriendApplicationResultValueCallback(std::move(result), 1, arguments);
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendApplicationList(callback);
        }
        else if (method_call.method_name().compare("refuseFriendApplication") == 0)
        {

            V2TIMFriendApplicationResultValueCallback *callback = new V2TIMFriendApplicationResultValueCallback(std::move(result), 2, arguments);
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendApplicationList(callback);
        }
        else if (method_call.method_name().compare("deleteFriendApplication") == 0)
        {

            V2TIMFriendApplicationResultValueCallback *callback = new V2TIMFriendApplicationResultValueCallback(std::move(result), 3, arguments);
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendApplicationList(callback);
        }
        else if (method_call.method_name().compare("setFriendApplicationRead") == 0)
        {
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->SetFriendApplicationRead(callback);
        }
        else if (method_call.method_name().compare("getBlackList") == 0)
        {
            CommV2TIMFriendInfoVectorValueCallback *callback = new CommV2TIMFriendInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetBlackList(callback);
        }
        else if (method_call.method_name().compare("addToBlackList") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->AddToBlackList(uids, callback);
        }
        else if (method_call.method_name().compare("deleteFromBlackList") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->DeleteFromBlackList(uids, callback);
        }
        else if (method_call.method_name().compare("createFriendGroup") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->CreateFriendGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("getFriendGroups") == 0)
        {
            auto groupNameList_it = arguments->find(flutter::EncodableValue("groupNameList"));
            flutter::EncodableList groupNameList = {};
            if (groupNameList_it != arguments->end())
            {

                groupNameList = std::get<flutter::EncodableList>(groupNameList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = groupNameList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(groupNameList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMFriendGroupVectorValueCallback *callback = new V2TIMFriendGroupVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendGroups(uids, callback);
        }
        else if (method_call.method_name().compare("deleteFriendGroup") == 0)
        {
            auto groupNameList_it = arguments->find(flutter::EncodableValue("groupNameList"));
            flutter::EncodableList groupNameList = {};
            if (groupNameList_it != arguments->end())
            {

                groupNameList = std::get<flutter::EncodableList>(groupNameList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = groupNameList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(groupNameList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->DeleteFriendGroup(uids, callback);
        }
        else if (method_call.method_name().compare("renameFriendGroup") == 0)
        {

            auto oldName_it = arguments->find(flutter::EncodableValue("oldName"));
            auto newName_it = arguments->find(flutter::EncodableValue("newName"));

            std::string oldName = "";
            if (oldName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = oldName_it->second;
                if (!fvalue.IsNull())
                {
                    oldName = std::get<std::string>(fvalue);
                }
            }
            std::string newName = "";
            if (newName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = newName_it->second;
                if (!fvalue.IsNull())
                {
                    newName = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->RenameFriendGroup(V2TIMString{oldName.c_str()}, V2TIMString{newName.c_str()}, callback);
        }
        else if (method_call.method_name().compare("addFriendsToFriendGroup") == 0)
        {

            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->AddFriendsToFriendGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("deleteFriendsFromFriendGroup") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMFriendOperationResultVectortValueCallback *callback = new V2TIMFriendOperationResultVectortValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->DeleteFriendsFromFriendGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("searchFriends") == 0)
        {
            auto searchParam_it = arguments->find(flutter::EncodableValue("searchParam"));
            V2TIMFriendSearchParam searchParam;
            if (searchParam_it != arguments->end())
            {
                flutter::EncodableValue fvalue = searchParam_it->second;
                if (!fvalue.IsNull())
                {
                    auto searchParamMap = std::get<flutter::EncodableMap>(fvalue);

                    auto isSearchUserID_it = searchParamMap.find(flutter::EncodableValue("isSearchUserID"));
                    auto isSearchNickName_it = searchParamMap.find(flutter::EncodableValue("isSearchNickName"));
                    auto isSearchRemark_it = searchParamMap.find(flutter::EncodableValue("isSearchRemark"));
                    auto keywordList_it = searchParamMap.find(flutter::EncodableValue("keywordList"));

                    if (isSearchUserID_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchUserID_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchUserID = std::get<bool>(vv);
                        }
                    }
                    if (isSearchNickName_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchNickName_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchNickName = std::get<bool>(vv);
                        }
                    }
                    if (isSearchRemark_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchRemark_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchRemark = std::get<bool>(vv);
                        }
                    }
                    if (keywordList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.keywordList = kws;
                        }
                    }
                }
            }
            V2TIMFriendInfoResultVectorValueCallback *callback = new V2TIMFriendInfoResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->SearchFriends(searchParam, callback);
        }
        else if (method_call.method_name().compare("getJoinedGroupList") == 0)
        {
            V2TIMGroupInfoVectorValueCallback *callback = new V2TIMGroupInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetJoinedGroupList(callback);
        }
        else if (method_call.method_name().compare("getGroupsInfo") == 0) {
        auto groupIDList_it = arguments->find(flutter::EncodableValue("groupIDList"));
        V2TIMStringVector groupIDList = {};
        if (groupIDList_it != arguments->end())
        {
            flutter::EncodableValue vv = groupIDList_it->second;
            if (!vv.IsNull())
            {

                auto list = std::get<flutter::EncodableList>(vv);
                
                for (size_t i = 0; i < list.size(); i++)
                {
                    groupIDList.PushBack(V2TIMString{ std::get<std::string>(list[i]).c_str() });
                }

            }
        }   
            V2TIMGroupInfoResultVectorValueCallback* callback = new V2TIMGroupInfoResultVectorValueCallback(std::move(result),false,arguments);
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupsInfo(groupIDList,callback);
        }else if(method_call.method_name().compare("getFriendsInfo") == 0){
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
        V2TIMStringVector userIDList = {};
        if (userIDList_it != arguments->end())
        {
            flutter::EncodableValue vv = userIDList_it->second;
            if (!vv.IsNull())
            {

                auto list = std::get<flutter::EncodableList>(vv);
                
                for (size_t i = 0; i < list.size(); i++)
                {
                    userIDList.PushBack(V2TIMString{ std::get<std::string>(list[i]).c_str() });
                }

            }
        }   
            V2TIMFriendInfoResultVectorValueCallback* callback = new V2TIMFriendInfoResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetFriendshipManager()->GetFriendsInfo(userIDList,callback);
            
        }
        else if (method_call.method_name().compare("setGroupListener") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setGroupListener is not support on windows platform. use addGroupListener instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("deleteGroupAttributes") == 0)
        {
            auto keys_it = arguments->find(flutter::EncodableValue("keys"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            flutter::EncodableList keys = {};
            if (keys_it != arguments->end())
            {

                keys = std::get<flutter::EncodableList>(keys_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = keys.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(keys[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->DeleteGroupAttributes(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("setGroupAttributes") == 0)
        {
            auto attributes_it = arguments->find(flutter::EncodableValue("attributes"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            V2TIMGroupAttributeMap map = {};
            if (attributes_it != arguments->end())
            {
                flutter::EncodableValue fvalue = attributes_it->second;
                if (!fvalue.IsNull())
                {
                    auto attributesMap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;

                    for (iter = attributesMap.begin(); iter != attributesMap.end(); iter++)

                    {
                        flutter::EncodableValue keyv = iter->first;
                        flutter::EncodableValue vv = iter->second;
                        if (!keyv.IsNull() && !vv.IsNull())
                        {
                            map.Insert(V2TIMString{std::get<std::string>(keyv).c_str()}, V2TIMString{std::get<std::string>(vv).c_str()});
                        }
                    }
                }
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupAttributes(V2TIMString{groupID.c_str()}, map, callback);
        }
        else if (method_call.method_name().compare("getGroupAttributes") == 0)
        {
            auto keys_it = arguments->find(flutter::EncodableValue("keys"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            flutter::EncodableList keys = {};
            if (keys_it != arguments->end())
            {

                keys = std::get<flutter::EncodableList>(keys_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = keys.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(keys[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMGroupAttributeMapValueCallback *callback = new V2TIMGroupAttributeMapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupAttributes(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("getGroupOnlineMemberCount") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            Uint32TValueCallback *callback = new Uint32TValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupOnlineMemberCount(V2TIMString{groupID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("getGroupMemberList") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto filter_it = arguments->find(flutter::EncodableValue("filter"));
            auto nextSeq_it = arguments->find(flutter::EncodableValue("nextSeq"));
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            auto offset_it = arguments->find(flutter::EncodableValue("offset"));
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            int filter = 0;
            if (filter_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    filter = std::get<int>(fvalue);
                }
            }

            std::string nextSeq = "";
            if (nextSeq_it != arguments->end())
            {
                flutter::EncodableValue fvalue = nextSeq_it->second;
                if (!fvalue.IsNull())
                {
                    nextSeq = std::get<std::string>(fvalue);
                }
            }

            int count = 0;
            if (count_it != arguments->end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                }
            }

            int offset = 0;
            if (offset_it != arguments->end())
            {
                flutter::EncodableValue fvalue = offset_it->second;
                if (!fvalue.IsNull())
                {
                    offset = std::get<int>(fvalue);
                }
            }
            uint64_t seq;
            try
            {
                seq = std::strtoull(nextSeq.c_str(), NULL, 0);
            }
            catch (const std::exception &)
            {
                seq = 0;
            }
            V2TIMGroupMemberInfoResultValueCallback *callback = new V2TIMGroupMemberInfoResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupMemberList(V2TIMString{groupID.c_str()}, filter, seq, callback);
        }
        else if (method_call.method_name().compare("getGroupMembersInfo") == 0)
        {

            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            flutter::EncodableList memberList = {};
            if (memberList_it != arguments->end())
            {

                memberList = std::get<flutter::EncodableList>(memberList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = memberList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(memberList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMGroupMemberFullInfoVectorValueCallback *callback = new V2TIMGroupMemberFullInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupMembersInfo(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("setGroupMemberInfo") == 0)
        {

            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto nameCard_it = arguments->find(flutter::EncodableValue("nameCard"));
            auto customInfo_it = arguments->find(flutter::EncodableValue("customInfo"));
            V2TIMGroupMemberFullInfo info = V2TIMGroupMemberFullInfo();
            uint32_t flag = 0x00;
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                    info.userID = V2TIMString{userID.c_str()};
                }
            }

            std::string nameCard = "";
            if (nameCard_it != arguments->end())
            {
                flutter::EncodableValue fvalue = nameCard_it->second;
                if (!fvalue.IsNull())
                {
                    nameCard = std::get<std::string>(fvalue);
                    info.nameCard = V2TIMString{nameCard.c_str()};
                    flag = flag | 0x01 << 3;
                }
            }

            if (customInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = customInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto customInfoMap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo = V2TIMCustomInfo();
                    for (iter = customInfoMap.begin(); iter != customInfoMap.end(); iter++)

                    {
                        flutter::EncodableValue k = iter->first;
                        flutter::EncodableValue v = iter->first;
                        if (!k.IsNull() && !v.IsNull())
                        {
                            ctiminfo.Insert(V2TIMString{std::get<std::string>(k).c_str()}, ConvertDataUtils::string2Buffer(std::get<std::string>(v)));
                        }
                    }
                    info.customInfo = ctiminfo;
                    flag = flag | 0x01 << 4;
                }
            }
            info.modifyFlag = flag;
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupMemberInfo(V2TIMString{groupID.c_str()}, info, callback);
        }
        else if (method_call.method_name().compare("muteGroupMember") == 0)
        {

            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto seconds_it = arguments->find(flutter::EncodableValue("seconds"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }

            int seconds = 0;
            if (seconds_it != arguments->end())
            {
                flutter::EncodableValue fvalue = seconds_it->second;
                if (!fvalue.IsNull())
                {
                    seconds = std::get<int>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->MuteGroupMember(V2TIMString{groupID.c_str()}, V2TIMString{userID.c_str()}, seconds, callback);
        }
        else if (method_call.method_name().compare("inviteUserToGroup") == 0)
        {

            auto userList_it = arguments->find(flutter::EncodableValue("userList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            flutter::EncodableList userList = {};
            if (userList_it != arguments->end())
            {

                userList = std::get<flutter::EncodableList>(userList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMGroupMemberOperationResultVectorValueCallback *callback = new V2TIMGroupMemberOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->InviteUserToGroup(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("kickGroupMember") == 0)
        {

            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto duration_it = arguments->find(flutter::EncodableValue("duration"));
            auto reason_it = arguments->find(flutter::EncodableValue("reason"));
            flutter::EncodableList memberList = {};
            if (memberList_it != arguments->end())
            {

                memberList = std::get<flutter::EncodableList>(memberList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = memberList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(memberList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string reason = "";
            if (reason_it != arguments->end())
            {
                flutter::EncodableValue fvalue = reason_it->second;
                if (!fvalue.IsNull())
                {
                    reason = std::get<std::string>(fvalue);
                }
            }

            int duration = 0;
            if (duration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = duration_it->second;
                if (!fvalue.IsNull())
                {
                    duration = std::get<int>(fvalue);
                }
            }
            V2TIMGroupMemberOperationResultVectorValueCallback *callback = new V2TIMGroupMemberOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->KickGroupMember(V2TIMString{groupID.c_str()}, uids, V2TIMString{reason.c_str()}, duration, callback);
        }
        else if (method_call.method_name().compare("setGroupMemberRole") == 0)
        {

            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto role_it = arguments->find(flutter::EncodableValue("role"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }

            int role = 0;
            if (role_it != arguments->end())
            {
                flutter::EncodableValue fvalue = role_it->second;
                if (!fvalue.IsNull())
                {
                    role = std::get<int>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupMemberRole(V2TIMString{groupID.c_str()}, V2TIMString{userID.c_str()}, role, callback);
        }
        else if (method_call.method_name().compare("transferGroupOwner") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->TransferGroupOwner(V2TIMString{groupID.c_str()}, V2TIMString{userID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("getGroupApplicationList") == 0)
        {
            V2TIMGroupApplicationResultValueCallback *callback = new V2TIMGroupApplicationResultValueCallback(std::move(result), 0, arguments);
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupApplicationList(callback);
        }
        else if (method_call.method_name().compare("acceptGroupApplication") == 0)
        {

            V2TIMGroupApplicationResultValueCallback *callback = new V2TIMGroupApplicationResultValueCallback(std::move(result), 1, arguments);
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupApplicationList(callback);
        }
        else if (method_call.method_name().compare("refuseGroupApplication") == 0)
        {
            V2TIMGroupApplicationResultValueCallback *callback = new V2TIMGroupApplicationResultValueCallback(std::move(result), 2, arguments);
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupApplicationList(callback);
        }
        else if (method_call.method_name().compare("setGroupApplicationRead") == 0)
        {
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupApplicationRead(callback);
        }
        else if (method_call.method_name().compare("searchGroups") == 0)
        {
            auto searchParam_it = arguments->find(flutter::EncodableValue("searchParam"));
            V2TIMGroupSearchParam searchParam;
            if (searchParam_it != arguments->end())
            {
                flutter::EncodableValue fvalue = searchParam_it->second;
                if (!fvalue.IsNull())
                {
                    auto searchParamMap = std::get<flutter::EncodableMap>(fvalue);

                    auto isSearchGroupID_it = searchParamMap.find(flutter::EncodableValue("isSearchGroupID"));
                    auto isSearchGroupName_it = searchParamMap.find(flutter::EncodableValue("isSearchGroupName"));
                    auto isSearchRemark_it = searchParamMap.find(flutter::EncodableValue("isSearchRemark"));
                    auto keywordList_it = searchParamMap.find(flutter::EncodableValue("keywordList"));

                    if (isSearchGroupID_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchGroupID_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchGroupID = std::get<bool>(vv);
                        }
                    }
                    if (isSearchGroupName_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchGroupName_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchGroupName = std::get<bool>(vv);
                        }
                    }

                    if (keywordList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.keywordList = kws;
                        }
                    }
                }
            }
            V2TIMGroupInfoVectorValueCallback *callback = new V2TIMGroupInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SearchGroups(searchParam, callback);
        }
        else if (method_call.method_name().compare("searchGroupMembers") == 0)
        {
            auto searchParam_it = arguments->find(flutter::EncodableValue("param"));
            V2TIMGroupMemberSearchParam searchParam;
            if (searchParam_it != arguments->end())
            {
                flutter::EncodableValue fvalue = searchParam_it->second;
                if (!fvalue.IsNull())
                {
                    auto searchParamMap = std::get<flutter::EncodableMap>(fvalue);

                    auto isSearchMemberUserID_it = searchParamMap.find(flutter::EncodableValue("isSearchMemberUserID"));
                    auto isSearchMemberNickName_it = searchParamMap.find(flutter::EncodableValue("isSearchMemberNickName"));
                    auto isSearchMemberRemark_it = searchParamMap.find(flutter::EncodableValue("isSearchMemberRemark"));
                    auto isSearchMemberNameCard_it = searchParamMap.find(flutter::EncodableValue("isSearchMemberNameCard"));
                    auto keywordList_it = searchParamMap.find(flutter::EncodableValue("keywordList"));
                    auto groupIDList_it = searchParamMap.find(flutter::EncodableValue("groupIDList"));

                    if (isSearchMemberUserID_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchMemberUserID_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchMemberUserID = std::get<bool>(vv);
                        }
                    }
                    if (isSearchMemberNickName_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchMemberNickName_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchMemberNickName = std::get<bool>(vv);
                        }
                    }
                    if (isSearchMemberRemark_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchMemberRemark_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchMemberRemark = std::get<bool>(vv);
                        }
                    }
                    if (isSearchMemberNameCard_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = isSearchMemberNameCard_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.isSearchMemberNameCard = std::get<bool>(vv);
                        }
                    }
                    if (keywordList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                           
                            searchParam.keywordList = kws;
                        }
                    }
                    if (groupIDList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = groupIDList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{ std::get<std::string>(list[i]).c_str() });
                            }

                            searchParam.groupIDList = kws;
                        }
                    }
                }
            }
            V2TIMGroupSearchGroupMembersMapValueCallback *callback = new V2TIMGroupSearchGroupMembersMapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SearchGroupMembers(searchParam, callback);
        }
        else if (method_call.method_name().compare("searchGroupByID") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "searchGroupByID is not support on windows platform.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("initGroupAttributes") == 0)
        {

            auto attributes_it = arguments->find(flutter::EncodableValue("attributes"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            V2TIMGroupAttributeMap map = {};
            if (attributes_it != arguments->end())
            {
                flutter::EncodableValue fvalue = attributes_it->second;
                if (!fvalue.IsNull())
                {
                    auto attributesMap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    for (iter = attributesMap.begin(); iter != attributesMap.end(); iter++)

                    {
                        flutter::EncodableValue k = iter->first;
                        flutter::EncodableValue v = iter->second;

                        if (!k.IsNull() && !v.IsNull())
                        {
                            map.Insert(V2TIMString{std::get<std::string>(k).c_str()}, V2TIMString{std::get<std::string>(v).c_str()});
                        }
                    }
                }
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->InitGroupAttributes(V2TIMString{groupID.c_str()}, map, callback);
        }
        else if (method_call.method_name().compare("createTextMessage") == 0)
        {
            auto text_it = arguments->find(flutter::EncodableValue("text"));

            std::string text = "";
            if (text_it != arguments->end())
            {
                flutter::EncodableValue fvalue = text_it->second;
                if (!fvalue.IsNull())
                {
                    text = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateTextMessage(V2TIMString{text.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }

        if (method_call.method_name().compare("createTargetedGroupMessage") == 0)
        {
            auto id_it = arguments->find(flutter::EncodableValue("id"));
            auto receiverList_it = arguments->find(flutter::EncodableValue("receiverList"));
            std::string mid = "";
            if (id_it != arguments->end())
            {
                flutter::EncodableValue fvalue = id_it->second;
                if (!fvalue.IsNull())
                {
                    mid = std::get<std::string>(fvalue);
                }
            }

            flutter::EncodableList receiverList = {};
            if (receiverList_it != arguments->end())
            {

                receiverList = std::get<flutter::EncodableList>(receiverList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = receiverList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(receiverList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            auto createdMessageIt = createdMessageMap.find(mid);
            V2TIMMessage sendmessage;
            if (createdMessageIt != createdMessageMap.end())
            {
                sendmessage = createdMessageIt->second;
            }
            else
            {
                result->Success(FormatTIMValueCallback(-1, "id not extis", flutter::EncodableValue()));
                return;
            }

            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateTargetedGroupMessage(sendmessage, uids);
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createCustomMessage") == 0)
        {

            auto data_it = arguments->find(flutter::EncodableValue("data"));
            auto desc_it = arguments->find(flutter::EncodableValue("desc"));
            auto extension_it = arguments->find(flutter::EncodableValue("extension"));

            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            std::string desc = "";
            if (desc_it != arguments->end())
            {
                flutter::EncodableValue fvalue = desc_it->second;
                if (!fvalue.IsNull())
                {
                    desc = std::get<std::string>(fvalue);
                }
            }
            std::string extension = "";
            if (extension_it != arguments->end())
            {
                flutter::EncodableValue fvalue = extension_it->second;
                if (!fvalue.IsNull())
                {
                    extension = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateCustomMessage(ConvertDataUtils::string2Buffer(data), V2TIMString{desc.c_str()}, V2TIMString{extension.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createImageMessage") == 0)
        {
            auto imagePath_it = arguments->find(flutter::EncodableValue("imagePath"));

            std::string imagePath = "";
            if (imagePath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = imagePath_it->second;
                if (!fvalue.IsNull())
                {
                    imagePath = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateImageMessage(V2TIMString{imagePath.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createSoundMessage") == 0)
        {

            auto soundPath_it = arguments->find(flutter::EncodableValue("soundPath"));
            auto duration_it = arguments->find(flutter::EncodableValue("duration"));

            std::string soundPath = "";
            if (soundPath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = soundPath_it->second;
                if (!fvalue.IsNull())
                {
                    soundPath = std::get<std::string>(fvalue);
                }
            }

            int duration = 0;
            if (duration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = duration_it->second;
                if (!fvalue.IsNull())
                {
                    duration = std::get<int>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateSoundMessage(V2TIMString{soundPath.c_str()}, duration);
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createVideoMessage") == 0)
        {

            auto videoFilePath_it = arguments->find(flutter::EncodableValue("videoFilePath"));
            auto type_it = arguments->find(flutter::EncodableValue("type"));
            auto duration_it = arguments->find(flutter::EncodableValue("duration"));
            auto snapshotPath_it = arguments->find(flutter::EncodableValue("snapshotPath"));

            std::string videoFilePath = "";
            if (videoFilePath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = videoFilePath_it->second;
                if (!fvalue.IsNull())
                {
                    videoFilePath = std::get<std::string>(fvalue);
                }
            }

            std::string type = "";
            if (type_it != arguments->end())
            {
                flutter::EncodableValue fvalue = type_it->second;
                if (!fvalue.IsNull())
                {
                    type = std::get<std::string>(fvalue);
                }
            }

            std::string snapshotPath = "";
            if (snapshotPath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = snapshotPath_it->second;
                if (!fvalue.IsNull())
                {
                    snapshotPath = std::get<std::string>(fvalue);
                }
            }

            int duration = 0;
            if (duration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = duration_it->second;
                if (!fvalue.IsNull())
                {
                    duration = std::get<int>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateVideoMessage(V2TIMString{videoFilePath.c_str()}, V2TIMString{type.c_str()}, duration, V2TIMString{snapshotPath.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("sendMessage") == 0)
        {
            auto id_it = arguments->find(flutter::EncodableValue("id"));
            auto receiver_it = arguments->find(flutter::EncodableValue("receiver"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto priority_it = arguments->find(flutter::EncodableValue("priority"));
            auto onlineUserOnly_it = arguments->find(flutter::EncodableValue("onlineUserOnly"));
            auto isExcludedFromUnreadCount_it = arguments->find(flutter::EncodableValue("isExcludedFromUnreadCount"));
            auto isExcludedFromLastMessage_it = arguments->find(flutter::EncodableValue("isExcludedFromLastMessage"));
            auto isSupportMessageExtension_it = arguments->find(flutter::EncodableValue("isSupportMessageExtension"));
            auto isExcludedFromContentModeration_it = arguments->find(flutter::EncodableValue("isExcludedFromContentModeration"));
            auto needReadReceipt_it = arguments->find(flutter::EncodableValue("needReadReceipt"));
            auto offlinePushInfo_it = arguments->find(flutter::EncodableValue("offlinePushInfo"));
            auto cloudCustomData_it = arguments->find(flutter::EncodableValue("cloudCustomData"));
            auto localCustomData_it = arguments->find(flutter::EncodableValue("localCustomData"));

            std::string id = "";
            if (id_it != arguments->end())
            {
                flutter::EncodableValue fvalue = id_it->second;
                if (!fvalue.IsNull())
                {
                    id = std::get<std::string>(fvalue);
                }
            }

            std::string receiver = "";
            if (receiver_it != arguments->end())
            {
                flutter::EncodableValue fvalue = receiver_it->second;
                if (!fvalue.IsNull())
                {
                    receiver = std::get<std::string>(fvalue);
                }
            }

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            int priority = 1;
            if (priority_it != arguments->end())
            {
                flutter::EncodableValue fvalue = priority_it->second;
                if (!fvalue.IsNull())
                {
                    priority = std::get<int>(fvalue);
                }
            }

            bool onlineUserOnly = false;
            if (onlineUserOnly_it != arguments->end())
            {
                flutter::EncodableValue fvalue = onlineUserOnly_it->second;
                if (!fvalue.IsNull())
                {
                    onlineUserOnly = std::get<bool>(fvalue);
                }
            }

            bool isExcludedFromUnreadCount = false;
            if (isExcludedFromUnreadCount_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isExcludedFromUnreadCount_it->second;
                if (!fvalue.IsNull())
                {
                    isExcludedFromUnreadCount = std::get<bool>(fvalue);
                }
            }

            bool isExcludedFromLastMessage = false;
            if (isExcludedFromLastMessage_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isExcludedFromLastMessage_it->second;
                if (!fvalue.IsNull())
                {
                    isExcludedFromLastMessage = std::get<bool>(fvalue);
                }
            }

            bool isSupportMessageExtension = false;
            if (isSupportMessageExtension_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isSupportMessageExtension_it->second;
                if (!fvalue.IsNull())
                {
                    isSupportMessageExtension = std::get<bool>(fvalue);
                }
            }

            bool isExcludedFromContentModeration = false;
            if (isExcludedFromContentModeration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = isExcludedFromContentModeration_it->second;
                if (!fvalue.IsNull())
                {
                    isExcludedFromContentModeration = std::get<bool>(fvalue);
                }
            }

            bool needReadReceipt = false;
            if (needReadReceipt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = needReadReceipt_it->second;
                if (!fvalue.IsNull())
                {
                    needReadReceipt = std::get<bool>(fvalue);
                }
            }
            V2TIMOfflinePushInfo pushInfo = V2TIMOfflinePushInfo();
            if (offlinePushInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = offlinePushInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto offlinePushInfoMap = std::get<flutter::EncodableMap>(fvalue);

                    auto title_it = offlinePushInfoMap.find(flutter::EncodableValue("title"));

                    if (title_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = title_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.title = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }

                    auto desc_it = offlinePushInfoMap.find(flutter::EncodableValue("desc"));
                    if (desc_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = desc_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.desc = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto ext_it = offlinePushInfoMap.find(flutter::EncodableValue("ext"));
                    if (ext_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = ext_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.ext = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto disablePush_it = offlinePushInfoMap.find(flutter::EncodableValue("disablePush"));
                    if (disablePush_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = disablePush_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.disablePush = std::get<bool>(vv);
                        }
                    }
                    auto iOSSound_it = offlinePushInfoMap.find(flutter::EncodableValue("iOSSound"));
                    if (iOSSound_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = iOSSound_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.iOSSound = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto ignoreIOSBadge_it = offlinePushInfoMap.find(flutter::EncodableValue("ignoreIOSBadge"));
                    if (ignoreIOSBadge_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = ignoreIOSBadge_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.ignoreIOSBadge = std::get<bool>(vv);
                        }
                    }
                    auto androidOPPOChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidOPPOChannelID"));
                    if (androidOPPOChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidOPPOChannelID_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidOPPOChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidVIVOClassification_it = offlinePushInfoMap.find(flutter::EncodableValue("androidVIVOClassification"));
                    if (androidVIVOClassification_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidVIVOClassification_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidVIVOClassification = std::get<int>(vv);
                        }
                    }

                    auto androidSound_it = offlinePushInfoMap.find(flutter::EncodableValue("androidSound"));
                    if (androidSound_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidSound_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidSound = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidFCMChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidFCMChannelID"));
                    if (androidFCMChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidFCMChannelID_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidFCMChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidXiaoMiChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidXiaoMiChannelID"));
                    if (androidXiaoMiChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidXiaoMiChannelID_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidXiaoMiChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto iOSPushTypee_it = offlinePushInfoMap.find(flutter::EncodableValue("iOSPushType"));
                    if (iOSPushTypee_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = iOSPushTypee_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.iOSPushType = static_cast<V2TIMIOSOfflinePushType>(std::get<int>(vv));
                        }
                    }
                    auto androidHuaWeiCategory_it = offlinePushInfoMap.find(flutter::EncodableValue("androidHuaWeiCategory"));
                    if (androidHuaWeiCategory_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidHuaWeiCategory_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidHuaWeiCategory = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidVIVOCategory_it = offlinePushInfoMap.find(flutter::EncodableValue("androidVIVOCategory"));
                    if (androidVIVOCategory_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidVIVOCategory_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidVIVOCategory = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }



                    auto androidHuaWeiImage_it = offlinePushInfoMap.find(flutter::EncodableValue("androidHuaWeiImage"));
                    if (androidHuaWeiImage_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidHuaWeiImage_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidHuaWeiImage = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidHonorImage_it = offlinePushInfoMap.find(flutter::EncodableValue("androidHonorImage"));
                    if (androidHonorImage_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidHonorImage_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidHonorImage = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidFCMImage_it = offlinePushInfoMap.find(flutter::EncodableValue("androidFCMImage"));
                    if (androidFCMImage_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = androidFCMImage_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidFCMImage = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto iOSImage_it = offlinePushInfoMap.find(flutter::EncodableValue("iOSImage"));
                    if (iOSImage_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = iOSImage_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.iOSImage = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }

                }
            }
            std::string cloudCustomData = "";
            if (cloudCustomData_it != arguments->end())
            {
                flutter::EncodableValue fvalue = cloudCustomData_it->second;
                if (!fvalue.IsNull())
                {
                    cloudCustomData = std::get<std::string>(fvalue);
                }
            }

            std::string localCustomData = "";
            if (localCustomData_it != arguments->end())
            {
                flutter::EncodableValue fvalue = localCustomData_it->second;
                if (!fvalue.IsNull())
                {
                    localCustomData = std::get<std::string>(fvalue);
                }
            }
            auto createdMessageIt = createdMessageMap.find(id);
            // V2TIMMessage sendmessage = V2TIMMessage();
            if (createdMessageIt != createdMessageMap.end())
            {
                // sendmessage = createdMessageIt->second;
                createdMessageIt->second.cloudCustomData = ConvertDataUtils::string2Buffer(cloudCustomData);
                createdMessageIt->second.SetLocalCustomData(ConvertDataUtils::string2Buffer(localCustomData),nullptr);
                createdMessageIt->second.isExcludedFromContentModeration = isExcludedFromContentModeration;
                createdMessageIt->second.isExcludedFromLastMessage = isExcludedFromLastMessage;
                createdMessageIt->second.isExcludedFromUnreadCount = isExcludedFromUnreadCount;
                createdMessageIt->second.needReadReceipt = needReadReceipt;
                createdMessageIt->second.supportMessageExtension = isSupportMessageExtension;
                V2TIMSendCallbackValueCallback* cb = new V2TIMSendCallbackValueCallback(std::move(result), createdMessageIt->second, id, messageListener->getUuids());
                V2TIMManager::GetInstance()->GetMessageManager()->SendMessageW(createdMessageIt->second, V2TIMString{ receiver.c_str() }, V2TIMString{ groupID.c_str() }, static_cast<V2TIMMessagePriority>(priority), onlineUserOnly, pushInfo, cb);
            }
            else
            {
                result->Success(FormatTIMValueCallback(-1, "id not extis", flutter::EncodableValue()));
                return;
            }

            
        }
        else if (method_call.method_name().compare("createFileMessage") == 0)
        {
            auto filePath_it = arguments->find(flutter::EncodableValue("filePath"));
            auto fileName_it = arguments->find(flutter::EncodableValue("fileName"));

            std::string filePath = "";
            if (filePath_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filePath_it->second;
                if (!fvalue.IsNull())
                {
                    filePath = std::get<std::string>(fvalue);
                }
            }

            std::string fileName = "";
            if (fileName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = fileName_it->second;
                if (!fvalue.IsNull())
                {
                    fileName = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateFileMessage(V2TIMString{filePath.c_str()}, V2TIMString{fileName.c_str()});
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createTextAtMessage") == 0)
        {
            auto text_it = arguments->find(flutter::EncodableValue("text"));
            auto atUserList_it = arguments->find(flutter::EncodableValue("atUserList"));

            std::string text = "";
            if (text_it != arguments->end())
            {
                flutter::EncodableValue fvalue = text_it->second;
                if (!fvalue.IsNull())
                {
                    text = std::get<std::string>(fvalue);
                }
            }
            flutter::EncodableList atUserList = {};
            if (atUserList_it != arguments->end())
            {

                atUserList = std::get<flutter::EncodableList>(atUserList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = atUserList.size();
            for (size_t i = 0; i < usize; i++)
            {
                std::string uid = std::get<std::string>(atUserList[i]).c_str();
                auto atllconst = V2TIMString{ "__kImSDK_MessageAtALL__" };
                auto atllconst2 = V2TIMString{ "__kImSDK_MessageAtALL__" };
                if (V2TIMString{ uid.c_str()}.operator==(atllconst) || V2TIMString{ uid.c_str() }.operator==(atllconst2)) {
                    uids.PushBack(kImSDK_MesssageAtALL);
                }
                else {
                    uids.PushBack(V2TIMString{ uid.c_str() });
                }
                
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateTextAtMessage(V2TIMString{text.c_str()}, uids);
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createLocationMessage") == 0)
        {

            auto desc_it = arguments->find(flutter::EncodableValue("desc"));
            auto longitude_it = arguments->find(flutter::EncodableValue("longitude"));
            auto latitude_it = arguments->find(flutter::EncodableValue("latitude"));

            std::string desc = "";
            if (desc_it != arguments->end())
            {
                flutter::EncodableValue fvalue = desc_it->second;
                if (!fvalue.IsNull())
                {
                    desc = std::get<std::string>(fvalue);
                }
            }
            double longitude = 0;
            if (longitude_it != arguments->end())
            {
                flutter::EncodableValue fvalue = longitude_it->second;
                if (!fvalue.IsNull())
                {
                    longitude = std::get<double>(fvalue);
                }
            }
            double latitude = 0;
            if (latitude_it != arguments->end())
            {
                flutter::EncodableValue fvalue = latitude_it->second;
                if (!fvalue.IsNull())
                {
                    latitude = std::get<double>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateLocationMessage(V2TIMString{desc.c_str()}, longitude, latitude);
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createFaceMessage") == 0)
        {

            auto index_it = arguments->find(flutter::EncodableValue("index"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));

            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }

            int index = 0;
            if (index_it != arguments->end())
            {
                flutter::EncodableValue fvalue = index_it->second;
                if (!fvalue.IsNull())
                {
                    index = std::get<int>(fvalue);
                }
            }
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateFaceMessage(index, ConvertDataUtils::string2Buffer(data));
            std::string id = ConvertDataUtils::generateRandomString();
            createdMessageMap.insert(std::make_pair(id, message));
            auto res = flutter::EncodableMap();
            auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&message);
            messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
            res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
        }
        else if (method_call.method_name().compare("createMergerMessage") == 0)
        {

            auto msgIDList_it = arguments->find(flutter::EncodableValue("msgIDList"));

            flutter::EncodableList msgIDList = {};
            if (msgIDList_it != arguments->end())
            {

                msgIDList = std::get<flutter::EncodableList>(msgIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = msgIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(msgIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 1, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("createForwardMessage") == 0)
        {

            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector msgIDList = {};
            msgIDList.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 0, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
        }
        else if (method_call.method_name().compare("sendTextMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendTextMessage is not support on windows . use createTextMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendCustomMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendCustomMessage is not support on windows . use createCustomMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendImageMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendImageMessage is not support on windows . use createImageMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendVideoMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendVideoMessage is not support on windows . use createVideoMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendFileMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendFileMessage is not support on windows . use createFileMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendSoundMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendSoundMessage is not support on windows . use createSoundMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendTextAtMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendTextAtMessage is not support on windows . use createTextAtMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendLocationMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendLocationMessage is not support on windows . use createLocationMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendFaceMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendFaceMessage is not support on windows . use createFaceMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendMergerMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendMergerMessage is not support on windows . use createMergerMessage and sendMessage instead.", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("setLocalCustomData") == 0)
        {

            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringVector uids = {};

            uids.PushBack(V2TIMString{msgID.c_str()});

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 3, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("setLocalCustomInt") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringVector uids = {};

            uids.PushBack(V2TIMString{msgID.c_str()});

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 4, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("setCloudCustomData") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setCloudCustomData is not support on windows . ", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getC2CHistoryMessageList") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "getC2CHistoryMessageList is not support on windows . use getHistoryMessageListV2 instead .", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("getHistoryMessageList") == 0)
        {
            auto getType_it = arguments->find(flutter::EncodableValue("getType"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto lastMsgSeq_it = arguments->find(flutter::EncodableValue("lastMsgSeq"));
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            auto lastMsgID_it = arguments->find(flutter::EncodableValue("lastMsgID"));
            auto messageTypeList_it = arguments->find(flutter::EncodableValue("messageTypeList"));
            auto messageSeqList_it = arguments->find(flutter::EncodableValue("messageSeqList"));
            auto timeBegin_it = arguments->find(flutter::EncodableValue("timeBegin"));
            auto timePeriod_it = arguments->find(flutter::EncodableValue("timePeriod"));
            V2TIMMessageListGetOption opt = V2TIMMessageListGetOption();
            int getType = 0;
            if (getType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = getType_it->second;
                if (!fvalue.IsNull())
                {
                    getType = std::get<int>(fvalue);
                    opt.getType = static_cast<V2TIMMessageGetType>(getType);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                    if (!userID.empty()) {
                        opt.userID = V2TIMString{ userID.c_str() };
                    }
                    
                }
            }

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                    if (!groupID.empty()) {
                        opt.groupID = V2TIMString{ groupID.c_str() };
                    }
                }
            }

            int lastMsgSeq = -1;
            if (lastMsgSeq_it != arguments->end())
            {
                flutter::EncodableValue fvalue = lastMsgSeq_it->second;
                if (!fvalue.IsNull())
                {
                    lastMsgSeq = std::get<int>(fvalue);
                    if (lastMsgSeq != -1) {
                        opt.lastMsgSeq = lastMsgSeq;
                    }
                }
            }

            int count = -1;
            if (count_it != arguments->end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                    opt.count = count;
                }
            }

            flutter::EncodableList messageTypeList = {};
            if (messageTypeList_it != arguments->end())
            {

                messageTypeList = std::get<flutter::EncodableList>(messageTypeList_it->second);
            }

            V2TIMElemTypeVector uids = {};
            size_t usize = messageTypeList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<int>(messageTypeList[i]);
                uids.PushBack(static_cast<V2TIMElemType>(uid));
            }
            opt.messageTypeList = uids;
            flutter::EncodableList messageSeqList = {};
            if (messageSeqList_it != arguments->end())
            {

                messageSeqList = std::get<flutter::EncodableList>(messageSeqList_it->second);
            }

            V2TIMUInt64Vector uid2s = {};
            size_t u2size = messageSeqList.size();
            for (size_t i = 0; i < u2size; i++)
            {
                auto uid = std::get<int>(messageSeqList[i]);
                uid2s.PushBack(uid);
            }
            opt.messageSeqList = uid2s;
            int timeBegin = 0;
            if (timeBegin_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timeBegin_it->second;
                if (!fvalue.IsNull())
                {
                    timeBegin = std::get<int>(fvalue);
                    opt.getTimeBegin = timeBegin;
                }
            }

            int timePeriod = 0;
            if (timePeriod_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timePeriod_it->second;
                if (!fvalue.IsNull())
                {
                    timePeriod = std::get<int>(fvalue);
                    opt.getTimePeriod = timePeriod;
                }
            }

            std::string lastMsgID = "";
            if (lastMsgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = lastMsgID_it->second;
                if (!fvalue.IsNull())
                {
                    lastMsgID = std::get<std::string>(fvalue);
                    V2TIMStringVector msgIDList = {};
                    msgIDList.PushBack(V2TIMString{lastMsgID.c_str()});
                    V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 5, arguments, &createdMessageMap);
                    V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
                    return;
                }
            }
            V2TIMMessageVectorValueCallbackReturn *callback = new V2TIMMessageVectorValueCallbackReturn(std::move(result), 5, count,false);
            V2TIMManager::GetInstance()->GetMessageManager()->GetHistoryMessageList(opt, callback);
        }
        else if (method_call.method_name().compare("getHistoryMessageListV2") == 0)
        {

            auto getType_it = arguments->find(flutter::EncodableValue("getType"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto lastMsgSeq_it = arguments->find(flutter::EncodableValue("lastMsgSeq"));
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            auto lastMsgID_it = arguments->find(flutter::EncodableValue("lastMsgID"));
            auto messageTypeList_it = arguments->find(flutter::EncodableValue("messageTypeList"));
            auto messageSeqList_it = arguments->find(flutter::EncodableValue("messageSeqList"));
            auto timeBegin_it = arguments->find(flutter::EncodableValue("timeBegin"));
            auto timePeriod_it = arguments->find(flutter::EncodableValue("timePeriod"));
            V2TIMMessageListGetOption opt = V2TIMMessageListGetOption();
            int getType = 0;
            if (getType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = getType_it->second;
                if (!fvalue.IsNull())
                {
                    getType = std::get<int>(fvalue);
                    opt.getType = static_cast<V2TIMMessageGetType>(getType);
                }
            }
            
            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                    if (!userID.empty()) {
                        opt.userID = V2TIMString{ userID.c_str() };
                    }
                    
                }
            }

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second; 
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                    if (!groupID.empty()) {
                        opt.groupID = V2TIMString{ groupID.c_str() };
                    }
                    
                }
            }

            int lastMsgSeq = -1;
            if (lastMsgSeq_it != arguments->end())
            {
                flutter::EncodableValue fvalue = lastMsgSeq_it->second;
                if (!fvalue.IsNull())
                {
                    lastMsgSeq = std::get<int>(fvalue);
                    if (lastMsgSeq!=-1) {
                        opt.lastMsgSeq = lastMsgSeq;
                    }
                    
                }
            }

            int count = -1;
            if (count_it != arguments->end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                    opt.count = count;
                }
            }

            flutter::EncodableList messageTypeList = {};
            if (messageTypeList_it != arguments->end())
            {

                messageTypeList = std::get<flutter::EncodableList>(messageTypeList_it->second);
            }

            V2TIMElemTypeVector uids = {};
            size_t usize = messageTypeList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<int>(messageTypeList[i]);
                uids.PushBack(static_cast<V2TIMElemType>(uid));
            }
            opt.messageTypeList = uids;
            flutter::EncodableList messageSeqList = {};
            if (messageSeqList_it != arguments->end())
            {

                messageSeqList = std::get<flutter::EncodableList>(messageSeqList_it->second);
            }

            V2TIMUInt64Vector uid2s = {};
            size_t u2size = messageSeqList.size();
            for (size_t i = 0; i < u2size; i++)
            {
                auto uid = std::get<int>(messageSeqList[i]);
                uid2s.PushBack(uid);
            }
            opt.messageSeqList = uid2s;
            int timeBegin = 0;
            if (timeBegin_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timeBegin_it->second;
                if (!fvalue.IsNull())
                {
                    timeBegin = std::get<int>(fvalue);
                    opt.getTimeBegin = timeBegin;
                }
            }

            int timePeriod = 0;
            if (timePeriod_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timePeriod_it->second;
                if (!fvalue.IsNull())
                {
                    timePeriod = std::get<int>(fvalue);
                    opt.getTimePeriod = timePeriod;
                }
            }

            std::string lastMsgID = "";
            if (lastMsgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = lastMsgID_it->second;
                if (!fvalue.IsNull())
                {
                    lastMsgID = std::get<std::string>(fvalue);
                    V2TIMStringVector msgIDList = {};
                    msgIDList.PushBack(V2TIMString{lastMsgID.c_str()});
                    V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 6, arguments, &createdMessageMap);
                    V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
                    return;
                }
            }
            V2TIMMessageVectorValueCallbackReturn *callback = new V2TIMMessageVectorValueCallbackReturn(std::move(result), 6, count,false);
            V2TIMManager::GetInstance()->GetMessageManager()->GetHistoryMessageList(opt, callback);
        }
        else if (method_call.method_name().compare("getGroupHistoryMessageList") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "getGroupHistoryMessageList is not support on windows . use getHistoryMessageListV2 instead .", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("revokeMessage") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};

            uids.PushBack(V2TIMString{msgID.c_str()});

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 7, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("markC2CMessageAsRead") == 0)
        {
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->MarkC2CMessageAsRead(V2TIMString{userID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("sendForwardMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "sendForwardMessage is not support on windows . use createForwardMessage and sendMessage instead .", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("reSendMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "reSendMessage is not support on windows . Delete the failed message and send a message with the same content instead .", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("setC2CReceiveMessageOpt") == 0)
        {

            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));
            auto opt_it = arguments->find(flutter::EncodableValue("opt"));

            int opt = 0;
            if (opt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = opt_it->second;
                if (!fvalue.IsNull())
                {
                    opt = std::get<int>(fvalue);
                }
            }

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SetC2CReceiveMessageOpt(uids, static_cast<V2TIMReceiveMessageOpt>(opt), callback);
        }
        else if (method_call.method_name().compare("getC2CReceiveMessageOpt") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMReceiveMessageOptInfoVectorValueCallback *callback = new V2TIMReceiveMessageOptInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->GetC2CReceiveMessageOpt(uids, callback);
        }

        if (method_call.method_name().compare("setGroupReceiveMessageOpt") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto opt_it = arguments->find(flutter::EncodableValue("opt"));

            int opt = 0;
            if (opt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = opt_it->second;
                if (!fvalue.IsNull())
                {
                    opt = std::get<int>(fvalue);
                }
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SetGroupReceiveMessageOpt(V2TIMString{groupID.c_str()}, static_cast<V2TIMReceiveMessageOpt>(opt), callback);
        }
        else if (method_call.method_name().compare("markGroupMessageAsRead") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->MarkGroupMessageAsRead(V2TIMString{groupID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("deleteMessageFromLocalStorage") == 0)
        {

            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};

            uids.PushBack(V2TIMString{msgID.c_str()});

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 8, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("deleteMessages") == 0)
        {

            auto msgIDs_it = arguments->find(flutter::EncodableValue("msgIDs"));

            flutter::EncodableList msgIDs = {};
            if (msgIDs_it != arguments->end())
            {

                msgIDs = std::get<flutter::EncodableList>(msgIDs_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = msgIDs.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(msgIDs[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 9, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("insertGroupMessageToLocalStorage") == 0)
        {

            auto data_it = arguments->find(flutter::EncodableValue("data"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto sender_it = arguments->find(flutter::EncodableValue("sender"));

            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string sender = "";
            if (sender_it != arguments->end())
            {
                flutter::EncodableValue fvalue = sender_it->second;
                if (!fvalue.IsNull())
                {
                    sender = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessageValueCallback *callback = new V2TIMMessageValueCallback(std::move(result));
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateCustomMessage(ConvertDataUtils::string2Buffer(data));
            V2TIMManager::GetInstance()->GetMessageManager()->InsertGroupMessageToLocalStorage(message, V2TIMString{groupID.c_str()}, V2TIMString{sender.c_str()}, callback);
        }
        else if (method_call.method_name().compare("insertC2CMessageToLocalStorage") == 0)
        {
            auto data_it = arguments->find(flutter::EncodableValue("data"));
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto sender_it = arguments->find(flutter::EncodableValue("sender"));

            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }

            std::string sender = "";
            if (sender_it != arguments->end())
            {
                flutter::EncodableValue fvalue = sender_it->second;
                if (!fvalue.IsNull())
                {
                    sender = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessageValueCallback *callback = new V2TIMMessageValueCallback(std::move(result));
            V2TIMMessage message = V2TIMManager::GetInstance()->GetMessageManager()->CreateCustomMessage(ConvertDataUtils::string2Buffer(data));
            V2TIMManager::GetInstance()->GetMessageManager()->InsertGroupMessageToLocalStorage(message, V2TIMString{userID.c_str()}, V2TIMString{sender.c_str()}, callback);
        }
        else if (method_call.method_name().compare("clearC2CHistoryMessage") == 0)
        {
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));

            std::string userID = "";
            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->ClearC2CHistoryMessage(V2TIMString{userID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("clearGroupHistoryMessage") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->ClearGroupHistoryMessage(V2TIMString{groupID.c_str()}, callback);
        }
        else if (method_call.method_name().compare("searchLocalMessages") == 0)
        {
            auto searchParam_it = arguments->find(flutter::EncodableValue("searchParam"));
            V2TIMMessageSearchParam searchParam = V2TIMMessageSearchParam();
            if (searchParam_it != arguments->end())
            {
                flutter::EncodableValue fvalue = searchParam_it->second;
                if (!fvalue.IsNull())
                {
                    auto searchParamMap = std::get<flutter::EncodableMap>(fvalue);

                    auto keywordListMatchType_it = searchParamMap.find(flutter::EncodableValue("keywordListMatchType"));
                    auto conversationID_it = searchParamMap.find(flutter::EncodableValue("conversationID"));
                    auto searchTimePosition_it = searchParamMap.find(flutter::EncodableValue("searchTimePosition"));
                    auto searchTimePeriod_it = searchParamMap.find(flutter::EncodableValue("searchTimePeriod"));
                    auto pageIndex_it = searchParamMap.find(flutter::EncodableValue("pageIndex"));
                    auto pageSize_it = searchParamMap.find(flutter::EncodableValue("pageSize"));
                    auto searchCount_it = searchParamMap.find(flutter::EncodableValue("searchCount"));
                    auto searchCursor_it = searchParamMap.find(flutter::EncodableValue("searchCursor"));
                    auto messageTypeList_it = searchParamMap.find(flutter::EncodableValue("messageTypeList"));
                    auto senderUserIDList_it = searchParamMap.find(flutter::EncodableValue("senderUserIDList"));
                    auto keywordList_it = searchParamMap.find(flutter::EncodableValue("keywordList"));

                    if (keywordListMatchType_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordListMatchType_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.keywordListMatchType = static_cast<V2TIMKeywordListMatchType>(std::get<int>(vv));
                        }
                    }
                    if (conversationID_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = conversationID_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.conversationID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (searchTimePosition_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchTimePosition_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchTimePosition = std::get<int>(vv);
                        }
                    }
                    if (searchTimePeriod_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchTimePeriod_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchTimePeriod = std::get<int>(vv);
                        }
                    }
                    if (pageIndex_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = pageIndex_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.pageIndex = std::get<int>(vv);
                        }
                    }
                    if (pageSize_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = pageSize_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.pageSize = std::get<int>(vv);
                        }
                    }
                    if (searchCount_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchCount_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchCount = std::get<int>(vv);
                        }
                    }
                    if (searchCursor_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchCursor_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchCursor = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (messageTypeList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = messageTypeList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMElemTypeVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(static_cast<V2TIMElemType>(std::get<int>(list[i])));
                            }
                            searchParam.messageTypeList = kws;
                        }
                    }
                    if (senderUserIDList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = senderUserIDList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.senderUserIDList = kws;
                        }
                    }
                    if (keywordList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.keywordList = kws;
                        }
                    }
                }
            }

            V2TIMMessageSearchResultValueCallback *callback = new V2TIMMessageSearchResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SearchLocalMessages(searchParam, callback);
        }
        else if (method_call.method_name().compare("findMessages") == 0)
        {
            auto messageIDList_it = arguments->find(flutter::EncodableValue("messageIDList"));

            flutter::EncodableList messageIDList = {};
            if (messageIDList_it != arguments->end())
            {

                messageIDList = std::get<flutter::EncodableList>(messageIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = messageIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(messageIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 10, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("markAllMessageAsRead") == 0)
        {
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->MarkAllMessageAsRead(callback);
        }
        else if (method_call.method_name().compare("addAdvancedMsgListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (messageListener->getUuids().size() == 0)
            {
                messageListener->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->GetMessageManager()->AddAdvancedMsgListener(messageListener);
            }
            else
            {
                messageListener->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeAdvancedMsgListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                messageListener->cleanUuid();
                V2TIMManager::GetInstance()->GetMessageManager()->RemoveAdvancedMsgListener(messageListener);
            }
            else
            {
                messageListener->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("sendMessageReadReceipts") == 0)
        {
            auto messageIDList_it = arguments->find(flutter::EncodableValue("messageIDList"));

            flutter::EncodableList messageIDList = {};
            if (messageIDList_it != arguments->end())
            {

                messageIDList = std::get<flutter::EncodableList>(messageIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = messageIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(messageIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 11, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getMessageReadReceipts") == 0)
        {
            auto messageIDList_it = arguments->find(flutter::EncodableValue("messageIDList"));

            flutter::EncodableList messageIDList = {};
            if (messageIDList_it != arguments->end())
            {

                messageIDList = std::get<flutter::EncodableList>(messageIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = messageIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(messageIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 12, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getGroupMessageReadMemberList") == 0)
        {

            auto messageID_it = arguments->find(flutter::EncodableValue("messageID"));

            std::string messageID = "";
            if (messageID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = messageID_it->second;
                if (!fvalue.IsNull())
                {
                    messageID = std::get<std::string>(fvalue);
                }
            }

            TXV2TIMStringVector uids = TXV2TIMStringVector();
            uids.PushBack(V2TIMString{messageID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 13, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getJoinedCommunityList") == 0)
        {
            V2TIMGroupInfoVectorValueCallback *callback = new V2TIMGroupInfoVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetJoinedCommunityList(callback);
        }
        else if (method_call.method_name().compare("createTopicInCommunity") == 0)
        {

            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto topicInfo_it = arguments->find(flutter::EncodableValue("topicInfo"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMTopicInfo info = V2TIMTopicInfo();
            if (topicInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = topicInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto topicInfoMap = std::get<flutter::EncodableMap>(fvalue);

                    auto topicID_it = topicInfoMap.find(flutter::EncodableValue("topicID"));
                    auto topicName_it = topicInfoMap.find(flutter::EncodableValue("topicName"));
                    auto faceUrl_it = topicInfoMap.find(flutter::EncodableValue("topicFaceUrl"));
                    auto introduction_it = topicInfoMap.find(flutter::EncodableValue("introduction"));
                    auto notification_it = topicInfoMap.find(flutter::EncodableValue("notification"));
                    auto isAllMute_it = topicInfoMap.find(flutter::EncodableValue("isAllMute"));
                    auto customString_it = topicInfoMap.find(flutter::EncodableValue("customString"));
                    auto defaultPermissions_it = topicInfoMap.find(flutter::EncodableValue("defaultPermissions"));
                    if (topicID_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = topicID_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (topicName_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = topicID_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicName = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (faceUrl_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = faceUrl_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicFaceURL = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (introduction_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = introduction_it->second;
                        if (!vv.IsNull())
                        {
                            info.introduction = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (notification_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = notification_it->second;
                        if (!vv.IsNull())
                        {
                            info.notification = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (customString_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = customString_it->second;
                        if (!vv.IsNull())
                        {
                            info.customString = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (isAllMute_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = isAllMute_it->second;
                        if (!vv.IsNull())
                        {
                            info.isAllMuted = std::get<bool>(vv);
                        }
                    }
                    if (defaultPermissions_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = defaultPermissions_it->second;
                        if (!vv.IsNull())
                        {
                            info.defaultPermissions = std::get<int>(vv);
                        }
                    }
                }
            }
            CommV2TIMStringValueCallback *callback = new CommV2TIMStringValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->CreateTopicInCommunity(V2TIMString{groupID.c_str()}, info, callback);
        }
        else if (method_call.method_name().compare("deleteTopicFromCommunity") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto topicIDList_it = arguments->find(flutter::EncodableValue("topicIDList"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            flutter::EncodableList topicIDList = {};
            if (topicIDList_it != arguments->end())
            {

                topicIDList = std::get<flutter::EncodableList>(topicIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = topicIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(topicIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            V2TIMTopicOperationResultVectorValueCallback *callback = new V2TIMTopicOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->DeleteTopicFromCommunity(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("setTopicInfo") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto topicInfo_it = arguments->find(flutter::EncodableValue("topicInfo"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMTopicInfo info = V2TIMTopicInfo();
            if (topicInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = topicInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto topicInfoMap = std::get<flutter::EncodableMap>(fvalue);
                    auto topicID_it = topicInfoMap.find(flutter::EncodableValue("topicID"));
                    auto topicName_it = topicInfoMap.find(flutter::EncodableValue("topicName"));
                    auto faceUrl_it = topicInfoMap.find(flutter::EncodableValue("topicFaceUrl"));
                    auto introduction_it = topicInfoMap.find(flutter::EncodableValue("introduction"));
                    auto notification_it = topicInfoMap.find(flutter::EncodableValue("notification"));
                    auto isAllMute_it = topicInfoMap.find(flutter::EncodableValue("isAllMute"));
                    auto customString_it = topicInfoMap.find(flutter::EncodableValue("customString"));
                    auto defaultPermissions_it = topicInfoMap.find(flutter::EncodableValue("defaultPermissions"));
                    uint32_t flag = 0x00;
                    if (topicID_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = topicID_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (topicName_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = topicName_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicName = V2TIMString{std::get<std::string>(vv).c_str()};
                            flag = flag | 0x01;
                        }
                    }
                    if (faceUrl_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = faceUrl_it->second;
                        if (!vv.IsNull())
                        {
                            info.topicFaceURL = V2TIMString{std::get<std::string>(vv).c_str()};
                            flag = flag | 0x01 << 3;
                        }
                    }
                    if (introduction_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = introduction_it->second;
                        if (!vv.IsNull())
                        {
                            info.introduction = V2TIMString{std::get<std::string>(vv).c_str()};
                            flag = flag | 0x01 << 2;
                        }
                    }
                    if (notification_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = notification_it->second;
                        if (!vv.IsNull())
                        {
                            info.notification = V2TIMString{std::get<std::string>(vv).c_str()};
                            flag = flag | 0x01 << 1;
                        }
                    }
                    if (customString_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = customString_it->second;
                        if (!vv.IsNull())
                        {
                            info.customString = V2TIMString{std::get<std::string>(vv).c_str()};
                            flag = flag | 0x01 << 11;
                        }
                    }
                    if (isAllMute_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = isAllMute_it->second;
                        if (!vv.IsNull())
                        {
                            info.isAllMuted = std::get<bool>(vv);
                            flag = flag | 0x01 << 8;
                        }
                    }
                    if (defaultPermissions_it != topicInfoMap.end())
                    {
                        flutter::EncodableValue vv = defaultPermissions_it->second;
                        if (!vv.IsNull())
                        {
                            info.defaultPermissions = std::get<int>(vv);
                            flag = flag | 0x01 << 14;
                        }
                    }
                    info.modifyFlag = flag;
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetTopicInfo(info, callback);
        }
        else if (method_call.method_name().compare("getTopicInfoList") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto topicIDList_it = arguments->find(flutter::EncodableValue("topicIDList"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            flutter::EncodableList topicIDList = {};
            if (topicIDList_it != arguments->end())
            {

                topicIDList = std::get<flutter::EncodableList>(topicIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = topicIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(topicIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMTopicInfoResultVectorValueCallback* callback = new V2TIMTopicInfoResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetTopicInfoList(V2TIMString{ groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("modifyMessage") == 0)
        {
            auto message_it = arguments->find(flutter::EncodableValue("message"));

            if (message_it != arguments->end())
            {
                flutter::EncodableValue fvalue = message_it->second;
                if (!fvalue.IsNull())
                {
                    auto messageMap = std::get<flutter::EncodableMap>(fvalue);
                    auto msgID_it = messageMap.find(flutter::EncodableValue("msgID"));
                    if (msgID_it != messageMap.end())
                    {
                        flutter::EncodableValue vv = msgID_it->second;
                        if (!vv.IsNull())
                        {
                            V2TIMStringVector uids = V2TIMStringVector();
                            uids.PushBack(V2TIMString{std::get<std::string>(vv).c_str()});
                            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 14, arguments, &createdMessageMap);
                            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
                            return;
                        }
                    }
                }
            }
            result->Success(FormatTIMValueCallback(-1, "message not found", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("appendMessage") == 0)
        {

            auto createMessageBaseId_it = arguments->find(flutter::EncodableValue("createMessageBaseId"));
            auto createMessageAppendId_it = arguments->find(flutter::EncodableValue("createMessageAppendId"));

            std::string createMessageBaseId = "";
            if (createMessageBaseId_it != arguments->end())
            {
                flutter::EncodableValue fvalue = createMessageBaseId_it->second;
                if (!fvalue.IsNull())
                {
                    createMessageBaseId = std::get<std::string>(fvalue);
                }
            }
            std::string createMessageAppendId = "";
            if (createMessageAppendId_it != arguments->end())
            {
                flutter::EncodableValue fvalue = createMessageAppendId_it->second;
                if (!fvalue.IsNull())
                {
                    createMessageAppendId = std::get<std::string>(fvalue);
                }
            }
            auto c_it = createdMessageMap.find(createMessageBaseId);
            auto a_it = createdMessageMap.find(createMessageAppendId);
            V2TIMMessage *cmessage = new V2TIMMessage();
            V2TIMMessage *amessage = new V2TIMMessage();
            if (c_it != createdMessageMap.end())
            {
                cmessage = &c_it->second;
            }
            if (a_it != createdMessageMap.end())
            {
                amessage = &a_it->second;
            }
            if (cmessage != nullptr && amessage != nullptr)
            {
                cmessage->elemList.PushBack(cmessage->elemList[0]);
                result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(ConvertDataUtils::convertV2TIMMessage2Map(cmessage))));
            }
            else
            {
                result->Success(FormatTIMValueCallback(-1, "message id error", flutter::EncodableValue()));
            }
        }
        else if (method_call.method_name().compare("getUserStatus") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMUserStatusVectorValueCallback *callbacl = new V2TIMUserStatusVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetUserStatus(uids, callbacl);
        }
        else if (method_call.method_name().compare("setSelfStatus") == 0)
        {

            auto status_it = arguments->find(flutter::EncodableValue("status"));

            std::string status = "";
            if (status_it != arguments->end())
            {
                flutter::EncodableValue fvalue = status_it->second;
                if (!fvalue.IsNull())
                {
                    status = std::get<std::string>(fvalue);
                }
            }
            V2TIMUserStatus s = V2TIMUserStatus();
            s.customStatus = V2TIMString{status.c_str()};

            CommonCallback *callback = new CommonCallback(std::move(result));

            V2TIMManager::GetInstance()->SetSelfStatus(s, callback);
        }
        else if (method_call.method_name().compare("checkAbility") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "checkAbility is not support on windows . ", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("subscribeUserStatus") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->SubscribeUserStatus(uids, callback);
        }
        else if (method_call.method_name().compare("unsubscribeUserStatus") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->UnsubscribeUserStatus(uids, callback);
        }
        else if (method_call.method_name().compare("setConversationCustomData") == 0)
        {

            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto customData_it = arguments->find(flutter::EncodableValue("customData"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            std::string customData = "";
            if (customData_it != arguments->end())
            {
                flutter::EncodableValue fvalue = customData_it->second;
                if (!fvalue.IsNull())
                {
                    customData = std::get<std::string>(fvalue);
                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->SetConversationCustomData(uids, ConvertDataUtils::string2Buffer(customData), callback);
        }
        else if (method_call.method_name().compare("getConversationListByFilter") == 0)
        {

            auto filter_it = arguments->find(flutter::EncodableValue("filter"));
            auto nextSeq_it = arguments->find(flutter::EncodableValue("nextSeq"));
            auto count_it = arguments->find(flutter::EncodableValue("count"));
            V2TIMConversationListFilter filter = V2TIMConversationListFilter();
            if (filter_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    auto filterMap = std::get<flutter::EncodableMap>(fvalue);
                    auto conversationGroup_it = filterMap.find(flutter::EncodableValue("conversationGroup"));
                    auto filterType_it = filterMap.find(flutter::EncodableValue("filterType"));
                    auto markType_it = filterMap.find(flutter::EncodableValue("markType"));
                    auto hasGroupAtInfot_it = filterMap.find(flutter::EncodableValue("hasGroupAtInfo"));
                    auto hasUnreadCount_it = filterMap.find(flutter::EncodableValue("hasUnreadCount"));
                    if (conversationGroup_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = conversationGroup_it->second;
                        if (!vv.IsNull())
                        {
                            filter.conversationGroup = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (filterType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = filterType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.filterType = std::get<int>(vv);
                        }
                    }
                    if (markType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = markType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.markType = std::get<int>(vv);
                        }
                    }
                    if (hasGroupAtInfot_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasGroupAtInfot_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasGroupAtInfo = std::get<bool>(vv);
                        }
                    }
                    if (hasUnreadCount_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasUnreadCount_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasUnreadCount = std::get<bool>(vv);
                        }
                    }
                }
            }

            int nextSeq = 0;
            if (nextSeq_it != arguments->end())
            {
                flutter::EncodableValue fvalue = nextSeq_it->second;
                if (!fvalue.IsNull())
                {
                    nextSeq = std::get<int>(fvalue);
                }
            }

            int count = 0;
            if (count_it != arguments->end())
            {
                flutter::EncodableValue fvalue = count_it->second;
                if (!fvalue.IsNull())
                {
                    count = std::get<int>(fvalue);
                }
            }
            CommV2TIMConversationResultValueCallback *callback = new CommV2TIMConversationResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetConversationListByFilter(filter, static_cast<uint64_t>(nextSeq), count, callback);
        }
        else if (method_call.method_name().compare("markConversation") == 0)
        {

            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto enableMark_it = arguments->find(flutter::EncodableValue("enableMark"));
            auto markType_it = arguments->find(flutter::EncodableValue("markType"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            bool enableMark = false;
            if (enableMark_it != arguments->end())
            {
                flutter::EncodableValue fvalue = enableMark_it->second;
                if (!fvalue.IsNull())
                {
                    enableMark = std::get<bool>(fvalue);
                }
            }

            uint64_t markType = 0;
            if (markType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = markType_it->second;
                if (!fvalue.IsNull())
                {
                    
                    std::vector<uint64_t> validMarkType = {  };

                    validMarkType.push_back(0x1LL << 0);
                    validMarkType.push_back(0x1LL << 1);
                    validMarkType.push_back(0x1LL << 2);
                    validMarkType.push_back(0x1LL << 3);

                    markType = fvalue.LongValue();
                   
                    

                    

                    
                    
                    for (int i = 32; i < 64;i++) {
                        validMarkType.push_back(0x1LL << i);
                    }
                    auto it = std::find(validMarkType.begin(), validMarkType.end(), markType);

                    if (it!= validMarkType.end()) {
                    }
                    else {
                        result->Success(FormatTIMValueCallback(-1, "Illegal markType, markType must be between [0x1l<<0,0x1l<<1,0x1l<<2,0x1l<<3,0x1l<<32,...,0x1l<<63]", flutter::EncodableValue()));
                    }

                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->MarkConversation(uids, markType, enableMark, callback);
        }

        else if (method_call.method_name().compare("createConversationGroup") == 0)
        {

            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            std::string groupName = "";
            if (groupName_it != arguments->end())
            {

                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->CreateConversationGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("getConversationGroupList") == 0)
        {
            V2TIMStringVectorValueCallback *callback = new V2TIMStringVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetConversationGroupList(callback);
        }
        else if (method_call.method_name().compare("deleteConversationGroup") == 0)
        {
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));

            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->DeleteConversationGroup(V2TIMString{groupName.c_str()}, callback);
        }
        else if (method_call.method_name().compare("renameConversationGroup") == 0)
        {
            auto oldName_it = arguments->find(flutter::EncodableValue("oldName"));
            auto newName_it = arguments->find(flutter::EncodableValue("newName"));

            std::string oldName = "";
            if (oldName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = oldName_it->second;
                if (!fvalue.IsNull())
                {
                    oldName = std::get<std::string>(fvalue);
                }
            }
            std::string newName = "";
            if (newName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = newName_it->second;
                if (!fvalue.IsNull())
                {
                    newName = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->RenameConversationGroup(V2TIMString{oldName.c_str()}, V2TIMString{newName.c_str()}, callback);
        }
        else if (method_call.method_name().compare("downloadMergerMessage") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 15, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("addConversationsToGroup") == 0)
        {
            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->AddConversationsToGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("deleteConversationList") == 0)
        {
            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto clearMessage_it = arguments->find(flutter::EncodableValue("clearMessage"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            bool clearMessage = "";
            if (clearMessage_it != arguments->end())
            {
                flutter::EncodableValue fvalue = clearMessage_it->second;
                if (!fvalue.IsNull())
                {
                    clearMessage = std::get<bool>(fvalue);
                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->DeleteConversationList(uids, clearMessage, callback);
        }
        else if (method_call.method_name().compare("subscribeUnreadMessageCountByFilter") == 0)
        {
            auto filter_it = arguments->find(flutter::EncodableValue("filter"));

            V2TIMConversationListFilter filter = V2TIMConversationListFilter();
            if (filter_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    auto filterMap = std::get<flutter::EncodableMap>(fvalue);
                    auto conversationGroup_it = filterMap.find(flutter::EncodableValue("conversationGroup"));
                    auto filterType_it = filterMap.find(flutter::EncodableValue("filterType"));
                    auto markType_it = filterMap.find(flutter::EncodableValue("markType"));
                    auto hasGroupAtInfo_it = filterMap.find(flutter::EncodableValue("hasGroupAtInfo"));
                    auto hasUnreadCount_it = filterMap.find(flutter::EncodableValue("hasUnreadCount"));
                    if (conversationGroup_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = conversationGroup_it->second;
                        if (!vv.IsNull())
                        {
                            filter.conversationGroup = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (filterType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = filterType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.filterType = std::get<int>(vv);
                        }
                    }
                    if (markType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = markType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.markType = std::get<int>(vv);
                        }
                    }
                    if (hasGroupAtInfo_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasGroupAtInfo_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasGroupAtInfo = std::get<bool>(vv);
                        }
                    }
                    if (hasUnreadCount_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasUnreadCount_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasUnreadCount = std::get<bool>(vv);
                        }
                    }
                }
            }
            V2TIMManager::GetInstance()->GetConversationManager()->SubscribeUnreadMessageCountByFilter(filter);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("unsubscribeUnreadMessageCountByFilter") == 0)
        {
            auto filter_it = arguments->find(flutter::EncodableValue("filter"));

            V2TIMConversationListFilter filter = V2TIMConversationListFilter();
            if (filter_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    auto filterMap = std::get<flutter::EncodableMap>(fvalue);
                    auto conversationGroup_it = filterMap.find(flutter::EncodableValue("conversationGroup"));
                    auto filterType_it = filterMap.find(flutter::EncodableValue("filterType"));
                    auto markType_it = filterMap.find(flutter::EncodableValue("markType"));
                    auto hasGroupAtInfo_it = filterMap.find(flutter::EncodableValue("hasGroupAtInfo"));
                    auto hasUnreadCount_it = filterMap.find(flutter::EncodableValue("hasUnreadCount"));
                    if (conversationGroup_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = conversationGroup_it->second;
                        if (!vv.IsNull())
                        {
                            filter.conversationGroup = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (filterType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = filterType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.filterType = std::get<int>(vv);
                        }
                    }
                    if (markType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = markType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.markType = std::get<int>(vv);
                        }
                    }
                    if (hasGroupAtInfo_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasGroupAtInfo_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasGroupAtInfo = std::get<bool>(vv);
                        }
                    }
                    if (hasUnreadCount_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasUnreadCount_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasUnreadCount = std::get<bool>(vv);
                        }
                    }
                }
            }
            V2TIMManager::GetInstance()->GetConversationManager()->UnsubscribeUnreadMessageCountByFilter(filter);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("cleanConversationUnreadMessageCount") == 0)
        {

            auto conversationID_it = arguments->find(flutter::EncodableValue("conversationID"));
            auto cleanTimestamp_it = arguments->find(flutter::EncodableValue("cleanTimestamp"));
            auto cleanSequence_it = arguments->find(flutter::EncodableValue("cleanSequence"));

            std::string conversationID = "";
            if (conversationID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = conversationID_it->second;
                if (!fvalue.IsNull())
                {
                    conversationID = std::get<std::string>(fvalue);
                }
            }

            int cleanTimestamp = 0;
            if (cleanTimestamp_it != arguments->end())
            {
                flutter::EncodableValue fvalue = cleanTimestamp_it->second;
                if (!fvalue.IsNull())
                {
                    cleanTimestamp = std::get<int>(fvalue);
                }
            }

            int cleanSequence = 0;
            if (cleanSequence_it != arguments->end())
            {
                flutter::EncodableValue fvalue = cleanSequence_it->second;
                if (!fvalue.IsNull())
                {
                    cleanSequence = std::get<int>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->CleanConversationUnreadMessageCount(V2TIMString{conversationID.c_str()}, static_cast<uint64_t>(cleanTimestamp), static_cast<uint64_t>(cleanSequence), callback);
        }
        else if (method_call.method_name().compare("getUnreadMessageCountByFilter") == 0)
        {
            auto filter_it = arguments->find(flutter::EncodableValue("filter"));

            V2TIMConversationListFilter filter = V2TIMConversationListFilter();
            if (filter_it != arguments->end())
            {
                flutter::EncodableValue fvalue = filter_it->second;
                if (!fvalue.IsNull())
                {
                    auto filterMap = std::get<flutter::EncodableMap>(fvalue);
                    auto conversationGroup_it = filterMap.find(flutter::EncodableValue("conversationGroup"));
                    auto filterType_it = filterMap.find(flutter::EncodableValue("filterType"));
                    auto markType_it = filterMap.find(flutter::EncodableValue("markType"));
                    auto hasGroupAtInfo_it = filterMap.find(flutter::EncodableValue("hasGroupAtInfo"));
                    auto hasUnreadCount_it = filterMap.find(flutter::EncodableValue("hasUnreadCount"));
                    if (conversationGroup_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = conversationGroup_it->second;
                        if (!vv.IsNull())
                        {
                            filter.conversationGroup = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (filterType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = filterType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.filterType = std::get<int>(vv);
                        }
                    }
                    if (markType_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = markType_it->second;
                        if (!vv.IsNull())
                        {
                            filter.markType = std::get<int>(vv);
                        }
                    }
                    if (hasGroupAtInfo_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasGroupAtInfo_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasGroupAtInfo = std::get<bool>(vv);
                        }
                    }
                    if (hasUnreadCount_it != filterMap.end())
                    {
                        flutter::EncodableValue vv = hasUnreadCount_it->second;
                        if (!vv.IsNull())
                        {
                            filter.hasUnreadCount = std::get<bool>(vv);
                        }
                    }
                }
            }
            CommUint64ValueCallback *callback = new CommUint64ValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->GetUnreadMessageCountByFilter(filter, callback);
        }
        else if (method_call.method_name().compare("convertVoiceToText") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 16, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("deleteConversationsFromGroup") == 0)
        {
            auto conversationIDList_it = arguments->find(flutter::EncodableValue("conversationIDList"));
            auto groupName_it = arguments->find(flutter::EncodableValue("groupName"));
            flutter::EncodableList conversationIDList = {};
            if (conversationIDList_it != arguments->end())
            {

                conversationIDList = std::get<flutter::EncodableList>(conversationIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = conversationIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(conversationIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            std::string groupName = "";
            if (groupName_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupName_it->second;
                if (!fvalue.IsNull())
                {
                    groupName = std::get<std::string>(fvalue);
                }
            }
            V2TIMConversationOperationResultVectorValueCallback *callback = new V2TIMConversationOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetConversationManager()->DeleteConversationsFromGroup(V2TIMString{groupName.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("addSignalingListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (signalListener->getUuids().size() == 0)
            {
                signalListener->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->GetSignalingManager()->AddSignalingListener(signalListener);
            }
            else
            {
                signalListener->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeSignalingListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                signalListener->cleanUuid();
                V2TIMManager::GetInstance()->GetSignalingManager()->RemoveSignalingListener(NULL);
            }
            else
            {
                signalListener->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("invite") == 0)
        {
            auto invitee_it = arguments->find(flutter::EncodableValue("invitee"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));
            auto timeout_it = arguments->find(flutter::EncodableValue("timeout"));
            auto onlineUserOnly_it = arguments->find(flutter::EncodableValue("onlineUserOnly"));
            auto offlinePushInfo_it = arguments->find(flutter::EncodableValue("offlinePushInfo"));

            std::string invitee = "";
            if (invitee_it != arguments->end())
            {
                flutter::EncodableValue fvalue = invitee_it->second;
                if (!fvalue.IsNull())
                {
                    invitee = std::get<std::string>(fvalue);
                }
            }
            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            int timeout = 0;
            if (timeout_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timeout_it->second;
                if (!fvalue.IsNull())
                {
                    timeout = std::get<int>(fvalue);
                }
            }
            bool onlineUserOnly = "";
            if (onlineUserOnly_it != arguments->end())
            {
                flutter::EncodableValue fvalue = onlineUserOnly_it->second;
                if (!fvalue.IsNull())
                {
                    onlineUserOnly = std::get<bool>(fvalue);
                }
            }
            V2TIMOfflinePushInfo pushInfo = V2TIMOfflinePushInfo();
            if (offlinePushInfo_it != arguments->end())
            {
                flutter::EncodableValue fvalue = offlinePushInfo_it->second;
                if (!fvalue.IsNull())
                {
                    auto offlinePushInfoMap = std::get<flutter::EncodableMap>(fvalue);

                    auto title_it = offlinePushInfoMap.find(flutter::EncodableValue("title"));

                    if (title_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.title = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }

                    auto desc_it = offlinePushInfoMap.find(flutter::EncodableValue("desc"));
                    if (desc_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.desc = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto ext_it = offlinePushInfoMap.find(flutter::EncodableValue("ext"));
                    if (ext_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.ext = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto disablePush_it = offlinePushInfoMap.find(flutter::EncodableValue("disablePush"));
                    if (disablePush_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.disablePush = std::get<bool>(vv);
                        }
                    }
                    auto iOSSound_it = offlinePushInfoMap.find(flutter::EncodableValue("iOSSound"));
                    if (iOSSound_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.iOSSound = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto ignoreIOSBadge_it = offlinePushInfoMap.find(flutter::EncodableValue("ignoreIOSBadge"));
                    if (ignoreIOSBadge_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.ignoreIOSBadge = std::get<bool>(vv);
                        }
                    }
                    auto androidOPPOChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidOPPOChannelID"));
                    if (androidOPPOChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidOPPOChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidVIVOClassification_it = offlinePushInfoMap.find(flutter::EncodableValue("androidVIVOClassification"));
                    if (androidVIVOClassification_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidVIVOClassification = std::get<int>(vv);
                        }
                    }

                    auto androidSound_it = offlinePushInfoMap.find(flutter::EncodableValue("androidSound"));
                    if (androidSound_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidSound = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidFCMChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidFCMChannelID"));
                    if (androidFCMChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidFCMChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidXiaoMiChannelID_it = offlinePushInfoMap.find(flutter::EncodableValue("androidXiaoMiChannelID"));
                    if (androidXiaoMiChannelID_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidXiaoMiChannelID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto iOSPushTypee_it = offlinePushInfoMap.find(flutter::EncodableValue("iOSPushType"));
                    if (iOSPushTypee_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.iOSPushType = static_cast<V2TIMIOSOfflinePushType>(std::get<int>(vv));
                        }
                    }
                    auto androidHuaWeiCategory_it = offlinePushInfoMap.find(flutter::EncodableValue("androidHuaWeiCategory"));
                    if (androidHuaWeiCategory_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidHuaWeiCategory = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    auto androidVIVOCategory_it = offlinePushInfoMap.find(flutter::EncodableValue("androidVIVOCategory"));
                    if (androidVIVOCategory_it != offlinePushInfoMap.end())
                    {
                        flutter::EncodableValue vv = offlinePushInfo_it->second;
                        if (!vv.IsNull())
                        {
                            pushInfo.AndroidVIVOCategory = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMString uuid =  V2TIMManager::GetInstance()->GetSignalingManager()->Invite(V2TIMString{invitee.c_str()}, V2TIMString{data.c_str()}, onlineUserOnly, pushInfo, timeout, callback);
            callback->setStringData(uuid.CString());
            
        }
        else if (method_call.method_name().compare("inviteInGroup") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));
            auto timeout_it = arguments->find(flutter::EncodableValue("timeout"));
            auto onlineUserOnly_it = arguments->find(flutter::EncodableValue("onlineUserOnly"));
            auto inviteeList_it = arguments->find(flutter::EncodableValue("inviteeList"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            int timeout = 0;
            if (timeout_it != arguments->end())
            {
                flutter::EncodableValue fvalue = timeout_it->second;
                if (!fvalue.IsNull())
                {
                    timeout = std::get<int>(fvalue);
                }
            }
            bool onlineUserOnly = "";
            if (onlineUserOnly_it != arguments->end())
            {
                flutter::EncodableValue fvalue = onlineUserOnly_it->second;
                if (!fvalue.IsNull())
                {
                    onlineUserOnly = std::get<bool>(fvalue);
                }
            }
            flutter::EncodableList inviteeList = {};
            if (inviteeList_it != arguments->end())
            {

                inviteeList = std::get<flutter::EncodableList>(inviteeList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = inviteeList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(inviteeList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMString uuid =  V2TIMManager::GetInstance()->GetSignalingManager()->InviteInGroup(V2TIMString{groupID.c_str()}, uids, V2TIMString{data.c_str()}, onlineUserOnly, timeout, callback);
            callback->setStringData(uuid.CString());
        }
        else if (method_call.method_name().compare("cancel") == 0)
        {

            auto inviteID_it = arguments->find(flutter::EncodableValue("inviteID"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));

            std::string inviteID = "";
            if (inviteID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = inviteID_it->second;
                if (!fvalue.IsNull())
                {
                    inviteID = std::get<std::string>(fvalue);
                }
            }
            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetSignalingManager()->Cancel(V2TIMString{inviteID.c_str()}, V2TIMString{data.c_str()}, callback);
        }
        else if (method_call.method_name().compare("accept") == 0)
        {
            auto inviteID_it = arguments->find(flutter::EncodableValue("inviteID"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));

            std::string inviteID = "";
            if (inviteID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = inviteID_it->second;
                if (!fvalue.IsNull())
                {
                    inviteID = std::get<std::string>(fvalue);
                }
            }
            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetSignalingManager()->Accept(V2TIMString{inviteID.c_str()}, V2TIMString{data.c_str()}, callback);
        }
        else if (method_call.method_name().compare("reject") == 0)
        {
            auto inviteID_it = arguments->find(flutter::EncodableValue("inviteID"));
            auto data_it = arguments->find(flutter::EncodableValue("data"));

            std::string inviteID = "";
            if (inviteID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = inviteID_it->second;
                if (!fvalue.IsNull())
                {
                    inviteID = std::get<std::string>(fvalue);
                }
            }
            std::string data = "";
            if (data_it != arguments->end())
            {
                flutter::EncodableValue fvalue = data_it->second;
                if (!fvalue.IsNull())
                {
                    data = std::get<std::string>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetSignalingManager()->Reject(V2TIMString{inviteID.c_str()}, V2TIMString{data.c_str()}, callback);
        }
        else if (method_call.method_name().compare("getSignalingInfo") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 17, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("addInvitedSignaling") == 0)
        {
            auto info_it = arguments->find(flutter::EncodableValue("info"));
            V2TIMSignalingInfo info = V2TIMSignalingInfo();
            if (info_it != arguments->end())
            {
                flutter::EncodableValue fvalue = info_it->second;
                if (!fvalue.IsNull())
                {
                    auto infoMap = std::get<flutter::EncodableMap>(fvalue);
                    auto actionType_it = infoMap.find(flutter::EncodableValue("actionType"));
                    auto data_it = infoMap.find(flutter::EncodableValue("data"));
                    auto groupID_it = infoMap.find(flutter::EncodableValue("groupID"));
                    auto inviteeList_it = infoMap.find(flutter::EncodableValue("inviteeList"));
                    auto inviteID_it = infoMap.find(flutter::EncodableValue("inviteID"));
                    auto inviter_it = infoMap.find(flutter::EncodableValue("inviter"));
                    auto timeout_it = infoMap.find(flutter::EncodableValue("timeout"));

                    if (actionType_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = actionType_it->second;
                        if (!vv.IsNull())
                        {
                            info.actionType = static_cast<V2TIMSignalingActionType>(std::get<int>(vv));
                        }
                    }
                    if (data_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = data_it->second;
                        if (!vv.IsNull())
                        {
                            info.data = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (groupID_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = groupID_it->second;
                        if (!vv.IsNull())
                        {
                            info.groupID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (inviteID_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = inviteID_it->second;
                        if (!vv.IsNull())
                        {
                            info.inviteID == V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (inviter_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = inviter_it->second;
                        if (!vv.IsNull())
                        {
                            info.inviter == V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (timeout_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = timeout_it->second;
                        if (!vv.IsNull())
                        {
                            info.timeout = std::get<int>(vv);
                        }
                    }
                    if (inviteeList_it != infoMap.end())
                    {
                        flutter::EncodableValue vv = inviteeList_it->second;
                        if (!vv.IsNull())
                        {
                            V2TIMStringVector ill = {};
                            auto list = std::get<flutter::EncodableList>(vv);
                            size_t ll = list.size();
                            for (size_t i = 0; i < ll; i++)
                            {
                                ill.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            info.inviteeList = ill;
                        }
                    }
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetSignalingManager()->AddInvitedSignaling(info, callback);
        }
        else if (method_call.method_name().compare("setMessageExtensions") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 18, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getMessageExtensions") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 19, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("deleteMessageExtensions") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 20, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getMessageOnlineUrl") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));
            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 21, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("downloadMessage") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));

            std::string msgID = "";
            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringVector uids = {};
            uids.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 22, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("setGroupCounters") == 0)
        {
            auto counters_it = arguments->find(flutter::EncodableValue("counters"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringToInt64Map map = {};
            if (counters_it != arguments->end())
            {
                flutter::EncodableValue fvalue = counters_it->second;
                if (!fvalue.IsNull())
                {
                    auto countersMap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = countersMap.begin(); iter != countersMap.end(); iter++)

                    {

                        map.Insert(V2TIMString{std::get<std::string>(iter->first).c_str()}, std::get<int>(iter->second));
                    }
                }
            }
            V2TIMStringToInt64MapValueCallback *callback = new V2TIMStringToInt64MapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->SetGroupCounters(V2TIMString{groupID.c_str()}, map, callback);
        }

        if (method_call.method_name().compare("getGroupCounters") == 0)
        {
            auto keys_it = arguments->find(flutter::EncodableValue("keys"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            flutter::EncodableList keys = {};
            if (keys_it != arguments->end())
            {

                keys = std::get<flutter::EncodableList>(keys_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = keys.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(keys[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMStringToInt64MapValueCallback *callback = new V2TIMStringToInt64MapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->GetGroupCounters(V2TIMString{groupID.c_str()}, uids, callback);
        }
        else if (method_call.method_name().compare("increaseGroupCounter") == 0)
        {
            auto key_it = arguments->find(flutter::EncodableValue("key"));
            auto value_it = arguments->find(flutter::EncodableValue("value"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string key = "";
            if (key_it != arguments->end())
            {
                flutter::EncodableValue fvalue = key_it->second;
                if (!fvalue.IsNull())
                {
                    key = std::get<std::string>(fvalue);
                }
            }

            int value = 0;
            if (value_it != arguments->end())
            {
                flutter::EncodableValue fvalue = value_it->second;
                if (!fvalue.IsNull())
                {
                    value = std::get<int>(fvalue);
                }
            }
            V2TIMStringToInt64MapValueCallback *callback = new V2TIMStringToInt64MapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->IncreaseGroupCounter(V2TIMString{groupID.c_str()}, V2TIMString{key.c_str()}, value, callback);
        }
        else if (method_call.method_name().compare("decreaseGroupCounter") == 0)
        {
            auto key_it = arguments->find(flutter::EncodableValue("key"));
            auto value_it = arguments->find(flutter::EncodableValue("value"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));

            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }

            std::string key = "";
            if (key_it != arguments->end())
            {
                flutter::EncodableValue fvalue = key_it->second;
                if (!fvalue.IsNull())
                {
                    key = std::get<std::string>(fvalue);
                }
            }

            int value = 0;
            if (value_it != arguments->end())
            {
                flutter::EncodableValue fvalue = value_it->second;
                if (!fvalue.IsNull())
                {
                    value = std::get<int>(fvalue);
                }
            }
            V2TIMStringToInt64MapValueCallback *callback = new V2TIMStringToInt64MapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->DecreaseGroupCounter(V2TIMString{groupID.c_str()}, V2TIMString{key.c_str()}, value, callback);
        }
        else if (method_call.method_name().compare("translateText") == 0)
        {
            auto texts_it = arguments->find(flutter::EncodableValue("texts"));
            auto targetLanguage_it = arguments->find(flutter::EncodableValue("targetLanguage"));
            auto sourceLanguage_it = arguments->find(flutter::EncodableValue("sourceLanguage"));

            std::string targetLanguage = "";
            if (targetLanguage_it != arguments->end())
            {
                flutter::EncodableValue fvalue = targetLanguage_it->second;
                if (!fvalue.IsNull())
                {
                    targetLanguage = std::get<std::string>(fvalue);
                }
            }
            std::string sourceLanguage = "auto";
            if (sourceLanguage_it != arguments->end())
            {
                flutter::EncodableValue fvalue = sourceLanguage_it->second;
                if (!fvalue.IsNull())
                {
                    sourceLanguage = std::get<std::string>(fvalue);
                }
            }

            flutter::EncodableList texts = {};
            if (texts_it != arguments->end())
            {

                texts = std::get<flutter::EncodableList>(texts_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = texts.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(texts[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            V2TIMStringToV2TIMStringMapValueCallback *callback = new V2TIMStringToV2TIMStringMapValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->TranslateText(uids,V2TIMString{sourceLanguage.c_str()}, V2TIMString{targetLanguage.c_str()},  callback);
        }
        else if (method_call.method_name().compare("setAvChatRoomCanFindMessage") == 0)
        {
            result->Success(FormatTIMValueCallback(-1, "setAvChatRoomCanFindMessage is not support on windows", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("subscribeUserInfo") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->SubscribeUserInfo(uids, callback);
        }
        else if (method_call.method_name().compare("unsubscribeUserInfo") == 0)
        {
            auto userIDList_it = arguments->find(flutter::EncodableValue("userIDList"));

            flutter::EncodableList userIDList = {};
            if (userIDList_it != arguments->end())
            {

                userIDList = std::get<flutter::EncodableList>(userIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = userIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(userIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->UnsubscribeUserInfo(uids, callback);
        }
        else if (method_call.method_name().compare("markGroupMemberList") == 0)
        {

            auto memberIDList_it = arguments->find(flutter::EncodableValue("memberIDList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto markType_it = arguments->find(flutter::EncodableValue("markType"));
            auto enableMark_it = arguments->find(flutter::EncodableValue("enableMark"));

            flutter::EncodableList memberIDList = {};
            if (memberIDList_it != arguments->end())
            {

                memberIDList = std::get<flutter::EncodableList>(memberIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = memberIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(memberIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }
            std::string groupID = "";
            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            int markType = 0;
            if (markType_it != arguments->end())
            {
                flutter::EncodableValue fvalue = markType_it->second;
                if (!fvalue.IsNull())
                {
                    markType = std::get<int>(fvalue);
                }
            }
            bool enableMark = false;
            if (enableMark_it != arguments->end())
            {
                flutter::EncodableValue fvalue = enableMark_it->second;
                if (!fvalue.IsNull())
                {
                    enableMark = std::get<bool>(fvalue);
                }
            }
            CommonCallback *callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetGroupManager()->MarkGroupMemberList(V2TIMString{groupID.c_str()}, uids, markType, enableMark, callback);
        }
        else if (method_call.method_name().compare("setAllReceiveMessageOpt") == 0)
        {

            auto opt_it = arguments->find(flutter::EncodableValue("opt"));
            auto startHour_it = arguments->find(flutter::EncodableValue("startHour"));
            auto startMinute_it = arguments->find(flutter::EncodableValue("startMinute"));
            auto startSecond_it = arguments->find(flutter::EncodableValue("startSecond"));
            auto duration_it = arguments->find(flutter::EncodableValue("duration"));
            int opt = 0;
            if (opt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = opt_it->second;
                if (!fvalue.IsNull())
                {
                    opt = std::get<int>(fvalue);
                }
            }
            int startHour = 0;
            if (startHour_it != arguments->end())
            {
                flutter::EncodableValue fvalue = startHour_it->second;
                if (!fvalue.IsNull())
                {
                    startHour = std::get<int>(fvalue);
                }
            }
            int startMinute = 0;
            if (startMinute_it != arguments->end())
            {
                flutter::EncodableValue fvalue = startMinute_it->second;
                if (!fvalue.IsNull())
                {
                    startMinute = std::get<int>(fvalue);
                }
            }
            int startSecond = 0;
            if (startSecond_it != arguments->end())
            {
                flutter::EncodableValue fvalue = startSecond_it->second;
                if (!fvalue.IsNull())
                {
                    startSecond = std::get<int>(fvalue);
                }
            }
            int duration = 0;
            if (duration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = duration_it->second;
                if (!fvalue.IsNull())
                {
                    duration = std::get<int>(fvalue);
                }
            }
            CommonCallback* callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SetAllReceiveMessageOpt(static_cast<V2TIMReceiveMessageOpt>(opt), startHour,startMinute,startSecond,duration, callback);
        }
        else if (method_call.method_name().compare("setAllReceiveMessageOptWithTimestamp") == 0)
        {
            auto opt_it = arguments->find(flutter::EncodableValue("opt"));
            auto startTimeStamp_it = arguments->find(flutter::EncodableValue("startTimeStamp"));
            auto duration_it = arguments->find(flutter::EncodableValue("duration"));
            int opt = 0;
            if (opt_it != arguments->end())
            {
                flutter::EncodableValue fvalue = opt_it->second;
                if (!fvalue.IsNull())
                {
                    opt = std::get<int>(fvalue);
                }
            }
            int startTimeStamp = 0;
            if (startTimeStamp_it != arguments->end())
            {
                flutter::EncodableValue fvalue = startTimeStamp_it->second;
                if (!fvalue.IsNull())
                {
                    startTimeStamp = std::get<int>(fvalue);
                }
            }
            int duration = 0;
            if (duration_it != arguments->end())
            {
                flutter::EncodableValue fvalue = duration_it->second;
                if (!fvalue.IsNull())
                {
                    duration = std::get<int>(fvalue);
                }
            }
            CommonCallback* callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SetAllReceiveMessageOpt(static_cast<V2TIMReceiveMessageOpt>(opt), startTimeStamp, duration, callback);
        }
        else if (method_call.method_name().compare("getAllReceiveMessageOpt") == 0)
        {
        V2TIMReceiveMessageOptInfoValueCallback* callback = new V2TIMReceiveMessageOptInfoValueCallback(std::move(result));
        V2TIMManager::GetInstance()->GetMessageManager()->GetAllReceiveMessageOpt(callback);
        }
        else if (method_call.method_name().compare("addMessageReaction") == 0)
        {
            
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));
            
            std::string msgID = "";

            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector msgIDList = {};
            msgIDList.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 23, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);

        }
        else if (method_call.method_name().compare("removeMessageReaction") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));
            std::string msgID = "";

            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector msgIDList = {};
            msgIDList.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 24, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
        }
        else if (method_call.method_name().compare("getMessageReactions") == 0)
        {
            auto msgIDList_it = arguments->find(flutter::EncodableValue("msgIDList"));
            
            flutter::EncodableList msgIDList = {};
            if (msgIDList_it != arguments->end())
            {

                msgIDList = std::get<flutter::EncodableList>(msgIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = msgIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(msgIDList[i]).c_str();
                uids.PushBack(V2TIMString{uid});
            }

            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 25, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(uids, callback);
        }
        else if (method_call.method_name().compare("getAllUserListOfMessageReaction") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));
            

            std::string msgID = "";

            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector msgIDList = {};
            msgIDList.PushBack(V2TIMString{msgID.c_str()});
            V2TIMMessageVetorValueCallback *callback = new V2TIMMessageVetorValueCallback(std::move(result), 26, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
        }
        else if (method_call.method_name().compare("uikitTrace") == 0)
        {
            auto trace_it = arguments->find(flutter::EncodableValue("trace"));
            std::string trace = "";
            if (trace_it != arguments->end())
            {
                flutter::EncodableValue fvalue = trace_it->second;
                if (!fvalue.IsNull())
                {
                    trace = std::get<std::string>(fvalue);
                }
            }

            V2TIMStringToV2TIMStringMap map = {};
            map.Insert("logLevel", "V2TIM_LOG_DEBUG");
            map.Insert("fileName", "IMFlutterUIKit");
            map.Insert("logContent", V2TIMString{trace.c_str()});
            V2TIMManager::GetInstance()->CallExperimentalAPI(V2TIMString{"writeLog"}, &map, nullptr);
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("searchCloudMessages") == 0)
        {
            auto searchParam_it = arguments->find(flutter::EncodableValue("searchParam"));
            V2TIMMessageSearchParam searchParam = V2TIMMessageSearchParam();
            if (searchParam_it != arguments->end())
            {
                flutter::EncodableValue fvalue = searchParam_it->second;
                if (!fvalue.IsNull())
                {
                    auto searchParamMap = std::get<flutter::EncodableMap>(fvalue);

                    auto keywordListMatchType_it = searchParamMap.find(flutter::EncodableValue("keywordListMatchType"));
                    auto conversationID_it = searchParamMap.find(flutter::EncodableValue("conversationID"));
                    auto searchTimePosition_it = searchParamMap.find(flutter::EncodableValue("searchTimePosition"));
                    auto searchTimePeriod_it = searchParamMap.find(flutter::EncodableValue("searchTimePeriod"));
                    auto pageIndex_it = searchParamMap.find(flutter::EncodableValue("pageIndex"));
                    auto pageSize_it = searchParamMap.find(flutter::EncodableValue("pageSize"));
                    auto searchCount_it = searchParamMap.find(flutter::EncodableValue("searchCount"));
                    auto searchCursor_it = searchParamMap.find(flutter::EncodableValue("searchCursor"));
                    auto messageTypeList_it = searchParamMap.find(flutter::EncodableValue("messageTypeList"));
                    auto senderUserIDList_it = searchParamMap.find(flutter::EncodableValue("senderUserIDList"));
                    auto keywordList_it = searchParamMap.find(flutter::EncodableValue("keywordList"));

                    if (keywordListMatchType_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordListMatchType_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.keywordListMatchType = static_cast<V2TIMKeywordListMatchType>(std::get<int>(vv));
                        }
                    }
                    if (conversationID_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = conversationID_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.conversationID = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (searchTimePosition_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchTimePosition_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchTimePosition = std::get<int>(vv);
                        }
                    }
                    if (searchTimePeriod_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchTimePeriod_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchTimePeriod = std::get<int>(vv);
                        }
                    }
                    if (pageIndex_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = pageIndex_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.pageIndex = std::get<int>(vv);
                        }
                    }
                    if (pageSize_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = pageSize_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.pageSize = std::get<int>(vv);
                        }
                    }
                    if (searchCount_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchCount_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchCount = std::get<int>(vv);
                        }
                    }
                    if (searchCursor_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = searchCursor_it->second;
                        if (!vv.IsNull())
                        {

                            searchParam.searchCursor = V2TIMString{std::get<std::string>(vv).c_str()};
                        }
                    }
                    if (messageTypeList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = messageTypeList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMElemTypeVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(static_cast<V2TIMElemType>(std::get<int>(list[i])));
                            }
                            searchParam.messageTypeList = kws;
                        }
                    }
                    if (senderUserIDList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = senderUserIDList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.senderUserIDList = kws;
                        }
                    }
                    if (keywordList_it != searchParamMap.end())
                    {
                        flutter::EncodableValue vv = keywordList_it->second;
                        if (!vv.IsNull())
                        {

                            auto list = std::get<flutter::EncodableList>(vv);
                            V2TIMStringVector kws = {};
                            for (size_t i = 0; i < list.size(); i++)
                            {
                                kws.PushBack(V2TIMString{std::get<std::string>(list[i]).c_str()});
                            }
                            searchParam.keywordList = kws;
                        }
                    }
                }
            }

            V2TIMMessageSearchResultValueCallback *callback = new V2TIMMessageSearchResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetMessageManager()->SearchCloudMessages(searchParam, callback);
        }
        else if (method_call.method_name().compare("setOfflinePushConfig") == 0)
        {
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("doBackground") == 0)
        {
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("doForeground") == 0)
        {
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("pinGroupMessage") == 0)
        {
            auto msgID_it = arguments->find(flutter::EncodableValue("msgID"));


            std::string msgID = "";

            if (msgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = msgID_it->second;
                if (!fvalue.IsNull())
                {
                    msgID = std::get<std::string>(fvalue);
                }
            }
            V2TIMStringVector msgIDList = {};
            msgIDList.PushBack(V2TIMString{ msgID.c_str() });
            V2TIMMessageVetorValueCallback* callback = new V2TIMMessageVetorValueCallback(std::move(result), 27, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->FindMessages(msgIDList, callback);
        }
        else if (method_call.method_name().compare("getPinnedGroupMessageList") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));


            std::string groupID = "";

            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            V2TIMMessageVetorValueCallback* callback = new V2TIMMessageVetorValueCallback(std::move(result), 10, arguments, &createdMessageMap);
            V2TIMManager::GetInstance()->GetMessageManager()->GetPinnedGroupMessageList(V2TIMString{ groupID.c_str()},callback);

        }
        else if (method_call.method_name().compare("insertGroupMessageToLocalStorageV2") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto senderID_it = arguments->find(flutter::EncodableValue("senderID"));
            auto createdMsgID_it = arguments->find(flutter::EncodableValue("createdMsgID"));
        
            std::string groupID = "";
            std::string senderID = "";
            std::string createdMsgID = "";

            if (groupID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = groupID_it->second;
                if (!fvalue.IsNull())
                {
                    groupID = std::get<std::string>(fvalue);
                }
            }
            if (senderID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = senderID_it->second;
                if (!fvalue.IsNull())
                {
                    senderID = std::get<std::string>(fvalue);
                }
            }
            if (createdMsgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = createdMsgID_it->second;
                if (!fvalue.IsNull())
                {
                    createdMsgID = std::get<std::string>(fvalue);
                }
            }
            auto createdMessageIt = createdMessageMap.find(createdMsgID);
            if (createdMessageIt != createdMessageMap.end()) {
                auto msg = createdMessageIt->second;
                V2TIMMessageValueCallback* callback = new V2TIMMessageValueCallback(std::move(result));
                V2TIMManager::GetInstance()->GetMessageManager()->InsertGroupMessageToLocalStorage(msg, V2TIMString{ groupID.c_str() }, V2TIMString{ senderID.c_str()}, callback);
                
            }
            else {
                result->Success(FormatTIMValueCallback(-1, "created message not found",flutter::EncodableValue()));
            }
        }
        else if (method_call.method_name().compare("insertC2CMessageToLocalStorageV2") == 0)
        {
            auto userID_it = arguments->find(flutter::EncodableValue("userID"));
            auto senderID_it = arguments->find(flutter::EncodableValue("senderID"));
            auto createdMsgID_it = arguments->find(flutter::EncodableValue("createdMsgID"));

            std::string userID = "";
            std::string senderID = "";
            std::string createdMsgID = "";

            if (userID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = userID_it->second;
                if (!fvalue.IsNull())
                {
                    userID = std::get<std::string>(fvalue);
                }
            }
            if (senderID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = senderID_it->second;
                if (!fvalue.IsNull())
                {
                    senderID = std::get<std::string>(fvalue);
                }
            }
            if (createdMsgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = createdMsgID_it->second;
                if (!fvalue.IsNull())
                {
                    createdMsgID = std::get<std::string>(fvalue);
                }
            }
            auto createdMessageIt = createdMessageMap.find(createdMsgID);
            if (createdMessageIt != createdMessageMap.end()) {
                auto msg = createdMessageIt->second;
                V2TIMMessageValueCallback* callback = new V2TIMMessageValueCallback(std::move(result));
                V2TIMManager::GetInstance()->GetMessageManager()->InsertC2CMessageToLocalStorage(msg, V2TIMString{ userID.c_str() }, V2TIMString{ senderID.c_str() }, callback);

            }
            else {
                result->Success(FormatTIMValueCallback(-1, "created message not found", flutter::EncodableValue()));
            }
        }
        else if (method_call.method_name().compare("createAtSignedGroupMessage") == 0)
        {
        
            auto createdMsgID_it = arguments->find(flutter::EncodableValue("createdMsgID"));

            auto atUserList_it = arguments->find(flutter::EncodableValue("atUserList"));

            flutter::EncodableList atUserList = {};
            if (atUserList_it != arguments->end())
            {

                atUserList = std::get<flutter::EncodableList>(atUserList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = atUserList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(atUserList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            std::string createdMsgID = "";

        
            if (createdMsgID_it != arguments->end())
            {
                flutter::EncodableValue fvalue = createdMsgID_it->second;
                if (!fvalue.IsNull())
                {
                    createdMsgID = std::get<std::string>(fvalue);
                }
            }
            auto createdMessageIt = createdMessageMap.find(createdMsgID);
            if (createdMessageIt != createdMessageMap.end()) {
                auto msg = createdMessageIt->second;
                
                auto createdMsg = V2TIMManager::GetInstance()->GetMessageManager()->CreateAtSignedGroupMessage(msg, uids);
                std::string id = ConvertDataUtils::generateRandomString();
                createdMessageMap.insert(std::make_pair(id, createdMsg));
                auto res = flutter::EncodableMap();
                auto messageInfo = ConvertDataUtils::convertV2TIMMessage2Map(&createdMsg);
                messageInfo[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
                res[flutter::EncodableValue("id")] = flutter::EncodableValue(id.c_str());
                res[flutter::EncodableValue("messageInfo")] = flutter::EncodableValue(messageInfo);
                result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue(res)));
            }
            else {
                result->Success(FormatTIMValueCallback(-1, "created message not found", flutter::EncodableValue()));
            }
        }
        else if (method_call.method_name().compare("addCommunityListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }

            if (communityListener->getUuids().size() == 0)
            {
                communityListener->setUuid(listenerUuid);
                V2TIMManager::GetInstance()->GetCommunityManager()->AddCommunityListener(communityListener);
            }
            else
            {
                communityListener->setUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("removeCommunityListener") == 0)
        {
            auto listenerUuid_it = arguments->find(flutter::EncodableValue("listenerUuid"));
            std::string listenerUuid = "";
            if (listenerUuid_it != arguments->end())
            {
                flutter::EncodableValue fvalue = listenerUuid_it->second;
                if (!fvalue.IsNull())
                {
                    listenerUuid = std::get<std::string>(fvalue);
                }
            }
            if (listenerUuid == "")
            {
                communityListener->cleanUuid();
                V2TIMManager::GetInstance()->GetCommunityManager()->RemoveCommunityListener(communityListener);
            }
            else
            {
                communityListener->removeUuid(listenerUuid);
            }
            result->Success(FormatTIMValueCallback(0, "", flutter::EncodableValue()));
        }
        else if (method_call.method_name().compare("createCommunity") == 0)
        {
            auto info_it = arguments->find(flutter::EncodableValue("info"));
            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            V2TIMGroupInfo n_ginfo = V2TIMGroupInfo();
            V2TIMCreateGroupMemberInfoVector n_memberList = V2TIMCreateGroupMemberInfoVector();
            if (info_it != arguments->end())
            {
                flutter::EncodableValue fvalue = info_it->second;
                if (!fvalue.IsNull())
                {
                    flutter::EncodableMap info_map = std::get<flutter::EncodableMap>(fvalue);
                    auto gid_it = info_map.find(flutter::EncodableValue("groupID"));
                    if (gid_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gid_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string groupID = std::get<std::string>(ifvalue);
                            n_ginfo.groupID = V2TIMString{ groupID.c_str() };
                        }
                        
                    }
                    auto gtype_it = info_map.find(flutter::EncodableValue("groupType"));
                    if (gtype_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gtype_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string groupType = std::get<std::string>(ifvalue);
                            n_ginfo.groupType = V2TIMString{ groupType.c_str() };
                        }
                    }
                    auto gname_it = info_map.find(flutter::EncodableValue("groupName"));
                    if (gname_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gname_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string groupName = std::get<std::string>(ifvalue);
                            n_ginfo.groupName = V2TIMString{ groupName.c_str() };
                        }
                    }
                    auto gnoti_it = info_map.find(flutter::EncodableValue("notification"));
                    if (gnoti_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gnoti_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string notification = std::get<std::string>(ifvalue);
                            n_ginfo.notification = V2TIMString{ notification.c_str() };
                        }
                    }
                    auto gintroi_it = info_map.find(flutter::EncodableValue("introduction"));
                    if (gintroi_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gintroi_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string introduction = std::get<std::string>(ifvalue);
                            n_ginfo.introduction = V2TIMString{ introduction.c_str() };
                        }
                    }
                    auto gface_it = info_map.find(flutter::EncodableValue("faceUrl"));
                    if (gface_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gface_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string faceUrl = std::get<std::string>(ifvalue);
                            n_ginfo.faceURL = V2TIMString{ faceUrl.c_str() };
                        }
                    }
                    auto gallmute_it = info_map.find(flutter::EncodableValue("isAllMuted"));
                    if (gallmute_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gallmute_it->second;
                        if (!ifvalue.IsNull()) {
                            bool isAllMuted = std::get<bool>(ifvalue);
                            n_ginfo.allMuted = isAllMuted;
                        }
                    }
                    auto gsuppt_it = info_map.find(flutter::EncodableValue("isSupportTopic"));
                    if (gsuppt_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gsuppt_it->second;
                        if (!ifvalue.IsNull()) {
                            bool isSupportTopic = std::get<bool>(ifvalue);
                            n_ginfo.isSupportTopic = isSupportTopic;
                        }
                    }
                    auto gappopt_it = info_map.find(flutter::EncodableValue("groupAddOpt"));
                    if (gappopt_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gappopt_it->second;
                        if (!ifvalue.IsNull()) {
                            int groupAddOpt = std::get<int>(ifvalue);
                            n_ginfo.groupAddOpt = static_cast<V2TIMGroupAddOpt>(groupAddOpt);
                        }
                    }
                    auto gapproopt_it = info_map.find(flutter::EncodableValue("approveOpt"));
                    if (gapproopt_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gapproopt_it->second;
                        if (!ifvalue.IsNull()) {
                            int approveOpt = std::get<int>(ifvalue);
                            n_ginfo.groupApproveOpt = static_cast<V2TIMGroupAddOpt>(approveOpt);
                        }
                    }
                    auto gcus_info_it = info_map.find(flutter::EncodableValue("customInfo"));
                    if (gcus_info_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gcus_info_it->second;
                        if (!ifvalue.IsNull()) {
                            flutter::EncodableMap customInfomap = std::get<flutter::EncodableMap>(ifvalue);
                            flutter::EncodableMap::iterator iter;
                            V2TIMCustomInfo ctiminfo;
                            for (iter = customInfomap.begin(); iter != customInfomap.end(); iter++)

                            {
                                std::string data = std::get<std::string>(iter->second);
                                ctiminfo.Insert(V2TIMString{ std::get<std::string>(iter->first).c_str() }, ConvertDataUtils::string2Buffer(data));
                            }
                            
                           
                            n_ginfo.customInfo = ctiminfo;
                        }
                       
                    }
                    auto genper_g_it = info_map.find(flutter::EncodableValue("isEnablePermissionGroup"));
                    if (genper_g_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = genper_g_it->second;
                        if (!ifvalue.IsNull()) {
                            bool isEnablePermissionGroup = std::get<bool>(ifvalue);
                            n_ginfo.enablePermissionGroup = isEnablePermissionGroup;
                        }
                    }
                    auto g_default_it = info_map.find(flutter::EncodableValue("defaultPermissions"));
                    if (g_default_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = g_default_it->second;
                        if (!ifvalue.IsNull()) {
                            int defaultPermissions = std::get<int>(ifvalue);
                            n_ginfo.defaultPermissions = defaultPermissions;
                        }
                    }
                    
                }
            }
            if (memberList_it != arguments->end()) {
                flutter::EncodableValue fvalue = memberList_it->second;
                if (!fvalue.IsNull()) {
                    flutter::EncodableList d_list = std::get<flutter::EncodableList>(fvalue);
                    for (size_t i = 0; i < d_list.size(); i++)
                    {
                        flutter::EncodableValue item = d_list.at(i);
                        if (!item.IsNull()) {
                            flutter::EncodableMap itemMap = std::get<flutter::EncodableMap>(item);
                            auto role_it = itemMap.find(flutter::EncodableValue("role"));
                            auto userID_it = itemMap.find(flutter::EncodableValue("userID"));
                            V2TIMCreateGroupMemberInfo iifo = V2TIMCreateGroupMemberInfo();
                            if (role_it != itemMap.end()) {
                                flutter::EncodableValue itemfvalue = role_it->second;
                                if (!itemfvalue.IsNull()) {
                                    iifo.role = std::get<int>(itemfvalue);
                                }
                            }
                            if (userID_it != itemMap.end()) {
                                flutter::EncodableValue itemfvalue = userID_it->second;
                                if (!itemfvalue.IsNull()) {
                                    std::string uid = std::get<std::string>(itemfvalue);
                                    iifo.userID = V2TIMString{ uid.c_str() };
                                }
                            }
                            n_memberList.PushBack(iifo);
                        }
                    }
                }
            }
            CommV2TIMStringValueCallback *callback = new CommV2TIMStringValueCallback(std::move(result));

            V2TIMManager::GetInstance()->GetCommunityManager()->CreateCommunity(n_ginfo, n_memberList, callback);
        }
        else if (method_call.method_name().compare("createPermissionGroupInCommunity") == 0)
        {
            auto info_it = arguments->find(flutter::EncodableValue("info"));
            V2TIMPermissionGroupInfo n_info = V2TIMPermissionGroupInfo();
            if (info_it != arguments->end())
            {
                flutter::EncodableValue fvalue = info_it->second;
                if (!fvalue.IsNull())
                {
                    flutter::EncodableMap info_map = std::get<flutter::EncodableMap>(fvalue);
                    auto gid_it = info_map.find(flutter::EncodableValue("groupID"));
                    if (gid_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gid_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string groupID = std::get<std::string>(ifvalue);
                            n_info.groupID = V2TIMString{ groupID.c_str() };
                        }

                    }
                    auto gpergid_it = info_map.find(flutter::EncodableValue("permissionGroupID"));
                    if (gpergid_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpergid_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string permissionGroupID = std::get<std::string>(ifvalue);
                            n_info.permissionGroupID = V2TIMString{ permissionGroupID.c_str() };
                        }

                    }
                    auto gpergname_it = info_map.find(flutter::EncodableValue("permissionGroupName"));
                    if (gpergname_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpergname_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string permissionGroupName = std::get<std::string>(ifvalue);
                            n_info.permissionGroupName = V2TIMString{ permissionGroupName.c_str() };
                        }

                    }
                    auto gcusdata_it = info_map.find(flutter::EncodableValue("customData"));
                    if (gcusdata_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gcusdata_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string customData = std::get<std::string>(ifvalue);
                            n_info.customData = V2TIMString{ customData.c_str() };
                        }

                    }
                    auto gpermia_it = info_map.find(flutter::EncodableValue("groupPermission"));
                    if (gpermia_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpermia_it->second;
                        if (!ifvalue.IsNull()) {
                            int groupPermission = std::get<int>(ifvalue);
                            n_info.groupPermission = groupPermission;
                        }

                    }
                    
                }
            }
            CommV2TIMStringValueCallback* callback = new CommV2TIMStringValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->CreatePermissionGroupInCommunity(n_info,callback);
        }
        else if (method_call.method_name().compare("deletePermissionGroupFromCommunity") == 0)
        {
            auto permissionGroupIDList_it = arguments->find(flutter::EncodableValue("permissionGroupIDList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            std::string groupID = "";

            flutter::EncodableList permissionGroupIDList = {};
            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }
            if (permissionGroupIDList_it != arguments->end())
            {

                permissionGroupIDList = std::get<flutter::EncodableList>(permissionGroupIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = permissionGroupIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(permissionGroupIDList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMPermissionGroupOperationResultVectorValueCallback* callback = new V2TIMPermissionGroupOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->DeletePermissionGroupFromCommunity(V2TIMString{ groupID.c_str() }, uids, callback );
        }
        else if (method_call.method_name().compare("modifyPermissionGroupInfoInCommunity") == 0)
        {
            auto info_it = arguments->find(flutter::EncodableValue("info"));
            V2TIMPermissionGroupInfo n_info = V2TIMPermissionGroupInfo();
            auto modify_flag = 0;
            if (info_it != arguments->end())
            {
                flutter::EncodableValue fvalue = info_it->second;
                if (!fvalue.IsNull())
                {
                    flutter::EncodableMap info_map = std::get<flutter::EncodableMap>(fvalue);
                    auto gid_it = info_map.find("groupID");
                    if (gid_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gid_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string groupID = std::get<std::string>(ifvalue);
                            n_info.groupID = V2TIMString{ groupID.c_str() };
                        
                        }

                    }
                    auto gpergid_it = info_map.find("permissionGroupID");
                    if (gpergid_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpergid_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string permissionGroupID = std::get<std::string>(ifvalue);
                            n_info.permissionGroupID = V2TIMString{ permissionGroupID.c_str() };
                       
                        }

                    }
                    auto gpergname_it = info_map.find("permissionGroupName");
                    if (gpergname_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpergname_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string permissionGroupName = std::get<std::string>(ifvalue);
                            n_info.permissionGroupName = V2TIMString{ permissionGroupName.c_str() };
                            modify_flag = modify_flag | 0x1;
                        }

                    }
                    auto gcusdata_it = info_map.find("customData");
                    if (gcusdata_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gcusdata_it->second;
                        if (!ifvalue.IsNull()) {
                            std::string customData = std::get<std::string>(ifvalue);
                            n_info.customData = V2TIMString{ customData.c_str() };
                            modify_flag = modify_flag | 0x1 << 2;
                        }

                    }
                    auto gpermia_it = info_map.find("groupPermission");
                    if (gpermia_it != info_map.end()) {
                        flutter::EncodableValue ifvalue = gpermia_it->second;
                        if (!ifvalue.IsNull()) {
                            int groupPermission = std::get<int>(ifvalue);
                            n_info.groupPermission = groupPermission;
                            modify_flag = modify_flag | 0x1 << 1;
                        }

                    }

                }
            }
            n_info.modifyFlag = modify_flag;
            CommonCallback* callback = new CommonCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->ModifyPermissionGroupInfoInCommunity(n_info, callback);
        }
        else if (method_call.method_name().compare("getJoinedPermissionGroupListInCommunity") == 0)
        {
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            std::string groupID = "";

            
            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }
            V2TIMPermissionGroupInfoResultVectorValueCallback* callback = new V2TIMPermissionGroupInfoResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->GetJoinedPermissionGroupListInCommunity(V2TIMString{ groupID.c_str()},callback);
        }
        else if (method_call.method_name().compare("getPermissionGroupListInCommunity") == 0)
        {
            auto permissionGroupIDList_it = arguments->find(flutter::EncodableValue("permissionGroupIDList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            std::string groupID = "";

            flutter::EncodableList permissionGroupIDList = {};
            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }
            if (permissionGroupIDList_it != arguments->end())
            {

                permissionGroupIDList = std::get<flutter::EncodableList>(permissionGroupIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = permissionGroupIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(permissionGroupIDList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMPermissionGroupInfoResultVectorValueCallback* callback = new V2TIMPermissionGroupInfoResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->GetPermissionGroupListInCommunity(V2TIMString{ groupID.c_str() }, uids, callback);
        }
        else if (method_call.method_name().compare("addCommunityMembersToPermissionGroup") == 0)
        {
            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            flutter::EncodableList memberList = {};
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }

            if (memberList_it != arguments->end())
            {

                memberList = std::get<flutter::EncodableList>(memberList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = memberList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(memberList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMPermissionGroupMemberOperationResultVectorValueCallback* callback = new V2TIMPermissionGroupMemberOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->AddCommunityMembersToPermissionGroup(V2TIMString{ groupID.c_str()}, V2TIMString{ permissionGroupID.c_str() },uids, callback);
        }
        else if (method_call.method_name().compare("removeCommunityMembersFromPermissionGroup") == 0)
        {
            auto memberList_it = arguments->find(flutter::EncodableValue("memberList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            flutter::EncodableList memberList = {};
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }

            if (memberList_it != arguments->end())
            {

                memberList = std::get<flutter::EncodableList>(memberList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = memberList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(memberList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMPermissionGroupMemberOperationResultVectorValueCallback* callback = new V2TIMPermissionGroupMemberOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->RemoveCommunityMembersFromPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, uids, callback);
        }
        else if (method_call.method_name().compare("getCommunityMemberListInPermissionGroup") == 0)
        {
            auto nextCursor_it = arguments->find(flutter::EncodableValue("nextCursor"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            std::string nextCursor = "";
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }
            if (nextCursor_it != arguments->end())
            {

                nextCursor = std::get<std::string>(nextCursor_it->second);
            }
            
            V2TIMPermissionGroupMemberInfoResultValueCallback* callback = new V2TIMPermissionGroupMemberInfoResultValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->GetCommunityMemberListInPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, V2TIMString{ nextCursor.c_str() }, callback);
        }
        else if (method_call.method_name().compare("addTopicPermissionToPermissionGroup") == 0)
        {
            auto topicPermissionMap_it = arguments->find(flutter::EncodableValue("topicPermissionMap"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }
            auto  imap264 = V2TIMStringToUint64Map();
            if (topicPermissionMap_it != arguments->end()) {
                flutter::EncodableValue fvalue = topicPermissionMap_it->second;
                if (!fvalue.IsNull()) {
                    flutter::EncodableMap fvmap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = fvmap.begin(); iter != fvmap.end(); iter++)

                    {
                        int data = std::get<int>(iter->second);
                        imap264.Insert(V2TIMString{ std::get<std::string>(iter->first).c_str() }, data);
                    }
                       
                }
            }
            V2TIMTopicOperationResultVectorValueCallback* callback = new V2TIMTopicOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->AddTopicPermissionToPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, imap264, callback);
        }
        else if (method_call.method_name().compare("deleteTopicPermissionFromPermissionGroup") == 0)
        {
            auto topicIDList_it = arguments->find(flutter::EncodableValue("topicIDList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            flutter::EncodableList topicIDList = {};
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }

            if (topicIDList_it != arguments->end())
            {

                topicIDList = std::get<flutter::EncodableList>(topicIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = topicIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(topicIDList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMTopicOperationResultVectorValueCallback* callback = new V2TIMTopicOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->DeleteTopicPermissionFromPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, uids, callback);

        }
        else if (method_call.method_name().compare("modifyTopicPermissionInPermissionGroup") == 0)
        {
            auto topicPermissionMap_it = arguments->find(flutter::EncodableValue("topicPermissionMap"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }
            auto  imap264 = V2TIMStringToUint64Map();
            if (topicPermissionMap_it != arguments->end()) {
                flutter::EncodableValue fvalue = topicPermissionMap_it->second;
                if (!fvalue.IsNull()) {
                    flutter::EncodableMap fvmap = std::get<flutter::EncodableMap>(fvalue);
                    flutter::EncodableMap::iterator iter;
                    V2TIMCustomInfo ctiminfo;
                    for (iter = fvmap.begin(); iter != fvmap.end(); iter++)

                    {
                        int data = std::get<int>(iter->second);
                        imap264.Insert(V2TIMString{ std::get<std::string>(iter->first).c_str() }, data);
                    }

                }
            }
            V2TIMTopicOperationResultVectorValueCallback* callback = new V2TIMTopicOperationResultVectorValueCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->ModifyTopicPermissionInPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, imap264, callback);
        }

        else if (method_call.method_name().compare("getTopicPermissionInPermissionGroup") == 0)
        {
            auto topicIDList_it = arguments->find(flutter::EncodableValue("topicIDList"));
            auto groupID_it = arguments->find(flutter::EncodableValue("groupID"));
            auto permissionGroupID_it = arguments->find(flutter::EncodableValue("permissionGroupID"));
            std::string groupID = "";
            flutter::EncodableList topicIDList = {};
            std::string permissionGroupID = "";

            if (groupID_it != arguments->end())
            {

                groupID = std::get<std::string>(groupID_it->second);
            }

            if (permissionGroupID_it != arguments->end())
            {

                permissionGroupID = std::get<std::string>(permissionGroupID_it->second);
            }

            if (topicIDList_it != arguments->end())
            {

                topicIDList = std::get<flutter::EncodableList>(topicIDList_it->second);
            }

            V2TIMStringVector uids = {};
            size_t usize = topicIDList.size();
            for (size_t i = 0; i < usize; i++)
            {
                auto uid = std::get<std::string>(topicIDList[i]).c_str();
                uids.PushBack(V2TIMString{ uid });
            }
            V2TIMTopicPermissionResultVectorCallback* callback = new V2TIMTopicPermissionResultVectorCallback(std::move(result));
            V2TIMManager::GetInstance()->GetCommunityManager()->GetTopicPermissionInPermissionGroup(V2TIMString{ groupID.c_str() }, V2TIMString{ permissionGroupID.c_str() }, uids, callback);
        }

    }

} // namespace tencent_cloud_chat_sdk
