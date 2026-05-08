import 'package:flutter/material.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  // Seçilen rolü tutacak değişken (Varsayılan: Müşteri)
  String secilenRol = 'Müşteri'; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Hesap Oluştur")),
      body: SingleChildScrollView( // Klavye açıldığında ekranın kayması için
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Ad Soyad', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            const TextField(
              decoration: InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            
            // --- HOCANIN İSTEDİĞİ ROL SEÇİMİ ---
            DropdownButtonFormField<String>(
              value: secilenRol,
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Rolü',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Müşteri', child: Text("Müşteri (Bahçe Kiralayacağım)")),
                DropdownMenuItem(value: 'Sahip', child: Text("Bahçe Sahibi (Bahçem Var)")),
              ],
              onChanged: (value) {
                setState(() {
                  secilenRol = value!;
                });
                print("LOG: Kullanıcı rolü seçildi: $secilenRol"); // Log kaydı kuralı
              },
            ),
            
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                print("LOG: Kayıt ol butonuna basıldı. Rol: $secilenRol");
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