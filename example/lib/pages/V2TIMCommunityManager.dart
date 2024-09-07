import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/addCommunityMembersToPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/addTopicPermissionToPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/createAtSignedGroupMessage.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/createCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/createPermissionGroupInCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/deletePermissionGroupFromCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/deleteTopicPermissionFromPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/getCommunityMemberListInPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/getJoinedPermissionGroupListInCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/getPermissionGroupListInCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/getTopicPermissionInPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/insertC2CMessageToLocalStorageV2.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/insertGroupMessageToLocalStorageV2.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/modifyPermissionGroupInfoInCommunity.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/modifyTopicPermissionInPermissionGroup.dart';
import 'package:tencent_cloud_chat_sdk_example/api/V2TIMCommunityManager/removeCommunityMembersFromPermissionGroup.dart';

class V2TIMCommunityManagerPage extends StatefulWidget {
  const V2TIMCommunityManagerPage({super.key});

  @override
  State<StatefulWidget> createState() => V2TIMCommunityManagerPageState();
}

class V2TIMCommunityManagerPageState extends State<V2TIMCommunityManagerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GridView(
              scrollDirection: Axis.vertical,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 5,
                childAspectRatio: 6,
              ),
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InsertGroupMessageToLocalStorageV2()),
                    );
                  },
                  child: const Text('insertGroupMessageToLocalStorageV2'),
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const InsertC2CMessageToLocalStorageV2()),
                      );
                    },
                    child: const Text('insertC2CMessageToLocalStorageV2')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateAtSignedGroupMessage()),
                      );
                    },
                    child: const Text('createAtSignedGroupMessage')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreatePermissionGroupInCommunity()),
                      );
                    },
                    child: const Text('createPermissionGroupInCommunity')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeletePermissionGroupFromCommunity()),
                      );
                    },
                    child: const Text('deletePermissionGroupFromCommunity')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModifyPermissionGroupInfoInCommunity()),
                      );
                    },
                    child: const Text('modifyPermissionGroupInfoInCommunity')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GetJoinedPermissionGroupListInCommunity()),
                      );
                    },
                    child: const Text('getJoinedPermissionGroupListInCommunity')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GetPermissionGroupListInCommunity()),
                      );
                    },
                    child: const Text('getPermissionGroupListInCommunity')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddCommunityMembersToPermissionGroup()),
                      );
                    },
                    child: const Text('addCommunityMembersToPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RemoveCommunityMembersFromPermissionGroup()),
                      );
                    },
                    child: const Text('removeCommunityMembersFromPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GetCommunityMemberListInPermissionGroup()),
                      );
                    },
                    child: const Text('getCommunityMemberListInPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddTopicPermissionToPermissionGroup()),
                      );
                    },
                    child: const Text('addTopicPermissionToPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DeleteTopicPermissionFromPermissionGroup()),
                      );
                    },
                    child: const Text('deleteTopicPermissionFromPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ModifyTopicPermissionInPermissionGroup()),
                      );
                    },
                    child: const Text('modifyTopicPermissionInPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GetTopicPermissionInPermissionGroup()),
                      );
                    },
                    child: const Text('getTopicPermissionInPermissionGroup')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateCommunity()),
                      );
                    },
                    child: const Text('createCommunity')),
              ],
            ),
          )
        ],
      ),
      appBar: AppBar(
        title: const Text('community manager'),
      ),
    );
  }
}
