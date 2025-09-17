import 'package:flutter/material.dart';

class CardsPage extends StatefulWidget {
  @override
  _CardsPageState createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  int _activeSlot = 1;
  
  final List<Map<String, dynamic>> _slots = [
    {'id': 1, 'type': 'HF', 'card': 'MIFARE Classic 1k', 'uid': '04689571fa5c64', 'active': true},
    {'id': 2, 'type': 'HF', 'card': 'Empty', 'uid': null, 'active': false},
    {'id': 3, 'type': 'HF', 'card': 'MIFARE DESFire', 'uid': '04a1b2c3d4e5f6', 'active': false},
    {'id': 4, 'type': 'HF', 'card': 'Empty', 'uid': null, 'active': false},
    {'id': 5, 'type': 'LF', 'card': 'EM410x', 'uid': '1234567890', 'active': false},
    {'id': 6, 'type': 'LF', 'card': 'HID Prox', 'uid': 'FC:104 CN:7180', 'active': false},
    {'id': 7, 'type': 'LF', 'card': 'Empty', 'uid': null, 'active': false},
    {'id': 8, 'type': 'LF', 'card': 'Empty', 'uid': null, 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Card Slots'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshSlots,
            tooltip: 'Refresh Slots',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active slot indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.radio_button_checked, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Active Slot: $_activeSlot (${_slots[_activeSlot - 1]['type']})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          
          // Slots grid
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: _slots.length,
              itemBuilder: (context, index) {
                final slot = _slots[index];
                return _buildSlotCard(slot);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSlotCard(Map<String, dynamic> slot) {
    bool isEmpty = slot['card'] == 'Empty';
    bool isActive = slot['id'] == _activeSlot;
    
    return Card(
      elevation: isActive ? 8 : 2,
      color: isActive ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: () => _selectSlot(slot['id']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Slot header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Slot ${slot['id']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: slot['type'] == 'HF' ? Colors.blue : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      slot['type'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 8),
              
              // Card info
              if (isEmpty) ..[
                Icon(Icons.credit_card_off, size: 32, color: Colors.grey),
                SizedBox(height: 4),
                Text(
                  'Empty Slot',
                  style: TextStyle(color: Colors.grey),
                ),
              ] else ..[
                Icon(
                  slot['type'] == 'HF' ? Icons.nfc : Icons.radio,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(height: 4),
                Text(
                  slot['card'],
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (slot['uid'] != null) ..[
                  SizedBox(height: 2),
                  Text(
                    slot['uid'],
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
              
              Spacer(),
              
              // Action buttons
              if (!isEmpty) ..[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, size: 16),
                      onPressed: () => _editSlot(slot['id']),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: Icon(Icons.clear, size: 16),
                      onPressed: () => _clearSlot(slot['id']),
                      tooltip: 'Clear',
                    ),
                  ],
                ),
              ] else ..[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add, size: 20),
                      onPressed: () => _addCard(slot['id']),
                      tooltip: 'Add Card',
                    ),
                  ],
                ),
              ],
              
              // Active indicator
              if (isActive)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _selectSlot(int slotId) {
    setState(() {
      _activeSlot = slotId;
      // Update active status in slots
      for (var slot in _slots) {
        slot['active'] = slot['id'] == slotId;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slot $slotId activated'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _refreshSlots() {
    // Simulate refresh
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Slots refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _editSlot(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Slot $slotId'),
        content: Text('Edit functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _clearSlot(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Slot $slotId'),
        content: Text('Are you sure you want to clear this slot?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _slots[slotId - 1] = {
                  'id': slotId,
                  'type': slotId <= 4 ? 'HF' : 'LF',
                  'card': 'Empty',
                  'uid': null,
                  'active': slotId == _activeSlot,
                };
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Slot $slotId cleared')),
              );
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }
  
  void _addCard(int slotId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Card to Slot $slotId'),
        content: Text('Add card functionality would be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}