part of 'socket_bloc.dart';

@immutable
abstract class SocketState {}

class SocketInitial extends SocketState {}

class TestsState extends SocketState {}

class TestsLoadedState extends SocketState {
  final List<TestData> tests;
  final ResultData latest;

  TestsLoadedState({this.tests, this.latest});
}

class CloseState extends SocketState {}

class UpdateTestsState extends SocketState {}