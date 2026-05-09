import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class GirisEkrani extends StatelessWidget {
  const GirisEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Hobi Bahçesi Sistemi",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 30),
            const TextField(
              decoration: InputDecoration(
                labelText: 'E-posta veya Öğrenci No',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 25),
            
            ElevatedButton(
              onPressed: () {
                print("LOG: Giriş başarılı, Bahçe Listesine gidiliyor.");
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const AnaEkran()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Giriş Yap"),
            ),
            
            const SizedBox(height: 10),
            
            TextButton(
              onPressed: () {
                print("LOG: Kayıt Ol ekranına yönlendiriliyor.");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KayitEkrani()),
                );
              },
              child: const Text(
                "Hesabınız yok mu? Kayıt Olun",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
}