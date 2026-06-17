import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final socketServiceProvider =
    Provider<SocketService>((ref) => SocketService(ref));

class SocketService {
  final Ref ref;
  IO.Socket? _socket;
  final _storage = const FlutterSecureStorage();

  // Stream Controllers for events
  final _orderEvents = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get orderEvents => _orderEvents.stream;

  final _tenderingEvents = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get tenderingEvents => _tenderingEvents.stream;

  SocketService(this.ref);

  Future<void> init() async {
    if (_socket != null && _socket!.connected) return;

    final token = await _storage.read(key: 'token');
    final baseUrl = dotenv.env['API_URL']?.replaceAll('/api', '') ??
        dotenv.env['SOCKET_URL'] ?? 'https://api.marketplace.com';

    debugPrint('🔌 Connecting to Socket: $baseUrl');

    _socket = IO.io(
        baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setAuth({'token': token})
            .disableAutoConnect()
            .build());

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('✅ Socket Connected');
    });

    _socket!.onDisconnect((_) {
      debugPrint('❌ Socket Disconnected');
    });

    _socket!.on('new_order', (data) {
      debugPrint('🔔 New order received: $data');
      _orderEvents
          .add({...Map<String, dynamic>.from(data), 'type': 'new_order'});
    });

    _socket!.on('order_status_update', (data) {
      debugPrint('📦 Order status sync: $data');
      _orderEvents
          .add({...Map<String, dynamic>.from(data), 'type': 'status_update'});
    });

    _socket!.on('tendering_update', (data) {
      debugPrint('✨ Tendering update: $data');
      _tenderingEvents.add(Map<String, dynamic>.from(data));
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
