import 'command_base.dart';

/// High Frequency (HF) RFID commands implementation
/// Compatible with Proxmark3 Iceman firmware

class HfSearchCommand extends CommandBase {
  @override
  String get command => 'hf search';

  @override
  String get category => 'HF';

  @override
  String get description => 'Search for high frequency tags';

  @override
  List<String> get aliases => ['hf'];

  @override
  Map<String, String> get parameters => {
    'timeout': 'Search timeout in seconds (default: 5)',
    'silent': 'Suppress verbose output'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1800));
    
    return CommandResult(
      success: true,
      output: '''
#db# Searching for high frequency tags...

UID : 04 68 95 71 fa 5c 64
ATQA : 00 44
SAK : 20
Type: NXP MIFARE DESFire EV1 4k
proprietary non iso14443-4 card found, RATS not supported

14a card found, UID: 04689571fa5c64
Type: MIFARE Classic compatible
Prng detection: weak

Valid ISO14443A tag found!''',
      data: {
        'uid': '04689571fa5c64',
        'atqa': '0044',
        'sak': '20',
        'type': 'MIFARE DESFire EV1 4k',
        'success': true
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: hf search [options]

Search for high frequency RFID tags (13.56 MHz). This command will attempt 
to detect and identify various HF tag types including MIFARE, DESFire, etc.

Options:
  --timeout N    Set search timeout in seconds (default: 5)
  --silent       Suppress verbose output

Examples:
  hf search              # Standard search
  hf search --timeout 10 # Extended search time
  hf search --silent     # Quiet mode
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true;
  }
}

class Hf14aInfoCommand extends CommandBase {
  @override
  String get command => 'hf 14a info';

  @override
  String get category => 'HF';

  @override
  String get description => 'Get ISO14443-A tag information';

  @override
  List<String> get aliases => ['hf 14a'];

  @override
  Map<String, String> get parameters => {};

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    await Future.delayed(Duration(milliseconds: 1200));
    
    return CommandResult(
      success: true,
      output: '''
#db# Getting ISO14443-A tag info...

UID : 04 68 95 71 fa 5c 64
ATQA : 00 44
SAK : 20
TYPE : NXP MIFARE DESFire EV1 4k
proprietary non iso14443-4 card found, RATS not supported

Fingerprinting based on ATQA/SAK values:
TYPE : MIFARE Classic compatible
MANUFACTURER : NXP Semiconductors
PRNG detection: weak

Card is selected. You can now start sending commands.''',
      data: {
        'uid': '04689571fa5c64',
        'atqa': '0044',
        'sak': '20',
        'manufacturer': 'NXP Semiconductors',
        'type': 'MIFARE DESFire EV1 4k',
        'prng': 'weak'
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: hf 14a info

Get detailed information about an ISO14443-A tag including UID, ATQA, SAK,
manufacturer information, and card type detection.

Example:
  hf 14a info    # Get tag information
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true;
  }
}

class HfMfDumpCommand extends CommandBase {
  @override
  String get command => 'hf mf dump';

  @override
  String get category => 'HF';

  @override
  String get description => 'Dump MIFARE Classic card';

  @override
  List<String> get aliases => ['hf mf'];

