import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/question_bloc/question_event.dart';
import 'package:flutter_tcp_sockets/bloc/question_bloc/question_state.dart';

class QuestionBloc extends Bloc<QuestionEvent, QuestionState> {
  @override
  QuestionState get initialState => InitialQuestionState();

  @override
  Stream<QuestionState> mapEventToState(QuestionEvent event) async* {
    if (event is QuestionLoadedEvent) {
      yield QuestionLoadedState(data: event.data);
    } else if (event is QuestionsEndedEvent) {
      yield QuestionsEndedState(resultData: event.resultData);
    }
  }
}
