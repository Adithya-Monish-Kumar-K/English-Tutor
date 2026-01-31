import 'chat_mode.dart';

/// Represents a single message in the chat
class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final ChatMode? mode;
  final String? englishText;
  final String? tamilText;
  final bool hasVocabulary;

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.mode,
    this.englishText,
    this.tamilText,
    this.hasVocabulary = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
      'mode': mode?.index,
      'englishText': englishText,
      'tamilText': tamilText,
      'hasVocabulary': hasVocabulary ? 1 : 0,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      content: map['content'],
      isUser: map['isUser'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
      mode: map['mode'] != null ? ChatMode.values[map['mode']] : null,
      englishText: map['englishText'],
      tamilText: map['tamilText'],
      hasVocabulary: map['hasVocabulary'] == 1,
    );
  }

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    ChatMode? mode,
    String? englishText,
    String? tamilText,
    bool? hasVocabulary,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      mode: mode ?? this.mode,
      englishText: englishText ?? this.englishText,
      tamilText: tamilText ?? this.tamilText,
      hasVocabulary: hasVocabulary ?? this.hasVocabulary,
    );
  }
}
