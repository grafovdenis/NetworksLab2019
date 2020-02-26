import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_tcp_socket_server/data/question_data.dart';

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class TestData {
  final String title;
  final String _id;
  final List<QuestionData> questions;
  int _index = 0;
  String get id => _id;
  int _rightAnswers = 0;
  bool ended = false;
  num result = null;

  TestData({this.title, String id, this.questions})
      : _id = id == null ? generateMd5(title) : id;

  @override
  String toString() {
    return '{"title" : $title, "id" : $_id}';
  }

  Map<String, dynamic> toMap() => {"title": title, "id": _id};

  String startTest() {
    _index = 0;
    return jsonEncode({
        'action': 'answer',
        'params': {'question': questions[_index++].toMap()}
      });
  }

  String nextQuestion({int answer}) {
    if (questions[_index - 1].rightAnswer == answer) {
      _rightAnswers++;
    }
    if (_index < questions.length) {
      final nextQuestion = questions[_index];
      _index++;
      return jsonEncode({
        'action': 'answer',
        'params': {'question': nextQuestion.toMap()}
      });
    } else {
      result = _rightAnswers / questions.length;
      var _result = jsonEncode({
        'action': 'answer',
        'params': {
          'question': null,
          'result': {
            'result': _rightAnswers / questions.length,
            'title': this.title,
          }
        }
      });
      _index = 0;
      ended = true;
      _rightAnswers = 0;
      return _result;
    }
  }
}
