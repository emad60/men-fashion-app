import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
 
  final List<Map<String, String>> notifications = [
    {
      'title': 'Order Shipped',
      'body': 'Your order #12345 has been shipped and is on its way.',
      'timestamp': '10 mins ago'
    },
    {
      'title': 'New Offer',
      'body': 'Enjoy 20% off on your next purchase. Limited time offer!',
      'timestamp': '1 hour ago'
    },
    {
      'title': 'Account Update',
      'body': 'Your account details were updated successfully.',
      'timestamp': 'Yesterday'
    },
    {
      'title': 'New Message',
      'body': 'You have received a new message from Customer Support.',
      'timestamp': '2 days ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: notifications.isEmpty
          ? Center(child: Text('No notifications yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    title: Text(
                      notification['title']!,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification['body']!),
                          SizedBox(height: 6),
                          Text(
                            notification['timestamp']!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
