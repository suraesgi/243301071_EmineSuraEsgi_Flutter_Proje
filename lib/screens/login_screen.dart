import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'owner_dashboard_screen.dart';

String secilenRol = "Müşteri"; 

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hobi Bahçesi Kiralama ve Hizmet Sistemi",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 30),
            const TextField(
              decoration: InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {
                if (secilenRol == "Bahçe Sahibi") {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SahipPaneli()));
                } else {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnaEkran()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Giriş Yap"),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KayitEkrani())),
              child: const Text("Hesabınız yok mu? Kayıt Olun", style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}