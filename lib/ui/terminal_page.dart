import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart';
import 'package:provider/provider.dart';
import '../commands/command_registry.dart';
import '../bridge/chameleon_communicator.dart';
import '../bridge/chameleon_connector.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({Key? key}) : super(key: key);

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  late Terminal terminal;
  late CommandRegistry commandRegistry;
  final StringBuffer inputBuffer = StringBuffer();
  final List<String> commandHistory = [];
  int historyIndex = -1;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeTerminal();
    _initializeCommandRegistry();
  }

  void _initializeTerminal() {
    terminal = Terminal(
      maxLines: 10000,
    );

    // Set up terminal event handlers
    terminal.onOutput = (data) {
      // Handle terminal output if needed
    };

    terminal.onInput = (data) {
      _handleInput(data);
    };

    // Display welcome message
    _displayWelcomeMessage();
  }

  void _initializeCommandRegistry() {
    commandRegistry = CommandRegistry();
    commandRegistry.initialize();
  }

  void _displayWelcomeMessage() {
    final welcomeText = '''
[+] Chameleon Ultra GUI Terminal v2.0.0
[+] Proxmark3-compatible command interface
[+] Type 'help' for available commands
[+] Type 'help <category>' for category-specific help
[=]
''';

    terminal.write(welcomeText);
    _displayPrompt();
  }

  void _displayPrompt() {
    final connector = context.read<ChameleonConnector>();
    final status = connector.isConnected ? 'connected' : 'disconnected';
    terminal.write('pm3 [$status]> ');
  }

  void _handleInput(String data) {
    for (int i = 0; i < data.length; i++) {
      final char = data[i];
      final charCode = char.codeUnitAt(0);

      switch (charCode) {
        case 13: // Enter key
          _processCommand();
          break;
        case 8: // Backspace
        case 127: // Delete
          if (inputBuffer.isNotEmpty) {
            inputBuffer.length = inputBuffer.length - 1;
            terminal.write('\b \b'); // Clear character on screen
          }
          break;
        case 9: // Tab - autocomplete
          _handleAutocomplete();
          break;
        case 27: // Escape sequences (arrow keys)
          if (i + 2 < data.length && data[i + 1] == '[') {
            switch (data[i + 2]) {
              case 'A': // Up arrow
                _handleHistoryUp();
                i += 2;
                break;
              case 'B': // Down arrow
                _handleHistoryDown();
                i += 2;
                break;
              case 'C': // Right arrow
              case 'D': // Left arrow
                // Ignore for now
                i += 2;
                break;
            }
          }
          break;
        default:
          if (charCode >= 32 && charCode <= 126) {
            // Printable character
            inputBuffer.write(char);
            terminal.write(char);
          }
          break;
      }
    }
  }

  void _processCommand() async {
    final input = inputBuffer.toString().trim();
    inputBuffer.clear();

    terminal.write('\n');

    if (input.isEmpty) {
      _displayPrompt();
      return;
    }

    // Add to history
    if (commandHistory.isEmpty || commandHistory.last != input) {
      commandHistory.add(input);
      if (commandHistory.length > 100) {
        commandHistory.removeAt(0);
      }
    }
    historyIndex = -1;

    // Handle built-in commands
    if (await _handleBuiltInCommands(input)) {
      _displayPrompt();
      return;
    }

    // Parse and execute command
    final parsedCommand = commandRegistry.parseCommand(input);

    if (parsedCommand == null) {
      terminal.write('[-] Unknown command: ${input.split(' ').first}\n');
      terminal.write('[-] Type "help" for available commands\n');
      _displayPrompt();
      return;
    }

    // Check if device is connected for device commands
    final connector = context.read<ChameleonConnector>();
    if (!connector.isConnected && _requiresConnection(parsedCommand.command.category)) {
      terminal.write('[-] Device not connected. Connect to Chameleon Ultra first.\n');
      _displayPrompt();
      return;
    }

    // Execute command
    try {
      final communicator = context.read<ChameleonCommunicator>();
      final commandContext = CommandContext(
        connector: connector,
        communicator: communicator,
        outputCallback: (text) => terminal.write('$text\n'),
        errorCallback: (text) => terminal.write('[-] $text\n'),
      );

      final result = await parsedCommand.command.execute(
        parsedCommand.args,
        commandContext,
      );

      if (result.success) {
        terminal.write(result.output);
        if (result.output.isNotEmpty && !result.output.endsWith('\n')) {
          terminal.write('\n');
        }
      } else {
        terminal.write('[-] ${result.error}\n');
      }
    } catch (e) {
      terminal.write('[-] Command execution failed: $e\n');
    }

    _displayPrompt();
  }

  Future<bool> _handleBuiltInCommands(String input) async {
    final parts = input.toLowerCase().split(' ');
    final command = parts.first;

    switch (command) {
      case 'clear':
      case 'cls':
        terminal.clear();
        return true;

      case 'exit':
      case 'quit':
        Navigator.of(context).pop();
        return true;

      case 'help':
        if (parts.length > 1) {
          final category = parts[1];
          final help = commandRegistry.getHelp(category);
          terminal.write('$help\n');
        } else {
          _displayGeneralHelp();
        }
        return true;

      case 'history':
        _displayHistory();
        return true;

      case 'connect':
        await _handleConnect();
        return true;

      case 'disconnect':
        await _handleDisconnect();
        return true;

      case 'status':
        _displayConnectionStatus();
        return true;

      default:
        return false;
    }
  }

  void _displayGeneralHelp() {
    final help = commandRegistry.getHelp();
    final builtInHelp = '''

Built-in commands:
  help [category]  Show help for commands
  clear           Clear terminal screen
  connect         Connect to Chameleon Ultra
  disconnect      Disconnect from device
  status          Show connection status
  history         Show command history
  exit            Exit terminal

$help
''';

    terminal.write(builtInHelp);
  }

  void _displayHistory() {
    terminal.write('[+] Command history:\n');
    for (int i = 0; i < commandHistory.length; i++) {
      terminal.write('  ${i + 1}: ${commandHistory[i]}\n');
    }
  }

  Future<void> _handleConnect() async {
    final connector = context.read<ChameleonConnector>();

    if (connector.isConnected) {
      terminal.write('[=] Already connected\n');
      return;
    }

    terminal.write('[=] Connecting to Chameleon Ultra...\n');

    try {
      await connector.connectToDevice();
      terminal.write('[+] Connected successfully\n');
      setState(() {
        isConnected = true;
      });
    } catch (e) {
      terminal.write('[-] Connection failed: $e\n');
    }
  }

  Future<void> _handleDisconnect() async {
    final connector = context.read<ChameleonConnector>();

    if (!connector.isConnected) {
      terminal.write('[=] Not connected\n');
      return;
    }

    terminal.write('[=] Disconnecting...\n');

    try {
      await connector.disconnectDevice();
      terminal.write('[+] Disconnected\n');
      setState(() {
        isConnected = false;
      });
    } catch (e) {
      terminal.write('[-] Disconnect failed: $e\n');
    }
  }

  void _displayConnectionStatus() {
    final connector = context.read<ChameleonConnector>();

    terminal.write('[+] Connection Status:\n');
    terminal.write('[=] Connected: ${connector.isConnected ? "YES" : "NO"}\n');

    if (connector.isConnected) {
      terminal.write('[=] Device: ${connector.deviceName}\n');
      terminal.write('[=] Connection type: ${connector.connectionType}\n');
    }
  }

  void _handleAutocomplete() {
    final input = inputBuffer.toString();
    final suggestions = commandRegistry.getSuggestions(input);

    if (suggestions.isEmpty) {
      return;
    }

    if (suggestions.length == 1) {
      // Complete the command
      final completion = suggestions.first;
      final remaining = completion.substring(input.length);
      inputBuffer.write(remaining);
      terminal.write(remaining);
    } else {
      // Show suggestions
      terminal.write('\n');
      final suggestionText = suggestions.join('  ');
      terminal.write(suggestionText);
      terminal.write('\n');
      _displayPrompt();
      terminal.write(input);
    }
  }

  void _handleHistoryUp() {
    if (commandHistory.isEmpty) return;

    if (historyIndex == -1) {
      historyIndex = commandHistory.length - 1;
    } else if (historyIndex > 0) {
      historyIndex--;
    }

    _replaceCurrentInput(commandHistory[historyIndex]);
  }

  void _handleHistoryDown() {
    if (commandHistory.isEmpty || historyIndex == -1) return;

    if (historyIndex < commandHistory.length - 1) {
      historyIndex++;
      _replaceCurrentInput(commandHistory[historyIndex]);
    } else {
      historyIndex = -1;
      _replaceCurrentInput('');
    }
  }

  void _replaceCurrentInput(String newInput) {
    // Clear current input on screen
    for (int i = 0; i < inputBuffer.length; i++) {
      terminal.write('\b \b');
    }

    // Set new input
    inputBuffer.clear();
    inputBuffer.write(newInput);
    terminal.write(newInput);
  }

  bool _requiresConnection(String category) {
    return ['hw', 'lf', 'hf', 'chameleon'].contains(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxmark3 Terminal'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.green,
        actions: [
          Consumer<ChameleonConnector>(
            builder: (context, connector, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: Row(
                  children: [
                    Icon(
                      connector.isConnected
                          ? Icons.bluetooth_connected
                          : Icons.bluetooth_disabled,
                      color: connector.isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      connector.isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: connector.isConnected ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TerminalView(
                  terminal,
                  theme: TerminalTheme(
                    cursor: TerminalCursor.block,
                    selection: const TerminalSelectionTheme(
                      color: Color(0x40ffffff),
                    ),
                  ),
                  style: const TerminalStyle(
                    fontSize: 14,
                    fontFamily: 'RobotoMono',
                    color: Colors.green,
                    backgroundColor: Colors.black,
                  ),
                  autofocus: true,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[900],
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      terminal.clear();
                      _displayWelcomeMessage();
                    },
                    tooltip: 'Clear terminal',
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white70),
                    onPressed: () {
                      _displayHistory();
                      _displayPrompt();
                    },
                    tooltip: 'Show history',
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white70),
                    onPressed: () {
                      _handleBuiltInCommands('help');
                      _displayPrompt();
                    },
                    tooltip: 'Show help',
                  ),
                  const Spacer(),
                  Consumer<ChameleonConnector>(
                    builder: (context, connector, child) {
                      return ElevatedButton.icon(
                        onPressed: connector.isConnected
                            ? () => _handleBuiltInCommands('disconnect')
                            : () => _handleBuiltInCommands('connect'),
                        icon: Icon(
                          connector.isConnected
                              ? Icons.bluetooth_disabled
                              : Icons.bluetooth,
                        ),
                        label: Text(
                          connector.isConnected ? 'Disconnect' : 'Connect',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: connector.isConnected
                              ? Colors.red[700]
                              : Colors.blue[700],
                          foregroundColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    terminal.dispose();
    super.dispose();
  }
}
