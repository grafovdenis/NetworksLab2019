import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'dart:io';

import 'package:dart_tcp_socket_server/data/answer_data.dart';
import 'package:dart_tcp_socket_server/data/question_data.dart';
import 'package:dart_tcp_socket_server/data/test_data.dart';
import 'package:dart_tcp_socket_server/user.dart';

void startServer() {
  List<User> users = [];
  List<TestData> tests = [
    TestData(
      title: "Physical test",
      questions: [
        QuestionData(
            title: "Is Earth the third planet from the Sun",
            rightAnswer: 0,
            answers: [
              AnswerData(title: "Yes", id: 0),
              AnswerData(title: "No", id: 1),
            ]),
        QuestionData(
            title: "Gravitational acceleration is approximately equal (m/s^2)",
            rightAnswer: 1,
            answers: [
              AnswerData(title: "12", id: 0),
              AnswerData(title: "9.8", id: 1)
            ]),
      ],
    ),
    TestData(
      title: "Random test",
      questions: [
        QuestionData(title: "Is Earth flat?", rightAnswer: 1, answers: [
          AnswerData(title: "Yes", id: 0),
          AnswerData(title: "No", id: 1),
        ]),
        QuestionData(title: "Can people fly?", rightAnswer: 0, answers: [
          AnswerData(title: "Not exactly", id: 0),
          AnswerData(title: "Yes", id: 1)
        ]),
        QuestionData(title: "How much is 1 kg?", rightAnswer: 0, answers: [
          AnswerData(title: "1000 g", id: 0),
          AnswerData(title: "100 g", id: 1),
          AnswerData(title: "10 g", id: 2),
        ]),
      ],
    ),
  ];
  Future<ServerSocket> serverFuture = ServerSocket.bind('10.215.6.119', 3000);
  serverFuture.then((ServerSocket server) {
    server.listen((Socket socket) {
      User user;
      void _write(Object obj) {
        socket.write(obj);
        print("Send ${user?.username} $obj");
      }

      socket.listen((List<int> data) {
        final json = jsonDecode(String.fromCharCodes(data));
        (user == null)
            ? print(json)
            : print("${user.username} send ${String.fromCharCodes(data)}");
        switch (json['action']) {
          case "login":
            bool stop = false;
            users.forEach((_user) {
              if (_user.socket != null &&
                  _user.username == json['params']['username']) {
                _write(jsonEncode({"action": "close"}));
                stop = true;
              }
            });
            if (!stop) {
              user = users.firstWhere((_user) {
                return _user.username == json['params']['username'];
              }, orElse: () {
                final _user =
                    User(socket: socket, username: json['params']['username']);
                users.add(_user);
                return _user;
              });
              _write(jsonEncode({'action': 'login'}));
            }
            break;
          case "tests":
            _write(jsonEncode({
              'action': 'tests',
              'params': {
                'tests': tests.map((test) => test.toMap()).toList(),
                'last': (user?.runningTest != null)
                    ? {
                        "title": user.runningTest.title,
                        "result": user.runningTest.result
                      }
                    : null
              },
            }));
            break;
          case "test":
            if (user.runningTest != null && user.runningTest.ended) {
              user.runningTest = null;
            }
            if (user.runningTest == null) {
              user.runningTest = TestData(
                id: json['params']['id'],
              );
              user.runningTest =
                  tests.where((test) => test.id == user.runningTest.id).first;
              _write(user.runningTest.startTest());
            } else {
              _write(jsonEncode({'action': 'close'}));
            }
            break;
          case "answer":
            final int answer = json['params']['answer'];
            _write(user.runningTest.nextQuestion(answer: answer));
            break;
          default:
            break;
        }
      }).onDone(() {
        user?.socket = null;
        socket.close();
      });
    });
  });
}

void main() {
  startServer();
}
