part of 'socket_bloc.dart';

@immutable
abstract class SocketState {}

class SocketInitial extends SocketState {}

class TestsState extends SocketState {}

class TestsLoadedState extends SocketState {
  final data;

  TestsLoadedState({this.data});
}
