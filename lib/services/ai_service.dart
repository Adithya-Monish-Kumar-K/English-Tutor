import '../models/chat_mode.dart';

/// Abstract interface for AI chatbot functionality
abstract class AIService {
  /// Send a message to the AI and get a response
  Future<String> chat(String message, ChatMode mode);

  /// Translate text between Tamil and English
  Future<String> translate(String text, {bool toEnglish = true});

  /// Explain an English sentence in Tamil
  Future<String> explainSentence(String englishSentence);

  /// Correct English text and explain corrections in Tamil
  Future<String> correctEnglish(String text);

  /// Practice English conversation with Tamil explanations
  Future<String> practiceConversation(String userMessage);

  /// Check if the service is available
  Future<bool> isAvailable();
}
