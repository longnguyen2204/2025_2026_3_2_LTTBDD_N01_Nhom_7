import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import '../models/word.dart';
import '../repositories/deck_repository.dart';

/// Tiêu chí lọc danh sách từ vựng theo trạng thái học.
enum WordFilter { all, learned, notLearned, favorite }

/// Tiêu chí sắp xếp danh sách từ vựng.
enum WordSortOption { termAsc, termDesc, learnedFirst, unlearnedFirst }

/// Quản lý danh sách bộ từ vựng và các từ vựng bên trong mỗi bộ.
/// Thuộc tầng State/Logic trong kiến trúc phân lớp.
class DeckProvider extends ChangeNotifier {
  final List<Deck> _decks = [];

  /// Bộ đếm dùng để sinh id duy nhất cho Deck và Word.
  int _idCounter = 0;

  final DeckRepository _repository = DeckRepository();

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  String? _profileId;

  DeckProvider();

  Future<void> setProfile(String profileId) async {
    _profileId = profileId;
    _isLoaded = false;
    notifyListeners();

    final loaded = await _repository.loadDecks(profileId);
    if (loaded.isEmpty) {
      if (profileId == 'profile_1') {
        _decks.clear();
        _seedData();
        await _repository.saveDecks(profileId, _decks);
      } else {
        _decks.clear();
      }
    } else {
      _decks
        ..clear()
        ..addAll(loaded);

      var maxId = 0;
      for (final deck in _decks) {
        maxId = _maxSuffix(deck.id, maxId);
        for (final word in deck.words) {
          maxId = _maxSuffix(word.id, maxId);
        }
      }
      _idCounter = maxId;
    }
    _isLoaded = true;
    notifyListeners();
  }

  void _persist() {
    if (_profileId == null) return;
    unawaited(_repository.saveDecks(_profileId!, _decks));
  }

  String _generateId(String prefix) {
    _idCounter++;
    return '${prefix}_$_idCounter';
  }

  int _maxSuffix(String id, int current) {
    final parts = id.split('_');
    final suffix = int.tryParse(parts.last);
    if (suffix == null) return current;
    return suffix > current ? suffix : current;
  }

  // ---------- Quản lý bộ từ vựng ----------

  /// Trả về danh sách bộ từ vựng (chỉ đọc, tránh UI sửa trực tiếp).
  List<Deck> getDecks() => List.unmodifiable(_decks);

  /// Tìm một bộ từ theo id, trả về null nếu không tồn tại.
  Deck? getDeckById(String id) {
    for (final deck in _decks) {
      if (deck.id == id) return deck;
    }
    return null;
  }

  /// Tạo mới một bộ từ vựng.
  void addDeck(String name) {
    _decks.add(Deck(id: _generateId('deck'), name: name));
    notifyListeners();
    _persist();
  }

