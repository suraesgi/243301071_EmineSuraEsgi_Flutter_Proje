import 'package:flutter/material.dart';

class SahipPaneli extends StatelessWidget {
  const SahipPaneli({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bahçe Sahibi Paneli"),
        backgroundColor: Colors.green.shade900, 
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ozetKart("Toplam Bahçe", "3", Colors.blue),
                _ozetKart("Bekleyen Talep", "5", Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Gelen Kiralama Talepleri",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Müşteri: Ahmet Yılmaz ${index + 1}"),
                    subtitle: const Text("Bahçe No: 4 - Talep Tarihi: 09.05.2026"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () {}),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Geçmiş Müşteriler",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.history),
                title: Text("Mehmet Demir"),
                subtitle: Text("Kiralama Süresi: 12 Ay - Tamamlandı"),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          print("LOG: Yeni bahçe ekleme ekranına gidiliyor.");
        },
        label: const Text(
          "Yeni Bahçe Ekle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green.shade900,
      ),
    );
  }

  Widget _ozetKart(String baslik, String deger, Color renk) {
    return Expanded(
      child: Card(
        color: renk.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(deger, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: renk)),
            ],
          ),
        ),
      ),
    );
  }
}