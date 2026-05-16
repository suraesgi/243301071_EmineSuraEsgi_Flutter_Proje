import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'kiralamalarim_screen.dart';

class ProfilEkrani extends StatefulWidget {
  const ProfilEkrani({super.key});

  @override
  State<ProfilEkrani> createState() => _ProfilEkraniState();
}

class _ProfilEkraniState extends State<ProfilEkrani> {
  
  Future<Map<String, dynamic>> _profilVerileriniGetir() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("Kullanıcı oturumu bulunamadı.");

    final userResponse = await Supabase.instance.client
        .from('kullanicilar')
        .select()
        .eq('id', user.id)
        .single();

    if (userResponse['rol'] == "Bahçe Sahibi") {
      final sahipResponse = await Supabase.instance.client
          .from('sahipler')
          .select('iban_no')
          .eq('kullanici_id', user.id)
          .maybeSingle();
      
      if (sahipResponse != null) {
        userResponse['iban'] = sahipResponse['iban_no'];
      }
    }

    final logResponse = await Supabase.instance.client
        .from('loglar')
        .select()
        .eq('kullanici_id', user.id)
        .order('tarih', ascending: false)
        .limit(10);

    final kiralikResponse = await Supabase.instance.client
        .from('bahceler')
        .select() 
        .eq('kiralayan_id', user.id);

    await Supabase.instance.client.from('loglar').insert({
      'kullanici_id': user.id,
      'islem': "Profil sayfası görüntülendi.",
    });

    return {
      'bilgiler': userResponse,
      'hareketler': logResponse,
      'kiralikBahceler': kiralikResponse, 
    };
  }

  Future<void> _cikisYap(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Profilim", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profilVerileriniGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final bilgiler = data['bilgiler'];
          final hareketler = data['hareketler'] as List;
          final kiralikBahceler = data['kiralikBahceler'] as List;

          final String tamAd = "${bilgiler['ad'] ?? ''} ${bilgiler['soyad'] ?? ''}";
          final String rol = bilgiler['rol'] ?? "Müşteri";

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                  ),
                  padding: const EdgeInsets.only(bottom: 30, top: 10),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 60, color: Colors.green),
                      ),
                      const SizedBox(height: 15),
                      Text(tamAd, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text(rol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // 1. İLETİŞİM BİLGİLERİ GRUBU
                      _bilgiGrubu("İletişim Bilgileri", [
                        _bilgiSatiri(Icons.email_outlined, "E-posta", bilgiler['eposta'] ?? ""),
                        _bilgiSatiri(Icons.phone_android, "Telefon", bilgiler['telefon'] ?? "Belirtilmemiş"),
                        if (bilgiler['iban'] != null)
                          _bilgiSatiri(Icons.account_balance_wallet_outlined, "IBAN No", bilgiler['iban']),
                      ]),

                      const SizedBox(height: 25),

                      // 2. DİNAMİK İŞLEMLER GRUBU (ROL BAZLI)
                      _bilgiGrubu(rol == "Bahçe Sahibi" ? "Sahip İşlemleri" : "Kiralama İşlemleri", [
                        if (rol == "Bahçe Sahibi")
                          _profilButonu(
                            Icons.villa_outlined, 
                            "Bahçelerimin Durumu", 
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Bahçelerinizin durumu listeleniyor..."),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }, 
                            renk: Colors.orange.shade800,
                          )
                        else
                          _profilButonu(
                            Icons.history, 
                            "Kiralama Geçmişim", 
                            () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => const KiralamalarimEkrani()),
                              );
                            }, 
                            renk: Colors.blue.shade700,
                          ),
                      ]),

                      const SizedBox(height: 25), 

                      _bilgiGrubu("Son Hareketlerim (Log Kaydı)", [
                        if (hareketler.isEmpty)
                          const ListTile(title: Text("Henüz hareket yok", style: TextStyle(fontSize: 14, color: Colors.grey)))
                        else
                          ...hareketler.map((log) => ListTile(
                            dense: true,
                            leading: const Icon(Icons.access_time, size: 18, color: Colors.blueGrey),
                            title: Text(log['islem'] ?? "", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            subtitle: Text(log['tarih']?.toString().split('.')[0].replaceFirst('T', ' ') ?? "", style: const TextStyle(fontSize: 11)),
                          )),
                      ]),

                      const SizedBox(height: 25),

                      _bilgiGrubu("Hesap Yönetimi", [
                        _profilButonu(Icons.settings_outlined, "Ayarlar", () {}),
                        _profilButonu(Icons.logout, "Güvenli Çıkış", () => _cikisYap(context), renk: Colors.red.shade700),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
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
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey.shade200)),
          child: Column(children: cocuklar),
        ),
      ],
    );
  }

  Widget _bilgiSatiri(IconData ikon, String baslik, String deger) {
    return ListTile(
      leading: Icon(ikon, color: Colors.green.shade700, size: 22),
      title: Text(baslik, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      subtitle: Text(deger, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _profilButonu(IconData ikon, String baslik, VoidCallback tiklama, {Color renk = Colors.black87}) {
    return ListTile(
      onTap: tiklama,
      leading: Icon(ikon, color: renk, size: 22),
      title: Text(baslik, style: TextStyle(color: renk, fontWeight: FontWeight.w500, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}