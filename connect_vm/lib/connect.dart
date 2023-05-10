import 'dart:developer';
import 'package:connect_vm/service/service.dart';

String host = "127.0.0.1";
int port = 61463;

Future<void> connectToVm(String uri) async {
  final info = await Service.getInfo();

  final service = await connectWithWebSocket(info.serverWebSocketUri!, (error) {
    print('error recieved: $error');
  });
  final version = await service.getVersion();

  print('connected to $version');
}
