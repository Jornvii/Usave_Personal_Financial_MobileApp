import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/notification_db.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool loading = false;
  List<Map<String, String>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void clearNotifications() async {
    final db = NotificationDB();
    await db.deleteAllNotifications();
    _loadNotifications();
    print("All notifications deleted successfully.");
  }

  Future<void> _loadNotifications() async {
    final notificationDB = NotificationDB();
    final notificationsFromDB = await notificationDB.getNotifications();

    setState(() {
      notifications = notificationsFromDB.map((n) {
        return {
          'message': n['message'] as String,
          'time': n['time'] as String,
          'id': n['id'].toString(),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            label: const Text("Clear All"),
            onPressed: clearNotifications,
            icon: const Icon(Icons.delete, color: Colors.red),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        padding: const EdgeInsets.all(2),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final id = int.parse(notification['id']!);

          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              _showDeleteConfirmation(id);
              return false;
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: NotificationCard(
              message: notification['message']!,
              time: notification['time']!,
            ),
          );
        },
      ),
    );
  }

  void _deleteNotification(int id) async {
    final notificationDB = NotificationDB();
    final result = await notificationDB.deleteNotification(id);
    if (result > 0) {
      setState(() {
        notifications
            .removeWhere((notification) => notification['id'] == id.toString());
      });
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Notification"),
        content:
            const Text("Are you sure you want to delete this notification?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _deleteNotification(id);
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.message,
    required this.time,
  });

  @override
  _NotificationCardState createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final displayMessage = widget.message.length > 100 && !_isExpanded
        ? '${widget.message.substring(0, 60)} ...'
        : widget.message;

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color.fromARGB(112, 139, 195, 74),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: _formatText(displayMessage),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.time,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  if (widget.message.length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? "Read Less" : "Read More",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _formatText(String text) {
    final boldPattern = RegExp(r'\*\*(.*?)\*\*');
    final bulletPattern = RegExp(r'^\* (.*?)');
    final spans = <TextSpan>[];

    if (bulletPattern.hasMatch(text)) {
      final match = bulletPattern.firstMatch(text);
      spans.add(TextSpan(
        text: '• ${match?.group(1)}',
        style: const TextStyle(fontWeight: FontWeight.normal),
      ));
    } else {
      int lastIndex = 0;
      final matches = boldPattern.allMatches(text);
      for (final match in matches) {
        if (match.start > lastIndex) {
          spans.add(TextSpan(
            text: text.substring(lastIndex, match.start),
            style: const TextStyle(fontWeight: FontWeight.normal),
          ));
        }
        spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        lastIndex = match.end;
      }
      if (lastIndex < text.length) {
        spans.add(TextSpan(
          text: text.substring(lastIndex),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ));
      }
    }
    return TextSpan(
      children: spans,
      style: const TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}
