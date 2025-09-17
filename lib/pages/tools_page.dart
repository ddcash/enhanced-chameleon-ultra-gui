import 'package:flutter/material.dart';

class ToolsPage extends StatefulWidget {
  @override
  _ToolsPageState createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RFID Tools'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // HF Tools Section
          _buildSectionHeader('High Frequency (HF) Tools'),
          _buildToolCard(
            'HF Search',
            'Search for 13.56MHz tags',
            Icons.search,
            () => _runHfSearch(),
          ),
          _buildToolCard(
            'MIFARE Tools',
            'Read, write, dump MIFARE cards',
            Icons.credit_card,
            () => _openMifareTools(),
          ),
          _buildToolCard(
            'ISO14443-A Info',
            'Get detailed tag information',
            Icons.info,
            () => _getHfInfo(),
          ),
          
          SizedBox(height: 16),
          
          // LF Tools Section
          _buildSectionHeader('Low Frequency (LF) Tools'),
          _buildToolCard(
            'LF Search',
            'Search for 125kHz tags',
            Icons.search,
            () => _runLfSearch(),
          ),
          _buildToolCard(
            'EM410x Tools',
            'Read and clone EM410x cards',
            Icons.nfc,
            () => _openEm410xTools(),
          ),
          _buildToolCard(
            'HID Prox Tools',
            'Read HID proximity cards',
            Icons.badge,
            () => _openHidTools(),
          ),
          _buildToolCard(
            'T55x7 Tools',
            'Read/write T55x7 chips',
            Icons.memory,
            () => _openT55x7Tools(),
          ),
          
          SizedBox(height: 16),
          
          // Data Tools Section
          _buildSectionHeader('Data Tools'),
          _buildToolCard(
            'Hex Viewer',
            'View and analyze hex data',
            Icons.visibility,
            () => _openHexViewer(),
          ),
          _buildToolCard(
            'Data Converter',
            'Convert between hex, dec, binary',
            Icons.transform,
            () => _openDataConverter(),
          ),
          _buildToolCard(
            'XOR Calculator',
            'Perform XOR operations on data',
            Icons.calculate,
            () => _openXorCalculator(),
          ),
          
          SizedBox(height: 16),
          
          // Chameleon Tools Section
          _buildSectionHeader('Chameleon Tools'),
          _buildToolCard(
            'Device Info',
            'Get Chameleon device information',
            Icons.device_hub,
            () => _getChameleonInfo(),
          ),
          _buildToolCard(
            'LED Control',
            'Control device LEDs',
            Icons.lightbulb,
            () => _openLedControl(),
          ),
          _buildToolCard(
            'Slot Manager',
            'Advanced slot management',
            Icons.storage,
            () => _openSlotManager(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildToolCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
  
  void _runHfSearch() {
    _showToolDialog('HF Search', 'Searching for high frequency tags...\n\nThis would execute: hf search');
  }
  
  void _openMifareTools() {
    _showToolDialog('MIFARE Tools', 'MIFARE card operations:\n\n• Read blocks\n• Write blocks\n• Dump card\n• Clone card');
  }
  
  void _getHfInfo() {
    _showToolDialog('HF Info', 'Getting tag information...\n\nThis would execute: hf 14a info');
  }
  
  void _runLfSearch() {
    _showToolDialog('LF Search', 'Searching for low frequency tags...\n\nThis would execute: lf search');
  }
  
  void _openEm410xTools() {
    _showToolDialog('EM410x Tools', 'EM410x operations:\n\n• Read EM410x\n• Clone to T55x7\n• Simulate card');
  }
  
  void _openHidTools() {
    _showToolDialog('HID Prox Tools', 'HID Proximity operations:\n\n• Read HID card\n• Clone card\n• Decode format');
  }
  
  void _openT55x7Tools() {
    _showToolDialog('T55x7 Tools', 'T55x7 operations:\n\n• Read configuration\n• Write blocks\n• Detect card\n• Wipe card');
  }
  
  void _openHexViewer() {
    _showToolDialog('Hex Viewer', 'View data in hex format with ASCII representation.\n\nFeatures:\n• Hex dump display\n• ASCII preview\n• Copy data');
  }
  
  void _openDataConverter() {
    _showToolDialog('Data Converter', 'Convert between different number formats:\n\n• Hex to Decimal\n• Decimal to Binary\n• Binary to Hex');
  }
  
  void _openXorCalculator() {
    _showToolDialog('XOR Calculator', 'Perform XOR operations on hex data:\n\n• XOR two values\n• XOR with single byte\n• Batch operations');
  }
  
  void _getChameleonInfo() {
    _showToolDialog('Chameleon Info', 'Device information:\n\nFirmware: 2.0.0\nHardware: Ultra\nBattery: 85%\nSerial: CU-123456789');
  }
  
  void _openLedControl() {
    _showToolDialog('LED Control', 'Control device LEDs:\n\n• Turn LEDs on/off\n• Blink patterns\n• Color selection\n• Test sequence');
  }
  
  void _openSlotManager() {
    Navigator.pushNamed(context, '/cards');
  }
  
  void _showToolDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}