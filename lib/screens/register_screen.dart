import 'package:flutter/material.dart';
import 'login_screen.dart';  
class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  String? _rolGrubu = "Müşteri"; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kayıt"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.person_add_alt_1, size: 60, color: Colors.green),
            const SizedBox(height: 30),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            const TextField(
              decoration: InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
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
            const SizedBox(height: 20),

            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Rolü Seçiniz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.supervised_user_circle),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text("Müşteri"),
                    value: "Müşteri",
                    groupValue: _rolGrubu,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero, 
                    onChanged: (val) {
                      setState(() {
                        _rolGrubu = val;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Bahçe Sahibi"),
                    value: "Bahçe Sahibi",
                    groupValue: _rolGrubu,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _rolGrubu = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                secilenRol = _rolGrubu!;
                
                print("LOG: Kayıt Tamamlandı. Hafızaya alınan rol: $secilenRol");

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Kayıt Ol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}