import 'dart:math';

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

/// Màn hình trả lời từng câu hỏi của bài kiểm tra (FR09, FR18).
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.deckId,
    required this.colorIndex,
    required this.quizType,
  });

  final String deckId;
  final int colorIndex;
  final QuizType quizType;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  final TtsService _ttsService = TtsService();
  final TextEditingController _typingController = TextEditingController();
  final Random _random = Random();

  int _comboCount = 0;
  String? _scoredQuestionId;

  /// Id của câu đã bấm "Kiểm tra" ở chế độ điền từ — dùng để khóa ô nhập
  /// và giữ kết quả đúng/sai cho tới khi sang câu kế tiếp.
  String? _checkedQuestionId;
  bool _lastAnswerCorrect = false;

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  void _onCheckTyping(QuizProvider quizProvider, QuizQuestion question) {
    final answer = _typingController.text.trim();
    if (answer.isEmpty) return;

    final correct = quizProvider.checkTypingAnswer(question.id, answer);
    final alreadyScored = _scoredQuestionId == question.id;
    setState(() {
      _checkedQuestionId = question.id;
      _lastAnswerCorrect = correct;
      if (!alreadyScored) {
        _comboCount = correct ? _comboCount + 1 : 0;
        _scoredQuestionId = question.id;
      }
    });
    _showAnswerFeedback(correct);
  }

  void _onSelectOption(
    QuizProvider quizProvider,
    QuizQuestion question,
    String option,
  ) {
    quizProvider.submitAnswer(question.id, option);
    final correct = question.isCorrect(option);
    if (_scoredQuestionId != question.id) {
      setState(() {
        _comboCount = correct ? _comboCount + 1 : 0;
        _scoredQuestionId = question.id;
      });
    }
    _showAnswerFeedback(correct);
  }

  void _showAnswerFeedback(bool correct) {
    final t = AppLocalizations.of(context)!;
    final praises = [
      t.feedbackCorrect1,
      t.feedbackCorrect2,
      t.feedbackCorrect3,
    ];
    final message = correct
        ? praises[_random.nextInt(praises.length)]
        : t.feedbackIncorrect;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: correct ? AppTheme.success : AppTheme.danger,
          duration: const Duration(milliseconds: 900),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.12,
            left: 16,
            right: 16,
          ),
          content: Row(
            children: [
              Icon(
                correct ? Icons.check_circle : Icons.cancel,
                color: Colors.white,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<bool?> _confirmExit(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.exitQuizTitle),
        content: Text(t.exitQuizMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: Text(t.exitQuizConfirm),
          ),
        ],
      ),
    );
  }

  void _onNext(QuizProvider quizProvider) {
    _typingController.clear();
    setState(() => _checkedQuestionId = null);
    quizProvider.nextQuestion();
  }

  Future<void> _onSubmit(Deck deck, QuizProvider quizProvider) async {
    final result = quizProvider.calculateResult();
    await quizProvider.saveResult(deck.name, result, widget.quizType);
    if (!mounted) return;

    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.pushReplacement(
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

    return PopScope(
      canPop: deck == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.quizTitle),
          leading: IconButton(
            icon: const BackButtonIcon(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () async {
              if (deck == null) {
                Navigator.of(context).pop();
                return;
              }
              final shouldExit = await _confirmExit(context);
              if (shouldExit == true && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: deck == null
                  ? _QuizMessage(message: t.emptyDeckForStudy)
                  : _buildQuizBody(deck, color),
            ),
          ),
        ),
      ),
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
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: total == 0 ? 0.0 : index / total),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return LinearProgressIndicator(
                  value: animatedValue,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                );
              },
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'quiz_type_icon_${question.type.name}',
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusM,
                            ),
                          ),
                          child: Icon(
                            isMultipleChoice
                                ? Icons.checklist_rounded
                                : Icons.edit_note_rounded,
                            size: 18,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Text(
                        t.questionPosition(index + 1, total),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: color,
                        ),
                      ),
                    ],
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
                    comboCount: _comboCount,
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
    final answered = answer != null;

    return [
      for (final option in question.options)
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS + 4),
          child: _OptionTile(
            text: option,
            selected: option == answer,
            answered: answered,
            isCorrectAnswer: option == question.correctAnswer,
            color: color,
            onTap: answered
                ? null
                : () => _onSelectOption(quizProvider, question, option),
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

/// Thẻ hiển thị từ cần trả lời kèm nút phát âm.
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.term,
    required this.color,
    required this.comboCount,
    required this.onSpeak,
  });

  final String term;
  final Color color;
  final int comboCount;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
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
        ),
        Positioned(
          top: -10,
          right: -4,
          child: AnimatedScale(
            scale: comboCount >= 2 ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                AppLocalizations.of(context)!.comboLabel(comboCount),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Một đáp án của câu hỏi trắc nghiệm.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.text,
    required this.selected,
    required this.answered,
    required this.isCorrectAnswer,
    required this.color,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool answered;
  final bool isCorrectAnswer;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCorrect = answered && isCorrectAnswer;
    final showWrong = answered && selected && !isCorrectAnswer;
    final dimmed = answered && !showCorrect && !showWrong;

    final background = showCorrect
        ? AppTheme.success.withValues(alpha: 0.15)
        : showWrong
        ? AppTheme.danger.withValues(alpha: 0.15)
        : selected && !answered
        ? color.withValues(alpha: 0.12)
        : theme.cardColor;

    final borderColor = showCorrect
        ? AppTheme.success
        : showWrong
        ? AppTheme.danger
        : selected && !answered
        ? color
        : theme.dividerColor.withValues(alpha: 0.5);

    final highlighted = showCorrect || showWrong || (selected && !answered);

    return Opacity(
      opacity: dimmed ? 0.5 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: borderColor,
                width: highlighted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected
                      ? color
                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    text,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: highlighted
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (showCorrect) ...[
                  const SizedBox(width: AppTheme.spacingS),
                  const Icon(Icons.check_circle, color: AppTheme.success),
                ] else if (showWrong) ...[
                  const SizedBox(width: AppTheme.spacingS),
                  const Icon(Icons.cancel, color: AppTheme.danger),
                ],
              ],
            ),
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.back),
            ),
          ],
        ),
      ),
    );
  }
}
