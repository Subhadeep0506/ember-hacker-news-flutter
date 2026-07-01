import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TappableUsername extends StatelessWidget {
  final String? username;
  final TextStyle? style;

  const TappableUsername({super.key, required this.username, this.style});

  @override
  Widget build(BuildContext context) {
    if (username == null || username!.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.push('/profile/$username'),
      child: Text(username ?? '', style: style),
    );
  }
}
