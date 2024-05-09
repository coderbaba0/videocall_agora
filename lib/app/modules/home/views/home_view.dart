import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
   HomeView({Key? key}) : super(key: key);
  final controller =Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        centerTitle: true,
      ),
        body: SafeArea(
          child:
             Stack(
              children: [
                AgoraVideoViewer(
                  client: controller.client,
                  //showNumberOfUsers: true,
                  layoutType: Layout.oneToOne,
                  //enableHostControls: true, // Add this to enable host controls
                ),
                  AgoraVideoButtons(
                  client: controller.client,
                  addScreenSharing: true, // Add this to enable screen sharing
                ),
              ],
            ),
          ),
    );
  }
}
