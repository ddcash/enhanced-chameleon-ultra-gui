import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _autoConnect = true;
  bool _enableNotifications = true;
  bool _verboseLogging = false;
  String _selectedPort = 'Auto-detect';
  int _baudRate = 115200;
  
  final List<String> _availablePorts = [
    'Auto-detect',
    'COM1',
    'COM2',
    'COM3',
    '/dev/ttyUSB0',
    '/dev/ttyUSB1',
  ];
  
  final List<int> _baudRates = [
    9600,
    19200,
    38400,
    57600,
    115200,
    230400,
    460800,
    921600,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Connection Settings
          _buildSectionHeader('Connection'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Auto-connect on startup'),
                  subtitle: Text('Automatically connect to device when app starts'),
                  trailing: Switch(
                    value: _autoConnect,
                    onChanged: (value) {
                      setState(() {
                        _autoConnect = value;
                      });
                    },
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Serial Port'),
                  subtitle: Text('Select communication port'),
                  trailing: DropdownButton<String>(
                    value: _selectedPort,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedPort = newValue;
                        });
                      }
                    },
                    items: _availablePorts.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Baud Rate'),
                  subtitle: Text('Communication speed'),
                  trailing: DropdownButton<int>(
                    value: _baudRate,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _baudRate = newValue;
                        });
                      }
                    },
                    items: _baudRates.map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // App Settings
          _buildSectionHeader('Application'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Dark Mode'),
                  subtitle: Text('Use dark theme'),
                  trailing: Switch(
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Notifications'),
                  subtitle: Text('Show app notifications'),
                  trailing: Switch(
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() {
                        _enableNotifications = value;
                      });
                    },
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Verbose Logging'),
                  subtitle: Text('Enable detailed debug output'),
                  trailing: Switch(
                    value: _verboseLogging,
                    onChanged: (value) {
                      setState(() {
                        _verboseLogging = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Command Settings
          _buildSectionHeader('Commands'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Command Timeout'),
                  subtitle: Text('Timeout for command execution (seconds)'),
                  trailing: Container(
                    width: 60,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: '10'),
                    ),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Command History'),
                  subtitle: Text('Maximum number of commands to remember'),
                  trailing: Container(
                    width: 60,
                    child: TextField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: '100'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // About Section
          _buildSectionHeader('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Version'),
                  subtitle: Text('2.0.0+0'),
                  leading: Icon(Icons.info_outline),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Build'),
                  subtitle: Text('Enhanced Chameleon Ultra GUI'),
                  leading: Icon(Icons.build),
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Compatibility'),
                  subtitle: Text('Proxmark3 Iceman firmware compatible'),
                  leading: Icon(Icons.check_circle_outline),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Action Buttons
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text('Reset to Defaults'),
                  leading: Icon(Icons.restore),
                  onTap: _resetToDefaults,
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Export Settings'),
                  leading: Icon(Icons.file_download),
                  onTap: _exportSettings,
                ),
                Divider(height: 1),
                ListTile(
                  title: Text('Import Settings'),
                  leading: Icon(Icons.file_upload),
                  onTap: _importSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
  
  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Settings'),
        content: Text('This will reset all settings to their default values. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _darkMode = false;
                _autoConnect = true;
                _enableNotifications = true;
                _verboseLogging = false;
                _selectedPort = 'Auto-detect';
                _baudRate = 115200;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
  
  void _exportSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality not yet implemented')),
    );
  }
  
  void _importSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Import functionality not yet implemented')),
    );
  }
}