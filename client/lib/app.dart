
import 'package:flutter/material.dart';
import 'home_screen.dart';

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping UI',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}