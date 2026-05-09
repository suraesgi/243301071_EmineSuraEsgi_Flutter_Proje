import 'package:flutter/material.dart';

class AnaEkran extends StatelessWidget {
  const AnaEkran({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hobi Bahçeleri"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              print("LOG: Profil ekranına gidiliyor.");
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 6, 
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.yard, color: Colors.green, size: 40),
              title: Text("${index + 1} Numaralı Hobi Bahçesi"),
              subtitle: Text("Konya / Meram\nAylık: ${500 + (index * 100)} TL"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                print("LOG: ${index + 1} numaralı bahçe detayına tıklandı.");
              },
            ),
          );
        },
      ),
    );
  }
}