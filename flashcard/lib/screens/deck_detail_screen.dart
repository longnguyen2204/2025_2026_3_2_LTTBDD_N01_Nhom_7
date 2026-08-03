import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/word.dart';
import '../providers/deck_provider.dart';
import '../providers/study_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/word_form.dart';
import 'study_screen.dart';

/// Chiều rộng tối đa của nội dung, căn giữa trên màn hình rộng.
const double _maxContentWidth = 600;

/// Chiều cao phần mở rộng của SliverAppBar.
const double _headerHeight = 190;

/// Số từ tối thiểu để có thể tạo một bài kiểm tra.
const int _minWordsForQuiz = 4;

/// Màn hình chi tiết một bộ từ vựng: danh sách từ bên trong,
/// lối vào phần Học và Kiểm tra (FR04, FR06).
class DeckDetailScreen extends StatelessWidget {
  const DeckDetailScreen({
    super.key,
    required this.deckId,
    this.colorIndex = 0,
  });

  /// Id của bộ từ. Dữ liệu luôn được lấy lại từ provider theo id này
  /// để danh sách cập nhật kịp thời sau mỗi thay đổi.
  final String deckId;

  /// Chỉ số dùng để lấy màu nhận diện của bộ từ.
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = AppTheme.deckColorAt(colorIndex);

