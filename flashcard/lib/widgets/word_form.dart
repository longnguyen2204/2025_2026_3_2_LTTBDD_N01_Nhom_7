import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/word.dart';
import '../theme/app_theme.dart';

/// Chiều rộng tối đa của biểu mẫu, căn giữa trên màn hình rộng.
const double _maxFormWidth = 600;

/// Biểu mẫu thêm / sửa một từ vựng, hiển thị dạng modal bottom sheet
/// (FR05, FR06). Widget chỉ thu thập dữ liệu và trả về đối tượng [Word];
/// việc lưu vào provider do màn hình gọi nó đảm nhiệm.
class WordForm extends StatefulWidget {
  const WordForm({super.key, this.initialWord});

  /// Từ đang sửa. Null nghĩa là đang thêm từ mới.
  final Word? initialWord;

  /// Mở biểu mẫu và trả về từ đã nhập, hoặc null nếu người dùng hủy.
  static Future<Word?> show(BuildContext context, {Word? initialWord}) {
    return showModalBottomSheet<Word>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      constraints: const BoxConstraints(maxWidth: _maxFormWidth),
      builder: (sheetContext) => WordForm(initialWord: initialWord),
    );
  }

  @override
  State<WordForm> createState() => _WordFormState();
}

class _WordFormState extends State<WordForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _termController;
  late final TextEditingController _meaningController;
  late final TextEditingController _phoneticController;
  late final TextEditingController _exampleController;

  /// Đang sửa một từ đã có hay đang thêm từ mới.
  bool get _isEditing => widget.initialWord != null;

  @override
  void initState() {
    super.initState();
    final word = widget.initialWord;
    _termController = TextEditingController(text: word?.term ?? '');
    _meaningController = TextEditingController(text: word?.meaning ?? '');
    _phoneticController = TextEditingController(text: word?.phonetic ?? '');
    _exampleController = TextEditingController(text: word?.example ?? '');
  }

  @override
  void dispose() {
    _termController.dispose();
    _meaningController.dispose();
    _phoneticController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  /// Trả về nội dung đã cắt khoảng trắng, hoặc null nếu ô để trống.
  String? _optionalText(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final original = widget.initialWord;
    Navigator.of(context).pop(
      Word(
        // Khi thêm mới, provider sẽ tự sinh id.
        id: original?.id ?? '',
        term: _termController.text.trim(),
        meaning: _meaningController.text.trim(),
        phonetic: _optionalText(_phoneticController),
        example: _optionalText(_exampleController),
        isLearned: original?.isLearned ?? false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      // Đẩy nội dung lên khi bàn phím hiện ra.
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingL,
            AppTheme.spacingS,
            AppTheme.spacingL,
            AppTheme.spacingL,
          ),
          child: Form(
            key: _formKey,
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
                  _isEditing ? t.editWord : t.addWord,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),

                TextFormField(
                  controller: _termController,
                  autofocus: !_isEditing,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.wordTerm,
                    prefixIcon: const Icon(Icons.abc_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.wordTermEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),

                TextFormField(
                  controller: _meaningController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.wordMeaning,
                    prefixIcon: const Icon(Icons.translate_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return t.wordMeaningEmpty;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacingM),

                TextFormField(
                  controller: _phoneticController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: t.wordPhonetic,
                    prefixIcon: const Icon(Icons.record_voice_over_outlined),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingM),

                TextFormField(
                  controller: _exampleController,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: t.wordExample,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.format_quote_rounded),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(t.cancel),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingS + 4),
                    Expanded(
                      child: FilledButton(
                        onPressed: _submit,
                        child: Text(t.save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
