import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
import 'package:flutter_tcp_sockets/data/answer_data.dart';
import 'package:flutter_tcp_sockets/data/question_data.dart';
import 'package:flutter_tcp_sockets/data/test_data.dart';
import 'package:flutter_tcp_sockets/widgets/question_widget.dart';
import 'package:flutter_tcp_sockets/widgets/test_widget.dart';

class TestsPage extends StatefulWidget {
  TestsPage({Key key}) : super(key: key);

  @override
  _TestsPageState createState() => _TestsPageState();
}

class _TestsPageState extends State<TestsPage> {
  List<TestWidget> tests = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tests page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            BlocProvider.of<SocketBloc>(context).add(CloseEvent());
            Navigator.of(context).pop();
          },
        ),
      ),
      body: StreamBuilder(
        stream: BlocProvider.of<SocketBloc>(context).socket,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final data = String.fromCharCodes(snapshot.data as Uint8List)
                .replaceAll('{"action":"login"}', '');
            print(data);
            try {
              final json = jsonDecode(data);
              if (json['action'] == "close") {
                BlocProvider.of<SocketBloc>(context).add(CloseEvent());
                Navigator.of(context).pop();
              } else if (tests.isEmpty) {
                if (json['action'] == 'tests') {
                  List _tests = json['params']['tests'];
                  if (json['params']['last'] != null) {
                    final String _title = json['params']['last']['title'];
                    final num _result = json['params']['last']['result'];
                    _tests.forEach((test) {
                      tests.add(TestWidget(
                        key: Key(test['id']),
                        testData: TestData(
                          title: test['title'],
                          id: test['id'],
                        ),
                        subtitle: (test['title'] == _title)
                            ? Text("Result: $_result")
                            : null,
                      ));
                    });
                  } else {
                    _tests.forEach((test) {
                      tests.add(TestWidget(
                        key: Key(test['id']),
                        testData: TestData(
                          title: test['title'],
                          id: test['id'],
                        ),
                      ));
                    });
                  }
                  return Column(
                    children: tests,
                  );
                }
              } else {
                if (json['action'] == 'answer' &&
                    json['params']['question'] != null) {
                  List<TestWidget> _tests = [];
                  final question = QuestionWidget(
                      data: QuestionData(
                          title: json['params']['question']['title'],
                          answers: List.generate(
                              (json['params']['question']['answers'] as List)
                                  .length, (index) {
                            return AnswerData(
                                id: json['params']['question']['answers'][index]
                                    ['id'],
                                title: json['params']['question']['answers']
                                    [index]['title']);
                          })));
                  tests.forEach((test) {
                    if (test.started) {
                      print(test.testData.title);
                      _tests.add(TestWidget(
                        key: Key(test.testData.id),
                        testData: TestData(
                            title: test.testData.title,
                            id: test.testData.title),
                        questionWidget: question,
                        initiallyExpanded: test.started,
                        started: test.started,
                      ));
                    }
                  });
                  return Column(
                    children: _tests,
                  );
                } else {
                  final String _last = json['params']['result']['title'];
                  final num _result = json['params']['result']['result'];
                  tests = tests.map((test) {
                    return TestWidget(
                      started: false,
                      testData: test.testData,
                      questionWidget: null,
                      initiallyExpanded: false,
                      subtitle: (test.testData.title == _last)
                          ? Text("Result: ${(_result * 100).toStringAsFixed(0)}%")
                          : null,
                    );
                  }).toList();
                  return Column(
                    children: tests,
                  );
                }
              }
            } catch (e) {
              print(e);
            }
            print(data);
          }
          return Container();
        },
      ),
    );
  }
}
