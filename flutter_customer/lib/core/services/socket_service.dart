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
  final _orderUpdates = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get orderUpdates => _orderUpdates.stream;

  final _tenderingUpdates = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get tenderingUpdates => _tenderingUpdates.stream;

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

    _socket!.on('order_status_update', (data) {
      debugPrint('📦 Order status update: $data');
      _orderUpdates.add(Map<String, dynamic>.from(data));
    });

    _socket!.on('order_created', (data) {
      debugPrint('🛒 New order created: $data');
      _orderUpdates
          .add({...Map<String, dynamic>.from(data), 'status': 'created'});
    });

    _socket!.on('tendering_update', (data) {
      debugPrint('✨ Tendering update received: $data');
      _tenderingUpdates.add(Map<String, dynamic>.from(data));
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
