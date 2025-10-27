import 'package:flutter/material.dart';
import '../demo_globals.dart';

class DemoTopActions extends StatelessWidget {
  const DemoTopActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ValueListenableBuilder<bool>(
            valueListenable: DemoGlobals.loggingEnabled,
            builder: (context, enabled, _) => Row(
              children: [
                const Text('Logging'),
                Switch.adaptive(
                  value: enabled,
                  onChanged: (v) => DemoGlobals.setLogging(v),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ValueListenableBuilder<bool>(
            valueListenable: DemoGlobals.isLoggedIn,
            builder: (context, loggedIn, _) => Row(
              children: [
                const Text('Login'),
                Switch.adaptive(
                  value: loggedIn,
                  onChanged: (v) => DemoGlobals.setLogin(v),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

