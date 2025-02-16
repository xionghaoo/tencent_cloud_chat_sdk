// void 	onFriendApplicationListAdded (List< V2TIMFriendApplication > applicationList)

// void 	onFriendApplicationListDeleted (List< String > userIDList)

// void 	onFriendApplicationListRead ()

// void 	onFriendListAdded (List< V2TIMFriendInfo > users)

// void 	onFriendListDeleted (List< String > userList)

// void 	onBlackListAdd (List< V2TIMFriendInfo > infoList)

// void 	onBlackListDeleted (List< String > userList)

// ignore_for_file: file_names, prefer_function_declarations_over_variables

// void 	onFriendInfoChanged (List< V2TIMFriendInfo > infoList)
//
import 'package:tencent_cloud_chat_sdk/enum/callbacks.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_application.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_friend_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_official_account_info.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_user_full_info.dart';

class V2TimFriendshipListener {
  OnFriendApplicationListAddedCallback onFriendApplicationListAdded = (
    List<V2TimFriendApplication> applicationList,
  ) {};
  OnFriendApplicationListDeletedCallback onFriendApplicationListDeleted = (
    List<String> userIDList,
  ) {};
  OnFriendApplicationListReadCallback onFriendApplicationListRead = () {};
  OnFriendListAddedCallback onFriendListAdded = (
    List<V2TimFriendInfo> users,
  ) {};
  OnFriendListDeletedCallback onFriendListDeleted = (
    List<String> userList,
  ) {};
  OnBlackListAddCallback onBlackListAdd = (
    List<V2TimFriendInfo> infoList,
  ) {};
  OnBlackListDeletedCallback onBlackListDeleted = (
    List<String> userList,
  ) {};
  OnFriendInfoChangedCallback onFriendInfoChanged = (
    List<V2TimFriendInfo> infoList,
  ) {};

  OnOfficialAccountSubscribed onOfficialAccountSubscribed =
      (V2TimOfficialAccountInfo officialAccountInfo) {};
  OnOfficialAccountUnsubscribed onOfficialAccountUnsubscribed =
      (String officialAccountID) {};
  OnOfficialAccountDeleted onOfficialAccountDeleted =
      (String officialAccountID) {};
  OnOfficialAccountInfoChanged onOfficialAccountInfoChanged =
      (V2TimOfficialAccountInfo officialAccountInfo) {};
  OnMyFollowingListChanged onMyFollowingListChanged =
      (List<V2TimUserFullInfo> userInfoList, bool isAdd) {};
  OnMyFollowersListChanged onMyFollowersListChanged =
      (List<V2TimUserFullInfo> userInfoList, bool isAdd) {};
  OnMutualFollowersListChanged onMutualFollowersListChanged =
      (List<V2TimUserFullInfo> userInfoList, bool isAdd) {};

  V2TimFriendshipListener({
    OnFriendApplicationListAddedCallback? onFriendApplicationListAdded,
    OnFriendApplicationListDeletedCallback? onFriendApplicationListDeleted,
    OnFriendApplicationListReadCallback? onFriendApplicationListRead,
    OnFriendListAddedCallback? onFriendListAdded,
    OnFriendListDeletedCallback? onFriendListDeleted,
    OnBlackListAddCallback? onBlackListAdd,
    OnBlackListDeletedCallback? onBlackListDeleted,
    OnFriendInfoChangedCallback? onFriendInfoChanged,
    OnOfficialAccountSubscribed? onOfficialAccountSubscribed,
    OnOfficialAccountUnsubscribed? onOfficialAccountUnsubscribed,
    OnOfficialAccountDeleted? onOfficialAccountDeleted,
    OnOfficialAccountInfoChanged? onOfficialAccountInfoChanged,
    OnMyFollowingListChanged? onMyFollowingListChanged,
    OnMyFollowersListChanged? onMyFollowersListChanged,
    OnMutualFollowersListChanged? onMutualFollowersListChanged,
  }) {
    if (onFriendApplicationListAdded != null) {
      this.onFriendApplicationListAdded = onFriendApplicationListAdded;
    }
    if (onFriendApplicationListDeleted != null) {
      this.onFriendApplicationListDeleted = onFriendApplicationListDeleted;
    }
    if (onFriendApplicationListRead != null) {
      this.onFriendApplicationListRead = onFriendApplicationListRead;
    }
    if (onFriendListAdded != null) {
      this.onFriendListAdded = onFriendListAdded;
    }
    if (onFriendListDeleted != null) {
      this.onFriendListDeleted = onFriendListDeleted;
    }
    if (onBlackListAdd != null) {
      this.onBlackListAdd = onBlackListAdd;
    }
    if (onBlackListDeleted != null) {
      this.onBlackListDeleted = onBlackListDeleted;
    }
    if (onFriendInfoChanged != null) {
      this.onFriendInfoChanged = onFriendInfoChanged;
    }

    if (onOfficialAccountSubscribed != null) {
      this.onOfficialAccountSubscribed = onOfficialAccountSubscribed;
    }
    if (onOfficialAccountUnsubscribed != null) {
      this.onOfficialAccountUnsubscribed = onOfficialAccountUnsubscribed;
    }
    if (onOfficialAccountDeleted != null) {
      this.onOfficialAccountDeleted = onOfficialAccountDeleted;
    }
    if (onOfficialAccountInfoChanged != null) {
      this.onOfficialAccountInfoChanged = onOfficialAccountInfoChanged;
    }
    if (onMyFollowingListChanged != null) {
      this.onMyFollowingListChanged = onMyFollowingListChanged;
    }
    if (onMyFollowersListChanged != null) {
      this.onMyFollowersListChanged = onMyFollowersListChanged;
    }
    if (onMutualFollowersListChanged != null) {
      this.onMutualFollowersListChanged = onMutualFollowersListChanged;
    }
  }
}
