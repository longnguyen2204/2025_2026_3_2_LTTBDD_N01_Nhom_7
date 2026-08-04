import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/deck.dart';
import '../models/quiz_history.dart';
import '../providers/deck_provider.dart';
import '../providers/quiz_provider.dart';
import '../theme/app_theme.dart';

const double _maxContentWidth = 600;

/// Màn hình thống kê tiến độ học và kết quả làm bài (FR20).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.statisticsTitle)),
      body: Consumer2<DeckProvider, QuizProvider>(
        builder: (context, deckProvider, quizProvider, _) {
          final decks = deckProvider.getDecks();
          final history = quizProvider.getHistory();

          if (decks.isEmpty) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: _EmptyStatistics(message: t.emptyStatistics),
              ),
            );
          }

          final totalWords = _totalWords(decks);
          final learned = deckProvider.totalLearnedWords();
          final notLearned = totalWords - learned;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SummaryGrid(
                      deckCount: decks.length,
                      wordCount: totalWords,
                      learnedCount: learned,
                      quizCount: history.length,
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    _SectionTitle(title: t.overallProgress),
                    const SizedBox(height: AppTheme.spacingM),
                    if (totalWords > 0)
                      _LearnedPieChart(learned: learned, notLearned: notLearned)
                    else
                      _MutedText(text: t.emptyStatistics),
                    const SizedBox(height: AppTheme.spacingL),
                    _SectionTitle(title: t.progressByDeck),
                    const SizedBox(height: AppTheme.spacingM),
                    ..._buildDeckProgress(decks, deckProvider),
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.spacingL),
                      _AverageScoreCard(
                        label: t.averageScore,
                        percent: _averageScorePercent(history),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingL),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDeckProgress(List<Deck> decks, DeckProvider provider) {
    final sorted = List<Deck>.from(decks)
      ..sort(
        (a, b) =>
            provider.deckProgress(b.id).compareTo(provider.deckProgress(a.id)),
      );

    return [
      for (var i = 0; i < sorted.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS + 4),
          child: _DeckProgressCard(
            deck: sorted[i],
            progress: provider.deckProgress(sorted[i].id),
            color: AppTheme.deckColorAt(decks.indexOf(sorted[i])),
          ),
        ),
    ];
  }
}

int _totalWords(List<Deck> decks) {
  return decks.fold(0, (sum, deck) => sum + deck.wordCount());
}

/// Trung bình cộng tỉ lệ đúng của từng lượt làm bài (không phải tổng số câu
/// đúng chia tổng số câu), nên mỗi lượt có trọng số bằng nhau.
double _averageScorePercent(List<QuizHistory> history) {
  final valid = history.where((item) => item.totalQuestions > 0).toList();
  if (valid.isEmpty) return 0;

  final sum = valid.fold<double>(
    0,
    (total, item) => total + item.score / item.totalQuestions,
  );
  return sum / valid.length * 100;
}

/// Bốn ô số liệu tổng quan ở đầu trang.
class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.deckCount,
    required this.wordCount,
    required this.learnedCount,
    required this.quizCount,
  });

  final int deckCount;
  final int wordCount;
  final int learnedCount;
  final int quizCount;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: AppTheme.spacingS + 4,
      mainAxisSpacing: AppTheme.spacingS + 4,
      childAspectRatio: 1.6,
      children: [
        _StatTile(
          icon: Icons.style_rounded,
          value: '$deckCount',
          label: t.totalDecks,
          color: AppTheme.primary,
        ),
        _StatTile(
          icon: Icons.menu_book_rounded,
          value: '$wordCount',
          label: t.totalWords,
          color: AppTheme.secondary,
        ),
        _StatTile(
          icon: Icons.check_circle_rounded,
          value: '$learnedCount',
          label: t.totalLearned,
          color: AppTheme.success,
        ),
        _StatTile(
          icon: Icons.quiz_rounded,
          value: '$quizCount',
          label: t.quizzesCompleted,
          color: AppTheme.deckColorAt(3),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM - 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Biểu đồ tròn tỉ lệ đã thuộc / chưa thuộc kèm chú thích.
class _LearnedPieChart extends StatelessWidget {
  const _LearnedPieChart({required this.learned, required this.notLearned});

  final int learned;
  final int notLearned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final notLearnedColor = Colors.grey.shade300;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 34,
                  sections: [
                    PieChartSectionData(
                      value: learned.toDouble(),
                      color: AppTheme.success,
                      radius: 30,
                      showTitle: false,
                    ),
                    PieChartSectionData(
                      value: notLearned.toDouble(),
                      color: notLearnedColor,
                      radius: 30,
                      showTitle: false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendRow(
                    color: AppTheme.success,
                    label: t.learned,
                    value: learned,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  _LegendRow(
                    color: notLearnedColor,
                    label: t.notLearned,
                    value: notLearned,
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

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacingS),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
        Text(
          '$value',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Một dòng tiến độ của mỗi bộ từ.
class _DeckProgressCard extends StatelessWidget {
  const _DeckProgressCard({
    required this.deck,
    required this.progress,
    required this.color,
  });

  final Deck deck;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Card(
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    deck.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  '${(progress * 100).round()}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.learnedProgress(deck.learnedCount(), deck.wordCount()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Điểm trung bình của toàn bộ lượt làm bài đã lưu.
class _AverageScoreCard extends StatelessWidget {
  const _AverageScoreCard({required this.label, required this.percent});

  final String label;
  final double percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: AppTheme.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              '${percent.round()}%',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _MutedText extends StatelessWidget {
  const _MutedText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Trạng thái khi chưa có bộ từ nào để thống kê.
class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics({required this.message});

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
                Icons.insert_chart_outlined_rounded,
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
