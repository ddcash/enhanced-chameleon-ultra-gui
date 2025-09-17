import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Communication bridge for Chameleon Ultra device
/// Handles serial communication, BLE, and command processing
class ChameleonCommunicator {
  static const MethodChannel _channel = MethodChannel('chameleon_ultra');
  
  bool _isConnected = false;
  String? _connectedPort;
  int _baudRate = 115200;
  
  StreamController<String> _dataStreamController = StreamController<String>.broadcast();
  StreamController<bool> _connectionStreamController = StreamController<bool>.broadcast();
  
  // Getters
  bool get isConnected => _isConnected;
  String? get connectedPort => _connectedPort;
  int get baudRate => _baudRate;
  
  // Streams
  Stream<String> get dataStream => _dataStreamController.stream;
  Stream<bool> get connectionStream => _connectionStreamController.stream;
  
  /// Initialize the communicator
  Future<void> initialize() async {
    try {
      await _channel.invokeMethod('initialize');
    } on PlatformException catch (e) {
      print('Failed to initialize communicator: ${e.message}');
    }
  }
  
  /// Connect to Chameleon Ultra device
  Future<bool> connect({String? port, int? baudRate}) async {
    try {
      final Map<String, dynamic> params = {
        'port': port ?? 'auto',
        'baudRate': baudRate ?? _baudRate,
      };
      
      final bool success = await _channel.invokeMethod('connect', params);
      
      if (success) {
        _isConnected = true;
        _connectedPort = port;
        _baudRate = baudRate ?? _baudRate;
        _connectionStreamController.add(true);
        
        // Start listening for data
        _startDataListener();
      }
      
      return success;
    } on PlatformException catch (e) {
      print('Failed to connect: ${e.message}');
      return false;
    }
  }
  
  /// Disconnect from device
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _connectedPort = null;
      _connectionStreamController.add(false);
    } on PlatformException catch (e) {
      print('Failed to disconnect: ${e.message}');
    }
  }
  
  /// Send command to device
  Future<String> sendCommand(String command) async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }
    
    try {
      final String response = await _channel.invokeMethod('sendCommand', {
        'command': command,
        'timeout': 5000, // 5 second timeout
      });
      
      return response;
    } on PlatformException catch (e) {
      throw Exception('Command failed: ${e.message}');
    }
  }
  
  /// Send raw data to device
  Future<void> sendRawData(Uint8List data) async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }
    
    try {
      await _channel.invokeMethod('sendRawData', {
        'data': data,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to send raw data: ${e.message}');
    }
  }
  
  /// Get available serial ports
  Future<List<String>> getAvailablePorts() async {
    try {
      final List<dynamic> ports = await _channel.invokeMethod('getAvailablePorts');
      return ports.cast<String>();
    } on PlatformException catch (e) {
      print('Failed to get available ports: ${e.message}');
      return [];
    }
  }
  
  /// Auto-detect Chameleon Ultra device
  Future<String?> autoDetectDevice() async {
    try {
      final String? port = await _channel.invokeMethod('autoDetectDevice');
      return port;
    } on PlatformException catch (e) {
      print('Auto-detection failed: ${e.message}');
      return null;
    }
  }
  
  /// Check device status
  Future<Map<String, dynamic>> getDeviceStatus() async {
    if (!_isConnected) {
      throw Exception('Device not connected');
    }
    
    try {
      final Map<dynamic, dynamic> status = await _channel.invokeMethod('getDeviceStatus');
      return Map<String, dynamic>.from(status);
    } on PlatformException catch (e) {
      throw Exception('Failed to get device status: ${e.message}');
    }
  }
  
  /// Start data listener for incoming device data
  void _startDataListener() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onDataReceived':
          final String data = call.arguments['data'];
          _dataStreamController.add(data);
          break;
        case 'onConnectionLost':
          _isConnected = false;
          _connectedPort = null;
          _connectionStreamController.add(false);
          break;
        case 'onError':
          final String error = call.arguments['error'];
          print('Communication error: $error');
          break;
      }
    });
  }
  
  /// Dispose resources
  void dispose() {
    _dataStreamController.close();
    _connectionStreamController.close();
  }
}

/// Mock implementation for development/testing
class MockChameleonCommunicator extends ChameleonCommunicator {
  bool _mockConnected = false;
  
  @override
  bool get isConnected => _mockConnected;
  
  @override
  Future<bool> connect({String? port, int? baudRate}) async {
    // Simulate connection delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    _mockConnected = true;
    _connectedPort = port ?? '/dev/ttyUSB0';
    _baudRate = baudRate ?? 115200;
    
    // Simulate connection success
    _connectionStreamController.add(true);
    
    return true;
  }
  
  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    _mockConnected = false;
    _connectedPort = null;
    
    _connectionStreamController.add(false);
  }
  
  @override
  Future<String> sendCommand(String command) async {
    if (!_mockConnected) {
      throw Exception('Device not connected');
    }
    
    // Simulate command processing delay
    await Future.delayed(Duration(milliseconds: 200 + (command.length * 10)));
    
    // Mock responses based on command
    if (command.startsWith('hw version')) {
      return '''#db# Chameleon Ultra detected
#db# Firmware version: 2.0.0
#db# Hardware version: Ultra
#db# Device serial: CU-123456789ABC

Chameleon Ultra firmware 2.0.0''';
    } else if (command.startsWith('hf search')) {
      return '''#db# Searching for high frequency tags...

UID : 04 68 95 71 fa 5c 64
ATQA : 00 44
SAK : 20
Type: NXP MIFARE DESFire EV1 4k

14a card found!''';
    } else if (command.startsWith('lf search')) {
      return '''#db# Searching for low frequency tags...

EM410x pattern found:
EM Tag ID      : 1234567890
Unique Tag ID  : 1234567890

Valid EM410x ID Found!''';
    } else if (command.startsWith('chameleon info')) {
      return '''Chameleon Ultra Device Information:

Hardware Version: 2.0
Firmware Version: 2.0.0
Device Serial: CU-123456789ABC
Battery Level: 85%
Charging: No
USB Connected: Yes''';
    } else {
      return '#db# Command executed successfully\n\nOK';
    }
  }
  
  @override
  Future<List<String>> getAvailablePorts() async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    return [
      '/dev/ttyUSB0',
      '/dev/ttyUSB1',
      'COM1',
      'COM2',
      'COM3',
    ];
  }
  
  @override
  Future<String?> autoDetectDevice() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // Simulate successful auto-detection
    return '/dev/ttyUSB0';
  }
  
  @override
  Future<Map<String, dynamic>> getDeviceStatus() async {
    if (!_mockConnected) {
      throw Exception('Device not connected');
    }
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'firmware_version': '2.0.0',
      'hardware_version': '2.0',
      'device_serial': 'CU-123456789ABC',
      'battery_level': 85,
      'charging': false,
      'usb_connected': true,
      'ble_available': true,
      'ble_connected': false,
      'active_slot': 1,
      'slots_used': 3,
      'total_slots': 8,
    };
  }
}