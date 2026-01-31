import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

/// Language setup and API key configuration screen
class LanguageSetupScreen extends StatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  State<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends State<LanguageSetupScreen> {
  final _apiKeyController = TextEditingController();
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _completeSetup() async {
    setState(() {
      _isLoading = true;
    });

    final settings = context.read<SettingsProvider>();
    final chat = context.read<ChatProvider>();

    // Save API key if provided
    if (_apiKeyController.text.isNotEmpty) {
      await settings.setApiKey(_apiKeyController.text.trim());
      chat.refreshAIService();
    }

    // Mark first launch complete
    await settings.completeFirstLaunch();

    // Add welcome message
    await chat.addWelcomeMessage();

    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const ChatScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('அமைப்பு'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Progress indicator
              Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? AppTheme.primaryColor
                            : AppTheme.primaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Step content
              Expanded(child: _buildStepContent()),

              // Navigation buttons
              Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('← பின்'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: _currentStep == 0 ? 1 : 1,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : (_currentStep < 2 ? _nextStep : _completeSetup),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _currentStep < 2 ? 'அடுத்து →' : 'தொடங்குக ✓',
                              style: const TextStyle(fontSize: 18),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildLanguageStep();
      case 1:
        return _buildHowItWorksStep();
      case 2:
        return _buildApiKeyStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildLanguageStep() {
    return Column(
      children: [
        const Icon(
          Icons.language_rounded,
          size: 80,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 24),
        const Text(
          'உங்கள் மொழி',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'தமிழ் உங்கள் தாய்மொழியாக அமைக்கப்பட்டுள்ளது',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.successColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'த',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'தமிழ்',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Tamil',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.successColor,
                size: 32,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorksStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            size: 64,
            color: AppTheme.warningColor,
          ),
          const SizedBox(height: 24),
          const Text(
            'எப்படி பயன்படுத்துவது',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          _buildFeatureItem(
            '🔄',
            'மொழிபெயர்ப்பு',
            'தமிழை ஆங்கிலமாகவும், ஆங்கிலத்தை தமிழாகவும் மாற்றுங்கள்',
          ),
          _buildFeatureItem(
            '💡',
            'விளக்கம்',
            'ஆங்கில வாக்கியங்களின் அர்த்தத்தைப் புரிந்துகொள்ளுங்கள்',
          ),
          _buildFeatureItem(
            '✏️',
            'திருத்தம்',
            'உங்கள் ஆங்கிலத்தை சரிபார்த்து திருத்துங்கள்',
          ),
          _buildFeatureItem(
            '💬',
            'பயிற்சி',
            'ஆங்கிலத்தில் உரையாடல் பயிற்சி செய்யுங்கள்',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyStep() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Icon(
            Icons.key_rounded,
            size: 64,
            color: AppTheme.englishHighlight,
          ),
          const SizedBox(height: 24),
          const Text(
            'API Key (விருப்பத்திற்கு)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Gemini API key இருந்தால் கீழே உள்ளிடவும்.\nஇல்லையென்றால் தவிர்க்கலாம்.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              hintText: 'Gemini API Key',
              prefixIcon: Icon(Icons.vpn_key_rounded),
            ),
            obscureText: true,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'API key இல்லாமலும் நீங்கள் demo mode-ல் பயன்படுத்தலாம்.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
