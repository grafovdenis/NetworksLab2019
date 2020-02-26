import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/question_bloc/question_state.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
import 'package:flutter_tcp_sockets/data/test_data.dart';

class TestPage extends StatelessWidget {
  final TestData data;
  const TestPage({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
            BlocProvider.of<SocketBloc>(context)
                .socket
                .write(jsonEncode({"action": "tests"}));
          },
        ),
      ),
      body: BlocListener<SocketBloc, SocketState>(
        listener: (context, state) {
          if (state is CloseState) {
            Navigator.of(context).popUntil((predicate) => predicate.isFirst);
          }
        },
        child: BlocBuilder(
          bloc: BlocProvider.of<SocketBloc>(context).questionBloc,
          builder: (context, state) {
            if (state is QuestionLoadedState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        state.data.title,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Column(
                      children:
                          List.generate(state.data.answers.length, (index) {
                        final answer = state.data.answers[index];
                        return Container(
                          padding: const EdgeInsets.all(8),
                          child: RaisedButton(
                            child: Text(answer.title),
                            onPressed: () {
                              BlocProvider.of<SocketBloc>(context)
                                  .socket
                                  .write(jsonEncode({
                                    'action': 'answer',
                                    "params": {
                                      "answer": state.data.answers[index].id
                                    }
                                  }));
                            },
                          ),
                        );
                      }),
                    )
                  ],
                ),
              );
            } else if (state is QuestionsEndedState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        "Your result is ${(state.resultData.result * 100).toStringAsFixed(0)}%"),
                    SizedBox(
                      height: 50,
                    ),
                    RaisedButton(
                      child: Text("Go back"),
                      onPressed: () {
                        BlocProvider.of<SocketBloc>(context)
                            .add(UpdateTestsEvent());
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
