import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetayEkrani extends StatelessWidget {
  final Map<String, dynamic> bahceVerisi;

  const DetayEkrani({super.key, required this.bahceVerisi});

  Future<void> _kiralamaTalebiOlustur(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    // Yüklenme durumunu göstermek için basit bir diyalog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      // 1. ÖDEV ŞARTI: Kiralama işlemini logla
      await Supabase.instance.client.from('loglar').insert({
        'kullanici_id': user.id,
        'islem': "KİRALAMA TALEBİ: ${bahceVerisi['baslik']} (Fiyat: ${bahceVerisi['fiyat']} TL)",
      });

      // 2. Opsiyonel: Bahçenin durumunu "Dolu" olarak güncelle (Ödevde istenirse)
      /*
      await Supabase.instance.client
          .from('bahceler')
          .update({'durum': 'Dolu'})
          .eq('id', bahceVerisi['id']);
      */

      if (context.mounted) {
        Navigator.pop(context); // Yüklenme diyaloğunu kapat
        _basariDiyaloguGoster(context, bahceVerisi['baslik']);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Yüklenme diyaloğunu kapat
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata oluştu: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _basariDiyaloguGoster(BuildContext context, String baslik) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          "$baslik başarıyla kiralandı!\nİşleminiz log kayıtlarına işlendi.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Diyaloğu kapat
              Navigator.pop(context); // Ana sayfaya dön
            },
            child: const Text("TAMAM", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String baslik = bahceVerisi['baslik'] ?? "İsimsiz Bahçe";
    final String konum = bahceVerisi['konum'] ?? "Konum Belirtilmemiş";
    final String metrekare = bahceVerisi['metrekare']?.toString() ?? "0";
    final String fiyat = bahceVerisi['fiyat']?.toString() ?? "0";
    final String aciklama = bahceVerisi['aciklama'] ?? "Açıklama bulunmuyor.";
    final String durum = bahceVerisi['durum'] ?? "Boş";

    return Scaffold(
      appBar: AppBar(
        title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görsel Alanı (Daha şık bir görünüm)
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    image: const DecorationImage(
                      image: NetworkImage("https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?q=80&w=1000&auto=format&fit=crop"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: durum == "Boş" ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      durum.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          baslik,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "$fiyat TL",
                        style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey, size: 18),
                      const SizedBox(width: 5),
                      Text(konum, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text("Öne Çıkan Özellikler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _ozellikSatiri(Icons.square_foot, "$metrekare m² Genişlik"),
                  _ozellikSatiri(Icons.water_drop, "Otomatik Sulama"),
                  _ozellikSatiri(Icons.fence, "Çitlerle Çevrili Güvenli Alan"),
                  const Divider(height: 40),
                  const Text("Editörün Notu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    aciklama,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  
                  // Kiralama Butonu (Eğer bahçe doluysa butonu pasif yapıyoruz)
                  ElevatedButton(
                    onPressed: durum == "Boş" ? () => _kiralamaTalebiOlustur(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: Text(
                      durum == "Boş" ? "HEMEN KİRALA" : "BU BAHÇE DOLU",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ozellikSatiri(IconData ikon, String metin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(ikon, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 15),
          Text(metin, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}