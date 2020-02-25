import 'dart:convert';

import 'package:crypto/crypto.dart';

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class Test {
  final String title;
  final String _id;

  Test({this.title, String id}) : _id = id == null ? generateMd5(title) : id;

  @override
  String toString() {
    return '{"title" : $title, "id" : $_id}';
  }

  Map toMap() => {"title": title, "id": _id};
}
