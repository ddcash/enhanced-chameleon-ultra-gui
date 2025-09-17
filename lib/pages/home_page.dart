import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chameleon_connector.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Chameleon Ultra GUI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<ChameleonConnector>(
        builder: (context, connector, child) {
          return Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Status Card
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              connector.isConnected ? Icons.link : Icons.link_off,
                              color: connector.isConnected ? Colors.green : Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Device Status',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          connector.isConnected ? 'Connected to Chameleon Ultra' : 'Not Connected',
                          style: TextStyle(
                            color: connector.isConnected ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (connector.isConnected) ..[
                          SizedBox(height: 8),
                          Text('Firmware: 2.0.0'),
                          Text('Hardware: Ultra'),
                          Text('Battery: 85%'),
                        ],
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Quick Actions
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  children: [
                    _buildActionCard(
                      context,
                      'Terminal',
                      'Open command terminal',
                      Icons.terminal,
                      () => Navigator.pushNamed(context, '/terminal'),
                    ),
                    _buildActionCard(
                      context,
                      'Card Slots',
                      'Manage card slots',
                      Icons.storage,
                      () => Navigator.pushNamed(context, '/cards'),
                    ),
                    _buildActionCard(
                      context,
                      'Tools',
                      'RFID tools & utilities',
                      Icons.build,
                      () => Navigator.pushNamed(context, '/tools'),
                    ),
                    _buildActionCard(
                      context,
                      'Settings',
                      'App configuration',
                      Icons.settings,
                      () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Recent Activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                
                Expanded(
                  child: Card(
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        _buildActivityItem('HF Search completed', '2 minutes ago'),
                        _buildActivityItem('MIFARE card detected', '5 minutes ago'),
                        _buildActivityItem('Slot 1 activated', '10 minutes ago'),
                        _buildActivityItem('Device connected', '15 minutes ago'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityItem(String activity, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Text(activity),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}