import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  @override
  SocketState get initialState => SocketInitial();

  Socket socket;

  @override
  Stream<SocketState> mapEventToState(
    SocketEvent event,
  ) async* {
    if (event is LoginEvent) {
      try {
        socket = await Socket.connect(event.ip, event.port);
        final message = {
          "action": "login",
          "params": {"username": event.username}
        };
        socket.write(jsonEncode(message));
        yield TestsState();
      } catch (e) {
        
      }
    } else if (event is TestsEvent) {
      final message = {"action": "tests"};
      socket.write(jsonEncode(message));
      yield TestsLoadedState();
    } else if (event is CloseEvent) {
      socket.close();
    }
  }
}
