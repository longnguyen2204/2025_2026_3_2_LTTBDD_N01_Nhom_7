import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/deck.dart';
import '../models/word.dart';
import '../providers/deck_provider.dart';
import '../providers/study_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/word_form.dart';
import 'quiz_screen.dart';
import 'study_screen.dart';

/// Chiều rộng tối đa của nội dung, căn giữa trên màn hình rộng.
const double _maxContentWidth = 600;

/// Chiều cao phần mở rộng của SliverAppBar.
const double _headerHeight = 190;

/// Số từ tối thiểu để có thể tạo một bài kiểm tra.
const int _minWordsForQuiz = 4;

/// Kích thước tab nhô lên mang chữ cái đầu của bộ từ, khớp với tab
/// trên thẻ ở màn hình danh sách để hiệu ứng Hero không đổi hình dạng.
const double _tabWidth = 44;
const double _tabHeight = 28;

/// Màn hình chi tiết một bộ từ vựng: danh sách từ bên trong,
/// lối vào phần Học và Kiểm tra (FR04, FR06).
class DeckDetailScreen extends StatefulWidget {
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
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _searchQuery = '';
  WordFilter _filter = WordFilter.all;
  WordSortOption _sort = WordSortOption.termAsc;
  bool _isFabExtended = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse && _isFabExtended) {
        setState(() => _isFabExtended = false);
      } else if (direction == ScrollDirection.forward && !_isFabExtended) {
        setState(() => _isFabExtended = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Danh sách từ hiển thị: lọc theo từ khóa, rồi theo trạng thái,
  /// rồi sắp xếp. Ba bước được ghép thủ công trên deck.words vì các hàm
  /// tương ứng của provider mỗi hàm đều tự đọc lại toàn bộ danh sách gốc.
  List<Word> _getDisplayWords(Deck deck) {
    var result = List<Word>.from(deck.words);

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where(
            (w) =>
                w.term.toLowerCase().contains(query) ||
                w.meaning.toLowerCase().contains(query),
          )
          .toList();
    }

    switch (_filter) {
      case WordFilter.all:
        break;
      case WordFilter.learned:
        result = result.where((w) => w.isLearned).toList();
      case WordFilter.notLearned:
        result = result.where((w) => !w.isLearned).toList();
      case WordFilter.favorite:
        result = result.where((w) => w.isFavorite).toList();
    }

    switch (_sort) {
      case WordSortOption.termAsc:
        result.sort(
          (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
        );
      case WordSortOption.termDesc:
        result.sort(
          (a, b) => b.term.toLowerCase().compareTo(a.term.toLowerCase()),
        );
      case WordSortOption.learnedFirst:
        result.sort(
          (a, b) => (b.isLearned ? 1 : 0).compareTo(a.isLearned ? 1 : 0),
        );
      case WordSortOption.unlearnedFirst:
        result.sort(
          (a, b) => (a.isLearned ? 1 : 0).compareTo(b.isLearned ? 1 : 0),
        );
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final color = AppTheme.deckColorAt(widget.colorIndex);

    return Scaffold(
      // Lắng nghe cả StudyProvider vì toggleLearned() sửa trạng thái đã thuộc
      // của Word mà không thông báo qua DeckProvider — thiếu nó thì phần
      // tiến độ ở đầu màn hình không cập nhật sau khi học xong.
      body: Consumer2<DeckProvider, StudyProvider>(
        builder: (context, deckProvider, studyProvider, _) {
          final deck = deckProvider.getDeckById(widget.deckId);

          // Bộ từ vừa bị xóa ở màn hình khác.
          if (deck == null) return const _DeckNotFound();

          final words = deck.words;
          final displayWords = _getDisplayWords(deck);
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
                controller: _scrollController,
                slivers: [
                  _DeckHeader(
                    deckId: widget.deckId,
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ActionButtons(
                            color: color,
                            wordCount: total,
                            deckId: widget.deckId,
                            colorIndex: widget.colorIndex,
                          ),
                          if (words.isNotEmpty) ...[
                            const SizedBox(height: AppTheme.spacingM),
                            _SearchField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  setState(() => _searchQuery = value),
                              onClear: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                            const SizedBox(height: AppTheme.spacingS),
                            _FilterSortBar(
                              filter: _filter,
                              sort: _sort,
                              onFilterChanged: (value) =>
                                  setState(() => _filter = value),
                              onSortChanged: (value) =>
                                  setState(() => _sort = value),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (words.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyWordList(message: t.emptyWordList),
                    )
                  else if (displayWords.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyWordList(
                        message: t.noSearchResults,
                        icon: Icons.search_off_rounded,
                      ),
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
                        itemCount: displayWords.length,
                        itemBuilder: (context, index) {
                          final word = displayWords[index];
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
                              onToggleFavorite: () => context
                                  .read<DeckProvider>()
                                  .toggleFavorite(widget.deckId, word.id),
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
      floatingActionButton: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        child: _isFabExtended
            ? FloatingActionButton.extended(
                onPressed: () => _onAddWord(context),
                icon: const Icon(Icons.add),
                label: Text(t.addWord),
              )
            : FloatingActionButton(
                tooltip: t.addWord,
                onPressed: () => _onAddWord(context),
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  // ---------- Các hành động trên từ vựng ----------

  /// Mở biểu mẫu thêm từ mới rồi lưu vào bộ từ hiện tại.
  Future<void> _onAddWord(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final word = await WordForm.show(context);
    if (word == null || !context.mounted) return;

    context.read<DeckProvider>().addWord(widget.deckId, word);
    _showSnackBar(context, t.wordAdded);
  }

  /// Mở biểu mẫu sửa từ với dữ liệu hiện có rồi cập nhật lại.
  Future<void> _onEditWord(BuildContext context, Word word) async {
    final t = AppLocalizations.of(context)!;
    final updated = await WordForm.show(context, initialWord: word);
    if (updated == null || !context.mounted) return;

    context.read<DeckProvider>().updateWord(widget.deckId, updated);
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
    context.read<DeckProvider>().deleteWord(widget.deckId, word.id);
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
      constraints: const BoxConstraints(maxWidth: _maxContentWidth),
      builder: (sheetContext) => _WordDetailSheet(
        word: word,
        color: AppTheme.deckColorAt(widget.colorIndex),
      ),
    );
  }
}

/// Phần đầu màn hình: tên bộ từ trên nền gradient kèm tiến độ học.
class _DeckHeader extends StatelessWidget {
  const _DeckHeader({
    required this.deckId,
    required this.name,
    required this.color,
    required this.total,
    required this.learned,
  });

  final String deckId;
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
                  Hero(
                    tag: 'deck_icon_$deckId',
                    child: Container(
                      width: _tabWidth,
                      height: _tabHeight,
                      decoration: BoxDecoration(
                        color: Color.lerp(color, Colors.black, 0.45)!,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        name.isEmpty ? '?' : name[0].toUpperCase(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
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
                    ? () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuizScreen(
                            deckId: deckId,
                            colorIndex: colorIndex,
                          ),
                        ),
                      )
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

/// Ô tìm kiếm từ vựng theo từ hoặc theo nghĩa.
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: t.searchWords,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                tooltip: t.cancel,
                onPressed: onClear,
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: AppTheme.spacingS + 4,
        ),
      ),
    );
  }
}

/// Hàng chọn tiêu chí lọc và tiêu chí sắp xếp danh sách từ.
class _FilterSortBar extends StatelessWidget {
  const _FilterSortBar({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final WordFilter filter;
  final WordSortOption sort;
  final ValueChanged<WordFilter> onFilterChanged;
  final ValueChanged<WordSortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<WordFilter>(
            segments: [
              ButtonSegment(value: WordFilter.all, label: Text(t.filterAll)),
              ButtonSegment(
                value: WordFilter.learned,
                label: Text(t.filterLearned),
              ),
              ButtonSegment(
                value: WordFilter.notLearned,
                label: Text(t.filterNotLearned),
              ),
              ButtonSegment(
                value: WordFilter.favorite,
                label: Text(t.filterFavorite),
              ),
            ],
            selected: {filter},
            onSelectionChanged: (selection) => onFilterChanged(selection.first),
            showSelectedIcon: false,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        _DropdownShell(
          icon: Icons.sort_rounded,
          child: DropdownButton<WordSortOption>(
            value: sort,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            onChanged: (value) {
              if (value != null) onSortChanged(value);
            },
            items: [
              for (final option in WordSortOption.values)
                DropdownMenuItem(
                  value: option,
                  child: Text(
                    _sortLabel(t, option),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Khung bo góc bọc quanh mỗi DropdownButton cho đồng bộ với ô tìm kiếm.
class _DropdownShell extends StatelessWidget {
  const _DropdownShell({required this.icon, required this.child});

  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingS + 4),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(child: child),
        ],
      ),
    );
  }
}

String _sortLabel(AppLocalizations t, WordSortOption sort) {
  switch (sort) {
    case WordSortOption.termAsc:
      return t.sortTermAsc;
    case WordSortOption.termDesc:
      return t.sortTermDesc;
    case WordSortOption.learnedFirst:
      return t.sortLearnedFirst;
    case WordSortOption.unlearnedFirst:
      return t.sortUnlearnedFirst;
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
    required this.onToggleFavorite,
  });

  final Word word;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<bool> Function() confirmDelete;
  final VoidCallback onToggleFavorite;

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
                                style: AppTheme.monoTextStyle(
                                  fontSize:
                                      theme.textTheme.bodySmall?.fontSize ?? 12,
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
                _FavoriteButton(
                  isFavorite: word.isFavorite,
                  onPressed: onToggleFavorite,
                ),
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
        color: isLearned
            ? AppTheme.success
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }
}

/// Nút đánh dấu / bỏ đánh dấu từ yêu thích.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return IconButton(
      tooltip: t.filterFavorite,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite
            ? AppTheme.danger
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
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
                style: AppTheme.monoTextStyle(
                  fontSize: theme.textTheme.titleSmall?.fontSize ?? 14,
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
    final badgeColor = isLearned
        ? AppTheme.success
        : theme.colorScheme.onSurface.withValues(alpha: 0.5);

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
  const _EmptyWordList({
    required this.message,
    this.icon = Icons.menu_book_rounded,
  });

  final String message;
  final IconData icon;

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
                icon,
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
