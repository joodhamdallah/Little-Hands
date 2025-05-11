import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
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
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFF600A),
      elevation: 0.5,
      centerTitle: true,
      title:
          title != null
              ? Text(
                title!,
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
          customActions ??
          (showIcons
              ? [
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
