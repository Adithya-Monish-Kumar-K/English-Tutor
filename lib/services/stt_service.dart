import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

/// Service for speech-to-text functionality
class STTService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  Function(String)? _onResult;
  Function(bool)? _onListeningChanged;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<bool> init() async {
    if (_isInitialized) return true;

    _isInitialized = await _speechToText.initialize(
      onError: (error) {
        _isListening = false;
        _onListeningChanged?.call(false);
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
          _onListeningChanged?.call(false);
        }
      },
    );

    return _isInitialized;
  }

  Future<void> startListening({
    String localeId = 'en_US',
    Function(String)? onResult,
    Function(bool)? onListeningChanged,
  }) async {
    if (!_isInitialized) {
      final success = await init();
      if (!success) return;
    }

    _onResult = onResult;
    _onListeningChanged = onListeningChanged;
    _lastWords = '';
    _isListening = true;
    _onListeningChanged?.call(true);

    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    _onResult?.call(_lastWords);

    if (result.finalResult) {
      _isListening = false;
      _onListeningChanged?.call(false);
    }
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    _onListeningChanged?.call(false);
  }

  Future<List<LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) await init();
    return _speechToText.locales();
  }

  Future<bool> hasPermission() async {
    if (!_isInitialized) await init();
    return _speechToText.hasPermission;
  }
}
