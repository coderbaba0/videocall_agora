import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:videocall/app/modules/home/views/home_view.dart';

import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SplashController>(
        init: SplashController(),
        builder: (controller) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/logo.png',
                    width: controller.animation.value * 200,
                    height: controller.animation.value * 200,
                  ),
                  SizedBox(height: 20,),
                  CircleAvatar(
                      radius:30,backgroundColor:Colors.orange,child: IconButton(onPressed: (){ Get.to(()=>HomeView());}, icon: Icon(Icons.skip_next)))
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
