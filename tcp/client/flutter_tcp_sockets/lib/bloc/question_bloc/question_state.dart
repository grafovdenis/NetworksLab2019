import 'package:flutter_tcp_sockets/data/question_data.dart';
import 'package:flutter_tcp_sockets/data/result_data.dart';

abstract class QuestionState {}

class InitialQuestionState extends QuestionState {}

class QuestionLoadedState extends QuestionState {
  final QuestionData data;
  QuestionLoadedState({this.data});
}

class QuestionsEndedState extends QuestionState {
  final ResultData resultData;

  QuestionsEndedState({this.resultData});
}
