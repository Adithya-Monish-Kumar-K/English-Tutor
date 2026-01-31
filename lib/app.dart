import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/settings_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/chat_screen.dart';

class TranslatorAIApp extends StatelessWidget {
  const TranslatorAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'English Tutor - ஆங்கில ஆசிரியர்',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: settings.isFirstLaunch
              ? const WelcomeScreen()
              : const ChatScreen(),
        );
      },
    );
  }
}
