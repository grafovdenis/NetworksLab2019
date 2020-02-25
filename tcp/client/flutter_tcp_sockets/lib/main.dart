import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/pages/home_page.dart';
import 'package:flutter_tcp_sockets/pages/tests_page.dart';

import 'bloc/socket_bloc.dart';

void main() => runApp(BlocProvider(
      create: (context) => SocketBloc(),
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => HomePage(),
        '/tests': (context) => TestsPage(),
      },
      initialRoute: '/',
    );
  }
}
