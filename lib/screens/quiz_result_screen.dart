import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/quiz_question.dart';
import '../models/quiz_result.dart';
import '../models/quiz_type.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';

const double _maxContentWidth = 600;
const Color _warningColor = Color(0xFFF59E0B);

/// Màn hình kết quả sau khi nộp bài trắc nghiệm (FR10).
class QuizResultScreen extends StatelessWidget {
  const QuizResultScreen({
    super.key,
    required this.result,
    required this.deckId,
    required this.colorIndex,
  });

  final QuizResult result;
  final String deckId;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final score = result.score();
    final scoreColor = score >= 0.8
        ? AppTheme.success
        : score >= 0.5
        ? _warningColor
        : AppTheme.danger;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.quizResultTitle),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ScoreSummary(
                    score: score,
                    color: scoreColor,
                    label: t.yourScore,
                    detail: t.correctCount(
                      result.correctAnswers,
                      result.totalQuestions,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    t.reviewAnswers,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS + 4),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.questions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppTheme.spacingS + 4),
                    itemBuilder: (context, index) {
                      final question = result.questions[index];
                      final answer = result.answerOf(question.id);

                      return _AnswerCard(
                        question: question,
                        answer: answer,
                        correct: _isAnswerCorrect(question, answer),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => QuizScreen(
                                deckId: deckId,
                                colorIndex: colorIndex,
                              ),
                            ),
                          ),
                          child: Text(t.retakeQuiz),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Expanded(
                        child: FilledButton(
                          // QuizScreen đã bị thay thế bởi màn hình này nên
                          // pop một lần là về thẳng DeckDetailScreen.
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(t.backToDeck),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Câu điền từ được chấm bằng cách chuẩn hóa hai chuỗi trước khi so sánh,
/// giống QuizProvider — isCorrect() so khớp tuyệt đối nên sẽ báo sai lệch.
bool _isAnswerCorrect(QuizQuestion question, String? answer) {
  if (answer == null) return false;
  if (question.type == QuizType.typing) {
    return answer.trim().toLowerCase() ==
        question.correctAnswer.trim().toLowerCase();
  }
  return question.isCorrect(answer);
}

/// Vòng tròn điểm số ở đầu trang.
class _ScoreSummary extends StatelessWidget {
  const _ScoreSummary({
    required this.score,
    required this.color,
    required this.label,
    required this.detail,
  });

  final double score;
  final Color color;
  final String label;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        SizedBox(
          width: 180,
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: score,
                  strokeWidth: 12,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '${(score * 100).round()}%',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Text(
          detail,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Một dòng trong phần xem lại đáp án.
class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.question,
    required this.answer,
    required this.correct,
  });

  final QuizQuestion question;
  final String? answer;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusColor = correct ? AppTheme.success : AppTheme.danger;

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              correct ? Icons.check_circle : Icons.cancel,
              color: statusColor,
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.word.term,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _AnswerLine(
                    label: t.yourAnswer,
                    value: answer ?? t.notAnswered,
                    color: statusColor,
                  ),
                  const SizedBox(height: 2),
                  _AnswerLine(
                    label: t.correctAnswer,
                    value: question.correctAnswer,
                    color: AppTheme.success,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerLine extends StatelessWidget {
  const _AnswerLine({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
