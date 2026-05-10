import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'profile_screen.dart';

class SahipPaneli extends StatefulWidget {
  const SahipPaneli({super.key});

  @override
  State<SahipPaneli> createState() => _SahipPaneliState();
}

class _SahipPaneliState extends State<SahipPaneli> {
  final String _userUID = Supabase.instance.client.auth.currentUser!.id;

  // Panelin her açılışını loglayalım (ÖDEV ŞARTI)
  @override
  void initState() {
    super.initState();
    _panelGirisiniLogla();
  }

  Future<void> _panelGirisiniLogla() async {
    await Supabase.instance.client.from('loglar').insert({
      'kullanici_id': _userUID,
      'islem': "Sahip Paneli görüntülendi.",
    });
  }

  Future<Map<String, dynamic>> _panelVerileriniGetir() async {
    // 1. Sahibe ait bahçeleri çek
    final bahceler = await Supabase.instance.client
        .from('bahceler')
        .select()
        .eq('sahip_id', _userUID);

    // 2. İşlem geçmişini çek (Kendi yaptığı işlemler veya bahçeleriyle ilgili loglar)
    final talepler = await Supabase.instance.client
        .from('loglar')
        .select()
        .eq('kullanici_id', _userUID) // Sadece bu kullanıcıya ait loglar
        .order('olusturulma_tarihi', ascending: false)
        .limit(10); // Son 10 işlem

    return {
      'toplamBahce': bahceler.length,
      'islemSayisi': talepler.length,
      'talepler': talepler,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bahçe Sahibi Paneli", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilEkrani()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _panelVerileriniGetir(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          final data = snapshot.data!;
          final List islemler = data['talepler'];

          return RefreshIndicator(
            onRefresh: () async { setState(() {}); }, 
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Genel Durum", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _ozetKart("Bahçelerim", data['toplamBahce'].toString(), Colors.blueAccent, Icons.landscape),
                      _ozetKart("Log Kayıtları", data['islemSayisi'].toString(), Colors.teal, Icons.list_alt),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text("Son Etkinlikler", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  if (islemler.isEmpty)
                    _bosDurumWidget()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: islemler.length,
                      itemBuilder: (context, index) {
                        final item = islemler[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Colors.green),
                            title: Text(item['islem'] ?? "İşlem Detayı Yok"),
                            subtitle: Text(item['olusturulma_tarihi']?.toString().split('.')[0] ?? ""),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Buraya Yeni Bahçe Ekleme Ekranı (Form Ekranı) gelecek
          _mesajGoster("Yeni bahçe ekleme formu açılıyor...");
        },
        label: const Text("Yeni Bahçe", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green.shade900,
      ),
    );
  }

  Widget _bosDurumWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          children: [
            Icon(Icons.layers_clear, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text("Henüz bir işlem kaydı bulunamadı.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj)));
  }

  Widget _ozetKart(String baslik, String deger, Color renk, IconData ikon) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [renk.withValues(alpha: 0.7), renk],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Icon(ikon, color: Colors.white, size: 30),
              const SizedBox(height: 10),
              Text(baslik, style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text(deger, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}