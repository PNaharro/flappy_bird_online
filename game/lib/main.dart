import 'package:flappy_ember/Login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flappy_ember/appdata.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        title: 'Flappy Online',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Login(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
