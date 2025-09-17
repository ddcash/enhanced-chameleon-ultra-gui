import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'chameleon_connector.dart';
import 'chameleon_communicator.dart';

void main() {
  runApp(const ChameleonUltraApp());
}

class ChameleonUltraApp extends StatelessWidget {
  const ChameleonUltraApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChameleonConnector()),
        Provider(create: (_) => ChameleonCommunicator()),
      ],
      child: MaterialApp(
        title: 'Enhanced Chameleon Ultra GUI',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        home: const MainNavigationPage(),
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.terminal_outlined),
      selectedIcon: Icon(Icons.terminal),
      label: 'Terminal',
    ),
    const NavigationDestination(
      icon: Icon(Icons.credit_card_outlined),
      selectedIcon: Icon(Icons.credit_card),
      label: 'Cards',
    ),
    const NavigationDestination(
      icon: Icon(Icons.build_outlined),
      selectedIcon: Icon(Icons.build),
      label: 'Tools',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  final List<Widget> _pages = [
    const HomePage(),
    const TerminalPage(),
    const CardManagerPage(),
    const ToolsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: _destinations,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enhanced Chameleon Ultra GUI'),
      ),
      body: Consumer<ChameleonConnector>(
        builder: (context, connector, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  connector.isConnected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_disabled,
                  size: 64,
                  color: connector.isConnected ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  connector.isConnected
                      ? 'Connected to ${connector.deviceName}'
                      : 'Not Connected',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: connector.isConnected
                      ? () => connector.disconnectDevice()
                      : () => connector.connectToDevice(),
                  icon: Icon(
                    connector.isConnected
                        ? Icons.bluetooth_disabled
                        : Icons.bluetooth,
                  ),
                  label: Text(
                    connector.isConnected ? 'Disconnect' : 'Connect',
                  ),
                ),
                const SizedBox(height: 32),
                if (connector.isConnected) ...[
                  const Text('🚀 Enhanced Features:'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFeatureChip('Proxmark3 Terminal', Icons.terminal),
                      _buildFeatureChip('LF Operations', Icons.radio),
                      _buildFeatureChip('HF Operations', Icons.nfc),
                      _buildFeatureChip('Hardware Control', Icons.settings),
                      _buildFeatureChip('Data Analysis', Icons.analytics),
                      _buildFeatureChip('Slot Management', Icons.credit_card),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxmark3 Terminal'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terminal, size: 64),
            SizedBox(height: 16),
            Text('Proxmark3 Terminal Interface'),
            Text('Terminal functionality will be implemented here'),
          ],
        ),
      ),
    );
  }
}

class CardManagerPage extends StatelessWidget {
  const CardManagerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Manager'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.credit_card, size: 64),
            SizedBox(height: 16),
            Text('Card management features'),
            Text('Use Terminal for Proxmark3-style operations'),
          ],
        ),
      ),
    );
  }
}

class ToolsPage extends StatelessWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tools'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build, size: 64),
            SizedBox(height: 16),
            Text('Advanced tools'),
            Text('Use Terminal for full Proxmark3 compatibility'),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 64),
            SizedBox(height: 16),
            Text('Settings'),
            Text('Use "chameleon config" in Terminal'),
          ],
        ),
      ),
    );
  }
}