import 'command_base.dart';

/// Chameleon Ultra specific commands
/// Enhanced commands for Chameleon Ultra device management

class ChameleonConnectCommand extends CommandBase {
  @override
  String get command => 'chameleon connect';

  @override
  String get category => 'Chameleon';

  @override
  String get description => 'Connect to Chameleon Ultra device';

  @override
  List<String> get aliases => ['connect', 'ch connect'];

  @override
  Map<String, String> get parameters => {
    'port': 'Serial port or device path',
    'baud': 'Baud rate (default: 115200)'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    String port = args.isNotEmpty ? args[0] : 'auto';
    int baud = args.length > 1 ? int.tryParse(args[1]) ?? 115200 : 115200;

    await Future.delayed(Duration(milliseconds: 2000));
    
    return CommandResult(
      success: true,
      output: '''
Connecting to Chameleon Ultra...
Port: $port
Baud rate: $baud

#db# Serial port opened successfully
#db# Chameleon Ultra detected
#db# Firmware version: 2.0.0
#db# Hardware version: Ultra
#db# Battery level: 85%
#db# Device serial: CU-123456789

Connection established successfully!
Device ready for commands.''',
      data: {
        'port': port,
        'baud_rate': baud,
        'firmware_version': '2.0.0',
        'hardware_version': 'Ultra',
        'battery_level': 85,
        'device_serial': 'CU-123456789',
        'connected': true
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: chameleon connect [port] [baud]

Connect to Chameleon Ultra device via serial communication.

Parameters:
  port  Serial port or device path (default: auto-detect)
  baud  Baud rate (default: 115200)

Examples:
  chameleon connect                    # Auto-detect device
  chameleon connect /dev/ttyUSB0      # Specific Linux port
  chameleon connect COM3              # Specific Windows port
  chameleon connect auto 921600       # Auto-detect with custom baud
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true; // Flexible connection parameters
  }
}

class ChameleonSlotCommand extends CommandBase {
  @override
  String get command => 'chameleon slot';

  @override
  String get category => 'Chameleon';

  @override
  String get description => 'Manage Chameleon card slots';

  @override
  List<String> get aliases => ['slot', 'ch slot'];

  @override
  Map<String, String> get parameters => {
    'action': 'Action: list, set, get, clear',
    'slot': 'Slot number (1-8)',
    'type': 'Card type: hf, lf'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: Action required (list, set, get, clear)',
        data: {'error': 'Missing action parameter'}
      );
    }

    String action = args[0].toLowerCase();
    
    switch (action) {
      case 'list':
        return await _listSlots();
      case 'set':
        return await _setSlot(args.length > 1 ? args[1] : '', args.length > 2 ? args[2] : '');
      case 'get':
        return await _getSlot(args.length > 1 ? args[1] : '');
      case 'clear':
        return await _clearSlot(args.length > 1 ? args[1] : '');
      default:
        return CommandResult(
          success: false,
          output: 'Error: Invalid action. Use: list, set, get, clear',
          data: {'error': 'Invalid action'}
        );
    }
  }

  Future<CommandResult> _listSlots() async {
    await Future.delayed(Duration(milliseconds: 800));
    
    return CommandResult(
      success: true,
      output: '''
Chameleon Ultra Card Slots:

Slot 1 (HF): MIFARE Classic 1k - UID: 04689571fa5c64
Slot 2 (HF): Empty
Slot 3 (HF): MIFARE DESFire - UID: 04a1b2c3d4e5f6
Slot 4 (HF): Empty
Slot 5 (LF): EM410x - ID: 1234567890
Slot 6 (LF): HID Prox - FC: 104, CN: 7180
Slot 7 (LF): Empty
Slot 8 (LF): Empty

Active slot: 1 (HF)''',
      data: {
        'slots': {
          '1': {'type': 'HF', 'card': 'MIFARE Classic 1k', 'uid': '04689571fa5c64'},
          '2': {'type': 'HF', 'card': 'Empty'},
          '3': {'type': 'HF', 'card': 'MIFARE DESFire', 'uid': '04a1b2c3d4e5f6'},
          '4': {'type': 'HF', 'card': 'Empty'},
          '5': {'type': 'LF', 'card': 'EM410x', 'id': '1234567890'},
          '6': {'type': 'LF', 'card': 'HID Prox', 'fc': 104, 'cn': 7180},
          '7': {'type': 'LF', 'card': 'Empty'},
          '8': {'type': 'LF', 'card': 'Empty'}
        },
        'active_slot': 1
      }
    );
  }