  @override
  Map<String, String> get parameters => {
    'k': 'Key (12 hex digits)',
    'keytype': 'Key type (A or B, default: A)',
    'filename': 'Output filename'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    String key = 'ffffffffffff'; // Default key
    String keyType = 'A';
    String filename = 'mifare_dump.bin';

    // Parse arguments
    for (int i = 0; i < args.length; i++) {
      if (args[i] == 'k' && i + 1 < args.length) {
        key = args[i + 1];
        i++;
      } else if (args[i] == 'keytype' && i + 1 < args.length) {
        keyType = args[i + 1].toUpperCase();
        i++;
      } else if (args[i] == 'f' && i + 1 < args.length) {
        filename = args[i + 1];
        i++;
      }
    }

    await Future.delayed(Duration(milliseconds: 3000));
    
    return CommandResult(
      success: true,
      output: '''
#db# Dumping MIFARE Classic card...
#db# Using key: $key (type $keyType)

Sector 0:
[0] 04 68 95 71 fa 5c 64 81 15 08 04 00 01 24 d4 c5
[1] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[2] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[3] ff ff ff ff ff ff ff 07 80 69 ff ff ff ff ff ff

Sector 1:
[4] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[5] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[6] 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
[7] ff ff ff ff ff ff ff 07 80 69 ff ff ff ff ff ff

... (continuing for all sectors)

#db# Dump completed successfully!
#db# Data saved to: $filename
#db# Total bytes: 1024

MIFARE Classic 1k dump completed.
File saved: $filename''',
      data: {
        'key_used': key,
        'key_type': keyType,
        'filename': filename,
        'bytes_dumped': 1024,
        'card_type': 'MIFARE Classic 1k'
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: hf mf dump [k <key>] [keytype <A|B>] [f <filename>]

Dump MIFARE Classic card to file.

Parameters:
  k <key>       Key to use (12 hex digits, default: ffffffffffff)
  keytype <A|B> Key type (default: A)
  f <filename>  Output filename (default: mifare_dump.bin)

Examples:
  hf mf dump                           # Use default key
  hf mf dump k ffffffffffff           # Specify key
  hf mf dump k 123456789abc keytype B  # Use key B
  hf mf dump f mycard.bin              # Custom filename
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    return true; // Flexible validation
  }
}

class HfMfReadCommand extends CommandBase {
  @override
  String get command => 'hf mf rdbl';

  @override
  String get category => 'HF';

  @override
  String get description => 'Read MIFARE Classic block';

  @override
  List<String> get aliases => ['hf mf read'];

  @override
  Map<String, String> get parameters => {
    'block': 'Block number to read',
    'key': 'Key (12 hex digits)',
    'keytype': 'Key type (A or B)'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: Block number required',
        data: {'error': 'Missing block parameter'}
      );
    }

    int blockNum = int.tryParse(args[0]) ?? 0;
    String key = args.length > 1 ? args[1] : 'ffffffffffff';
    String keyType = args.length > 2 ? args[2].toUpperCase() : 'A';

    await Future.delayed(Duration(milliseconds: 800));
    
    return CommandResult(
      success: true,
      output: '''
#db# Reading block $blockNum with key $key (type $keyType)

Block $blockNum: 04 68 95 71 fa 5c 64 81 15 08 04 00 01 24 d4 c5

Read completed successfully.''',
      data: {
        'block': blockNum,
        'data': '04689571fa5c648115080400012404c5',
        'key_used': key,
        'key_type': keyType
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: hf mf rdbl <block> [key] [keytype]

Read a single block from MIFARE Classic card.

Parameters:
  block     Block number to read (0-63 for 1k, 0-255 for 4k)
  key       Key to use (12 hex digits, default: ffffffffffff)
  keytype   Key type A or B (default: A)

Examples:
  hf mf rdbl 0                    # Read block 0 with default key
  hf mf rdbl 4 123456789abc      # Read block 4 with custom key
  hf mf rdbl 4 123456789abc B    # Read block 4 with key B
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    int? blockNum = int.tryParse(args[0]);
    return blockNum != null && blockNum >= 0;
  }
}

class HfMfWriteCommand extends CommandBase {
  @override
  String get command => 'hf mf wrbl';

  @override
  String get category => 'HF';

  @override
  String get description => 'Write MIFARE Classic block';

  @override
  List<String> get aliases => ['hf mf write'];

  @override
  Map<String, String> get parameters => {
    'block': 'Block number to write',
    'data': 'Data to write (32 hex digits)',
    'key': 'Key (12 hex digits)',
    'keytype': 'Key type (A or B)'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.length < 2) {
      return CommandResult(
        success: false,
        output: 'Error: Block number and data required',
        data: {'error': 'Missing parameters'}
      );
    }

    int blockNum = int.tryParse(args[0]) ?? 0;
    String data = args[1];
    String key = args.length > 2 ? args[2] : 'ffffffffffff';
    String keyType = args.length > 3 ? args[3].toUpperCase() : 'A';

    if (data.length != 32) {
      return CommandResult(
        success: false,
        output: 'Error: Data must be 32 hex digits (16 bytes)',
        data: {'error': 'Invalid data length'}
      );
    }

    await Future.delayed(Duration(milliseconds: 1000));
    
    return CommandResult(
      success: true,
      output: '''
#db# Writing block $blockNum with key $key (type $keyType)
#db# Data: $data

Block $blockNum written successfully.

WARNING: Block writing can permanently damage your card if you write
         incorrect data to sector trailers or manufacturer block!''',
      data: {
        'block': blockNum,
        'data': data,
        'key_used': key,
        'key_type': keyType
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: hf mf wrbl <block> <data> [key] [keytype]

Write a single block to MIFARE Classic card.

Parameters:
  block     Block number to write (0-63 for 1k, 0-255 for 4k)
  data      Data to write (32 hex digits = 16 bytes)
  key       Key to use (12 hex digits, default: ffffffffffff)
  keytype   Key type A or B (default: A)

WARNING: Be very careful when writing blocks! Incorrect data can brick your card.
         Never write to block 0 (manufacturer block) or sector trailers
         unless you know what you're doing!

Examples:
  hf mf wrbl 1 00000000000000000000000000000000  # Clear block 1
  hf mf wrbl 4 123456789abcdef0123456789abcdef 123456789abc  # Custom data and key
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.length < 2) return false;
    int? blockNum = int.tryParse(args[0]);
    if (blockNum == null || blockNum < 0) return false;
    String data = args[1];
    return data.length == 32 && RegExp(r'^[0-9a-fA-F]+$').hasMatch(data);
  }
}