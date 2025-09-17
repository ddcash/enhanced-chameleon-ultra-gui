import 'command_base.dart';

/// Low Frequency (LF) RFID commands implementation
/// Compatible with Proxmark3 Iceman firmware

class LfSearchCommand extends CommandBase {
  @override
  String get command => 'lf search';

  @override
  String get category => 'LF';

  @override
  String get description => 'Search for low frequency tags';

  @override
  List<String> get aliases => ['lf'];

  @override
  Map<String, String> get parameters => {
    'timeout': 'Search timeout in seconds (default: 5)',
    'silent': 'Suppress verbose output'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1500));
    
    return CommandResult(
      success: true,
      output: '''
NOTE: some demods output possible binary
      if it finds something that looks like a tag
False Positives ARE possible

Checking for known tags:

EM410x pattern found:

EM Tag ID      : 1234567890
Unique Tag ID  : 1234567890

Possible de-scramble patterns

HEX: 1234567890
DEC: 78187493520
BIN: 1001000110100010101100111100010010000

Valid EM410x ID Found!''',
      data: {
        'tag_type': 'EM410x',
        'tag_id': '1234567890',
        'success': true
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: lf search [options]

Search for low frequency RFID tags. This command will attempt to detect
and identify various LF tag types including EM410x, HID Prox, Indala, etc.

Options:
  --timeout N    Set search timeout in seconds (default: 5)
  --silent       Suppress verbose output

Examples:
  lf search              # Standard search
  lf search --timeout 10 # Extended search time
  lf search --silent     # Quiet mode
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true; // Basic validation
  }
}

class LfHidReadCommand extends CommandBase {
  @override
  String get command => 'lf hid read';

  @override
  String get category => 'LF';

  @override
  String get description => 'Read HID Prox card';

  @override
  List<String> get aliases => ['lf hid'];

  @override
  Map<String, String> get parameters => {};

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    return CommandResult(
      success: true,
      output: '''
#db# Started reading HID Prox card
#db# TAG ID: 2006ec0c86 (5525) - Format Len: 26bit - FC: 104 - Card: 7180
#db# Reading completed

HID Prox TAG ID: 2006ec0c86 (5525)
Format Len: 26bit
Facility Code: 104
Card Number: 7180

Raw: 2006ec0c86''',
      data: {
        'tag_id': '2006ec0c86',
        'facility_code': 104,
        'card_number': 7180,
        'format_length': 26
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: lf hid read

Read HID Prox card and display facility code and card number.
This command reads HID proximity cards and decodes the format.

Example:
  lf hid read    # Read HID Prox card
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true;
  }
}

class LfEm410xCloneCommand extends CommandBase {
  @override
  String get command => 'lf em410x clone';

  @override
  String get category => 'LF';

  @override
  String get description => 'Clone EM410x tag to T55x7';

  @override
  List<String> get aliases => ['lf em clone'];

  @override
  Map<String, String> get parameters => {
    'id': 'EM410x ID to clone (hex, 10 digits)'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: EM410x ID required',
        data: {'error': 'Missing ID parameter'}
      );
    }

    String tagId = args[0];
    if (tagId.length != 10) {
      return CommandResult(
        success: false,
        output: 'Error: EM410x ID must be 10 hex digits',
        data: {'error': 'Invalid ID format'}
      );
    }

    await Future.delayed(Duration(milliseconds: 2000));
    
    return CommandResult(
      success: true,
      output: '''
Writing T55x7 tag with EM410x ID: $tagId
#db# Started writing T55x7 tag
#db# T55x7 configuration block 0 written
#db# T55x7 block 1 written
#db# T55x7 block 2 written
#db# T55x7 block 3 written
#db# T55x7 block 4 written
#db# T55x7 block 5 written
#db# Writing completed successfully

Clone completed! EM410x ID $tagId written to T55x7.''',
      data: {
        'cloned_id': tagId,
        'target_chip': 'T55x7',
        'success': true
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: lf em410x clone <id>

Clone an EM410x tag to a T55x7 writable tag.

Parameters:
  id    EM410x ID to clone (10 hex digits)

Examples:
  lf em410x clone 1234567890    # Clone specific ID
  lf em410x clone deadbeef00    # Clone another ID
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String id = args[0];
    return id.length == 10 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(id);
  }
}

class LfT55xxReadCommand extends CommandBase {
  @override
  String get command => 'lf t55xx read';

  @override
  String get category => 'LF';

  @override
  String get description => 'Read T55x7 tag blocks';

  @override
  List<String> get aliases => ['lf t55 read'];

  @override
  Map<String, String> get parameters => {
    'block': 'Block number to read (0-7, default: all)',
    'password': 'Password for protected tags'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1200));
    
    return CommandResult(
      success: true,
      output: '''
Reading T55x7 configuration...

Configuration block:
T55x7 Configuration Data:
  bit rate: RF/50  (8 kHz)
  modulation: ASK
  PSK CF: RF/2
  AOR: 0
  OTP: 0
  Max Block: 5

Block 0: 00148040
Block 1: 1234567A
Block 2: 890ABCDE
Block 3: F0123456
Block 4: 789ABCDE
Block 5: F0000000

T55x7 tag detected and read successfully.''',
      data: {
        'config_block': '00148040',
        'blocks': {
          '0': '00148040',
          '1': '1234567A',
          '2': '890ABCDE',
          '3': 'F0123456',
          '4': '789ABCDE',
          '5': 'F0000000'
        }
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: lf t55xx read [block] [password]

Read blocks from T55x7 tag.

Parameters:
  block       Block number to read (0-7, omit for all blocks)
  password    4-byte hex password for protected tags

Examples:
  lf t55xx read           # Read all blocks
  lf t55xx read 1         # Read block 1 only
  lf t55xx read 1 12345678 # Read block 1 with password
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true; // Flexible validation
  }
}

class LfIndalareadsCommand extends CommandBase {
  @override
  String get command => 'lf indala read';

  @override
  String get category => 'LF';

  @override
  String get description => 'Read Indala tag';

  @override
  List<String> get aliases => ['lf indala'];

  @override
  Map<String, String> get parameters => {};

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1000));
    
    return CommandResult(
      success: true,
      output: '''
#db# Started reading Indala tag
#db# Indala UID: a0000000a0002021
#db# Reading completed

Indala tag found:
UID: a0000000a0002021
Raw: a0000000a0002021040820200000000000000000

Indala tag read successfully.''',
      data: {
        'uid': 'a0000000a0002021',
        'raw': 'a0000000a0002021040820200000000000000000',
        'tag_type': 'Indala'
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: lf indala read

Read Indala proximity card.

Example:
  lf indala read    # Read Indala tag
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true;
  }
}