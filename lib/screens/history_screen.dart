import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_history.dart';
import '../models/quiz_type.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

const double _maxContentWidth = 600;
const Color _warningColor = Color(0xFFF59E0B);

/// Màn hình lịch sử các lượt làm bài trắc nghiệm (FR19).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        final history = quizProvider.getHistory();

        return Scaffold(
          appBar: AppBar(
            title: Text(t.historyTitle),
            actions: [
              if (history.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: t.clearHistoryTitle,
                  onPressed: () => _onClearHistory(context),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: history.isEmpty
                  ? _EmptyHistory(message: t.emptyHistory)
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      itemCount: history.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppTheme.spacingS + 4,
                        ),
                        child: _HistoryTile(item: history[index]),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _onClearHistory(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.clearHistoryTitle),
          content: Text(t.clearHistoryMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
              child: Text(t.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    await context.read<QuizProvider>().clearHistory();
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.historyCleared)));
  }
}

/// Một lượt làm bài trong danh sách.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final QuizHistory item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = item.totalQuestions == 0
        ? 0
        : (item.score / item.totalQuestions * 100).round();
    final scoreColor = percent >= 80
        ? AppTheme.success
        : percent >= 50
        ? _warningColor
        : AppTheme.danger;
    final time = DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                item.quizType == QuizType.multipleChoice
                    ? Icons.checklist_rounded
                    : Icons.edit_note_rounded,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.deckName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.score}/${item.totalQuestions} · $time',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.14),
                border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
              ),
              child: Text(
                '$percent%',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Trạng thái khi chưa có lượt làm bài nào.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withValues(alpha: 0.07),
              ),
              child: Icon(
                Icons.history_rounded,
                size: 76,
                color: AppTheme.primary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: AppTheme.spacingL * 1.5),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }
}
