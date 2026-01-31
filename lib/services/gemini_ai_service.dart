import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/chat_mode.dart';
import 'ai_service.dart';

/// Gemini AI service implementation
class GeminiAIService implements AIService {
  final String apiKey;
  GenerativeModel? _model;
  ChatSession? _chatSession;

  // List of models to try in order of preference (based on available quota)
  static const List<String> _modelOptions = [
    'gemini-2.5-flash-lite', // 10 RPM - highest limit
    'gemini-2.5-flash', // 5 RPM
    'gemini-3-flash', // 5 RPM
    'gemma-3-4b', // 30 RPM - fallback
  ];

  int _currentModelIndex = 0;

  GeminiAIService({required this.apiKey}) {
    _initModel(_modelOptions[_currentModelIndex]);
  }

  void _initModel(String modelName) {
    _model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
    );
    _chatSession = _model!.startChat(history: [
      Content.text(_systemPrompt),
      Content.model([
        TextPart(
            'நான் புரிந்துகொண்டேன். நான் உங்களுக்கு ஆங்கிலம் கற்க உதவுவேன்!')
      ]),
    ]);
  }

  // Try next model if current one has quota issues
  bool _tryNextModel() {
    if (_currentModelIndex < _modelOptions.length - 1) {
      _currentModelIndex++;
      _initModel(_modelOptions[_currentModelIndex]);
      return true;
    }
    return false;
  }

  static const String _systemPrompt = '''
நீங்கள் ஒரு பொறுமையான, நட்பான ஆங்கில ஆசிரியர். நீங்கள் ஒரு தமிழ் பேசும் பெரியவருக்கு ஆங்கிலம் கற்றுக்கொடுக்கிறீர்கள்.

முக்கிய விதிகள்:
1. எப்போதும் தமிழில் பதில் அளிக்கவும். ஆங்கிலம் கற்பிக்கும்போது மட்டுமே ஆங்கிலத்தைப் பயன்படுத்தவும்.
2. எளிமையான, தெளிவான வாக்கியங்களைப் பயன்படுத்தவும்.
3. கடினமான இலக்கணத்தை தவிர்க்கவும் (கேட்கும்போது மட்டும்).
4. எப்போதும் ஊக்கமளிக்கும் வகையில் இருங்கள்.
5. ஸ்லாங் அல்லது சிக்கலான வெளிப்பாடுகளை ஒருபோதும் பயன்படுத்த வேண்டாம்.
6. பதில்கள் குறுகியதாகவும் தெளிவாகவும் இருக்க வேண்டும்.
7. ஆங்கில உதாரணங்களை **bold** அல்லது தனி வரியில் காட்டவும்.

நீங்கள் பின்வரும் பணிகளுக்கு உதவுவீர்கள்:
- தமிழிலிருந்து ஆங்கிலத்திற்கு மொழிபெயர்ப்பு
- ஆங்கில வாக்கியங்களை விளக்குதல்
- ஆங்கில தவறுகளை திருத்துதல்
- ஆங்கில உரையாடல் பயிற்சி

You are a patient, friendly English teacher helping a Tamil-speaking adult learn English.

Key rules:
1. ALWAYS respond primarily in Tamil. Use English ONLY for examples.
2. Use simple, clear sentences.
3. Avoid complex grammar (unless asked).
4. Always be encouraging and supportive.
5. Never use slang or complex expressions.
6. Keep responses short and clear.
7. Show English examples in **bold** or on separate lines.
''';

  @override
  Future<String> chat(String message, ChatMode mode) async {
    String prompt;

    switch (mode) {
      case ChatMode.translate:
        prompt = _buildTranslatePrompt(message);
        break;
      case ChatMode.explain:
        prompt = _buildExplainPrompt(message);
        break;
      case ChatMode.correct:
        prompt = _buildCorrectPrompt(message);
        break;
      case ChatMode.practice:
        prompt = _buildPracticePrompt(message);
        break;
    }

    try {
      final response = await _chatSession!.sendMessage(Content.text(prompt));
      return response.text ??
          'மன்னிக்கவும், பதில் கிடைக்கவில்லை. மீண்டும் முயற்சிக்கவும்.';
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();

      // Check if it's a quota error and try next model
      if (errorMessage.contains('quota') || errorMessage.contains('rate')) {
        if (_tryNextModel()) {
          // Retry with new model
          return chat(message, mode);
        }
        return '''⚠️ API quota முடிந்துவிட்டது.

சற்று நேரம் காத்திருந்து மீண்டும் முயற்சிக்கவும்.

(API quota exceeded. Please wait a moment and try again.)''';
      }

      return 'மன்னிக்கவும், ஒரு பிழை ஏற்பட்டது: ${e.toString()}';
    }
  }

  String _buildTranslatePrompt(String text) {
    return '''
மொழிபெயர்ப்பு பணி:
"$text"

இந்த உரையை மொழிபெயர்க்கவும். தமிழ் என்றால் ஆங்கிலத்திற்கும், ஆங்கிலம் என்றால் தமிழிற்கும் மொழிபெயர்க்கவும்.
மொழிபெயர்ப்பைக் காட்டி, ஒரு சிறிய விளக்கத்தையும் தமிழில் கொடுக்கவும்.
''';
  }

  String _buildExplainPrompt(String text) {
    return '''
ஆங்கில வாக்கியத்தை விளக்கவும்:
"$text"

இந்த ஆங்கில வாக்கியத்தின் அர்த்தம், பயன்பாடு மற்றும் சூழலை தமிழில் விளக்கவும்.
முக்கிய சொற்களை எடுத்துக்காட்டவும்.
''';
  }

  String _buildCorrectPrompt(String text) {
    return '''
ஆங்கில திருத்தம்:
"$text"

இந்த ஆங்கிலத்தை திருத்தி, சரியான வாக்கியத்தைக் காட்டவும்.
ஒவ்வொரு திருத்தத்தையும் தமிழில் விளக்கவும்.
''';
  }

  String _buildPracticePrompt(String text) {
    return '''
ஆங்கில உரையாடல் பயிற்சி:
பயனர் சொன்னது: "$text"

ஆங்கிலத்தில் பதில் அளித்து, பின்னர் தமிழில் விளக்கம் கொடுக்கவும்.
எளிமையான ஆங்கிலத்தைப் பயன்படுத்தவும்.
''';
  }

  @override
  Future<String> translate(String text, {bool toEnglish = true}) async {
    return chat(text, ChatMode.translate);
  }

  @override
  Future<String> explainSentence(String englishSentence) async {
    return chat(englishSentence, ChatMode.explain);
  }

  @override
  Future<String> correctEnglish(String text) async {
    return chat(text, ChatMode.correct);
  }

  @override
  Future<String> practiceConversation(String userMessage) async {
    return chat(userMessage, ChatMode.practice);
  }

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _model!.generateContent([Content.text('Test')]);
      return response.text != null;
    } catch (e) {
      return false;
    }
  }
}
