import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../models/chat_mode.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/mode_selector.dart';
import '../widgets/voice_input_button.dart';
import '../widgets/loading_indicator.dart';
import 'vocabulary_screen.dart';
import 'settings_screen.dart';

/// Main chat screen
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _handleVoiceInput() {
    final chat = context.read<ChatProvider>();
    if (chat.isListening) {
      chat.stopListening();
      if (chat.recognizedText.isNotEmpty) {
        _textController.text = chat.recognizedText;
      }
    } else {
      chat.startListening();
    }
  }

  void _speakText(String text) {
    // Extract English text from the message
    final englishPattern = RegExp(r'"([^"]+)"|\*\*([^*]+)\*\*');
    final matches = englishPattern.allMatches(text);

    String englishText = '';
    for (final match in matches) {
      final extracted = match.group(1) ?? match.group(2) ?? '';
      if (RegExp(r'[a-zA-Z]').hasMatch(extracted)) {
        englishText = '$englishText$extracted ';
      }
    }

    if (englishText.isNotEmpty) {
      context.read<SettingsProvider>().speakEnglish(englishText.trim());
    }
  }

  void _showSaveVocabularyDialog(String messageContent) {
    final englishController = TextEditingController();
    final tamilController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('சொல்லை சேமிக்கவும்'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: englishController,
              decoration: const InputDecoration(
                labelText: 'ஆங்கில சொல்',
                hintText: 'English word',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tamilController,
              decoration: const InputDecoration(
                labelText: 'தமிழ் அர்த்தம்',
                hintText: 'Tamil meaning',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ரத்து'),
          ),
          ElevatedButton(
            onPressed: () {
              if (englishController.text.isNotEmpty &&
                  tamilController.text.isNotEmpty) {
                context.read<ChatProvider>().saveToVocabulary(
                      englishWord: englishController.text.trim(),
                      tamilMeaning: tamilController.text.trim(),
                    );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('சொல் சேமிக்கப்பட்டது! ✓'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            child: const Text('சேமிக்க'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ஆங்கில ஆசிரியர்'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_rounded),
            tooltip: 'சேமித்த சொற்கள்',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VocabularyScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'அமைப்புகள்',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          Consumer<ChatProvider>(
            builder: (context, chat, _) {
              return ModeSelector(
                currentMode: chat.currentMode,
                onModeChanged: chat.setMode,
              );
            },
          ),

          // Chat messages
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                _scrollToBottom();

                if (chat.messages.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: chat.messages.length + (chat.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chat.messages.length && chat.isLoading) {
                      return const LoadingIndicator();
                    }

                    final message = chat.messages[index];
                    return ChatBubble(
                      message: message,
                      onSpeak: message.hasVocabulary
                          ? () => _speakText(message.content)
                          : null,
                      onSaveVocabulary: message.hasVocabulary
                          ? () => _showSaveVocabularyDialog(message.content)
                          : null,
                    );
                  },
                );
              },
            ),
          ),

          // Voice recognition indicator
          Consumer<ChatProvider>(
            builder: (context, chat, _) {
              if (chat.isListening || chat.recognizedText.isNotEmpty) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Row(
                    children: [
                      if (chat.isListening)
                        const Icon(
                          Icons.mic_rounded,
                          color: AppTheme.errorColor,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          chat.isListening
                              ? (chat.recognizedText.isEmpty
                                  ? 'கேட்கிறேன்...'
                                  : chat.recognizedText)
                              : chat.recognizedText,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!chat.isListening && chat.recognizedText.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            _textController.text = chat.recognizedText;
                          },
                          child: const Text('பயன்படுத்து'),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'உரையாடலைத் தொடங்குங்கள்!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<ChatProvider>(
              builder: (context, chat, _) {
                return Text(
                  'மேலே ${chat.currentMode.displayName} பயன்முறை தேர்ந்தெடுக்கப்பட்டுள்ளது.\nஒரு செய்தியை தட்டச்சு செய்யுங்கள்.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Voice input button
            Consumer<ChatProvider>(
              builder: (context, chat, _) {
                return VoiceInputButton(
                  isListening: chat.isListening,
                  onPressed: _handleVoiceInput,
                );
              },
            ),
            const SizedBox(width: 12),

            // Text input
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: _getHintText(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                maxLines: null,
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(width: 12),

            // Send button
            Material(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                onTap: _sendMessage,
                borderRadius: BorderRadius.circular(24),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Icon(Icons.send_rounded, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHintText() {
    final mode = context.read<ChatProvider>().currentMode;
    switch (mode) {
      case ChatMode.translate:
        return 'மொழிபெயர்க்க தட்டச்சு செய்க...';
      case ChatMode.explain:
        return 'ஆங்கில வாக்கியம் எழுதுக...';
      case ChatMode.correct:
        return 'உங்கள் ஆங்கிலம் எழுதுக...';
      case ChatMode.practice:
        return 'ஆங்கிலத்தில் பேசுக...';
    }
  }
}
