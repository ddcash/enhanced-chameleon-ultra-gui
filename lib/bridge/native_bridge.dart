import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Native platform bridge for enhanced hardware communication
/// Provides abstraction layer for different platforms (Android, iOS, Windows, Linux, macOS)
class NativeBridge {
  static const MethodChannel _channel = MethodChannel('enhanced_chameleon_bridge');
  
  static StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  /// Stream of events from native platform
  static Stream<Map<String, dynamic>> get eventStream => _eventController.stream;
  
  /// Initialize the native bridge
  static Future<bool> initialize() async {
    try {
      _channel.setMethodCallHandler(_handleMethodCall);
      final bool result = await _channel.invokeMethod('initialize');
      return result;
    } on PlatformException catch (e) {
      print('Failed to initialize native bridge: ${e.message}');
      return false;
    }
  }
  
  /// Handle method calls from native platform
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onDeviceConnected':
        _eventController.add({
          'type': 'device_connected',
          'data': call.arguments,
        });
        break;
      case 'onDeviceDisconnected':
        _eventController.add({
          'type': 'device_disconnected',
          'data': call.arguments,
        });
        break;
      case 'onDataReceived':
        _eventController.add({
          'type': 'data_received',
          'data': call.arguments,
        });
        break;
      case 'onNfcTagDetected':
        _eventController.add({
          'type': 'nfc_tag_detected',
          'data': call.arguments,
        });
        break;
      case 'onError':
        _eventController.add({
          'type': 'error',
          'data': call.arguments,
        });
        break;
      default:
        print('Unknown method call: ${call.method}');
    }
  }
  
  /// Get available serial ports
  static Future<List<String>> getAvailablePorts() async {
    try {
      final List<dynamic> ports = await _channel.invokeMethod('getAvailablePorts');
      return ports.cast<String>();
    } on PlatformException catch (e) {
      print('Failed to get available ports: ${e.message}');
      return [];
    }
  }
  
  /// Connect to device
  static Future<bool> connectToDevice(String port, int baudRate) async {
    try {
      final bool result = await _channel.invokeMethod('connectToDevice', {
        'port': port,
        'baudRate': baudRate,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to connect to device: ${e.message}');
      return false;
    }
  }
  
  /// Disconnect from device
  static Future<bool> disconnectFromDevice() async {
    try {
      final bool result = await _channel.invokeMethod('disconnectFromDevice');
      return result;
    } on PlatformException catch (e) {
      print('Failed to disconnect from device: ${e.message}');
      return false;
    }
  }
  
  /// Send command to device
  static Future<String> sendCommand(String command, {int timeout = 5000}) async {
    try {
      final String result = await _channel.invokeMethod('sendCommand', {
        'command': command,
        'timeout': timeout,
      });
      return result;
    } on PlatformException catch (e) {
      throw Exception('Command failed: ${e.message}');
    }
  }
  
  /// Send raw data to device
  static Future<bool> sendRawData(List<int> data) async {
    try {
      final bool result = await _channel.invokeMethod('sendRawData', {
        'data': data,
      });
      return result;
    } on PlatformException catch (e) {
      print('Failed to send raw data: ${e.message}');
      return false;
    }
  }
  
  /// Auto-detect Chameleon Ultra device
  static Future<String?> autoDetectDevice() async {
    try {
      final String? result = await _channel.invokeMethod('autoDetectDevice');
      return result;
    } on PlatformException catch (e) {
      print('Auto-detection failed: ${e.message}');
      return null;
    }
  }
  
  /// Get device information
  static Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getDeviceInfo');
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get device info: ${e.message}');
      return null;
    }
  }
  
  /// Check if NFC is available
  static Future<bool> isNfcAvailable() async {
    try {
      final bool result = await _channel.invokeMethod('isNfcAvailable');
      return result;
    } on PlatformException catch (e) {
      print('Failed to check NFC availability: ${e.message}');
      return false;
    }
  }
  
  /// Enable NFC reading
  static Future<bool> enableNfcReading() async {
    try {
      final bool result = await _channel.invokeMethod('enableNfcReading');
      return result;
    } on PlatformException catch (e) {
      print('Failed to enable NFC reading: ${e.message}');
      return false;
    }
  }
  
  /// Disable NFC reading
  static Future<bool> disableNfcReading() async {
    try {
      final bool result = await _channel.invokeMethod('disableNfcReading');
      return result;
    } on PlatformException catch (e) {
      print('Failed to disable NFC reading: ${e.message}');
      return false;
    }
  }
  
  /// Get platform-specific capabilities
  static Future<Map<String, bool>> getCapabilities() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getCapabilities');
      return Map<String, bool>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get capabilities: ${e.message}');
      return {
        'serial_communication': false,
        'usb_host': false,
        'nfc': false,
        'bluetooth': false,
      };
    }
  }
  
  /// Dispose resources
  static void dispose() {
    _eventController.close();
  }
}

/// Platform-specific implementations
class PlatformUtils {
  /// Check if running on mobile platform
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  
  /// Check if running on desktop platform
  static bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  
  /// Get platform name
  static String get platformName {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    return 'Unknown';
  }
  
  /// Get default serial ports for platform
  static List<String> get defaultSerialPorts {
    if (Platform.isWindows) {
      return ['COM1', 'COM2', 'COM3', 'COM4', 'COM5', 'COM6', 'COM7', 'COM8'];
    } else if (Platform.isLinux || Platform.isMacOS) {
      return [
        '/dev/ttyUSB0',
        '/dev/ttyUSB1',
        '/dev/ttyACM0',
        '/dev/ttyACM1',
        '/dev/cu.usbserial-*',
        '/dev/cu.usbmodem*',
      ];
    } else {
      return [];
    }
  }
  
  /// Get recommended baud rates
  static List<int> get standardBaudRates => [
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    460800,
    921600,
  ];
}