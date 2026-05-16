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

  Future<void> _bahceSil(String id, String baslik) async {
    try {
      await Supabase.instance.client.from('bahceler').delete().eq('id', id);
      await Supabase.instance.client.from('loglar').insert({
        'kullanici_id': _userUID,
        'islem': "BAHÇE SİLİNDİ: $baslik",
      });
      _mesajGoster("Bahçe başarıyla silindi.");
      setState(() {});
    } catch (e) {
      _mesajGoster("Silme işlemi başarısız: $e");
    }
  }

  Future<Map<String, dynamic>> _panelVerileriniGetir() async {
    final bahceler = await Supabase.instance.client
        .from('bahceler')
        .select()
        .eq('sahip_id', _userUID);

    final loglar = await Supabase.instance.client
        .from('loglar')
        .select()
        .eq('kullanici_id', _userUID);

    return {
      'bahceListesi': bahceler,
      'islemSayisi': loglar.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Yönetim Paneli", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
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
          final List bahceler = data['bahceListesi'];
          
          // Durum sayılarını hesapla
          final doluSayisi = bahceler.where((b) => b['durum'] == 'Dolu').length;
          final bosSayisi = bahceler.where((b) => b['durum'] == 'Boş').length;

          return RefreshIndicator(
            onRefresh: () async { setState(() {}); },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ÖZET BÖLÜMÜ ---
                  const Text("Genel Durum", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _modernOzetKarti("Toplam", bahceler.length.toString(), Colors.blue, Icons.inventory_2_outlined),
                        _modernOzetKarti("Boş", bosSayisi.toString(), Colors.green, Icons.check_circle_outline),
                        _modernOzetKarti("Dolu", doluSayisi.toString(), Colors.red, Icons.block_flipped),
                        _modernOzetKarti("Log", data['islemSayisi'].toString(), Colors.orange, Icons.history),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // --- BAHÇELER LİSTESİ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Kayıtlı Bahçelerim", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${bahceler.length} Bahçe", style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (bahceler.isEmpty)
                    _bosDurumGoster()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: bahceler.length,
                      itemBuilder: (context, index) {
                        final bahce = bahceler[index];
                        final String durum = bahce['durum'] ?? "Boş";
                        Color durumColor = durum == "Boş" ? Colors.green : Colors.red;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              // Kartın Üst Kısmı (Durum Çubuğu)
                              Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color: durumColor,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                ),
                              ),
                              ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: durumColor.withOpacity(0.1),
                                  child: Icon(Icons.yard_outlined, color: durumColor),
                                ),
                                title: Text(bahce['baslik'] ?? "İsimsiz", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text("${bahce['konum']} • ${bahce['metrekare']} m²", style: const TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Text("${bahce['fiyat']} TL / Ay", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                trailing: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: durumColor, borderRadius: BorderRadius.circular(8)),
                                      child: Text(durum, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _bahceSil(bahce['id'].toString(), bahce['baslik']),
                                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                      label: const Text("Sil", style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () { /* Düzenleme ekranı */ },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade700,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      child: const Text("Yönet"),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
        onPressed: () => _mesajGoster("Form modülü hazırlanıyor..."),
        label: const Text("Yeni Bahçe", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.green.shade900,
      ),
    );
  }

  Widget _modernOzetKarti(String baslik, String deger, Color renk, IconData ikon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: renk.withOpacity(0.1), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, color: renk, size: 28),
          const SizedBox(height: 12),
          Text(deger, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: renk)),
          Text(baslik, style: TextStyle(color: renk.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _bosDurumGoster() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.add_business_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Kayıtlı bahçeniz bulunmuyor.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mesaj), behavior: SnackBarBehavior.floating));
  }
}