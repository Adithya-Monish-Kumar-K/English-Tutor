/// User preferences model
class UserPreferences {
  final String nativeLanguage;
  final bool isFirstLaunch;
  final double speechRate;
  final String? apiKey;
  final bool voiceInputEnabled;

  UserPreferences({
    this.nativeLanguage = 'ta', // Tamil
    this.isFirstLaunch = true,
    this.speechRate = 0.5,
    this.apiKey,
    this.voiceInputEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'nativeLanguage': nativeLanguage,
      'isFirstLaunch': isFirstLaunch,
      'speechRate': speechRate,
      'apiKey': apiKey,
      'voiceInputEnabled': voiceInputEnabled,
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      nativeLanguage: map['nativeLanguage'] ?? 'ta',
      isFirstLaunch: map['isFirstLaunch'] ?? true,
      speechRate: map['speechRate'] ?? 0.5,
      apiKey: map['apiKey'],
      voiceInputEnabled: map['voiceInputEnabled'] ?? true,
    );
  }

  UserPreferences copyWith({
    String? nativeLanguage,
    bool? isFirstLaunch,
    double? speechRate,
    String? apiKey,
    bool? voiceInputEnabled,
  }) {
    return UserPreferences(
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      speechRate: speechRate ?? this.speechRate,
      apiKey: apiKey ?? this.apiKey,
      voiceInputEnabled: voiceInputEnabled ?? this.voiceInputEnabled,
    );
  }
}
