import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
import 'package:flutter_tcp_sockets/data/test_data.dart';
import 'package:flutter_tcp_sockets/widgets/question_widget.dart';

class TestWidget extends StatefulWidget {
  final TestData testData;
  final Function receiveData;
  final QuestionWidget questionWidget;
  final bool initiallyExpanded;
  final Widget subtitle;
  bool started;
  TestWidget(
      {Key key,
      this.testData,
      this.receiveData,
      this.questionWidget,
      this.initiallyExpanded = false,
      this.started = false,
      this.subtitle})
      : super(key: key);

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      subtitle: widget.subtitle,
      initiallyExpanded: widget.initiallyExpanded,
      title: Text(widget.testData.title),
      onExpansionChanged: (opened) {
        if (opened) {
          if (!widget.started) {
            widget.started = true;
            BlocProvider.of<SocketBloc>(context).socket.write(jsonEncode({
                  "action": "test",
                  "params": {"id": widget.testData.id}
                }));
          }
        }
      },
      children: [widget.questionWidget ?? Container()],
    );
  }
}
