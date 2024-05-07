import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'app/modules/custom_navigation.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/custom_route.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  showCallkitIncoming(const Uuid().v4()).then((value) =>  print('calling....'));

}
Future<void> showCallkitIncoming(String uuid) async {
  final params = CallKitParams(
    id: uuid,
    nameCaller: 'Hien Nguyen',
    appName: 'Callkit',
    avatar: 'https://i.pravatar.cc/100',
    handle: '0123456789',
    type: 0,
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
      isCustomNotification: true,
      isShowLogo: false,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#0955fa',
      backgroundUrl: 'assets/test.png',
      actionColor: '#4CAF50',
      textColor: '#ffffff',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(params);
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}
class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  late final Uuid _uuid;
  String? _currentUuid;
  late final FirebaseMessaging _firebaseMessaging;
  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    _uuid = const Uuid();
    initFirebase();
    WidgetsBinding.instance.addObserver(this);
  }
  Future<void> requestNotificationPermission() async {
    await FlutterCallkitIncoming.requestNotificationPermission({
      "rationaleMessagePermission":
      "Notification permission is required, to show notification.",
      "postNotificationMessageRequired":
      "Notification permission is required, Please allow notification permission from setting."
    });
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  Future<void> initFirebase() async {
    await Firebase.initializeApp();
    _firebaseMessaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print('Message title: ${message.notification?.title}, body: ${message.notification?.body}, data: ${message.data}');
      _currentUuid = _uuid.v4();
      print(_currentUuid);
      showCallkitIncoming(_currentUuid!).then((value) => print('calling to mr.'),);
    });
    _firebaseMessaging.getToken().then((token) {
      print('Device Token FCM: $token');
    });
  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData.light(),
      onGenerateRoute: AppRoute.generateRoute,
      initialRoute: AppRoute.splash,
      getPages: AppPages.routes,
      navigatorKey: NavigationService.instance.navigationKey,
      navigatorObservers: <NavigatorObserver>[NavigationService.instance.routeObserver],
    );
  }
}

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(
//     GetMaterialApp(
//       title: "Application",
//       debugShowCheckedModeBanner: false,
//       initialRoute: AppPages.INITIAL,
//       getPages: AppPages.routes,
//     ),
//   );
// }
