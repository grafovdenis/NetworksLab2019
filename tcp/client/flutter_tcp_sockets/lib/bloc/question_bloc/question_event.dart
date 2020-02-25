import 'package:flutter_tcp_sockets/data/question_data.dart';
import 'package:flutter_tcp_sockets/data/result_data.dart';

abstract class QuestionEvent {}

class QuestionLoadedEvent extends QuestionEvent {
  final QuestionData data;
  QuestionLoadedEvent({this.data});
}

class QuestionsEndedEvent extends QuestionEvent {
  final ResultData resultData;

  QuestionsEndedEvent({this.resultData});
}
