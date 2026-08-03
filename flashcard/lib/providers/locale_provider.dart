import 'package:flutter/material.dart';

/// Quản lý ngôn ngữ hiển thị của toàn ứng dụng (Tiếng Việt / Tiếng Anh).
/// Được MaterialApp gốc sử dụng để xác định locale hiện tại.
class LocaleProvider extends ChangeNotifier {
  /// Danh sách ngôn ngữ ứng dụng hỗ trợ.
  static const List<Locale> supportedLocales = [Locale('vi'), Locale('en')];

  Locale _currentLocale = const Locale('vi');

  Locale get currentLocale => _currentLocale;

  /// Đang hiển thị bằng tiếng Việt hay không — tiện cho UI hiển thị nhãn.
  bool get isVietnamese => _currentLocale.languageCode == 'vi';

  /// Đổi sang một ngôn ngữ cụ thể. Bỏ qua nếu ngôn ngữ không được hỗ trợ.
  void changeLocale(Locale locale) {
    final isSupported = supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
    if (!isSupported) return;
    if (locale.languageCode == _currentLocale.languageCode) return;

    _currentLocale = locale;
    notifyListeners();
  }

  /// Chuyển đổi qua lại giữa tiếng Việt và tiếng Anh.
  void toggleLanguage() {
    _currentLocale = isVietnamese ? const Locale('en') : const Locale('vi');
    notifyListeners();
  }
}
