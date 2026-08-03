import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/word.dart';
import '../providers/deck_provider.dart';
import '../providers/study_provider.dart';
import '../theme/app_theme.dart';

/// Chiều rộng tối đa của nội dung, căn giữa trên màn hình rộng.
const double _maxContentWidth = 600;

/// Màn hình học flashcard: lật thẻ để xem nghĩa, vuốt để chuyển thẻ
/// và đánh dấu từ đã thuộc (FR07, FR08).
class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, required this.deckId, this.colorIndex = 0});

  final String deckId;
  final int colorIndex;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final PageController _pageController = PageController();

  /// Người dùng đã lật thẻ lần nào chưa — dùng để đổi dòng gợi ý thao tác.
  bool _hasFlipped = false;

  /// Chỉ báo học xong một lần cho mỗi phiên, tránh hiện SnackBar lặp lại
  /// khi người dùng vuốt qua lại thẻ cuối.
  bool _finishNotified = false;

  @override
  void initState() {
    super.initState();
    // Gọi sau khi khung hình đầu tiên dựng xong để không notifyListeners
    // ngay trong lúc build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deck = context.read<DeckProvider>().getDeckById(widget.deckId);
      if (deck == null) return;
      context.read<StudyProvider>().startStudy(deck);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    final studyProvider = context.read<StudyProvider>();
    studyProvider.goToCard(index);

    if (!_finishNotified && studyProvider.isFinished()) {
      _finishNotified = true;
      final t = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.studyFinished)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = AppTheme.deckColorAt(widget.colorIndex);
    final deck = context.watch<DeckProvider>().getDeckById(widget.deckId);

    if (deck == null) {
      return _StudyMessage(title: t.studyTitle, message: t.emptyDeckForStudy);
    }
    if (deck.words.isEmpty) {
      return _StudyMessage(title: deck.name, message: t.emptyDeckForStudy);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(deck.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: t.close,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          // Nền gradient nhạt lấy từ màu của bộ từ.
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.18), AppTheme.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: Consumer<StudyProvider>(
                builder: (context, studyProvider, _) {
                  // Ở khung hình đầu tiên startStudy chưa chạy nên tạm dùng
                  // dữ liệu từ bộ từ để hiển thị.
                  final words = studyProvider.words.isEmpty
                      ? deck.words
                      : studyProvider.words;
                  final total = words.length;
                  final index = studyProvider.currentIndex.clamp(0, total - 1);
                  final currentWord = words[index];

                  return Column(
                    children: [
                      const SizedBox(height: kToolbarHeight),
                      _StudyProgressBar(
                        color: color,
                        current: index + 1,
                        total: total,
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: total,
                          onPageChanged: _onPageChanged,
                          itemBuilder: (context, position) {
                            final word = words[position];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppTheme.spacingL,
                                AppTheme.spacingM,
                                AppTheme.spacingL,
                                AppTheme.spacingS,
                              ),
                              child: _FlashcardWidget(
                                key: ValueKey(word.id),
                                word: word,
                                color: color,
                                onFlip: () {
                                  if (_hasFlipped) return;
                                  setState(() => _hasFlipped = true);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      _StudyHint(
                        text: _hintText(t, index: index, total: total),
                      ),
                      _StudyActionBar(
                        word: currentWord,
                        position: t.cardPosition(index + 1, total),
                        onToggleLearned: () => context
                            .read<StudyProvider>()
                            .toggleLearned(currentWord.id),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Gợi ý thao tác: chạm để lật khi chưa lật lần nào, sau đó là gợi ý vuốt.
  String _hintText(
    AppLocalizations t, {
    required int index,
    required int total,
  }) {
    if (index == 0 && !_hasFlipped) return t.tapToFlip;
    if (index == 0 && total > 1) return t.swipeHint;
    return '';
  }
}

/// Thanh tiến độ thể hiện vị trí thẻ hiện tại trên tổng số thẻ.
class _StudyProgressBar extends StatelessWidget {
  const _StudyProgressBar({
    required this.color,
    required this.current,
    required this.total,
  });

  final Color color;
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: total == 0 ? 0 : current / total,
          backgroundColor: Colors.white.withValues(alpha: 0.7),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }
}

/// Dòng gợi ý thao tác dưới thẻ. Luôn chiếm chỗ cố định để bố cục
/// không nhảy khi nội dung gợi ý thay đổi.
class _StudyHint extends StatelessWidget {
  const _StudyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 28,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            text,
            key: ValueKey(text),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// Thanh thao tác dưới cùng: nút đánh dấu đã thuộc và vị trí thẻ.
class _StudyActionBar extends StatelessWidget {
  const _StudyActionBar({
    required this.word,
    required this.position,
    required this.onToggleLearned,
  });

  final Word word;
  final String position;
  final VoidCallback onToggleLearned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isLearned = word.isLearned;
    final markColor = isLearned ? AppTheme.success : Colors.grey.shade600;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingL,
        AppTheme.spacingS,
        AppTheme.spacingL,
        AppTheme.spacingL,
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onToggleLearned,
              style: FilledButton.styleFrom(
                backgroundColor: isLearned
                    ? AppTheme.success.withValues(alpha: 0.14)
                    : Colors.white,
                foregroundColor: markColor,
                elevation: 0,
                side: BorderSide(color: markColor.withValues(alpha: 0.35)),
              ),
              icon: Icon(
                isLearned ? Icons.check_circle : Icons.check_circle_outline,
                color: markColor,
              ),
              label: Text(
                isLearned ? t.markNotLearned : t.markLearned,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Text(
            position,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ flashcard hai mặt, chạm để lật bằng hiệu ứng xoay 3D.
class _FlashcardWidget extends StatefulWidget {
  const _FlashcardWidget({
    super.key,
    required this.word,
    required this.color,
    required this.onFlip,
  });

  final Word word;
  final Color color;
  final VoidCallback onFlip;

  @override
  State<_FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<_FlashcardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(covariant _FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Thẻ mới luôn bắt đầu ở mặt trước.
    if (oldWidget.word.id != widget.word.id) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    if (_controller.isAnimating) return;
    if (_controller.value < 0.5) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    widget.onFlip();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final angle = _controller.value * math.pi;
          final showBack = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              // Thêm chiều sâu phối cảnh cho phép xoay.
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: showBack
                // Lật ngược mặt sau lại để chữ không bị soi gương.
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _CardBack(word: widget.word, color: widget.color),
                  )
                : _CardFront(word: widget.word, color: widget.color),
          );
        },
      ),
    );
  }
}

/// Mặt trước: từ tiếng Anh trên nền màu của bộ từ.
class _CardFront extends StatelessWidget {
  const _CardFront({required this.word, required this.color});

  final Word word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhonetic = word.phonetic != null && word.phonetic!.isNotEmpty;

    return _CardShell(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL + 4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, Colors.black, 0.24)!],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word.term,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSizeFor(word.term, maxSize: 46),
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.2,
            ),
          ),
        ),
        if (hasPhonetic) ...[
          const SizedBox(height: AppTheme.spacingM),
          Text(
            word.phonetic!,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

/// Mặt sau: nghĩa tiếng Việt và câu ví dụ trên nền trắng viền màu.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.word, required this.color});

  final Word word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasExample = word.example != null && word.example!.isNotEmpty;

    return _CardShell(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusL + 4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            word.meaning,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSizeFor(word.meaning, maxSize: 36),
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.25,
            ),
          ),
        ),
        if (hasExample) ...[
          const SizedBox(height: AppTheme.spacingL),
          Divider(color: color.withValues(alpha: 0.25), height: 1),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            word.example!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Khung chung của hai mặt thẻ: chiếm hết chỗ trống, bo góc lớn,
/// nội dung căn giữa và cuộn được khi quá dài.
class _CardShell extends StatelessWidget {
  const _CardShell({required this.decoration, required this.children});

  final BoxDecoration decoration;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: decoration,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL + 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        ),
      ),
    );
  }
}

/// Cỡ chữ giảm dần theo độ dài chuỗi để chữ dài vẫn vừa thẻ.
double _fontSizeFor(String text, {required double maxSize}) {
  if (text.length <= 10) return maxSize;
  if (text.length <= 18) return maxSize * 0.78;
  if (text.length <= 30) return maxSize * 0.6;
  return maxSize * 0.46;
}

/// Màn hình thông báo khi không thể bắt đầu phiên học.
class _StudyMessage extends StatelessWidget {
  const _StudyMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withValues(alpha: 0.07),
                ),
                child: Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: AppTheme.primary.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
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
              OutlinedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(t.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//âsasas