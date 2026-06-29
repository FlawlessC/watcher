import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.isWide,
  });

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isWide ? 'W A T C H E R' : 'WATCHER',
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          style: TextStyle(
            fontSize: isWide ? 34 : 42,
            fontWeight: FontWeight.w500,
            letterSpacing: isWide ? 8 : 6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 1,
              width: isWide ? 160 : 130,
              color: Colors.redAccent,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '◇',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 18,
                  height: 1,
                ),
              ),
            ),
            Container(
              height: 1,
              width: isWide ? 160 : 130,
              color: Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }
}
