import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_history.dart';
import '../models/quiz_type.dart';

class HistoryRepository {
  String _storageKey(String profileId) => 'quiz_history_data_$profileId';

  Future<List<QuizHistory>> loadHistory(String profileId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey(profileId));
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final history = jsonList
          .map((item) => _historyFromJson(item as Map<String, dynamic>))
          .toList();
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return history;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String profileId, List<QuizHistory> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map(_historyToJson).toList();
    await prefs.setString(_storageKey(profileId), jsonEncode(jsonList));
  }

  Map<String, dynamic> _historyToJson(QuizHistory item) {
    return {
      'id': item.id,
      'deckName': item.deckName,
      'score': item.score,
      'totalQuestions': item.totalQuestions,
      'quizType': item.quizType.name,
      'timestamp': item.timestamp.toIso8601String(),
    };
  }

  QuizHistory _historyFromJson(Map<String, dynamic> json) {
    return QuizHistory(
      id: json['id'] as String,
      deckName: json['deckName'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      quizType: QuizType.values.byName(json['quizType'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
