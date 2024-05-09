import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
   var client = AgoraClient(agoraConnectionData: AgoraConnectionData(appId: '',channelName: '')).obs();
   bool isSnackbarDisplayed = false;
  @override
  void onInit() {
    super.onInit();
    initializeAgora();
    sendPushMessage();
  }
  void initializeAgora() {
    client = AgoraClient(
      agoraConnectionData: AgoraConnectionData(
        appId: '8b8d2b1d937147288865f374f1ea815b',
        channelName: Get.arguments['channelId'],
        uid: int.parse(Get.arguments['userId']),
        tempToken: '007eJxTYFh3r3bKstfvjx4rO7Eq4t302IteIkxlnoJ93xc9NCoyYpqjwGCRZJFilGSYYmlsbmhibmRhYWFmmmZsbpJmmJpoYWiaNDHaJq0hkJFheo4UIyMDBIL4LAwlqcUlDAwAzt4f5A==',
      ),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ],
      agoraEventHandlers: AgoraRtcEventHandlers(
        // onJoinChannelSuccess: (RtcConnection connection,uid){
        //   Get.snackbar('alert', '$uid+joined sucessfully');
        // },
        // onLeaveChannel: (RtcConnection connection,RtcStats status){
        //   Get.snackbar('alert', '$status+ leaved sucessfully');
        //  Navigator.pop(Get.context!);
        //   Get.back();
        // },
        // onUserMuteAudio: (connection, uid, elapsed) {
        //   print('muted, uid: $uid');
        //   Get.snackbar('alert', '$uid+$elapsed');
        // },
        // onUserJoined: (connection, uid, elapsed) {
        //   print('User joined channel, uid: $uid');
        //   Get.snackbar('alert', '$uid+joined sucessfully');
        //
        // },

        onUserOffline: (connection, uid, reason) async{
          Get.back();
          if (!isSnackbarDisplayed) {
            Get.snackbar('alert', '$uid left the channel');
            isSnackbarDisplayed = true;
            await client.engine.leaveChannel();
          }
        },
        onError: (errorCode, message) {
          print('Error: $errorCode - $message');
        },
      ),
    );
    client.engine.leaveChannel();
  }
   // Method to check if user is connected to the channel
   bool isUserConnected() {
     return ConnectionStateType.connectionStateConnected == client.engine.getConnectionState();
   }
   void closeConnection() async{
    bool userconnected = isUserConnected();
    print(userconnected.toString());
    if(userconnected==false){
      client.engine.leaveChannel();
      await FlutterCallkitIncoming.endAllCalls();
    }
   }
  @override
  void onReady() async {
   await client.initialize();
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
  void sendPushMessage() async {
    try {
      var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAgBOVjKQ:APA91bH8yWi9S8V5_HUY9ZsKl77acSls3zejtpZciIir16nkMpaopppXMTnEe17pgFAoPZmmcfOeL4YfiLZlAQChOgjo8X3Af8TK84DsQQtLaOWQoAneccTbFFUPjm3nZZXdcgWquzfA',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'uid': '12',
              'channelid': 'test',
              'username': 'oneplus user',
              'profileimg': 'https://i.pravatar.cc/100',
              'calltype': '1',
              'timestamp': DateTime.now().toString(),
            },
            'to': 'fCLKCUOgTrGT2hg264xqJY:APA91bFEV5LX9UIGv0k295RRb4xJirM4An0Xm7CcX3dhQmH66Pr6X34AT0hkpVRCqeLKGhYCvi9QOsZPjSl5OIMa0k7bOpG1kBB5fnj8Ukv9N2kVdtW-AzfFQPBX2lM8Zta2eve0TFH9',
            // 'fDZEgjXDRSGLvnr3Cuxaai:APA91bGH9aLsy_vgOtKn7my0vuiOzg7ea_fMvAP8jfNBxNSM9oQMSdrr00HeFYn6XLkZl70URK9E_GdqwT9OKXkT8PQLH6J2cmWdJnxFYhx9jcatkDNf_R0S1U0CCwwSf5WLqayojL4M',
          },
        ),
      );
      print(response.body);
    } catch (e) {
      print("error push notification+$e");
    }
  }

  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
  }
}

