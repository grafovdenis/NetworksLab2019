import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';
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
          },
        ),
      ),
      body: BlocListener<SocketBloc, SocketState>(
        listener: (context, state) {
          if (state is CloseState) {
            Navigator.of(context).popUntil((predicate) => predicate.isFirst);
          } else if (state is UpdateTestsState) {
            tests = tests.map((it) => TestWidget(
                  started: false,
                  testData: it.testData,
                  result: it.result,
                ));
          }
        },
        child: BlocBuilder<SocketBloc, SocketState>(
          builder: (context, state) {
            if (state is TestsLoadedState) {
              tests = List.generate(state.tests.length, (index) {
                return TestWidget(
                    testData: state.tests[index],
                    result: (state.latest != null &&
                            state.latest.title != null &&
                            state.latest.title == state.tests[index].title)
                        ? state.latest.result
                        : null);
              });
              return Column(children: tests);
            } else {
              return Center(
                child: Text("no data"),
              );
            }
          },
        ),
      ),
    );
  }
}