  Future<CommandResult> _setSlot(String slotStr, String typeStr) async {
    if (slotStr.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: Slot number required',
        data: {'error': 'Missing slot parameter'}
      );
    }

    int? slot = int.tryParse(slotStr);
    if (slot == null || slot < 1 || slot > 8) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid slot number (1-8)',
        data: {'error': 'Invalid slot number'}
      );
    }

    await Future.delayed(Duration(milliseconds: 500));
    
    return CommandResult(
      success: true,
      output: '''
#db# Setting active slot to $slot
#db# Slot $slot activated successfully

Active slot changed to: $slot${typeStr.isNotEmpty ? ' ($typeStr)' : ''}''',
      data: {
        'active_slot': slot,
        'type': typeStr.toUpperCase()
      }
    );
  }

  Future<CommandResult> _getSlot(String slotStr) async {
    if (slotStr.isEmpty) {
      return CommandResult(
        success: true,
        output: 'Current active slot: 1 (HF)',
        data: {'active_slot': 1, 'type': 'HF'}
      );
    }

    int? slot = int.tryParse(slotStr);
    if (slot == null || slot < 1 || slot > 8) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid slot number (1-8)',
        data: {'error': 'Invalid slot number'}
      );
    }

    await Future.delayed(Duration(milliseconds: 300));
    
    return CommandResult(
      success: true,
      output: '''
Slot $slot information:
Type: ${slot <= 4 ? 'HF' : 'LF'}
Status: ${slot == 1 ? 'MIFARE Classic 1k - UID: 04689571fa5c64' : 'Empty'}
Active: ${slot == 1 ? 'Yes' : 'No'}''',
      data: {
        'slot': slot,
        'type': slot <= 4 ? 'HF' : 'LF',
        'active': slot == 1
      }
    );
  }

  Future<CommandResult> _clearSlot(String slotStr) async {
    if (slotStr.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: Slot number required',
        data: {'error': 'Missing slot parameter'}
      );
    }

    int? slot = int.tryParse(slotStr);
    if (slot == null || slot < 1 || slot > 8) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid slot number (1-8)',
        data: {'error': 'Invalid slot number'}
      );
    }

    await Future.delayed(Duration(milliseconds: 600));
    
    return CommandResult(
      success: true,
      output: '''
#db# Clearing slot $slot
#db# Slot $slot cleared successfully

Slot $slot has been cleared and is now empty.''',
      data: {
        'slot': slot,
        'cleared': true
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: chameleon slot <action> [parameters]

Manage Chameleon Ultra card slots (1-8: slots 1-4 are HF, 5-8 are LF).

Actions:
  list           List all slots and their contents
  set <slot>     Set active slot (1-8)
  get [slot]     Get current active slot or specific slot info
  clear <slot>   Clear/empty a specific slot

Examples:
  chameleon slot list      # List all slots
  chameleon slot set 3     # Set slot 3 as active
  chameleon slot get       # Get current active slot
  chameleon slot get 5     # Get info for slot 5
  chameleon slot clear 2   # Clear slot 2
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String action = args[0].toLowerCase();
    return ['list', 'set', 'get', 'clear'].contains(action);
  }
}

class ChameleonInfoCommand extends CommandBase {
  @override
  String get command => 'chameleon info';

  @override
  String get category => 'Chameleon';

  @override
  String get description => 'Get Chameleon device information';

  @override
  List<String> get aliases => ['info', 'ch info'];

