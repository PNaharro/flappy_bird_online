import 'dart:convert';
import 'package:flutter/material.dart';
import 'WebSocketsHandler.dart';

class FlappyEmberWaitingScreen extends StatefulWidget {
  final WebSocketsHandler webSocketHandler;

  FlappyEmberWaitingScreen({required this.webSocketHandler});

  @override
  _FlappyEmberWaitingScreenState createState() =>
      _FlappyEmberWaitingScreenState();
}

class _FlappyEmberWaitingScreenState extends State<FlappyEmberWaitingScreen> {
  List<String> players = [];

  @override
  void initState() {
    super.initState();
    widget.webSocketHandler.connectToServer("localhost", "8888", handleMessage);
  }

  void handleMessage(String message) {
    Map<String, dynamic> messageMap = json.decode(message);

    switch (messageMap['type']) {
      case 'newClient':
        setState(() {
          players.add(messageMap['id']);
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waiting for Players'),
      ),
      body: Column(
        children: [
          Text(
            'Players Waiting:',
            style: TextStyle(fontSize: 20),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(players[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
