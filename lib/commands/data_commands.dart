import 'command_base.dart';

/// Data manipulation and utility commands
/// Compatible with Proxmark3 Iceman firmware

class DataHexPrintCommand extends CommandBase {
  @override
  String get command => 'data hexprint';

  @override
  String get category => 'Data';

  @override
  String get description => 'Print data as hex dump';

  @override
  List<String> get aliases => ['data hex'];

  @override
  Map<String, String> get parameters => {
    'data': 'Hex data to print',
    'offset': 'Start offset (default: 0)',
    'length': 'Number of bytes to print'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: No data provided',
        data: {'error': 'Missing data parameter'}
      );
    }

    String hexData = args[0].replaceAll(' ', '');
    int offset = args.length > 1 ? int.tryParse(args[1]) ?? 0 : 0;
    int? length = args.length > 2 ? int.tryParse(args[2]) : null;

    if (hexData.length % 2 != 0) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid hex data (odd length)',
        data: {'error': 'Invalid hex format'}
      );
    }

    List<int> bytes = [];
    for (int i = 0; i < hexData.length; i += 2) {
      String byteStr = hexData.substring(i, i + 2);
      int? byte = int.tryParse(byteStr, radix: 16);
      if (byte == null) {
        return CommandResult(
          success: false,
          output: 'Error: Invalid hex character in: $byteStr',
          data: {'error': 'Invalid hex data'}
        );
      }
      bytes.add(byte);
    }

    int startIdx = offset;
    int endIdx = length != null ? offset + length : bytes.length;
    endIdx = endIdx.clamp(0, bytes.length);

    StringBuffer output = StringBuffer();
    output.writeln('Hex dump of ${endIdx - startIdx} bytes:');
    output.writeln('Offset | 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F | ASCII');
    output.writeln('-------|------------------------------------------------|------------------');

    for (int i = startIdx; i < endIdx; i += 16) {
      String offsetStr = i.toRadixString(16).padLeft(6, '0').toUpperCase();
      StringBuffer hexLine = StringBuffer();
      StringBuffer asciiLine = StringBuffer();

      for (int j = 0; j < 16; j++) {
        if (i + j < endIdx) {
          int byte = bytes[i + j];
          hexLine.write('${byte.toRadixString(16).padLeft(2, '0').toUpperCase()} ');
          asciiLine.write(byte >= 32 && byte <= 126 ? String.fromCharCode(byte) : '.');
        } else {
          hexLine.write('   ');
          asciiLine.write(' ');
        }
      }

      output.writeln('$offsetStr | ${hexLine.toString().trimRight()} | ${asciiLine.toString()}');
    }

    return CommandResult(
      success: true,
      output: output.toString(),
      data: {
        'hex_data': hexData,
        'bytes_processed': endIdx - startIdx,
        'offset': offset
      }
    );
  }

  @override
  String getHelp() {
    return '''
Usage: data hexprint <hex_data> [offset] [length]

Print hex data as formatted hex dump with ASCII representation.

Parameters:
  hex_data  Hex string to print (spaces optional)
  offset    Start offset in bytes (default: 0)
  length    Number of bytes to print (default: all)

Examples:
  data hexprint 48656c6c6f20576f726c64
  data hexprint "48 65 6c 6c 6f 20 57 6f 72 6c 64"
  data hexprint deadbeefcafebabe 0 4
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String hex = args[0].replaceAll(' ', '');
    return hex.length % 2 == 0 && RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex);
  }
}

class DataDecimalCommand extends CommandBase {
  @override
  String get command => 'data dec';

  @override
  String get category => 'Data';

  @override
  String get description => 'Convert hex to decimal';

  @override
  List<String> get aliases => ['data decimal'];

  @override
  Map<String, String> get parameters => {
    'hex': 'Hex value to convert'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: No hex value provided',
        data: {'error': 'Missing hex parameter'}
      );
    }

    String hexStr = args[0].replaceAll(' ', '').replaceAll('0x', '');
    
    try {
      int decimal = int.parse(hexStr, radix: 16);
      return CommandResult(
        success: true,
        output: '''
Hex: 0x${hexStr.toUpperCase()}
Dec: $decimal
Bin: ${decimal.toRadixString(2)}''',
        data: {
          'hex': hexStr,
          'decimal': decimal,
          'binary': decimal.toRadixString(2)
        }
      );
    } catch (e) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid hex value: $hexStr',
        data: {'error': 'Invalid hex format'}
      );
    }
  }

  @override
  String getHelp() {
    return '''
Usage: data dec <hex_value>

Convert hexadecimal value to decimal and binary.

Parameters:
  hex_value  Hex value to convert (with or without 0x prefix)

Examples:
  data dec ff
  data dec 0x1234
  data dec deadbeef
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String hex = args[0].replaceAll(' ', '').replaceAll('0x', '');
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
  }
}

class DataBinaryCommand extends CommandBase {
  @override
  String get command => 'data bin';

  @override
  String get category => 'Data';

  @override
  String get description => 'Convert hex to binary';

  @override
  List<String> get aliases => ['data binary'];

