import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:flutter_tcp_sockets/bloc/question_bloc/question_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/question_bloc/question_event.dart';
import 'package:flutter_tcp_sockets/data/answer_data.dart';
import 'package:flutter_tcp_sockets/data/question_data.dart';
import 'package:flutter_tcp_sockets/data/result_data.dart';
import 'package:flutter_tcp_sockets/data/test_data.dart';
import 'package:meta/meta.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => SocketInitial();

  Socket socket;

  QuestionBloc questionBloc = QuestionBloc();

  StreamSubscription _streamSubscription;

  void _listener(Uint8List data) {
    try {
      final json = jsonDecode(String.fromCharCodes(data));
      print(json);
      final String action = json['action'];
      switch (action) {
        case "close":
          this.add(CloseEvent());
          questionBloc.close();
          break;
        case "login":
          this.add(TestsEvent());
          break;
        case "tests":
          ResultData latest;
          if (json['params']['last'] != null) {
            latest = ResultData(
                title: json['params']['last']['title'],
                result: json['params']['last']['result']);
          }
          final List<TestData> tests =
              List.generate((json['params']['tests'] as List).length, (index) {
            final test = json['params']['tests'][index];
            return TestData(title: test['title'], id: test['id']);
          });
          this.add(TestsLoadedEvent(tests: tests, latest: latest));
          break;
        case "answer":
          if (json['params']['question'] != null) {
            final question = json['params']['question'];
            final data = QuestionData(
                title: question['title'],
                answers: List.generate((question['answers'] as List).length,
                    (index) {
                  final answer = question['answers'][index];
                  return AnswerData(title: answer['title'], id: answer['id']);
                }));
            questionBloc.add(QuestionLoadedEvent(data: data));
          } else if (json['params']['result'] != null) {
            questionBloc.add(QuestionsEndedEvent(
                resultData: ResultData(
                    result: json['params']['result']['result'],
                    title: json['params']['result']['title'])));
            this.add(UpdateTestsEvent());
          }
          break;
        default:
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if (event is LoginEvent) {
      try {
        socket = await Socket.connect(event.ip, event.port);
        final message = {
          "action": "login",
          "params": {"username": event.username}
        };
        socket.write(jsonEncode(message));
        _streamSubscription = socket.listen(_listener)
          ..onDone(() {
            this.add(CloseEvent());
          });
        yield TestsState();
      } catch (e) {
        print(e);
      }
    } else if (event is TestsEvent) {
      final message = {"action": "tests"};
      socket.write(jsonEncode(message));
    } else if (event is TestsLoadedEvent) {
      yield TestsLoadedState(tests: event.tests, latest: event.latest);
    } else if (event is CloseEvent) {
      _streamSubscription.cancel();
      socket.close();
      print("Disconnected");
      yield CloseState();
    } else if (event is UpdateTestsEvent) {
      socket.write(jsonEncode({
        "action": "tests",
      }));
    }
  }
}
