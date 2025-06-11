import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showIcons;
  final List<Widget>? customActions;
  final String? title;

  const CustomAppBar({
    super.key,
    this.showIcons = true,
    this.customActions,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUnreadCount();
  }

  Future<void> fetchUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final myId = prefs.getString('userId');
    if (myId == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('chats').get();

    int count = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final lastSender = data['lastSenderId'];
      final seenBy = List<String>.from(data['seenBy'] ?? []);

      if (lastSender != myId && !seenBy.contains(myId)) {
        count++;
      }
    }

    setState(() {
      unreadCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFF600A),
      elevation: 0.5,
      centerTitle: true,
      title:
          widget.title != null
              ? Text(
                widget.title!,
                style: const TextStyle(
                  fontFamily: 'NotoSansArabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              )
              : null,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset('assets/images/logo_without_bg.png'),
      ),
      actions:
          widget.customActions ??
          (widget.showIcons
              ? [
                IconButtonWithBadge(
                  unreadCount: unreadCount,
                  onTap: () {
                    Navigator.pushNamed(context, '/my-messages');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    Navigator.pushNamed(context, '/search');
                  },
                ),
              ]
              : []),
    );
  }
}

class IconButtonWithBadge extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onTap;

  const IconButtonWithBadge({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(icon: const Icon(Icons.message_rounded), onPressed: onTap),
        if (unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              child: Text(
                unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
