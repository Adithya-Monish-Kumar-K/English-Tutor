import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/vocabulary_card.dart';

/// Screen for viewing and managing saved vocabulary
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  String _searchQuery = '';
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('சேமித்த சொற்கள்'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: _showFavoritesOnly ? AppTheme.errorColor : null,
            ),
            tooltip: 'பிடித்தவை மட்டும்',
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'சொல்லைத் தேடுங்கள்...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          // Vocabulary list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chat, _) {
                var items = chat.vocabulary;

                // Filter by favorites
                if (_showFavoritesOnly) {
                  items = items.where((item) => item.isFavorite).toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  items = items.where((item) {
                    return item.englishWord.toLowerCase().contains(
                          _searchQuery,
                        ) ||
                        item.tamilMeaning.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                if (items.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        color: AppTheme.errorColor,
                        child: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      onDismissed: (_) {
                        chat.deleteVocabulary(item.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.englishWord} நீக்கப்பட்டது'),
                            action: SnackBarAction(
                              label: 'செயல்தவிர்',
                              onPressed: () {
                                chat.saveToVocabulary(
                                  englishWord: item.englishWord,
                                  tamilMeaning: item.tamilMeaning,
                                  exampleSentence: item.exampleSentence,
                                  exampleTranslation: item.exampleTranslation,
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: VocabularyCard(
                        item: item,
                        onSpeak: () {
                          context.read<SettingsProvider>().speakEnglish(
                            item.englishWord,
                          );
                        },
                        onToggleFavorite: () {
                          chat.toggleFavorite(item.id, !item.isFavorite);
                        },
                        onDelete: () {
                          _showDeleteConfirmation(
                            context,
                            chat,
                            item.id,
                            item.englishWord,
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
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
              child: Icon(
                _showFavoritesOnly
                    ? Icons.favorite_border_rounded
                    : Icons.bookmark_border_rounded,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _showFavoritesOnly
                  ? 'பிடித்த சொற்கள் இல்லை'
                  : 'சேமித்த சொற்கள் இல்லை',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'உரையாடலில் புதிய சொற்களைச் சேமிக்கலாம்',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ChatProvider chat,
    String id,
    String word,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('நீக்க வேண்டுமா?'),
        content: Text('"$word" என்ற சொல்லை நீக்க விரும்புகிறீர்களா?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ரத்து'),
          ),
          ElevatedButton(
            onPressed: () {
              chat.deleteVocabulary(id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('நீக்கு'),
          ),
        ],
      ),
    );
  }
}
