import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../theme/app_theme.dart';

/// Card widget for displaying a vocabulary item
class VocabularyCard extends StatelessWidget {
  final VocabularyItem item;
  final VoidCallback? onSpeak;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleFavorite;

  const VocabularyCard({
    super.key,
    required this.item,
    this.onSpeak,
    this.onDelete,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.englishWord,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.englishHighlight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.tamilMeaning,
                        style: const TextStyle(
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onSpeak != null)
                      IconButton(
                        onPressed: onSpeak,
                        icon: const Icon(Icons.volume_up_rounded),
                        color: AppTheme.primaryColor,
                        tooltip: 'கேளுங்கள்',
                      ),
                    if (onToggleFavorite != null)
                      IconButton(
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          item.isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                        ),
                        color: item.isFavorite
                            ? AppTheme.errorColor
                            : AppTheme.textSecondary,
                        tooltip: item.isFavorite ? 'நீக்கு' : 'பிடித்தவை',
                      ),
                    if (onDelete != null)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: AppTheme.textSecondary,
                        tooltip: 'நீக்கு',
                      ),
                  ],
                ),
              ],
            ),
            if (item.exampleSentence != null) ...[
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.format_quote_rounded,
                          size: 18,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'உதாரணம்',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.exampleSentence!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (item.exampleTranslation != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.exampleTranslation!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