//  class HomeController extends GetxController {
//    var client = AgoraClient(agoraConnectionData: AgoraConnectionData(appId: '',channelName: '')).obs();
//
//   // final AgoraClient clienttest = AgoraClient(
//   //   agoraConnectionData: AgoraConnectionData(
//   //     appId: "8b8d2b1d937147288865f374f1ea815b",
//   //     channelName: channelId3,
//   //     uid: 10,
//   //     tempToken: '007eJxTYIh8VV2VLXKg98WnHrk3M3ewejcoGTMertM4oLisZ7oAk6YCg0WSRYpRkmGKpbG5oYm5kYWFhZlpmrG5SZphaqKFoWmSL491WkMgI0NoiDQDIxSC+KwMJanFJUYMDADMOxwb',
//   //   ),
//   //   enabledPermission: [
//   //     Permission.camera,
//   //     Permission.microphone,
//   //     Permission.location,
//   //   ],
//   // );
//
//   @override
//   void onInit() {
//     super.onInit();
//     client = AgoraClient(
//       agoraConnectionData: AgoraConnectionData(
//         appId: '8b8d2b1d937147288865f374f1ea815b',
//         channelName: Get.arguments['channelId'],
//         uid: int.parse(Get.arguments['userId']),
//         tempToken: '007eJxTYFh3r3bKstfvjx4rO7Eq4t302IteIkxlnoJ93xc9NCoyYpqjwGCRZJFilGSYYmlsbmhibmRhYWFmmmZsbpJmmJpoYWiaNDHaJq0hkJFheo4UIyMDBIL4LAwlqcUlDAwAzt4f5A==',
//       ),
//       enabledPermission: [
//         Permission.camera,
//         Permission.microphone,
//       ],
//     ) ;
//     //initFirebase();
//     sendPushMessage();
//      //initAgora();
//
//   }
//
//   @override
//   void onReady() async{
//     await client.initialize();
//     super.onReady();
//
//   }
//   @override
//   void onClose() {
//     super.onClose();
//   }
//   void sendPushMessage() async {
//     try {
//       var response= await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           'Content-Type': 'application/json',
//           'Authorization':
//           'key=AAAAgBOVjKQ:APA91bH8yWi9S8V5_HUY9ZsKl77acSls3zejtpZciIir16nkMpaopppXMTnEe17pgFAoPZmmcfOeL4YfiLZlAQChOgjo8X3Af8TK84DsQQtLaOWQoAneccTbFFUPjm3nZZXdcgWquzfA',
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             // 'notification': <String, dynamic>{
//             //   'body': 'testjjj',
//             //   'title': 'title',
//             //   'color' : '#eeeeee',
//             //   //"image": image,
//             //   'count' : 10,
//             //   'notification_count' : 10,
//             //   'badge' : 10,
//             // },
//             'priority': 'high',
//             'data': <String, dynamic>{
//               'click_action': 'FLUTTER_NOTIFICATION_CLICK',
//               'uid': '25',
//               'channelid': 'test',
//               'username':'oneplus user',
//               'profileimg':'https://i.pravatar.cc/100',
//               'calltype':'1',
//               'timestamp':DateTime.now().toString(),
//             },
//             'to':
//             //'fDZEgjXDRSGLvnr3Cuxaai:APA91bGH9aLsy_vgOtKn7my0vuiOzg7ea_fMvAP8jfNBxNSM9oQMSdrr00HeFYn6XLkZl70URK9E_GdqwT9OKXkT8PQLH6J2cmWdJnxFYhx9jcatkDNf_R0S1U0CCwwSf5WLqayojL4M',
//             'fCLKCUOgTrGT2hg264xqJY:APA91bFEV5LX9UIGv0k295RRb4xJirM4An0Xm7CcX3dhQmH66Pr6X34AT0hkpVRCqeLKGhYCvi9QOsZPjSl5OIMa0k7bOpG1kBB5fnj8Ukv9N2kVdtW-AzfFQPBX2lM8Zta2eve0TFH9',
//             // "to": token[0],
//           },
//         ),
//       );
//       print(response.body);
//     } catch (e) {
//       print("error push notification");
//     }
//   }
//    Future<void> endAllCalls() async {
//      await FlutterCallkitIncoming.endAllCalls();
//    }
// }
