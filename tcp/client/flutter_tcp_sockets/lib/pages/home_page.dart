import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tcp_sockets/bloc/socket_bloc.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ipController = TextEditingController(text: "192.168.43.221");
  final usernameController = TextEditingController(text: "grafa");
  final portController = TextEditingController(text: "3000");
  final _formKey = GlobalKey<FormState>();
  SocketBloc socketBloc;

  @override
  void dispose() {
    ipController.dispose();
    usernameController.dispose();
    portController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    socketBloc = BlocProvider.of<SocketBloc>(context);
    super.initState();
  }

  connect() async {
    _formKey.currentState.validate();
    socketBloc.add(LoginEvent(
        ip: ipController.text.trim(),
        port: int.parse(portController.text.trim()),
        username: usernameController.text.trim()));
  }

  String validator(String value) {
    if (value.isEmpty) {
      return 'Please enter some text';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SocketBloc, SocketState>(
      listener: (context, state) {
        if (state is TestsState) {
          socketBloc.add(TestsEvent());
          Navigator.of(context).pushNamed('/tests');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Networks 2019"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: ipController,
                    validator: validator,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "IP",
                      icon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: portController,
                    validator: validator,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Port",
                      icon: Icon(Icons.location_on),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: usernameController,
                    validator: validator,
                    decoration: InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Username",
                      icon: Icon(Icons.person),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.done),
          onPressed: () => connect(),
        ),
      ),
    );
  }
}
