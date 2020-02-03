import 'package:bloc/bloc.dart';
import 'package:chika_scan/screen/chika_scan/chika_scan_screen_page.dart';
import 'package:chika_scan/simple_bloc_delegate.dart';
import 'package:flutter/material.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scan App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: ScanScreenPage(),
      home: ChikaScanScreenPage(),
    );
  }
}
