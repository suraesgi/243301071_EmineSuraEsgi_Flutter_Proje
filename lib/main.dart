import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; 

void main() {
  runApp(const HobiBahcesiApp());
}

class HobiBahcesiApp extends StatelessWidget {
  const HobiBahcesiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hobi Bahçesi Kiralama',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.green,
      ),
      home: const GirisEkrani(), 
    );
  }
}