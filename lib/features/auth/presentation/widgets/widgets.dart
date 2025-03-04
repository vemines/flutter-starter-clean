import 'package:flutter/material.dart';

import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/num_extension.dart';

class AuthSafeWrap extends StatelessWidget {
  final Widget child;
  const AuthSafeWrap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(maxWidth: 450),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          decoration: BoxDecoration(
            border:
                context.isMobile ? null : Border.all(color: context.colorScheme.onSurfaceVariant),
            borderRadius: 8.radius,
            color: context.colorScheme.surfaceBright,
          ),
          child: child,
        ),
      ),
    );
  }
}

class SocialSignin extends StatelessWidget {
  final void Function()? onPressed;
  final Widget icon;
  final String text;
  const SocialSignin({super.key, this.onPressed, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: TextButton.styleFrom(
        maximumSize: const Size(300, 60),
        backgroundColor: const Color(0xFFEDEEF0),
        padding: 10.eiAll,
      ),
      child: Padding(
        padding: 10.eiAll,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            icon,
            Text(text, style: context.textTheme.bodyLarge!.copyWith(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class AuthActionButton extends StatelessWidget {
  final String text;
  final void Function()? onPressed;
  const AuthActionButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(double.infinity, 55),
        backgroundColor: const Color(0xFF265AE8),
      ),
      child: Text(text, style: context.textTheme.bodyLarge!.copyWith(color: Colors.white)),
    );
  }
}
