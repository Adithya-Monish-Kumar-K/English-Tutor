/// Represents a saved vocabulary item
class VocabularyItem {
  final String id;
  final String englishWord;
  final String tamilMeaning;
  final String? exampleSentence;
  final String? exampleTranslation;
  final DateTime savedAt;
  final bool isFavorite;

  VocabularyItem({
    required this.id,
    required this.englishWord,
    required this.tamilMeaning,
    this.exampleSentence,
    this.exampleTranslation,
    required this.savedAt,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'englishWord': englishWord,
      'tamilMeaning': tamilMeaning,
      'exampleSentence': exampleSentence,
      'exampleTranslation': exampleTranslation,
      'savedAt': savedAt.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory VocabularyItem.fromMap(Map<String, dynamic> map) {
    return VocabularyItem(
      id: map['id'],
      englishWord: map['englishWord'],
      tamilMeaning: map['tamilMeaning'],
      exampleSentence: map['exampleSentence'],
      exampleTranslation: map['exampleTranslation'],
      savedAt: DateTime.parse(map['savedAt']),
      isFavorite: map['isFavorite'] == 1,
    );
  }

  VocabularyItem copyWith({
    String? id,
    String? englishWord,
    String? tamilMeaning,
    String? exampleSentence,
    String? exampleTranslation,
    DateTime? savedAt,
    bool? isFavorite,
  }) {
    return VocabularyItem(
      id: id ?? this.id,
      englishWord: englishWord ?? this.englishWord,
      tamilMeaning: tamilMeaning ?? this.tamilMeaning,
      exampleSentence: exampleSentence ?? this.exampleSentence,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      savedAt: savedAt ?? this.savedAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