  /// Cập nhật thông tin một bộ từ vựng đã có.
  void updateDeck(Deck deck) {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index == -1) return;
    _decks[index] = deck;
    notifyListeners();
    _persist();
  }

  /// Xóa một bộ từ vựng theo id.
  void deleteDeck(String id) {
    _decks.removeWhere((d) => d.id == id);
    notifyListeners();
    _persist();
  }

  // ---------- Quản lý từ vựng trong bộ ----------

  /// Thêm từ vựng mới vào bộ. Provider tự sinh id cho từ.
  void addWord(String deckId, Word word) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    deck.addWord(
      Word(
        id: _generateId('word'),
        term: word.term,
        meaning: word.meaning,
        phonetic: word.phonetic,
        example: word.example,
        isLearned: word.isLearned,
        isFavorite: word.isFavorite,
      ),
    );
    notifyListeners();
    _persist();
  }

  /// Cập nhật một từ vựng đã có trong bộ.
  void updateWord(String deckId, Word word) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    deck.updateWord(word);
    notifyListeners();
    _persist();
  }

  /// Xóa một từ vựng khỏi bộ.
  void deleteWord(String deckId, String wordId) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    deck.removeWord(wordId);
    notifyListeners();
    _persist();
  }

  // ---------- Tìm kiếm, lọc, sắp xếp ----------

  /// Tìm các từ trong bộ có từ hoặc nghĩa khớp với [query]
  /// (không phân biệt hoa thường). Trả về danh sách rỗng nếu
  /// bộ từ không tồn tại hoặc [query] rỗng thì trả về toàn bộ từ.
  List<Word> searchWords(String deckId, String query) {
    final deck = getDeckById(deckId);
    if (deck == null) return [];
    if (query.trim().isEmpty) return List.unmodifiable(deck.words);

    final lowerQuery = query.toLowerCase().trim();
    return deck.words
        .where(
          (w) =>
              w.term.toLowerCase().contains(lowerQuery) ||
              w.meaning.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Lọc danh sách từ trong bộ theo [filter].
  List<Word> filterWords(String deckId, WordFilter filter) {
    final deck = getDeckById(deckId);
    if (deck == null) return [];

    switch (filter) {
      case WordFilter.all:
        return List.unmodifiable(deck.words);
      case WordFilter.learned:
        return deck.words.where((w) => w.isLearned).toList();
      case WordFilter.notLearned:
        return deck.words.where((w) => !w.isLearned).toList();
      case WordFilter.favorite:
        return deck.words.where((w) => w.isFavorite).toList();
    }
  }

  /// Sắp xếp danh sách từ trong bộ theo [option].
  /// Trả về bản sao đã sắp xếp, không thay đổi thứ tự gốc trong [Deck].
  List<Word> sortWords(String deckId, WordSortOption option) {
    final deck = getDeckById(deckId);
    if (deck == null) return [];

    final sorted = List<Word>.from(deck.words);
    switch (option) {
      case WordSortOption.termAsc:
        sorted.sort(
          (a, b) => a.term.toLowerCase().compareTo(b.term.toLowerCase()),
        );
      case WordSortOption.termDesc:
        sorted.sort(
          (a, b) => b.term.toLowerCase().compareTo(a.term.toLowerCase()),
        );
      case WordSortOption.learnedFirst:
        sorted.sort(
          (a, b) => (b.isLearned ? 1 : 0).compareTo(a.isLearned ? 1 : 0),
        );
      case WordSortOption.unlearnedFirst:
        sorted.sort(
          (a, b) => (a.isLearned ? 1 : 0).compareTo(b.isLearned ? 1 : 0),
        );
    }
    return sorted;
  }

  /// Đảo trạng thái yêu thích của một từ trong bộ.
  void toggleFavorite(String deckId, String wordId) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    for (final word in deck.words) {
      if (word.id == wordId) {
        word.toggleFavorite();
        _persist();
        notifyListeners();
        return;
      }
    }
  }

  // ---------- Thống kê ----------

  /// Tổng số từ đã thuộc trên toàn bộ các bộ từ.
  int totalLearnedWords() {
    var total = 0;
    for (final deck in _decks) {
      total += deck.learnedCount();
    }
    return total;
  }

  /// Tiến độ học của một bộ từ, giá trị từ 0.0 đến 1.0.
  double deckProgress(String deckId) {
    final deck = getDeckById(deckId);
    if (deck == null || deck.wordCount() == 0) return 0.0;
    return deck.learnedCount() / deck.wordCount();
  }

  // ---------- Dữ liệu mẫu ----------

  /// Khởi tạo sẵn một số bộ từ vựng mẫu để phục vụ kiểm thử chức năng.
  /// Dữ liệu chỉ tồn tại trong bộ nhớ suốt phiên sử dụng.
  void _seedData() {
    _addSeedDeck('Giao tiếp hằng ngày', [
      ['hello', 'xin chào', '/həˈloʊ/', 'Hello, how are you?'],
      ['goodbye', 'tạm biệt', '/ˌɡʊdˈbaɪ/', 'Goodbye, see you tomorrow.'],
      ['thank you', 'cảm ơn', '/ˈθæŋk juː/', 'Thank you for your help.'],
      ['sorry', 'xin lỗi', '/ˈsɑːri/', 'Sorry, I am late.'],
      ['please', 'làm ơn', '/pliːz/', 'Please close the door.'],
      ['friend', 'bạn bè', '/frend/', 'She is my best friend.'],
    ]);

    _addSeedDeck('Du lịch', [
      ['airport', 'sân bay', '/ˈerpɔːrt/', 'We arrived at the airport early.'],
      ['hotel', 'khách sạn', '/hoʊˈtel/', 'The hotel is near the beach.'],
      ['ticket', 'vé', '/ˈtɪkɪt/', 'I bought a ticket to Da Nang.'],
      ['luggage', 'hành lý', '/ˈlʌɡɪdʒ/', 'My luggage is very heavy.'],
      ['passport', 'hộ chiếu', '/ˈpæspɔːrt/', 'Please show me your passport.'],
      ['map', 'bản đồ', '/mæp/', 'He is looking at the map.'],
    ]);

    _addSeedDeck('Công nghệ', [
      ['computer', 'máy tính', '/kəmˈpjuːtər/', 'I use a computer every day.'],
      ['software', 'phần mềm', '/ˈsɔːftwer/', 'This software is free.'],
      ['network', 'mạng lưới', '/ˈnetwɜːrk/', 'The network is very slow.'],
      [
        'database',
        'cơ sở dữ liệu',
        '/ˈdeɪtəbeɪs/',
        'The data is in a database.',
      ],
      ['password', 'mật khẩu', '/ˈpæswɜːrd/', 'Do not share your password.'],
      ['device', 'thiết bị', '/dɪˈvaɪs/', 'This device works well.'],
    ]);
  }

  /// Tạo một bộ từ mẫu kèm danh sách từ vựng.
  /// Mỗi phần tử của [rawWords] có dạng: [từ, nghĩa, phiên âm, ví dụ].
  void _addSeedDeck(String name, List<List<String>> rawWords) {
    final deck = Deck(id: _generateId('deck'), name: name);
    for (final raw in rawWords) {
      deck.addWord(
        Word(
          id: _generateId('word'),
          term: raw[0],
          meaning: raw[1],
          phonetic: raw[2],
          example: raw[3],
        ),
      );
    }
    _decks.add(deck);
  }
}
