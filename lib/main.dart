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
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
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
  ];

  final List<Widget> _pages = [
    const HomePage(),
    const TerminalPage(),
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
              ],
            ),
          );
        },
      ),
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