import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:videocall/app/modules/splash/views/splash_view.dart';

class HomeController extends GetxController {

  RxString currentTime = '00:00'.obs;
  Timer? _timer;
  int _secondsElapsed = 0;
  void startTimer() {
    _timer?.cancel(); // Cancel previous timer if any
    _secondsElapsed = 0;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _secondsElapsed++;
      int minutes = _secondsElapsed ~/ 60;
      int seconds = _secondsElapsed % 60;
      currentTime.value = '${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    });
  }
  void stopTimer() {
    _timer?.cancel();
  }
  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  var client = AgoraClient(
          agoraConnectionData: AgoraConnectionData(appId: '', channelName: ''))
      .obs();
  RxBool isremoteUserConnected = false.obs;
  RxBool isremoteUserchannelConnected = false.obs;
  bool isSnackbarDisplayedforconnection = false;
  bool isSnackbarDisplayedforchannel = false;
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
        tempToken:
            '007eJxTYLj/yFTp57w1QSnLHh/9w/LZ69+pSn+Nr3H7bvOXLNbvOLlTgcEiySLFKMkwxdLY3NDE3MjCwsLMNM3Y3CTNMDXRwtA0SXudbVpDICPD5+kVDIxQCOKzMJSkFpcwMAAAMpIiDg==',
      ),
      enabledPermission: [
        Permission.camera,
        Permission.microphone,
      ],
      agoraEventHandlers: AgoraRtcEventHandlers(
        onConnectionStateChanged: (connection, state, reason) {
          if (state == ConnectionStateType.connectionStateConnected) {
            if (!isSnackbarDisplayedforconnection) {
              //Get.snackbar('Connecting', 'Waiting for remote users to join...');
              isremoteUserConnected.value = true;
              isSnackbarDisplayedforconnection = true;
            }
          } else {
            isSnackbarDisplayedforconnection = false;
          }
        },
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
        onUserJoined: (connection, uid, elapsed) {
          if (!isSnackbarDisplayedforchannel) {
            Get.snackbar('Message', '$uid joined sucessfully');
            isremoteUserchannelConnected.value = true;
            startTimer();
            isSnackbarDisplayedforchannel = true;
          } else {
            isSnackbarDisplayedforchannel = false;
          }
        },
        onUserOffline: (connection, uid, reason) {
           // Get.delete<HomeController>();
           // Get.back();
          if (!isSnackbarDisplayed) {
            Get.snackbar('Messege', '$uid left the call');
            stopTimer();
            Get.defaultDialog(
                title: 'Message',
                middleText: 'User left the call',
                barrierDismissible: false,
                confirm: ElevatedButton(
                  onPressed: () {
                    Get.delete<HomeController>(); // Dispose of the controller
                    Get.to(()=>SplashView());
                  },
                  child: Text('OK'),
                ),
                );
            isSnackbarDisplayed = true;
          }
          else {
            isSnackbarDisplayed = false;
          }
        },
        onError: (errorCode, message) {
          print('Error: $errorCode - $message');
        },
      ),
    );
    client.engine.leaveChannel();
  }

  @override
  void onReady() async {
    await client.initialize();
    super.onReady();
  }

  @override
  void onClose() async{
    await client.engine.release();
    await FlutterCallkitIncoming.endAllCalls();
    _timer?.cancel();
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
              'uid': '10',
              'channelid': 'test',
              'username': 'oneplus user',
              'profileimg': 'https://i.pravatar.cc/100',
              'calltype': '1',
              'timestamp': DateTime.now().toString(),
            },
            'to':
                'fCLKCUOgTrGT2hg264xqJY:APA91bFEV5LX9UIGv0k295RRb4xJirM4An0Xm7CcX3dhQmH66Pr6X34AT0hkpVRCqeLKGhYCvi9QOsZPjSl5OIMa0k7bOpG1kBB5fnj8Ukv9N2kVdtW-AzfFQPBX2lM8Zta2eve0TFH9',
                //'fDZEgjXDRSGLvnr3Cuxaai:APA91bGH9aLsy_vgOtKn7my0vuiOzg7ea_fMvAP8jfNBxNSM9oQMSdrr00HeFYn6XLkZl70URK9E_GdqwT9OKXkT8PQLH6J2cmWdJnxFYhx9jcatkDNf_R0S1U0CCwwSf5WLqayojL4M',
          },
        ),
      );
      print(response.body);
    } catch (e) {
      print("error push notification+$e");
    }
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
