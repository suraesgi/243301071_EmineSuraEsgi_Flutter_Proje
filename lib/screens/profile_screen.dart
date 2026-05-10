import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  
  Future<Map<String, dynamic>> _kullaniciBilgileriniGetir() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    // 1. Kullanıcı bilgilerini çek
    final response = await Supabase.instance.client
        .from('kullanicilar')
        .select()
        .eq('id', user.id)
        .single();

    // 2. Rol "Bahçe Sahibi" ise IBAN'ı ekle
    if (response['rol'] == "Bahçe Sahibi") {
      final sahipResponse = await Supabase.instance.client
          .from('sahipler')
          .select('iban')
          .eq('kullanici_id', user.id)
          .maybeSingle();
      
      if (sahipResponse != null) {
        response['iban'] = sahipResponse['iban'];
      }
    }

    // ÖDEV ŞARTI: Profil görüntüleme işlemini logla
    await Supabase.instance.client.from('loglar').insert({
      'kullanici_id': user.id,
      'islem': "Profil sayfası görüntülendi.",
    });

    return response;
  }

  Future<void> _cikisYap(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    
    if (user != null) {
      // ÖDEV ŞARTI: Çıkış işlemini logla
      await Supabase.instance.client.from('loglar').insert({
        'kullanici_id': user.id,
        'islem': "Sistemden çıkış yapıldı.",
      });
    }

    await Supabase.instance.client.auth.signOut();
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const GirisEkrani()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _kullaniciBilgileriniGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final String tamAd = "${data['ad'] ?? ''} ${data['soyad'] ?? ''}";
          final String rol = data['rol'] ?? "Müşteri";
          final String eposta = data['eposta'] ?? "";
          final String? iban = data['iban'];

          return Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                padding: const EdgeInsets.only(bottom: 40, top: 10),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 65, color: Colors.green),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      tamAd,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        rol,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _bilgiGrubu("İletişim Bilgileri", [
                      _bilgiSatiri(Icons.email_outlined, "E-posta", eposta),
                      _bilgiSatiri(Icons.phone_android, "Telefon", data['telefon'] ?? "Belirtilmemiş"),
                    ]),
                    
                    if (iban != null) ...[
                      const SizedBox(height: 20),
                      _bilgiGrubu("Ödeme Bilgileri", [
                        _bilgiSatiri(Icons.account_balance_wallet_outlined, "IBAN", iban),
                      ]),
                    ],
                    
                    const SizedBox(height: 20),
                    _bilgiGrubu("Hesap İşlemleri", [
                      _profilButonu(Icons.history, 
                        rol == "Bahçe Sahibi" ? "Bahçe Kayıtlarım" : "Kiralama Geçmişim", 
                        () {}),
                      _profilButonu(Icons.settings_outlined, "Ayarlar", () {}),
                      _profilButonu(
                        Icons.logout, 
                        "Güvenli Çıkış", 
                        () => _cikisYap(context), 
                        renk: Colors.red.shade700
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bilgiGrubu(String baslik, List<Widget> cocuklar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(baslik, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: cocuklar),
        ),
      ],
    );
  }

  Widget _bilgiSatiri(IconData ikon, String baslik, String deger) {
    return ListTile(
      leading: Icon(ikon, color: Colors.green.shade700),
      title: Text(baslik, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(deger, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
    );
  }

  Widget _profilButonu(IconData ikon, String baslik, VoidCallback tiklama, {Color renk = Colors.black87}) {
    return ListTile(
      onTap: tiklama,
      leading: Icon(ikon, color: renk),
      title: Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}