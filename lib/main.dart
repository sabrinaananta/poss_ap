import 'package:flutter/material.dart';
import 'package:posproject/LocalDb.dart';
import 'package:posproject/pages/detailpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localDatabase = LocalDatabase();
  await localDatabase.addInitialData();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Options',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DetailPage(),
    );
  }
}