  @override
  Map<String, String> get parameters => {
    'hex': 'Hex value to convert to binary'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.isEmpty) {
      return CommandResult(
        success: false,
        output: 'Error: No hex value provided',
        data: {'error': 'Missing hex parameter'}
      );
    }

    String hexStr = args[0].replaceAll(' ', '').replaceAll('0x', '');
    
    try {
      StringBuffer binaryOutput = StringBuffer();
      binaryOutput.writeln('Hex to Binary conversion:');
      binaryOutput.writeln('Input: 0x${hexStr.toUpperCase()}');
      
      String fullBinary = '';
      for (int i = 0; i < hexStr.length; i++) {
        int nibble = int.parse(hexStr[i], radix: 16);
        String nibbleBinary = nibble.toRadixString(2).padLeft(4, '0');
        fullBinary += nibbleBinary;
      }
      
      binaryOutput.writeln('Binary: $fullBinary');
      binaryOutput.writeln('Length: ${fullBinary.length} bits');
      
      // Format binary in groups of 8
      StringBuffer formatted = StringBuffer();
      for (int i = 0; i < fullBinary.length; i += 8) {
        int end = (i + 8 < fullBinary.length) ? i + 8 : fullBinary.length;
        formatted.write(fullBinary.substring(i, end));
        if (end < fullBinary.length) formatted.write(' ');
      }
      binaryOutput.writeln('Formatted: $formatted');
      
      return CommandResult(
        success: true,
        output: binaryOutput.toString(),
        data: {
          'hex': hexStr,
          'binary': fullBinary,
          'bits': fullBinary.length
        }
      );
    } catch (e) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid hex value: $hexStr',
        data: {'error': 'Invalid hex format'}
      );
    }
  }

  @override
  String getHelp() {
    return '''
Usage: data bin <hex_value>

Convert hexadecimal value to binary representation.

Parameters:
  hex_value  Hex value to convert (with or without 0x prefix)

Examples:
  data bin ff
  data bin 0x1234
  data bin deadbeef
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.isEmpty) return false;
    String hex = args[0].replaceAll(' ', '').replaceAll('0x', '');
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex);
  }
}

class DataXorCommand extends CommandBase {
  @override
  String get command => 'data xor';

  @override
  String get category => 'Data';

  @override
  String get description => 'XOR two hex values';

  @override
  List<String> get aliases => [];

  @override
  Map<String, String> get parameters => {
    'data1': 'First hex value',
    'data2': 'Second hex value or single byte to XOR with all bytes'
  };

  @override
  Future<CommandResult> execute(List<String> args, CommandContext context) async {
    if (args.length < 2) {
      return CommandResult(
        success: false,
        output: 'Error: Two hex values required',
        data: {'error': 'Missing parameters'}
      );
    }

    String hex1 = args[0].replaceAll(' ', '');
    String hex2 = args[1].replaceAll(' ', '');

    if (hex1.length % 2 != 0 || hex2.length % 2 != 0) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid hex data (odd length)',
        data: {'error': 'Invalid hex format'}
      );
    }

    try {
      List<int> bytes1 = [];
      for (int i = 0; i < hex1.length; i += 2) {
        bytes1.add(int.parse(hex1.substring(i, i + 2), radix: 16));
      }

      List<int> bytes2 = [];
      for (int i = 0; i < hex2.length; i += 2) {
        bytes2.add(int.parse(hex2.substring(i, i + 2), radix: 16));
      }

      List<int> result = [];
      
      if (bytes2.length == 1) {
        // XOR all bytes with single byte
        int xorByte = bytes2[0];
        for (int byte in bytes1) {
          result.add(byte ^ xorByte);
        }
      } else {
        // XOR corresponding bytes
        int minLength = bytes1.length < bytes2.length ? bytes1.length : bytes2.length;
        for (int i = 0; i < minLength; i++) {
          result.add(bytes1[i] ^ bytes2[i]);
        }
      }

      String resultHex = result.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();

      return CommandResult(
        success: true,
        output: '''
XOR Operation:
Data 1: ${hex1.toUpperCase()}
Data 2: ${hex2.toUpperCase()}
Result: $resultHex''',
        data: {
          'input1': hex1,
          'input2': hex2,
          'result': resultHex
        }
      );
    } catch (e) {
      return CommandResult(
        success: false,
        output: 'Error: Invalid hex data',
        data: {'error': 'Invalid hex format'}
      );
    }
  }

  @override
  String getHelp() {
    return '''
Usage: data xor <hex1> <hex2>

Perform XOR operation on two hex values.

Parameters:
  hex1  First hex value
  hex2  Second hex value (or single byte to XOR with all bytes of hex1)

Examples:
  data xor ff00ff00 00ff00ff     # XOR two equal-length values
  data xor deadbeef ff           # XOR all bytes with 0xff
  data xor 123456 ab             # XOR with single byte
    ''';
  }

  @override
  bool validateArgs(List<String> args) {
    if (args.length < 2) return false;
    String hex1 = args[0].replaceAll(' ', '');
    String hex2 = args[1].replaceAll(' ', '');
    return hex1.length % 2 == 0 && hex2.length % 2 == 0 &&
           RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex1) &&
           RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex2);
  }
}