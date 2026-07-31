import 'package:flutter/foundation.dart';

import '../models/deck.dart';
import '../models/word.dart';

/// Quản lý danh sách bộ từ vựng và các từ vựng bên trong mỗi bộ.
/// Thuộc tầng State/Logic trong kiến trúc phân lớp.
class DeckProvider extends ChangeNotifier {
  final List<Deck> _decks = [];

  /// Bộ đếm dùng để sinh id duy nhất cho Deck và Word.
  int _idCounter = 0;

  DeckProvider() {
    _seedData();
  }

  String _generateId(String prefix) {
    _idCounter++;
    return '${prefix}_$_idCounter';
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
  }

  /// Cập nhật thông tin một bộ từ vựng đã có.
  void updateDeck(Deck deck) {
    final index = _decks.indexWhere((d) => d.id == deck.id);
    if (index == -1) return;
    _decks[index] = deck;
    notifyListeners();
  }

  /// Xóa một bộ từ vựng theo id.
  void deleteDeck(String id) {
    _decks.removeWhere((d) => d.id == id);
    notifyListeners();
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
      ),
    );
    notifyListeners();
  }

  /// Cập nhật một từ vựng đã có trong bộ.
  void updateWord(String deckId, Word word) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    deck.updateWord(word);
    notifyListeners();
  }

  /// Xóa một từ vựng khỏi bộ.
  void deleteWord(String deckId, String wordId) {
    final deck = getDeckById(deckId);
    if (deck == null) return;
    deck.removeWord(wordId);
    notifyListeners();
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
      ['database', 'cơ sở dữ liệu', '/ˈdeɪtəbeɪs/', 'The data is in a database.'],
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
