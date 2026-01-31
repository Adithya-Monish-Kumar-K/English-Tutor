import 'package:flutter/foundation.dart';
import '../models/user_preferences.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

/// Provider for app settings and preferences
class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;
  final TTSService _ttsService = TTSService();

  UserPreferences _preferences = UserPreferences();
  bool _isLoading = true;

  SettingsProvider(this._storageService) {
    _loadPreferences();
  }

  UserPreferences get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isFirstLaunch => _preferences.isFirstLaunch;
  String? get apiKey => _preferences.apiKey;
  double get speechRate => _preferences.speechRate;
  TTSService get ttsService => _ttsService;

  Future<void> _loadPreferences() async {
    _preferences = await _storageService.getPreferences();
    _ttsService.setSpeechRate(_preferences.speechRate);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeFirstLaunch() async {
    _preferences = _preferences.copyWith(isFirstLaunch: false);
    await _storageService.savePreferences(_preferences);
    notifyListeners();
  }

  Future<void> setApiKey(String apiKey) async {
    _preferences = _preferences.copyWith(apiKey: apiKey);
    await _storageService.setApiKey(apiKey);
    notifyListeners();
  }

  Future<void> setSpeechRate(double rate) async {
    _preferences = _preferences.copyWith(speechRate: rate);
    await _storageService.savePreferences(_preferences);
    await _ttsService.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> speakEnglish(String text) async {
    await _ttsService.speakEnglish(text);
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }
}
