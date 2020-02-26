import 'dart:io';

import 'package:dart_tcp_socket_server/data/test_data.dart';

class User {
  final String username;
  Socket socket;
  TestData runningTest = null;

  User({this.username, this.socket});

  bool operator ==(o) => o is User && o.username == this.username;
}
