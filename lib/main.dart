import 'package:example_flutter_gemini_new/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const apiKey = 'AIzaSyCtr7h2j5saozJD2kv-sFNahuRA4Kt_FSI';

void main() {
  Gemini.init(apiKey: apiKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Gemini Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Gemini Demo'),
      debugShowCheckedModeBanner: false,
    );
  }
}
