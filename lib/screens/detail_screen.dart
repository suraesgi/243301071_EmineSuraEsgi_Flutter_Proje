import 'package:flutter/material.dart';

class DetayEkrani extends StatelessWidget {
  final String bahceAdi;

  const DetayEkrani({super.key, required this.bahceAdi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bahceAdi),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.green.shade100,
              child: const Icon(Icons.image, size: 100, color: Colors.green),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bahceAdi,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Konya, Meram / Yaka Mevkii",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  const Text(
                    "Bahçe Özellikleri",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const ListTile(
                    leading: Icon(Icons.square_foot, color: Colors.green),
                    title: Text("500 Metrekare"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.water_drop, color: Colors.green),
                    title: Text("Sulama Sistemi Mevcut"),
                  ),
                  const ListTile(
                    leading: Icon(Icons.fence, color: Colors.green),
                    title: Text("Etrafı Panel Çit ile Çevrili"),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Açıklama",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Şehrin gürültüsünden uzak, ailenizle vakit geçirebileceğiniz, kendi sebzelerinizi yetiştirebileceğiniz harika bir hobi bahçesi.",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      print("LOG: $bahceAdi için kiralama talebi oluşturuldu.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Kiralama talebiniz iletildi!")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("ŞİMDİ KİRALA"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}