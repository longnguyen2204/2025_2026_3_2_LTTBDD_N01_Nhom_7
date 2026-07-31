import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/deck.dart';
import '../providers/deck_provider.dart';
import '../theme/app_theme.dart';
import 'deck_detail_screen.dart';

/// Chiều rộng tối đa của nội dung — trên màn hình rộng (tablet, web)
/// danh sách nằm giữa thay vì kéo giãn hết cỡ.
const double _maxContentWidth = 600;

/// Khoảng cách giữa hai thẻ bộ từ liền nhau.
const double _cardGap = 14;

/// Padding bên trong mỗi thẻ bộ từ.
const double _cardPadding = 18;

/// Độ rộng dải màu nhận diện ở cạnh trái mỗi thẻ.
const double _stripeWidth = 6;

/// Màn hình chính của ứng dụng: hiển thị danh sách bộ từ vựng,
/// cho phép tạo mới, sửa tên và xóa bộ từ (FR01, FR02, FR03).
class DeckListScreen extends StatelessWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.deckListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: t.statistics,
            // TODO: điều hướng sang StatisticsScreen khi màn hình này hoàn tất.
            onPressed: null,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: t.settings,
            // TODO: điều hướng sang SettingsScreen khi màn hình này hoàn tất.
            onPressed: null,
          ),
        ],
      ),
      body: Consumer<DeckProvider>(
        builder: (context, deckProvider, _) {
          final decks = deckProvider.getDecks();

          if (decks.isEmpty) {
            return _CenteredContent(
              child: _EmptyDeckList(message: t.emptyDeckList),
            );
          }

          return _CenteredContent(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM,
                AppTheme.spacingM,
                AppTheme.spacingM,
                // Chừa chỗ cho FloatingActionButton ở cuối danh sách.
                AppTheme.spacingL * 4,
              ),
              itemCount: decks.length,
              itemBuilder: (context, index) {
                final deck = decks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: _cardGap),
                  child: _DeckCard(
                    deck: deck,
                    color: AppTheme.deckColorAt(index),
                    progress: deckProvider.deckProgress(deck.id),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DeckDetailScreen(
                          deckId: deck.id,
                          colorIndex: index,
                        ),
                      ),
                    ),
                    onEdit: () => _onEditDeck(context, deck),
                    onDelete: () => _onDeleteDeck(context, deck),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: t.createDeck,
        onPressed: () => _onCreateDeck(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------- Các hành động trên bộ từ ----------

  Future<void> _onCreateDeck(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final name = await _showDeckNameDialog(context, title: t.createDeck);
    if (name == null || !context.mounted) return;

    context.read<DeckProvider>().addDeck(name);
    _showSnackBar(context, t.deckCreated);
  }

  Future<void> _onEditDeck(BuildContext context, Deck deck) async {
    final t = AppLocalizations.of(context)!;
    final name = await _showDeckNameDialog(
      context,
      title: t.editDeck,
      initialName: deck.name,
    );
    if (name == null || !context.mounted) return;

    context.read<DeckProvider>().updateDeck(
      Deck(id: deck.id, name: name, words: deck.words),
    );
    _showSnackBar(context, t.deckUpdated);
  }

  Future<void> _onDeleteDeck(BuildContext context, Deck deck) async {
    final t = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.deleteDeckTitle),
          content: Text(t.deleteDeckMessage(deck.name)),
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

    context.read<DeckProvider>().deleteDeck(deck.id);
    _showSnackBar(context, t.deckDeleted);
  }

  /// Mở hộp thoại nhập tên bộ từ. Trả về tên đã nhập, hoặc null nếu hủy.
  Future<String?> _showDeckNameDialog(
    BuildContext context, {
    required String title,
    String? initialName,
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) =>
          _DeckNameDialog(title: title, initialName: initialName),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Giới hạn chiều rộng nội dung và căn giữa trên màn hình rộng.
class _CenteredContent extends StatelessWidget {
  const _CenteredContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }
}

/// Trạng thái khi chưa có bộ từ vựng nào.
class _EmptyDeckList extends StatelessWidget {
  const _EmptyDeckList({required this.message});

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
                Icons.style_rounded,
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

/// Thẻ hiển thị thông tin tóm tắt của một bộ từ vựng.
class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.color,
    required this.progress,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Deck deck;
  final Color color;
  final double progress;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final total = deck.wordCount();
    final learned = deck.learnedCount();

    return DecoratedBox(
      // Bóng nhẹ để thẻ nổi khỏi nền mà không bị nặng nề.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.05),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dải màu nhận diện bộ từ ở cạnh trái.
                Container(width: _stripeWidth, color: color),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(_cardPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Điểm nhấn thị giác mang màu của bộ từ.
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.style_rounded,
                                color: color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    deck.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingS),
                                  _WordCountChip(
                                    label: t.wordCountLabel(total),
                                    color: color,
                                  ),
                                ],
                              ),
                            ),
                            _DeckMenuButton(onEdit: onEdit, onDelete: onDelete),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            // Khi chưa thuộc từ nào, nền thanh nhạt hơn hẳn
                            // để không bị nhìn nhầm thành đã hoàn thành.
                            backgroundColor: progress == 0
                                ? Colors.grey.withValues(alpha: 0.16)
                                : color.withValues(alpha: 0.16),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          t.learnedProgress(learned, total),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Nhãn nhỏ hiển thị số lượng từ trong bộ.
class _WordCountChip extends StatelessWidget {
  const _WordCountChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Menu sửa / xóa hiển thị ở góc phải mỗi thẻ bộ từ.
class _DeckMenuButton extends StatelessWidget {
  const _DeckMenuButton({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return PopupMenuButton<_DeckAction>(
      icon: const Icon(Icons.more_vert),
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _DeckAction.edit:
            onEdit();
          case _DeckAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _DeckAction.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: Text(t.edit),
          ),
        ),
        PopupMenuItem(
          value: _DeckAction.delete,
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

enum _DeckAction { edit, delete }

/// Hộp thoại nhập / sửa tên bộ từ, có kiểm tra tên rỗng.
class _DeckNameDialog extends StatefulWidget {
  const _DeckNameDialog({required this.title, this.initialName});

  final String title;
  final String? initialName;

  @override
  State<_DeckNameDialog> createState() => _DeckNameDialogState();
}

class _DeckNameDialogState extends State<_DeckNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: t.deckName,
            hintText: t.deckNameHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return t.deckNameEmpty;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(t.save)),
      ],
    );
  }
}
