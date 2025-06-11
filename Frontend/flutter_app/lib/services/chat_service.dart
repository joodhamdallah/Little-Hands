import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static String generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return sorted.join('_');
  }

  static Future<void> sendMessage({
    required String fromId,
    required String toId,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final chatId = generateChatId(fromId, toId);

    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    final chatDocRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId);

    final userType = prefs.getString('userType');
    final senderName =
        userType == "caregiver"
            ? prefs.getString('caregiverFullName') ?? "مستخدم"
            : prefs.getString('parentFullName') ?? "مستخدم";

    await messagesRef.add({
      'text': text,
      'senderId': fromId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await chatDocRef.set({
      'lastMessage': text,
      'lastSenderId': fromId,
      'timestamp': FieldValue.serverTimestamp(),
      'seenBy': [fromId],
      'users': [fromId, toId],
      'userNames': {fromId: senderName},
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot> getMessages(String fromId, String toId) {
    final chatId = generateChatId(fromId, toId);
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }
}
