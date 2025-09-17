import 'command_base.dart';
import 'hw_commands.dart';
import 'lf_commands.dart';
import 'hf_commands.dart';
import 'data_commands.dart';
import 'chameleon_commands.dart';

/// Registry for all Proxmark3-style commands
class CommandRegistry {
  static final CommandRegistry _instance = CommandRegistry._internal();
  factory CommandRegistry() => _instance;
  CommandRegistry._internal();

  final Map<String, CommandBase> _commands = {};
  final Map<String, List<CommandBase>> _categories = {};

  /// Initialize all commands
  void initialize() {
    _registerCommands();
  }

  void _registerCommands() {
    // Hardware commands
    _register(HwVersionCommand());
    _register(HwTuneCommand());
    _register(HwStatusCommand());

    // Low Frequency commands
    _register(LfSearchCommand());
    _register(LfHidReadCommand());
    _register(LfHidCloneCommand());
    _register(LfEm410xReadCommand());
    _register(LfEm410xCloneCommand());
    _register(LfT55xxReadCommand());
    _register(LfT55xxWriteCommand());

    // High Frequency commands
    _register(HfSearchCommand());
    _register(Hf14aInfoCommand());
    _register(Hf14aReadCommand());
    _register(Hf14aSimCommand());
    _register(HfMfRdblCommand());
    _register(HfMfWrblCommand());
    _register(HfMfDumpCommand());
    _register(HfMfRestoreCommand());

    // Data commands
    _register(DataClearCommand());
    _register(DataPlotCommand());
    _register(DataSaveCommand());
    _register(DataLoadCommand());
    _register(DataHexCommand());

    // Chameleon Ultra specific commands
    _register(ChameleonSlotCommand());
    _register(ChameleonLedCommand());
    _register(ChameleonBatteryCommand());
    _register(ChameleonConfigCommand());
  }

  void _register(CommandBase command) {
    _commands[command.command] = command;

    // Register aliases
    for (String alias in command.aliases) {
      _commands[alias] = command;
    }

    // Add to category
    if (!_categories.containsKey(command.category)) {
      _categories[command.category] = [];
    }
    if (!_categories[command.category]!.contains(command)) {
      _categories[command.category]!.add(command);
    }
  }

  /// Get command by name
  CommandBase? getCommand(String name) {
    return _commands[name];
  }

  /// Get all commands in a category
  List<CommandBase> getCommandsInCategory(String category) {
    return _categories[category] ?? [];
  }

  /// Get all categories
  List<String> getCategories() {
    return _categories.keys.toList()..sort();
  }

  /// Get all command names
  List<String> getAllCommandNames() {
    return _commands.keys.toList()..sort();
  }

  /// Parse command line input
  ParsedCommand? parseCommand(String input) {
    final parts = input.trim().split(RegExp(r'\\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return null;
    }

    final commandName = parts.first.toLowerCase();
    final args = parts.skip(1).toList();

    final command = getCommand(commandName);
    if (command == null) {
      return null;
    }

    return ParsedCommand(command, args);
  }

  /// Get command suggestions for autocomplete
  List<String> getSuggestions(String input) {
    final suggestions = <String>[];
    final lowerInput = input.toLowerCase();

    for (String commandName in _commands.keys) {
      if (commandName.startsWith(lowerInput)) {
        suggestions.add(commandName);
      }
    }

    return suggestions..sort();
  }

  /// Get help text for all commands or specific category
  String getHelp([String? category]) {
    if (category == null) {
      final buffer = StringBuffer();
      buffer.writeln('Available command categories:');
      for (String cat in getCategories()) {
        final commands = getCommandsInCategory(cat);
        buffer.writeln('  $cat - ${commands.length} commands');
      }
      buffer.writeln('\\nUse "help <category>" for category-specific help');
      buffer.writeln('Use "<command> help" for command-specific help');
      return buffer.toString();
    }

    final commands = getCommandsInCategory(category);
    if (commands.isEmpty) {
      return 'Unknown category: $category';
    }

    final buffer = StringBuffer();
    buffer.writeln('Commands in category "$category":');
    for (CommandBase command in commands) {
      buffer.writeln('  ${command.command} - ${command.description}');
    }
    return buffer.toString();
  }
}

/// Parsed command with arguments
class ParsedCommand {
  final CommandBase command;
  final List<String> args;

  ParsedCommand(this.command, this.args);
}