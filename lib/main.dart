import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import 'app/modules/custom_navigation.dart';
import 'app/modules/home/views/home_view.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/custom_route.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  print(message.data['timestamp']);
  DateTime a =DateTime.parse(message.data['timestamp']);
  DateTime b = DateTime.now();
  Duration difference = b.difference(a);
  print(difference);
  int days = difference.inDays;
  int hours = difference.inHours % 24;
  int minutes = difference.inMinutes % 60;
  int seconds = difference.inSeconds % 60;

  bool isnotifications = days >= 1 || hours >= 1 || minutes >= 1 || (seconds >= 30);
  if (isnotifications) {
    final params = CallKitParams(
      nameCaller: message.data['username'],
      avatar: message.data['profileimg'],
      type: int.parse(message.data['calltype']),
      missedCallNotification: const NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: 'Missed call',
        callbackText: 'Call back',
      ),
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
    FlutterCallkitIncoming.showMissCallNotification(params);
  } else {
    showCallkitIncoming(const Uuid().v4(), message.data).then((value) => print('calling....'));
  }
}
Future<void> showCallkitIncoming(String uuid,Map<String, dynamic> data) async {
  final params = CallKitParams(
    id: uuid,
    nameCaller: data['username'],
    appName: 'videoapp',
    avatar: data['profileimg'],
    handle: '0123456789',
    type: int.parse(data['calltype']),
    duration: 30000,
    textAccept: 'Accept',
    textDecline: 'Decline',
    missedCallNotification: const NotificationParams(
      showNotification: true,
      isShowCallback: true,
      subtitle: 'Missed call',
      callbackText: 'Call back',
    ),
    extra: <String, dynamic>{'userId': data['uid'],'channelId':data['channelid'],},
    headers: <String, dynamic>{'apiKey': 'Abc@1238888!', 'platform': 'flutter'},
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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
    _uuid = const Uuid();
    initFirebase();
    WidgetsBinding.instance.addObserver(this);
    checkAndNavigationCallingPage();
  }
  Future<dynamic> getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await FlutterCallkitIncoming.activeCalls();
    if (calls is List) {
      if (calls.isNotEmpty) {
        //print('DATA: $calls');
        //print('DATA: '+calls[0]['extra'].toString());
        _currentUuid = calls[0]['id'];
        print(_currentUuid);
        return calls[0];
      } else {
        _currentUuid = "";
        return null;
      }
    }
  }

  Future<void> checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    if (currentCall != null) {
      var remoteuser_payload = currentCall['extra'];
      print(remoteuser_payload);
       Get.to(()=>HomeView(),arguments: remoteuser_payload);
      //NavigationService.instance.pushNamedIfNotCurrent(AppRoute.callingPage, args: currentCall);
    }
  }
  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    print(state);
    if (state == AppLifecycleState.resumed) {
      // Your code for when app resumes
      checkAndNavigationCallingPage();
    }
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
      showCallkitIncoming(_currentUuid!, message.data).then((value) => print('calling to mr.'));
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
