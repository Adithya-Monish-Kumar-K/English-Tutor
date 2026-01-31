import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/chat_provider.dart';
import 'providers/settings_provider.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storageService)),
        ChangeNotifierProxyProvider<SettingsProvider, ChatProvider>(
          create: (context) =>
              ChatProvider(storageService, context.read<SettingsProvider>()),
          update: (context, settings, previous) =>
              previous ?? ChatProvider(storageService, settings),
        ),
      ],
      child: const TranslatorAIApp(),
    ),
  );
}
