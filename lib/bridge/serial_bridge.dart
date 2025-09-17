import 'dart:async';
import 'dart:typed_data';
import 'native_bridge.dart';

/// Serial communication bridge for Chameleon Ultra
/// Handles low-level serial protocol and data formatting
class SerialBridge {
  String? _connectedPort;
  int _baudRate = 115200;
  bool _isConnected = false;
  
  final StreamController<String> _dataController = StreamController<String>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  // Protocol constants
  static const int _maxPacketSize = 1024;
  static const int _commandTimeout = 5000;
  static const String _lineEnding = '\r\n';
  
  // Getters
  String? get connectedPort => _connectedPort;
  int get baudRate => _baudRate;
  bool get isConnected => _isConnected;
  
  // Streams
  Stream<String> get dataStream => _dataController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  /// Initialize serial bridge
  Future<bool> initialize() async {
    try {
      final bool result = await NativeBridge.initialize();
      
      // Listen to native bridge events
      NativeBridge.eventStream.listen((event) {
        switch (event['type']) {
          case 'device_connected':
            _handleConnectionEstablished(event['data']);
            break;
          case 'device_disconnected':
            _handleConnectionLost();
            break;
          case 'data_received':
            _handleDataReceived(event['data']);
            break;
          case 'error':
            _handleError(event['data']);
            break;
        }
      });
      
      return result;
    } catch (e) {
      print('Failed to initialize serial bridge: $e');
      return false;
    }
  }
  
  /// Connect to serial port
  Future<bool> connect(String port, {int baudRate = 115200}) async {
    try {
      if (_isConnected) {
        await disconnect();
      }
      
      final bool result = await NativeBridge.connectToDevice(port, baudRate);
      
      if (result) {
        _connectedPort = port;
        _baudRate = baudRate;
        _isConnected = true;
        _connectionController.add(true);
      }
      
      return result;
    } catch (e) {
      print('Failed to connect to $port: $e');
      return false;
    }
  }
  
  /// Disconnect from serial port
  Future<bool> disconnect() async {
    try {
      final bool result = await NativeBridge.disconnectFromDevice();
      
      _isConnected = false;
      _connectedPort = null;
      _connectionController.add(false);
      
      return result;
    } catch (e) {
      print('Failed to disconnect: $e');
      return false;
    }
  }
  
  /// Send command and wait for response
  Future<String> sendCommand(String command, {int timeout = _commandTimeout}) async {
    if (!_isConnected) {
      throw Exception('Not connected to device');
    }
    
    try {
      // Format command with proper line ending
      String formattedCommand = command.trim();
      if (!formattedCommand.endsWith(_lineEnding)) {
        formattedCommand += _lineEnding;
      }
      
      // Send command through native bridge
      final String response = await NativeBridge.sendCommand(formattedCommand, timeout: timeout);
      
      return response;
    } catch (e) {
      throw Exception('Command failed: $e');
    }
  }
  
  /// Send raw bytes to device
  Future<bool> sendRawData(Uint8List data) async {
    if (!_isConnected) {
      throw Exception('Not connected to device');
    }
    
    try {
      // Check packet size
      if (data.length > _maxPacketSize) {
        throw Exception('Packet too large: ${data.length} > $_maxPacketSize bytes');
      }
      
      final bool result = await NativeBridge.sendRawData(data.toList());
      return result;
    } catch (e) {
      print('Failed to send raw data: $e');
      return false;
    }
  }
  
  /// Send hex string as raw data
  Future<bool> sendHexData(String hexString) async {
    try {
      // Clean hex string
      String cleanHex = hexString.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
      
      if (cleanHex.length % 2 != 0) {
        throw Exception('Invalid hex string length');
      }
      
      // Convert hex to bytes
      List<int> bytes = [];
      for (int i = 0; i < cleanHex.length; i += 2) {
        String byteStr = cleanHex.substring(i, i + 2);
        bytes.add(int.parse(byteStr, radix: 16));
      }
      
      return await sendRawData(Uint8List.fromList(bytes));
    } catch (e) {
      print('Failed to send hex data: $e');
      return false;
    }
  }
  
  /// Get available serial ports
  Future<List<String>> getAvailablePorts() async {
    try {
      return await NativeBridge.getAvailablePorts();
    } catch (e) {
      print('Failed to get available ports: $e');
      return [];
    }
  }
  
  /// Auto-detect Chameleon Ultra device
  Future<String?> autoDetectDevice() async {
    try {
      return await NativeBridge.autoDetectDevice();
    } catch (e) {
      print('Auto-detection failed: $e');
      return null;
    }
  }
  
  /// Handle connection established event
  void _handleConnectionEstablished(Map<String, dynamic> data) {
    _connectedPort = data['port'];
    _baudRate = data['baudRate'] ?? _baudRate;
    _isConnected = true;
    _connectionController.add(true);
  }
  
  /// Handle connection lost event
  void _handleConnectionLost() {
    _isConnected = false;
    _connectedPort = null;
    _connectionController.add(false);
  }
  
  /// Handle incoming data
  void _handleDataReceived(Map<String, dynamic> data) {
    String receivedData = data['data'] ?? '';
    _dataController.add(receivedData);
  }
  
  /// Handle communication errors
  void _handleError(Map<String, dynamic> data) {
    String errorMessage = data['message'] ?? 'Unknown error';
    print('Serial communication error: $errorMessage');
    
    // If it's a connection error, update connection status
    if (errorMessage.contains('connection') || errorMessage.contains('disconnect')) {
      _handleConnectionLost();
    }
  }
  
  /// Dispose resources
  void dispose() {
    _dataController.close();
    _connectionController.close();
  }
}

/// Serial port configuration
class SerialConfig {
  final String port;
  final int baudRate;
  final int dataBits;
  final int stopBits;
  final String parity;
  final bool flowControl;
  
  const SerialConfig({
    required this.port,
    this.baudRate = 115200,
    this.dataBits = 8,
    this.stopBits = 1,
    this.parity = 'none',
    this.flowControl = false,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'port': port,
      'baudRate': baudRate,
      'dataBits': dataBits,
      'stopBits': stopBits,
      'parity': parity,
      'flowControl': flowControl,
    };
  }
  
  @override
  String toString() {
    return 'SerialConfig(port: $port, baud: $baudRate, $dataBits$parity$stopBits)';
  }
}