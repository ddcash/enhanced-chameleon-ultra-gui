import 'dart:async';

/// Base class for all Proxmark3-style commands
abstract class CommandBase {
  String get command;
  String get category;
  String get description;
  List<String> get aliases;
  Map<String, String> get parameters;

  Future<CommandResult> execute(List<String> args, CommandContext context);
  String getHelp();
  bool validateArgs(List<String> args);
}

/// Result of command execution
class CommandResult {
  final bool success;
  final String output;
  final String? error;
  final Map<String, dynamic>? data;

  CommandResult({
    required this.success,
    required this.output,
    this.error,
    this.data,
  });

  CommandResult.success(String output, {Map<String, dynamic>? data})
      : success = true,
        output = output,
        error = null,
        data = data;

  CommandResult.error(String error, {String? output})
      : success = false,
        output = output ?? '',
        error = error,
        data = null;
}

/// Context for command execution
class CommandContext {
  final dynamic connector;
  final dynamic communicator;
  final Function(String) outputCallback;
  final Function(String) errorCallback;

  CommandContext({
    required this.connector,
    required this.communicator,
    required this.outputCallback,
    required this.errorCallback,
  });
}

/// Command categories matching Proxmark3 structure
enum CommandCategory {
  hardware('hw', 'Hardware commands'),
  lowFrequency('lf', 'Low Frequency RFID commands'),
  highFrequency('hf', 'High Frequency RFID/NFC commands'),
  data('data', 'Data manipulation commands'),
  utils('utils', 'Utility commands'),
  chameleon('chameleon', 'Chameleon Ultra specific commands');

  const CommandCategory(this.prefix, this.description);

  final String prefix;
  final String description;
}