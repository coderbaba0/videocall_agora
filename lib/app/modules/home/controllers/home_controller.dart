import 'package:agora_uikit/agora_uikit.dart';
import 'package:get/get.dart';
class HomeController extends GetxController {
  final AgoraClient client = AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "8b8d2b1d937147288865f374f1ea815b",
      channelName: 'test',
      uid: 13,
      tempToken: '007eJxTYFj22D4q1mF7AuuC1S/frLE8y2uQPGHG8QXbFwS+OW4ZZvVFgcEiySLFKMkwxdLY3NDE3MjCwsLMNM3Y3CTNMDXRwtA0acdPkbSGQEYGXbGFDIxQCOKzMJSkFpcwMAAAlQgf9A==',
    ),

    enabledPermission: [
      Permission.camera,
      Permission.microphone,
    ],
  );
  @override
  void onInit() {
    super.onInit();
    initAgora();
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

}
