import 'package:agora_uikit/agora_uikit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  late final FirebaseMessaging _firebaseMessaging;
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.notification!.title}");
    await Firebase.initializeApp(); //make sure firebase is initialized before using it (showCallkitIncoming)
    //showCallkitIncoming(const Uuid().v4());
  }
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "8b8d2b1d937147288865f374f1ea815b",
      channelName: 'test',
      uid: 10,
      tempToken: '007eJxTYPjQtL9/Rakc3+ezU54zKlXG9r9Zfqtl/U8PvkO5r+fr+bgqMFgkWaQYJRmmWBqbG5qYG1lYWJiZphmbm6QZpiZaGJomWc61SGsIZGQ4+s2cgREKQXwWhpLU4hIGBgC+OyCK',
    ),
    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );

  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
    });
    _firebaseMessaging.getToken().then((token) {
      print('Device Token FCM: $token');
    }
    );
  }

  @override
  void onInit() {
    super.onInit();
    //initFirebase();
    sendPushMessage();
   // initAgora();
  }
  void initAgora() async {
    await client.initialize();
  }
  @override
  void onReady() {
    super.onReady();
  }
  @override
  void onClose() {
    super.onClose();
  }

  void sendPushMessage() async {
    try {
      var response= await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
          'key=AAAAgBOVjKQ:APA91bH8yWi9S8V5_HUY9ZsKl77acSls3zejtpZciIir16nkMpaopppXMTnEe17pgFAoPZmmcfOeL4YfiLZlAQChOgjo8X3Af8TK84DsQQtLaOWQoAneccTbFFUPjm3nZZXdcgWquzfA',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'body': 'testjjj',
              'title': 'title',
              'color' : '#eeeeee',
              //"image": image,
              'count' : 10,
              'notification_count' : 10,
              'badge' : 10,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to':
            //'fDZEgjXDRSGLvnr3Cuxaai:APA91bGH9aLsy_vgOtKn7my0vuiOzg7ea_fMvAP8jfNBxNSM9oQMSdrr00HeFYn6XLkZl70URK9E_GdqwT9OKXkT8PQLH6J2cmWdJnxFYhx9jcatkDNf_R0S1U0CCwwSf5WLqayojL4M',
            'fCLKCUOgTrGT2hg264xqJY:APA91bFEV5LX9UIGv0k295RRb4xJirM4An0Xm7CcX3dhQmH66Pr6X34AT0hkpVRCqeLKGhYCvi9QOsZPjSl5OIMa0k7bOpG1kBB5fnj8Ukv9N2kVdtW-AzfFQPBX2lM8Zta2eve0TFH9',
            // "to": token[0],
          },
        ),
      );
      print(response.body);
    } catch (e) {
      print("error push notification");
    }
  }
}
