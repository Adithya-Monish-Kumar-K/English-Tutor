import '../models/chat_mode.dart';
import 'ai_service.dart';

/// Mock AI service for offline/demo use
class MockAIService implements AIService {
  @override
  Future<String> chat(String message, ChatMode mode) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    switch (mode) {
      case ChatMode.translate:
        return _mockTranslate(message);
      case ChatMode.explain:
        return _mockExplain(message);
      case ChatMode.correct:
        return _mockCorrect(message);
      case ChatMode.practice:
        return _mockPractice(message);
    }
  }

  String _mockTranslate(String text) {
    // Check if text contains Tamil characters
    bool isTamil = RegExp(r'[\u0B80-\u0BFF]').hasMatch(text);

    if (isTamil) {
      return '''
**மொழிபெயர்ப்பு (Translation):**

உங்கள் வாக்கியம்: "$text"

**ஆங்கிலத்தில்:** "Hello, how are you?"

📝 **விளக்கம்:**
இது ஒரு அடிப்படை வாழ்த்து வாக்கியம். யாரையும் சந்திக்கும்போது இதைப் பயன்படுத்தலாம்.

💡 **குறிப்பு:**
"How are you?" என்பது நலம் விசாரிக்கும் முறை.
''';
    } else {
      return '''
**மொழிபெயர்ப்பு (Translation):**

உங்கள் வாக்கியம்: "$text"

**தமிழில்:** "வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?"

📝 **விளக்கம்:**
இது ஒரு பொதுவான ஆங்கில வாழ்த்து வாக்கியம்.
''';
    }
  }

  String _mockExplain(String text) {
    return '''
**வாக்கிய விளக்கம்:**

"$text"

📖 **அர்த்தம்:**
இந்த வாக்கியம் ஒரு எளிய கூற்று. இது தினசரி உரையாடலில் பயன்படுத்தப்படுகிறது.

🔤 **முக்கிய சொற்கள்:**
• **This** - இது
• **is** - ஆகும்/இருக்கிறது
• **example** - உதாரணம்

💡 **பயன்பாடு:**
நீங்கள் இந்த வாக்கிய அமைப்பை பல சூழல்களில் பயன்படுத்தலாம்.
''';
  }

  String _mockCorrect(String text) {
    return '''
**ஆங்கில திருத்தம்:**

❌ உங்கள் வாக்கியம்: "$text"

✅ **சரியான வாக்கியம்:** "This is a correct sentence."

📝 **திருத்தங்கள்:**
1. முதல் எழுத்து பெரிய எழுத்தாக இருக்க வேண்டும்
2. வாக்கியத்தின் முடிவில் புள்ளி (.) வேண்டும்

💪 **நல்ல முயற்சி!** தொடர்ந்து பயிற்சி செய்யுங்கள்.
''';
  }

  String _mockPractice(String text) {
    return '''
**English Response:**
"That's wonderful! I understand what you're saying."

---

**தமிழ் விளக்கம்:**
நான் சொன்னது: "அது அருமை! நீங்கள் சொல்வது புரிகிறது."

🗣️ **உரையாடலைத் தொடர:**
நீங்கள் "Thank you" (நன்றி) அல்லது "Can you help me?" (நீங்கள் எனக்கு உதவ முடியுமா?) என்று சொல்லலாம்.
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
    return true;
  }
}
