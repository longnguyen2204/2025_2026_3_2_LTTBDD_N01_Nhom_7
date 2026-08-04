import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/deck.dart';
import '../models/word.dart';

class DeckRepository {
  static const String _storageKey = 'decks_data';

  Future<List<Deck>> loadDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => _deckFromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDecks(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = decks.map(_deckToJson).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Map<String, dynamic> _deckToJson(Deck deck) {
    return {
      'id': deck.id,
      'name': deck.name,
      'words': deck.words.map(_wordToJson).toList(),
    };
  }

  Deck _deckFromJson(Map<String, dynamic> json) {
    final wordsJson = json['words'] as List<dynamic>? ?? [];
    return Deck(
      id: json['id'] as String,
      name: json['name'] as String,
      words: wordsJson
          .map((w) => _wordFromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> _wordToJson(Word word) {
    return {
      'id': word.id,
      'term': word.term,
      'meaning': word.meaning,
      'phonetic': word.phonetic,
      'example': word.example,
      'isLearned': word.isLearned,
      'isFavorite': word.isFavorite,
    };
  }

  Word _wordFromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] as String,
      term: json['term'] as String,
      meaning: json['meaning'] as String,
      phonetic: json['phonetic'] as String?,
      example: json['example'] as String?,
      isLearned: json['isLearned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
