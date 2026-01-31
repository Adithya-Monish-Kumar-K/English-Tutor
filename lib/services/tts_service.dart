import 'package:flutter_tts/flutter_tts.dart';

/// Service for text-to-speech functionality
class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  double _speechRate = 0.4; // Slower for learners

  Future<void> init() async {
    if (_isInitialized) return;

    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _isInitialized = true;
  }

  Future<void> speak(String text, {String language = 'en-US'}) async {
    await init();
    await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  Future<void> speakEnglish(String text) async {
    await speak(text, language: 'en-US');
  }

  Future<void> speakTamil(String text) async {
    await speak(text, language: 'ta-IN');
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.1, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  double get speechRate => _speechRate;

  Future<List<dynamic>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }

  Future<bool> isLanguageAvailable(String language) async {
    final result = await _flutterTts.isLanguageAvailable(language);
    return result == 1;
  }
}
