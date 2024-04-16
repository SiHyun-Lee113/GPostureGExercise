import 'package:flutter/material.dart';

class DefaultLayout extends StatelessWidget {
  final Widget child;
  final String? title;

  const DefaultLayout({
    super.key,
    required this.child,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: renderAppbar(),
      body: child,
    );
  }

  AppBar? renderAppbar() {
    if (title == null) {
      return null;
    } else {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title!,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        foregroundColor: Colors.black,
      );
    }
  }
}
