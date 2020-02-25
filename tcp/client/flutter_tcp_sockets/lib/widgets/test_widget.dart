import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
import 'package:flutter_tcp_sockets/data/test_data.dart';
import 'package:flutter_tcp_sockets/pages/test_page.dart';

class TestWidget extends StatefulWidget {
  final TestData testData;
  final num result;
  bool started;
  TestWidget({Key key, this.testData, this.result, this.started = false})
      : super(key: key);

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.testData.title),
      subtitle: (widget.result != null)
          ? Text("Last result: ${(widget.result * 100).toStringAsFixed(0)}%")
          : null,
      onTap: () {
        if (!widget.started) {
          BlocProvider.of<SocketBloc>(context).socket.write(jsonEncode({
                "action": "test",
                "params": {"id": widget.testData.id}
              }));
          widget.started = true;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return TestPage(
            data: widget.testData,
          );
        }));
      },
    );
  }
}