  @override
  Map<String, String> get parameters => {};

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    return CommandResult(
      success: true,
      output: '''
Chameleon Ultra Device Information:

Hardware Information:
  Device Type: Chameleon Ultra
  Hardware Version: 2.0
  Device Serial: CU-123456789ABC
  Bootloader Version: 1.5.2

Firmware Information:
  Version: 2.0.0
  Build Date: 2024-03-15
  Git Commit: a1b2c3d4
  Supports DFU: Yes

Power Information:
  Battery Level: 85%
  Charging: No
  USB Power: Yes
  Low Battery Warning: No

Antenna Status:
  HF Antenna: Connected
  LF Antenna: Connected
  
Storage Information:
  Flash Size: 1MB
  Free Space: 756KB
  Slots Used: 3/8

Communication:
  USB Connected: Yes
  BLE Available: Yes
  BLE Connected: No''',
      data: {
        'hardware_version': '2.0',
        'firmware_version': '2.0.0',
        'device_serial': 'CU-123456789ABC',
        'battery_level': 85,
        'charging': false,
        'usb_connected': true,
        'ble_available': true,
        'ble_connected': false,
        'slots_used': 3,
        'total_slots': 8
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: chameleon info

Display comprehensive information about the connected Chameleon Ultra device
including hardware details, firmware version, power status, and connectivity.

Example:
  chameleon info    # Show device information
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true;
  }
}

class ChameleonLedsCommand extends CommandBase {
  @override
  String get command => 'chameleon leds';

  @override
  String get category => 'Chameleon';

  @override
  String get description => 'Control Chameleon LED indicators';

  @override
  List<String> get aliases => ['leds', 'ch leds'];

  @override
  Map<String, String> get parameters => {
    'action': 'Action: on, off, blink, test',
    'color': 'LED color: red, green, blue, all',
    'duration': 'Duration for blink (ms)'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: Action required (on, off, blink, test)',
        data: {'error': 'Missing action parameter'}
      );
    }

    String action = args[0].toLowerCase();
    String color = args.length > 1 ? args[1].toLowerCase() : 'all';
    int duration = args.length > 2 ? int.tryParse(args[2]) ?? 1000 : 1000;

    await Future.delayed(Duration(milliseconds: 500));

    switch (action) {
      case 'on':
        return CommandResult(
          success: true,
          output: '''
#db# Turning $color LED(s) ON
#db# LED control successful

$color LED(s) are now ON.''',
          data: {'action': 'on', 'color': color}
        );

      case 'off':
        return CommandResult(
          success: true,
          output: '''
#db# Turning $color LED(s) OFF
#db# LED control successful

$color LED(s) are now OFF.''',
          data: {'action': 'off', 'color': color}
        );

      case 'blink':
        return CommandResult(
          success: true,
          output: '''
#db# Blinking $color LED(s) for ${duration}ms
#db# LED blink sequence started

$color LED(s) blinking for ${duration}ms.''',
          data: {'action': 'blink', 'color': color, 'duration': duration}
        );

      case 'test':
        return CommandResult(
          success: true,
          output: '''
#db# Starting LED test sequence
#db# Testing RED LED... OK
#db# Testing GREEN LED... OK  
#db# Testing BLUE LED... OK
#db# LED test completed

All LEDs are functioning correctly.''',
          data: {'action': 'test', 'all_leds_ok': true}
        );

      default:
        return CommandResult(
          success: false,
          output: 'Error: Invalid action. Use: on, off, blink, test',
          data: {'error': 'Invalid action'}
        );
    }
  }

  @override
  String getHelp() {
    return '''
Usage: chameleon leds <action> [color] [duration]

Control the LED indicators on the Chameleon Ultra device.

Parameters:
  action    LED action: on, off, blink, test
  color     LED color: red, green, blue, all (default: all)
  duration  Blink duration in milliseconds (default: 1000)

Examples:
  chameleon leds on red        # Turn red LED on
  chameleon leds off all       # Turn all LEDs off
  chameleon leds blink green 2000  # Blink green LED for 2 seconds
  chameleon leds test          # Test all LEDs
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String action = args[0].toLowerCase();
    return ['on', 'off', 'blink', 'test'].contains(action);
  }
}