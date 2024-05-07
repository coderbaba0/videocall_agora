import 'package:flutter/material.dart';
import 'package:videocall/app/modules/callng_page.dart';

import '../modules/splash/views/splash_view.dart';

class AppRoute {
  static const splash = '/splash';

  static const callingPage = '/calling_page';

  static Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashView(),
          settings: settings,
        );
      case callingPage:
        return MaterialPageRoute(
          builder: (_) => const CallingPage(),
          settings: settings,
        );
      default:
        return null;
    }
  }
}