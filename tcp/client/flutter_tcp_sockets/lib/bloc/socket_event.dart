part of 'socket_bloc.dart';

@immutable
abstract class SocketEvent {}

class LoginEvent extends SocketEvent {
  final String ip;
  final int port;
  final String username;

  LoginEvent({this.ip, this.port, this.username});
}

class TestsEvent extends SocketEvent {}

class CloseEvent extends SocketEvent {}

class TestsLoadedEvent extends SocketEvent {
  final List<TestData> tests;
  final ResultData latest;

  TestsLoadedEvent({this.tests, this.latest});
}

class UpdateTestsEvent extends SocketEvent {}