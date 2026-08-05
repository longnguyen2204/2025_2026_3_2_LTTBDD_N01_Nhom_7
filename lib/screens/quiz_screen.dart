import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/deck.dart';
import '../models/quiz_type.dart';
import '../providers/deck_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'quiz_play_screen.dart';

const double _maxContentWidth = 600;

/// Màn hình chọn hình thức làm bài kiểm tra (FR09, FR18).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.deckId, required this.colorIndex});

  final String deckId;
  final int colorIndex;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  void _startQuiz(Deck deck, QuizType type) {
    final t = AppLocalizations.of(context)!;

    if (deck.words.length < QuizProvider.minWordsRequired) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.notEnoughWords)));
      return;
    }

    context.read<QuizProvider>().generateQuiz(deck, type);
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => QuizPlayScreen(
          deckId: widget.deckId,
          colorIndex: widget.colorIndex,
          quizType: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = AppTheme.deckColorAt(widget.colorIndex);
    final deck = context.read<DeckProvider>().getDeckById(widget.deckId);

    return Scaffold(
      appBar: AppBar(title: Text(t.chooseQuizType)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: deck == null
                ? _QuizMessage(message: t.emptyDeckForStudy)
                : _buildTypeChooser(deck, color),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChooser(Deck deck, Color color) {
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      children: [
        _QuizTypeCard(
          icon: Icons.checklist_rounded,
          title: t.quizTypeMultipleChoice,
          description: t.quizTypeMultipleChoiceDesc,
          color: color,
          type: QuizType.multipleChoice,
          onTap: () => _startQuiz(deck, QuizType.multipleChoice),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _QuizTypeCard(
          icon: Icons.edit_note_rounded,
          title: t.quizTypeTyping,
          description: t.quizTypeTypingDesc,
          color: color,
          type: QuizType.typing,
          onTap: () => _startQuiz(deck, QuizType.typing),
        ),
      ],
    );
  }
}

/// Thẻ chọn hình thức làm bài ở màn hình đầu.
class _QuizTypeCard extends StatelessWidget {
  const _QuizTypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.type,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final QuizType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Hero(
                tag: 'quiz_type_icon_${type.name}',
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Icon(icon, size: 34, color: color),
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Row(
                      children: [
                        Text(
                          t.startQuiz,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thông báo khi không lấy được bộ từ để làm bài.
class _QuizMessage extends StatelessWidget {
  const _QuizMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingL),
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(t.back),
            ),
          ],
        ),
      ),
    );
  }
}
