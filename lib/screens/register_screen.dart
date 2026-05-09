import 'package:flutter/material.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  String secilenRol = 'Müşteri';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Hesap Oluştur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: secilenRol,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Rolü',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Müşteri', child: Text("Müşteri")),
                DropdownMenuItem(value: 'Sahip', child: Text("Bahçe Sahibi")),
              ],
              onChanged: (value) {
                setState(() {
                  secilenRol = value!;
                });
                print("LOG: Kullanıcı rolü seçildi: $secilenRol");
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                print("LOG: Kayıt başarılı. Rol: $secilenRol");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Kayıt başarılı! Şimdi giriş yapabilirsiniz.")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}