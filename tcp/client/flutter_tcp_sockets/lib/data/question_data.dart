import 'package:flutter_tcp_sockets/data/answer_data.dart';

class QuestionData {
  final String title;
  final List<AnswerData> answers;

  QuestionData({this.title, this.answers});
}