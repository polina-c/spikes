import 'dart:async';

import 'vm_service_wrapper.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

Future<VmServiceWrapper> connectWithWebSocket(
  Uri uri,
  void Function(Object? error) onError,
) async {
  final ws = WebSocketChannel.connect(uri);
  final stream = ws.stream.handleError(onError);
  final service = VmServiceWrapper.fromNewVmService(
    stream,
    (String message) {
      ws.sink.add(message);
    },
    uri,
  );

  if (ws.closeCode != null) {
    onError(ws.closeReason);
    return service;
  }

  return service;
}
