import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/deck.dart';
import '../models/quiz_question.dart';
import '../models/quiz_type.dart';
import '../providers/deck_provider.dart';
import '../providers/quiz_provider.dart';
import '../services/tts_service.dart';
import '../theme/app_theme.dart';
import 'quiz_result_screen.dart';

const double _maxContentWidth = 600;

/// Màn hình làm bài kiểm tra: chọn hình thức rồi lần lượt trả lời
/// từng câu hỏi (FR09, FR18).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.deckId, required this.colorIndex});

  final String deckId;
  final int colorIndex;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _typingController = TextEditingController();

  /// null khi còn ở giai đoạn chọn hình thức làm bài.
  QuizType? _quizType;

  /// Id của câu đã bấm "Kiểm tra" ở chế độ điền từ — dùng để khóa ô nhập
  /// và giữ kết quả đúng/sai cho tới khi sang câu kế tiếp.
  String? _checkedQuestionId;
  bool _lastAnswerCorrect = false;

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _startQuiz(Deck deck, QuizType type) {
    final t = AppLocalizations.of(context)!;

    if (deck.words.length < QuizProvider.minWordsRequired) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.notEnoughWords)));
      return;
    }

    context.read<QuizProvider>().generateQuiz(deck, type);
    setState(() => _quizType = type);
  }

  void _onCheckTyping(QuizProvider quizProvider, QuizQuestion question) {
    final answer = _typingController.text.trim();
    if (answer.isEmpty) return;

    final correct = quizProvider.checkTypingAnswer(question.id, answer);
    setState(() {
      _checkedQuestionId = question.id;
      _lastAnswerCorrect = correct;
    });
  }

  void _onNext(QuizProvider quizProvider) {
    _typingController.clear();
    setState(() => _checkedQuestionId = null);
    quizProvider.nextQuestion();
  }

  Future<void> _onSubmit(Deck deck, QuizProvider quizProvider) async {
    final result = quizProvider.calculateResult();
    await quizProvider.saveResult(deck.name, result, _quizType!);
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => QuizResultScreen(
          result: result,
          deckId: widget.deckId,
          colorIndex: widget.colorIndex,
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
      appBar: AppBar(
        title: Text(_quizType == null ? t.chooseQuizType : t.quizTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: deck == null
                ? _QuizMessage(message: t.emptyDeckForStudy)
                : _quizType == null
                ? _buildTypeChooser(deck, color)
                : _buildQuizBody(deck, color),
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
          onTap: () => _startQuiz(deck, QuizType.multipleChoice),
        ),
        const SizedBox(height: AppTheme.spacingM),
        _QuizTypeCard(
          icon: Icons.edit_note_rounded,
          title: t.quizTypeTyping,
          description: t.quizTypeTypingDesc,
          color: color,
          onTap: () => _startQuiz(deck, QuizType.typing),
        ),
      ],
    );
  }

  Widget _buildQuizBody(Deck deck, Color color) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<QuizProvider>(
      builder: (context, quizProvider, _) {
        final question = quizProvider.currentQuestion;
        if (question == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final total = quizProvider.totalQuestions;
        final index = quizProvider.currentIndex;
        final answer = quizProvider.currentAnswer;
        final isLast = !quizProvider.hasNext();
        final isMultipleChoice = question.type == QuizType.multipleChoice;

        return Column(
          children: [
            LinearProgressIndicator(
              value: total == 0 ? 0 : index / total,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                children: [
                  Text(
                    t.questionPosition(index + 1, total),
                    style: theme.textTheme.labelLarge?.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isMultipleChoice ? t.questionPrompt : t.typingPrompt,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _QuestionCard(
                    term: question.word.term,
                    color: color,
                    onSpeak: () => _ttsService.speak(question.word.term),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  if (isMultipleChoice)
                    ..._buildOptions(quizProvider, question, answer, color)
                  else
                    _buildTypingAnswer(quizProvider, question, color),
                ],
              ),
            ),
            _BottomBar(
              hint: answer != null
                  ? null
                  : isMultipleChoice
                  ? t.selectAnswerFirst
                  : t.checkAnswerFirst,
              label: isLast ? t.submitQuiz : t.nextQuestion,
              color: color,
              onPressed: answer == null
                  ? null
                  : isLast
                  ? () => _onSubmit(deck, quizProvider)
                  : () => _onNext(quizProvider),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildOptions(
    QuizProvider quizProvider,
    QuizQuestion question,
    String? answer,
    Color color,
  ) {
    return [
      for (final option in question.options)
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS + 4),
          child: _OptionTile(
            text: option,
            selected: option == answer,
            color: color,
            onTap: () => quizProvider.submitAnswer(question.id, option),
          ),
        ),
    ];
  }

  Widget _buildTypingAnswer(
    QuizProvider quizProvider,
    QuizQuestion question,
    Color color,
  ) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final checked = _checkedQuestionId == question.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _typingController,
                enabled: !checked,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onCheckTyping(quizProvider, question),
                decoration: InputDecoration(hintText: t.typingAnswerHint),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            FilledButton(
              onPressed: checked
                  ? null
                  : () => _onCheckTyping(quizProvider, question),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                minimumSize: const Size(0, 56),
              ),
              child: Text(t.checkAnswer),
            ),
          ],
        ),
        if (checked) ...[
          const SizedBox(height: AppTheme.spacingS + 4),
          Row(
            children: [
              Icon(
                _lastAnswerCorrect ? Icons.check_circle : Icons.cancel,
                color: _lastAnswerCorrect ? AppTheme.success : AppTheme.danger,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  _lastAnswerCorrect ? t.answerCorrect : t.answerIncorrect,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _lastAnswerCorrect
                        ? AppTheme.success
                        : AppTheme.danger,
                  ),
                ),
              ),
            ],
          ),
          if (!_lastAnswerCorrect) ...[
            const SizedBox(height: 4),
            Text(
              question.correctAnswer,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: Icon(icon, size: 34, color: color),
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

/// Thẻ hiển thị từ cần trả lời kèm nút phát âm.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.term,
    required this.color,
    required this.onSpeak,
  });

  final String term;
  final Color color;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.24)!],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              term,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingS),
          IconButton(
            onPressed: onSpeak,
            icon: const Icon(Icons.volume_up_rounded),
            color: Colors.white,
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}

/// Một đáp án của câu hỏi trắc nghiệm.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? color.withValues(alpha: 0.12) : theme.cardColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: selected
                  ? color
                  : theme.dividerColor.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: selected ? color : Colors.grey.shade400,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Thanh dưới cùng: gợi ý khi chưa trả lời và nút chuyển câu / nộp bài.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.hint,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String? hint;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingS,
        AppTheme.spacingL,
        AppTheme.spacingL,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24,
            child: hint == null
                ? null
                : Center(
                    child: Text(
                      hint!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(backgroundColor: color),
            child: Text(label),
          ),
        ],
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
