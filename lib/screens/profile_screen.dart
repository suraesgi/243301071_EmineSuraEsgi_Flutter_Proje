import 'package:flutter/material.dart';
import 'login_screen.dart'; // Çıkış yapınca login'e dönmek için

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilim"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Üst Kısım: Profil Resmi ve İsim
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(bottom: 30),
            child: const Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.green),
                ),
                SizedBox(height: 15),
                Text(
                  "Kullanıcı",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Rol",
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Seçenekler Listesi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _profilButonu(Icons.edit, "Bilgilerimi Düzenle", () {}),
                _profilButonu(Icons.history, "Kiralama Geçmişim", () {}),
                _profilButonu(Icons.notifications, "Bildirim Ayarları", () {}),
                _profilButonu(Icons.help_outline, "Yardım ve Destek", () {}),
                const Divider(),
                _profilButonu(Icons.logout, "Çıkış Yap", () {
                  // Çıkış yapınca her şeyi sıfırlayıp Login'e döner
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const GirisEkrani()),
                    (route) => false,
                  );
                }, renk: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Profil seçenekleri için yardımcı widget
  Widget _profilButonu(IconData ikon, String baslik, VoidCallback tiklama, {Color renk = Colors.black87}) {
    return ListTile(
      onTap: tiklama,
      leading: Icon(ikon, color: renk),
      title: Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}