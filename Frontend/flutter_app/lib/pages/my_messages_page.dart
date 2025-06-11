import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMessagesPage extends StatefulWidget {
  const MyMessagesPage({super.key});

  @override
  State<MyMessagesPage> createState() => _MyMessagesPageState();
}

class _MyMessagesPageState extends State<MyMessagesPage> {
  String? myId;

  @override
  void initState() {
    super.initState();
    loadMyId();
  }

  Future<void> loadMyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (myId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الرسائل'),
          backgroundColor: Color(0xFFFF600A),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: myId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final chats = snapshot.data!.docs;

            if (chats.isEmpty) {
              return const Center(child: Text('لا توجد محادثات حالياً.'));
            }

            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                final users = List<String>.from(chat['users']);
                final otherUserId = users.firstWhere((id) => id != myId);

                final rawData = chat.data() as Map<String, dynamic>;
                final userNames =
                    rawData['userNames'] is Map
                        ? Map<String, dynamic>.from(rawData['userNames'])
                        : {};
                final otherUserName = userNames[otherUserId] ?? otherUserId;

                final lastMessage = rawData['lastMessage'] ?? '';
                final timestamp = rawData['timestamp'];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Text(
                        otherUserName.toString().substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF600A),
                        ),
                      ),
                    ),
                    title: Text(
                      otherUserName.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansArabic',
                      ),
                    ),
                    subtitle: Text(
                      lastMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'NotoSansArabic',
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      timestamp != null
                          ? timestamp.toDate().toLocal().toString().substring(
                            0,
                            16,
                          )
                          : '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'myId': myId,
                          'otherId': otherUserId,
                          'otherUserName': otherUserName,
                        },
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
