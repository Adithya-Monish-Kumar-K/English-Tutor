/// Represents the different chat modes available in the app
enum ChatMode { translate, explain, correct, practice }

extension ChatModeExtension on ChatMode {
  String get displayName {
    switch (this) {
      case ChatMode.translate:
        return 'மொழிபெயர்ப்பு';
      case ChatMode.explain:
        return 'விளக்கம்';
      case ChatMode.correct:
        return 'திருத்தம்';
      case ChatMode.practice:
        return 'பயிற்சி';
    }
  }

  String get englishName {
    switch (this) {
      case ChatMode.translate:
        return 'Translate';
      case ChatMode.explain:
        return 'Explain';
      case ChatMode.correct:
        return 'Correct';
      case ChatMode.practice:
        return 'Practice';
    }
  }

  String get icon {
    switch (this) {
      case ChatMode.translate:
        return '🔄';
      case ChatMode.explain:
        return '💡';
      case ChatMode.correct:
        return '✏️';
      case ChatMode.practice:
        return '💬';
    }
  }

  String get description {
    switch (this) {
      case ChatMode.translate:
        return 'தமிழ் ↔ ஆங்கிலம் மொழிபெயர்ப்பு';
      case ChatMode.explain:
        return 'ஆங்கில வாக்கியத்தை விளக்குங்கள்';
      case ChatMode.correct:
        return 'என் ஆங்கிலத்தை திருத்துங்கள்';
      case ChatMode.practice:
        return 'ஆங்கிலத்தில் உரையாடுங்கள்';
    }
  }
}