    return Scaffold(
      // Lắng nghe cả StudyProvider vì toggleLearned() sửa trạng thái đã thuộc
      // của Word mà không thông báo qua DeckProvider — thiếu nó thì phần
      // tiến độ ở đầu màn hình không cập nhật sau khi học xong.
      body: Consumer2<DeckProvider, StudyProvider>(
        builder: (context, deckProvider, studyProvider, _) {
          final deck = deckProvider.getDeckById(deckId);

          // Bộ từ vừa bị xóa ở màn hình khác.
          if (deck == null) return const _DeckNotFound();

          final words = deck.words;
          final total = deck.wordCount();
          final learned = deck.learnedCount();

          return LayoutBuilder(
            builder: (context, constraints) {
              // Căn giữa nội dung bằng padding hai bên khi màn hình rộng.
              final side = math.max(
                AppTheme.spacingM,
                (constraints.maxWidth - _maxContentWidth) / 2,
              );

              return CustomScrollView(
                slivers: [
                  _DeckHeader(
                    name: deck.name,
                    color: color,
                    total: total,
                    learned: learned,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        side,
                        AppTheme.spacingM,
                        side,
                        AppTheme.spacingS,
                      ),
                      child: _ActionButtons(
                        color: color,
                        wordCount: total,
                        deckId: deckId,
                        colorIndex: colorIndex,
                      ),
                    ),
                  ),
                  if (words.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyWordList(message: t.emptyWordList),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        side,
                        AppTheme.spacingS,
                        side,
                        // Chừa chỗ cho FloatingActionButton.
                        AppTheme.spacingL * 4,
                      ),
                      sliver: SliverList.builder(
                        itemCount: words.length,
                        itemBuilder: (context, index) {
                          final word = words[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppTheme.spacingS + 4,
                            ),
                            child: _WordTile(
                              word: word,
                              color: color,
                              onTap: () => _showWordDetail(context, word),
                              onEdit: () => _onEditWord(context, word),
                              onDelete: () => _onDeleteWord(context, word),
                              confirmDelete: () =>
                                  _confirmDeleteWord(context, word),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: t.addWord,
        onPressed: () => _onAddWord(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- Các hành động trên từ vựng ----------

  /// Mở biểu mẫu thêm từ mới rồi lưu vào bộ từ hiện tại.
  Future<void> _onAddWord(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final word = await WordForm.show(context);
    if (word == null || !context.mounted) return;

    context.read<DeckProvider>().addWord(deckId, word);
    _showSnackBar(context, t.wordAdded);
  }

  /// Mở biểu mẫu sửa từ với dữ liệu hiện có rồi cập nhật lại.
  Future<void> _onEditWord(BuildContext context, Word word) async {
    final t = AppLocalizations.of(context)!;
    final updated = await WordForm.show(context, initialWord: word);
    if (updated == null || !context.mounted) return;

    context.read<DeckProvider>().updateWord(deckId, updated);
    _showSnackBar(context, t.wordUpdated);
  }

  /// Hỏi xác nhận trước khi xóa. Trả về true nếu người dùng đồng ý.
  Future<bool> _confirmDeleteWord(BuildContext context, Word word) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.deleteWordTitle),
          content: Text(t.deleteWordMessage(word.term)),
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

    return confirmed == true;
  }

  /// Xóa từ khỏi bộ và báo cho người dùng.
  void _onDeleteWord(BuildContext context, Word word) {
    final t = AppLocalizations.of(context)!;
    context.read<DeckProvider>().deleteWord(deckId, word.id);
    _showSnackBar(context, t.wordDeleted);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Mở BottomSheet xem chi tiết đầy đủ của một từ.
  Future<void> _showWordDetail(BuildContext context, Word word) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: _maxContentWidth),
      builder: (sheetContext) => _WordDetailSheet(
        word: word,
        color: AppTheme.deckColorAt(colorIndex),
      ),
    );
  }
}

/// Phần đầu màn hình: tên bộ từ trên nền gradient kèm tiến độ học.
class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.name,
    required this.color,
    required this.total,
    required this.learned,
  });

  final String name;
  final Color color;
  final int total;
  final int learned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    // Dòng chữ và thanh tiến độ cùng tính từ một cặp learned/total
    // nên không thể lệch nhau.
    final progress = total == 0 ? 0.0 : learned / total;

    return SliverAppBar(
      pinned: true,
      expandedHeight: _headerHeight,
      backgroundColor: color,
      foregroundColor: Colors.white,
      // Tên bộ từ nằm ngay trên thanh công cụ nên luôn ở trên cùng,
      // và khi cuộn thu gọn thì chỉ còn lại dòng này, không chồng chữ.
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        // Khối tiến độ mờ dần khi thu gọn, nằm dưới tên bộ từ.
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, Color.lerp(color, Colors.black, 0.28)!],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          t.wordCountLabel(total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingS),
                      Flexible(
                        child: Text(
                          t.learnedProgress(learned, total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingS + 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
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

/// Hai nút hành động chính: Học và Kiểm tra.
class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.color,
    required this.wordCount,
    required this.deckId,
    required this.colorIndex,
  });

  final Color color;
  final int wordCount;
  final String deckId;
  final int colorIndex;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final canStudy = wordCount > 0;
    final canQuiz = wordCount >= _minWordsForQuiz;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: canStudy
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => StudyScreen(
                            deckId: deckId,
                            colorIndex: colorIndex,
                          ),
                        ),
                      )
                    : null,
                style: FilledButton.styleFrom(backgroundColor: color),
                icon: const Icon(Icons.school_rounded),
                label: Text(t.study),
              ),
            ),
            const SizedBox(width: AppTheme.spacingS + 4),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canQuiz
                    ? () {
                        // TODO: điều hướng sang QuizScreen khi màn hình này
                        // được thành viên phụ trách hoàn tất.
                      }
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color.withValues(alpha: 0.5)),
                ),
                icon: const Icon(Icons.quiz_rounded),
                label: Text(t.quiz),
              ),
            ),
          ],
        ),
        // Giải thích vì sao nút Kiểm tra đang bị vô hiệu hóa.
        if (canStudy && !canQuiz)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.spacingS),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.notEnoughWords,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Một dòng từ vựng trong danh sách, vuốt sang trái để xóa.
class _WordTile extends StatelessWidget {
  const _WordTile({
    required this.word,
    required this.color,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.confirmDelete,
  });

