import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({Key? key}) : super(key: key);
  final controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
        centerTitle: true,
        actions: [
          Obx(()=>
            controller.isremoteUserchannelConnected.isTrue? Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text(
                '${controller.currentTime}',
                style: TextStyle(fontSize: 15),
              ),
            ):Text(''),
          )
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => Stack(
            children: [
              if (!controller.isremoteUserConnected.value &&
                  !controller.isremoteUserchannelConnected.value)
                Center(
                  child: Text(
                    'Connecting...',
                    style: TextStyle(fontSize: 15),
                  ),
                )
              else if (!controller.isremoteUserchannelConnected.value)
                Center(
                  child: Text(
                    'Ringing...',
                    style: TextStyle(fontSize: 15),
                  ),
                )
              else
                AgoraVideoViewer(
                  client: controller.client,
                  layoutType: Layout.oneToOne,
                ),
              AgoraVideoButtons(
                client: controller.client,
                addScreenSharing: true, // Add this to enable screen sharing
              ),
            ],
          ),
        ),
      ),
    );
  }
}
