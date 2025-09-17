import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:xterm/xterm.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import '../commands/command_registry.dart';
import '../chameleon_connector.dart';

class TerminalPage extends StatefulWidget {
  @override
  _TerminalPageState createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  late Terminal terminal;
  late CommandRegistry commandRegistry;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  List<String> _commandHistory = [];
  int _historyIndex = -1;
  String _currentInput = '';
  bool _isProcessingCommand = false;

  @override
  void initState() {
    super.initState();
    terminal = Terminal(
      maxLines: 10000,
    );
    commandRegistry = CommandRegistry();
    _initializeTerminal();
  }

  void _initializeTerminal() {
    terminal.write('Enhanced Chameleon Ultra GUI Terminal\r\n');
    terminal.write('Compatible with Proxmark3 Iceman firmware\r\n');
    terminal.write('Type "help" for available commands\r\n');
    terminal.write('\r\n');
    _showPrompt();
  }

  void _showPrompt() {
    terminal.write('proxmark3> ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terminal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _clearTerminal,
            tooltip: 'Clear Terminal',
          ),
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: _showHelp,
            tooltip: 'Show Help',
          ),
        ],
      ),
      body: Column(
        children: [
          // Terminal output
          Expanded(
            child: Container(
              color: Colors.black,
              child: TerminalView(
                terminal,
                theme: TerminalThemes.defaultTheme,
                padding: EdgeInsets.all(8),
                textStyle: TextStyle(
                  fontFamily: 'Consolas, monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ),
          
          // Command input area
          Container(
            padding: EdgeInsets.all(8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                // Command prompt indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Text(
                    'proxmark3>',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                
                // Command input field
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    style: TextStyle(fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Enter command...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onSubmitted: _processCommand,
                    onChanged: _handleInputChange,
                    enabled: !_isProcessingCommand,
                  ),
                ),
                
                // Send button
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isProcessingCommand ? null : () => _processCommand(_inputController.text),
                  child: _isProcessingCommand 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.send),
                ),
              ],
            ),
          ),
          
          // Quick command buttons
          Container(
            padding: EdgeInsets.all(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickCommandButton('hw version', Icons.info_outline),
                  SizedBox(width: 8),
                  _buildQuickCommandButton('hf search', Icons.search),
                  SizedBox(width: 8),
                  _buildQuickCommandButton('lf search', Icons.search),
                  SizedBox(width: 8),
                  _buildQuickCommandButton('chameleon info', Icons.device_hub),
                  SizedBox(width: 8),
                  _buildQuickCommandButton('chameleon slot list', Icons.view_list),
                  SizedBox(width: 8),
                  _buildQuickCommandButton('help', Icons.help),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCommandButton(String command, IconData icon) {
    return ElevatedButton.icon(
      onPressed: _isProcessingCommand ? null : () {
        _inputController.text = command;
        _processCommand(command);
      },
      icon: Icon(icon, size: 16),
      label: Text(command, style: TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _handleInputChange(String value) {
    _currentInput = value;
    // TODO: Implement auto-completion suggestions
  }

  void _processCommand(String command) async {
    if (command.trim().isEmpty) return;

    setState(() {
      _isProcessingCommand = true;
    });

    // Add command to history
    if (_commandHistory.isEmpty || _commandHistory.last != command) {
      _commandHistory.add(command);
      if (_commandHistory.length > 100) {
        _commandHistory.removeAt(0);
      }
    }
    _historyIndex = -1;

    // Display command in terminal
    terminal.write('$command\r\n');

    try {
      // Process command through registry
      var result = await commandRegistry.executeCommand(command);
      
      // Display result
      if (result.output.isNotEmpty) {
        // Add colors for different types of output
        List<String> lines = result.output.split('\n');
        for (String line in lines) {
          if (line.startsWith('#db#')) {
            // Debug/device messages in cyan
            terminal.write('\x1b[36m$line\x1b[0m\r\n');
          } else if (line.contains('Error:') || line.contains('FAILED')) {
            // Error messages in red
            terminal.write('\x1b[31m$line\x1b[0m\r\n');
          } else if (line.contains('successful') || line.contains('OK') || line.contains('found')) {
            // Success messages in green
            terminal.write('\x1b[32m$line\x1b[0m\r\n');
          } else if (line.startsWith('UID:') || line.startsWith('Tag ID:') || line.contains('Block')) {
            // Important data in yellow
            terminal.write('\x1b[33m$line\x1b[0m\r\n');
          } else {
            // Regular output
            terminal.write('$line\r\n');
          }
        }
      }

      // Update device connection status if applicable
      if (result.data.containsKey('connected')) {
        context.read<ChameleonConnector>().updateConnectionStatus(result.data['connected']);
      }

    } catch (e) {
      terminal.write('\x1b[31mCommand execution error: $e\x1b[0m\r\n');
    }

    terminal.write('\r\n');
    _showPrompt();
    
    // Clear input and refocus
    _inputController.clear();
    _currentInput = '';
    
    setState(() {
      _isProcessingCommand = false;
    });
    
    // Refocus input field
    _inputFocusNode.requestFocus();
  }

  void _clearTerminal() {
    terminal.buffer.clear();
    _initializeTerminal();
  }

  void _showHelp() {
    terminal.write('\r\n');
    terminal.write('=== Enhanced Chameleon Ultra GUI Terminal Help ===\r\n');
    terminal.write('\r\n');
    terminal.write('Available command categories:\r\n');
    terminal.write('  hw       - Hardware commands (hw version, hw tune, hw status)\r\n');
    terminal.write('  hf       - High Frequency commands (hf search, hf 14a info, hf mf dump)\r\n');
    terminal.write('  lf       - Low Frequency commands (lf search, lf em410x clone, lf hid read)\r\n');
    terminal.write('  data     - Data manipulation (data hexprint, data dec, data xor)\r\n');
    terminal.write('  chameleon- Chameleon specific (chameleon connect, chameleon slot)\r\n');
    terminal.write('\r\n');
    terminal.write('Tips:\r\n');
    terminal.write('  - Type "help <command>" for detailed help on a specific command\r\n');
    terminal.write('  - Use Up/Down arrows to navigate command history\r\n');
    terminal.write('  - Use the quick command buttons for common operations\r\n');
    terminal.write('  - Commands are compatible with Proxmark3 Iceman firmware\r\n');
    terminal.write('\r\n');
    _showPrompt();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }
}

// Custom terminal view widget that handles keyboard input
class TerminalView extends StatefulWidget {
  final Terminal terminal;
  final TerminalTheme theme;
  final EdgeInsets padding;
  final TextStyle textStyle;

  const TerminalView(
    this.terminal, {
    Key? key,
    required this.theme,
    this.padding = EdgeInsets.zero,
    required this.textStyle,
  }) : super(key: key);

  @override
  _TerminalViewState createState() => _TerminalViewState();
}

class _TerminalViewState extends State<TerminalView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.terminal.onOutput = (_) {
      // Auto-scroll to bottom when new output arrives
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.terminal.buffer.lines.length,
        itemBuilder: (context, index) {
          final line = widget.terminal.buffer.lines[index];
          return SelectableText(
            line.toString(),
            style: widget.textStyle.copyWith(
              color: Colors.white,
              fontFamily: 'Consolas',
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}