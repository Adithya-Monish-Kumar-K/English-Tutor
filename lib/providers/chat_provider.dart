import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/chat_mode.dart';
import '../models/vocabulary_item.dart';
import '../services/storage_service.dart';
import '../services/ai_service.dart';
import '../services/gemini_ai_service.dart';
import '../services/mock_ai_service.dart';
import '../services/stt_service.dart';
import 'settings_provider.dart';

/// Provider for chat functionality and message management
class ChatProvider extends ChangeNotifier {
  final StorageService _storageService;
  final SettingsProvider _settingsProvider;
  final STTService _sttService = STTService();
  final Uuid _uuid = const Uuid();

  AIService? _aiService;
  List<Message> _messages = [];
  List<VocabularyItem> _vocabulary = [];
  ChatMode _currentMode = ChatMode.translate;
  bool _isLoading = false;
  bool _isListening = false;
  String _recognizedText = '';

  ChatProvider(this._storageService, this._settingsProvider) {
    _initializeServices();
  }

  List<Message> get messages => _messages;
  List<VocabularyItem> get vocabulary => _vocabulary;
  ChatMode get currentMode => _currentMode;
  bool get isLoading => _isLoading;
  bool get isListening => _isListening;
  String get recognizedText => _recognizedText;
  bool get hasApiKey =>
      _settingsProvider.apiKey != null && _settingsProvider.apiKey!.isNotEmpty;

  Future<void> _initializeServices() async {
    await _loadMessages();
    await _loadVocabulary();
    _initAIService();
  }

  void _initAIService() {
    final apiKey = _settingsProvider.apiKey;
    if (apiKey != null && apiKey.isNotEmpty) {
      _aiService = GeminiAIService(apiKey: apiKey);
    } else {
      _aiService = MockAIService();
    }
    notifyListeners();
  }

  void refreshAIService() {
    _initAIService();
  }

  Future<void> _loadMessages() async {
    _messages = await _storageService.getMessages();
    notifyListeners();
  }

  Future<void> _loadVocabulary() async {
    _vocabulary = await _storageService.getVocabulary();
    notifyListeners();
  }

  void setMode(ChatMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      id: _uuid.v4(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
      mode: _currentMode,
    );

    _messages.add(userMessage);
    await _storageService.saveMessage(userMessage);
    notifyListeners();

    // Get AI response
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _aiService!.chat(content, _currentMode);

      final aiMessage = Message(
        id: _uuid.v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        mode: _currentMode,
        hasVocabulary: _containsEnglish(response),
      );

      _messages.add(aiMessage);
      await _storageService.saveMessage(aiMessage);
    } catch (e) {
      final errorMessage = Message(
        id: _uuid.v4(),
        content:
            'மன்னிக்கவும், ஒரு பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.\n\nError: ${e.toString()}',
        isUser: false,
        timestamp: DateTime.now(),
        mode: _currentMode,
      );
      _messages.add(errorMessage);
      await _storageService.saveMessage(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  bool _containsEnglish(String text) {
    return RegExp(r'[a-zA-Z]{3,}').hasMatch(text);
  }

  // Voice input methods
  Future<void> startListening() async {
    _recognizedText = '';
    await _sttService.startListening(
      localeId: _currentMode == ChatMode.practice ? 'en_US' : 'ta_IN',
      onResult: (text) {
        _recognizedText = text;
        notifyListeners();
      },
      onListeningChanged: (listening) {
        _isListening = listening;
        notifyListeners();
      },
    );
    _isListening = true;
    notifyListeners();
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
    _isListening = false;
    notifyListeners();
  }

  // Vocabulary methods
  Future<void> saveToVocabulary({
    required String englishWord,
    required String tamilMeaning,
    String? exampleSentence,
    String? exampleTranslation,
  }) async {
    final item = VocabularyItem(
      id: _uuid.v4(),
      englishWord: englishWord,
      tamilMeaning: tamilMeaning,
      exampleSentence: exampleSentence,
      exampleTranslation: exampleTranslation,
      savedAt: DateTime.now(),
    );

    await _storageService.saveVocabulary(item);
    await _loadVocabulary();
  }

  Future<void> deleteVocabulary(String id) async {
    await _storageService.deleteVocabulary(id);
    await _loadVocabulary();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    await _storageService.toggleFavorite(id, isFavorite);
    await _loadVocabulary();
  }

  Future<void> clearChatHistory() async {
    await _storageService.clearMessages();
    _messages = [];
    notifyListeners();
  }

  // Add welcome message for first launch
  Future<void> addWelcomeMessage() async {
    if (_messages.isEmpty) {
      final welcomeMessage = Message(
        id: _uuid.v4(),
        content: '''வணக்கம்! 🙏

நான் உங்கள் ஆங்கில ஆசிரியர். நான் உங்களுக்கு ஆங்கிலம் கற்க உதவுவேன்.

**நீங்கள் என்ன செய்யலாம்:**
• 🔄 **மொழிபெயர்ப்பு** - தமிழை ஆங்கிலமாக மாற்றுங்கள்
• 💡 **விளக்கம்** - ஆங்கில வாக்கியங்களைப் புரிந்துகொள்ளுங்கள்
• ✏️ **திருத்தம்** - உங்கள் ஆங்கிலத்தை சரிபார்க்கவும்
• 💬 **பயிற்சி** - ஆங்கிலத்தில் உரையாடுங்கள்

மேலே உள்ள பொத்தான்களைப் பயன்படுத்தி ஒரு பயன்முறையைத் தேர்ந்தெடுங்கள், பின்னர் உங்கள் செய்தியை தட்டச்சு செய்யுங்கள்!''',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(welcomeMessage);
      await _storageService.saveMessage(welcomeMessage);
      notifyListeners();
    }
  }
}
