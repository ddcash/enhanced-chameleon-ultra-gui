import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'bridge/chameleon_connector.dart';
import 'bridge/chameleon_communicator.dart';

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
        title: 'Chameleon Ultra GUI',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
        ],
        home: const HomePage(),
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
        title: const Text('Chameleon Ultra GUI'),
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