  final Word word;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function() confirmDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(word.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        decoration: BoxDecoration(
          color: AppTheme.danger,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          onLongPress: onEdit,
          splashColor: color.withValues(alpha: 0.12),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingM - 2),
            child: Row(
              children: [
                // Chữ cái đầu của từ làm điểm nhận diện.
                CircleAvatar(
                  radius: 22,
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Text(
                    word.term.isEmpty ? '?' : word.term[0].toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              word.term,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (word.phonetic != null &&
                              word.phonetic!.isNotEmpty) ...[
                            const SizedBox(width: AppTheme.spacingS),
                            Flexible(
                              child: Text(
                                word.phonetic!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        word.meaning,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                _LearnedIcon(isLearned: word.isLearned),
                _WordMenuButton(onEdit: onEdit, onDelete: onDelete),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon thể hiện trạng thái đã thuộc / chưa thuộc của một từ.
class _LearnedIcon extends StatelessWidget {
  const _LearnedIcon({required this.isLearned});

  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Tooltip(
      message: isLearned ? t.learned : t.notLearned,
      child: Icon(
        isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isLearned ? AppTheme.success : Colors.grey.shade400,
      ),
    );
  }
}

/// Menu sửa / xóa của mỗi dòng từ vựng.
class _WordMenuButton extends StatelessWidget {
  const _WordMenuButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopupMenuButton<_WordAction>(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _WordAction.edit:
            onEdit();
          case _WordAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _WordAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text(t.edit),
          ),
        ),
        PopupMenuItem(
          value: _WordAction.delete,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.delete_outline, color: AppTheme.danger),
            title: Text(
              t.delete,
              style: const TextStyle(color: AppTheme.danger),
            ),
          ),
        ),
      ],
    );
  }
}

enum _WordAction { edit, delete }

/// BottomSheet hiển thị đầy đủ thông tin của một từ vựng.
class _WordDetailSheet extends StatelessWidget {
  const _WordDetailSheet({required this.word, required this.color});

  final Word word;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasPhonetic = word.phonetic != null && word.phonetic!.isNotEmpty;
    final hasExample = word.example != null && word.example!.isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spacingL,
          AppTheme.spacingS,
          AppTheme.spacingL,
          AppTheme.spacingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh kéo của bottom sheet.
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              word.term,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            if (hasPhonetic) ...[
              const SizedBox(height: 4),
              Text(
                word.phonetic!,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingM),
            _LearnedBadge(isLearned: word.isLearned),
            const SizedBox(height: AppTheme.spacingL),
            _DetailSection(label: t.wordMeaning, content: word.meaning),
            if (hasExample) ...[
              const SizedBox(height: AppTheme.spacingM),
              _DetailSection(
                label: t.wordExample,
                content: word.example!,
                italic: true,
              ),
            ],
            const SizedBox(height: AppTheme.spacingL),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.close),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một mục thông tin trong BottomSheet chi tiết từ.
class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.label,
    required this.content,
    this.italic = false,
  });

  final String label;
  final String content;
  final bool italic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.5,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

/// Nhãn trạng thái học của từ trong BottomSheet.
class _LearnedBadge extends StatelessWidget {
  const _LearnedBadge({required this.isLearned});

  final bool isLearned;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final badgeColor = isLearned ? AppTheme.success : Colors.grey.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLearned ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: badgeColor,
          ),
          const SizedBox(width: 6),
          Text(
            isLearned ? t.learned : t.notLearned,
            style: theme.textTheme.labelLarge?.copyWith(color: badgeColor),
          ),
        ],
      ),
    );
  }
}

/// Trạng thái khi bộ từ chưa có từ vựng nào.
class _EmptyWordList extends StatelessWidget {
  const _EmptyWordList({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
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
                Icons.menu_book_rounded,
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
          ],
        ),
      ),
    );
  }
}

/// Hiển thị khi bộ từ không còn tồn tại (đã bị xóa ở màn hình khác).
class _DeckNotFound extends StatelessWidget {
  const _DeckNotFound();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.wordListTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 72,
                color: theme.colorScheme.onSurfaceVariant,
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
