import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
import 'package:flutter_tcp_sockets/data/question_data.dart';

class QuestionWidget extends StatelessWidget {
  final QuestionData data;
  const QuestionWidget({Key key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(data.title),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(data.answers.length, (index) {
              return FlatButton(
                child: Text(data.answers[index].title),
                onPressed: () {
                  BlocProvider.of<SocketBloc>(context).socket.write(jsonEncode({
                        "action": "answer",
                        "params": {"answer": data.answers[index].id}
                      }));
                },
              );
            }),
          ),
        )
      ],
    );
  }
}
