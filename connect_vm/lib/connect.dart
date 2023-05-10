import 'dart:developer';
import 'dart:io';
import 'package:vm_service/vm_service.dart';

String host = "127.0.0.1";
int port = 61463;

Future<void> connectToVm(String uri) async {
  final info = await Service.getInfo();
  print(info.serverUri);
  print(info.serverWebSocketUri);
  print('connected');
}
