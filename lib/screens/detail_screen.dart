import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetayEkrani extends StatefulWidget {
  final Map<String, dynamic> bahceVerisi;

  const DetayEkrani({super.key, required this.bahceVerisi});

  @override
  State<DetayEkrani> createState() => _DetayEkraniState();
}

class _DetayEkraniState extends State<DetayEkrani> {
  List<Map<String, dynamic>> secilenHizmetler = [];
  double ekHizmetToplami = 0;

  Future<void> _kiralamaTalebiOlustur(BuildContext context) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      final double anaFiyat = (widget.bahceVerisi['fiyat'] ?? 0).toDouble();
      final double toplamOdeme = anaFiyat + ekHizmetToplami;

      await Supabase.instance.client.from('bahceler').update({
        'durum': 'Dolu',
        'kiralayan_id': user.id,
      }).eq('id', widget.bahceVerisi['id']);

      if (secilenHizmetler.isNotEmpty) {
        for (var hizmet in secilenHizmetler) {
          await Supabase.instance.client.from('musteri_hizmetleri').insert({
            'musteri_id': user.id,
            'bahce_id': widget.bahceVerisi['id'] ?? widget.bahceVerisi['bahce_id'],
            'hizmet_id': hizmet['id'],
          });
        }
      }

      String hizmetNotu = secilenHizmetler.map((e) => e['hizmet_adi']).join(", ");
      String islemMesaji = "KİRANDI: ${widget.bahceVerisi['baslik']} | Toplam: $toplamOdeme TL";
      if (hizmetNotu.isNotEmpty) islemMesaji += " | Hizmetler: $hizmetNotu";

      await Supabase.instance.client.from('loglar').insert({
        'kullanici_id': user.id,
        'islem': islemMesaji,
      });

      if (context.mounted) {
        Navigator.pop(context);
        _basariDiyaloguGoster(context, widget.bahceVerisi['baslik'], toplamOdeme);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("İşlem başarısız: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _basariDiyaloguGoster(BuildContext context, String baslik, double toplam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: Text(
          "$baslik başarıyla kiralandı!\nToplam Ödeme: $toplam TL\nHizmetleriniz kaydedildi.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("TAMAM", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.bahceVerisi;
    final double anaFiyat = (b['fiyat'] ?? 0).toDouble();
    final double genelToplam = anaFiyat + ekHizmetToplami;

    return Scaffold(
      appBar: AppBar(
        title: Text(b['baslik'] ?? "Bahçe Detayı", style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ustGorsel(b),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b['baslik'] ?? "", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(b['konum'] ?? "", style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 40),
                  const Text("Bu Bahçede Neler Yetişir?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _yatisenUrunlerWidget(),
                  const Divider(height: 40),
                  const Text("Ek Hizmet Alın", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _ekHizmetlerWidget(),
                  const Divider(height: 40),
                  _fiyatKarti(genelToplam),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: b['durum'] == "Boş" ? () => _kiralamaTalebiOlustur(context) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: Text(b['durum'] == "Boş" ? "HEMEN KİRALA" : "BAHÇE DOLU"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ustGorsel(Map<String, dynamic> b) {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            image: const DecorationImage(
              image: NetworkImage(
                "https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?q=80&w=1000&auto=format&fit=crop",
              ),
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
              color: b['durum'] == "Boş" ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (b['durum'] ?? "Bilinmiyor").toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fiyatKarti(double toplam) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Toplam Ödenecek:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Text("$toplam TL", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
        ],
      ),
    );
  }

  Widget _yatisenUrunlerWidget() {
    final dynamic urunlerHam = widget.bahceVerisi['urunler'];
    final List<String> urunler = urunlerHam != null ? List<String>.from(urunlerHam) : [];

    if (urunler.isEmpty) {
      return const Text("Ürün bilgisi bulunamadı.", style: TextStyle(color: Colors.grey));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: urunler.map((urunAdi) {
        return Chip(
          label: Text(urunAdi),
          avatar: const Icon(Icons.eco, size: 16, color: Colors.green),
          backgroundColor: Colors.green.shade50,
        );
      }).toList(),
    );
  }

  Widget _ekHizmetlerWidget() {
    return FutureBuilder(
      future: Supabase.instance.client.from('hizmetler').select(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final hizmetler = snapshot.data as List;

        return Column(
          children: hizmetler.map((h) {
            bool isSelected = secilenHizmetler.any((e) => e['id'] == h['id']);
            return CheckboxListTile(
              title: Text(h['hizmet_adi']),
              subtitle: Text("+ ${h['birim_fiyat']} TL"),
              value: isSelected,
              activeColor: Colors.green,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    secilenHizmetler.add(h);
                    ekHizmetToplami += (h['birim_fiyat'] ?? 0);
                  } else {
                    secilenHizmetler.removeWhere((e) => e['id'] == h['id']);
                    ekHizmetToplami -= (h['birim_fiyat'] ?? 0);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }
}