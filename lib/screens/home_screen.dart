import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_screen.dart';
import 'profile_screen.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({super.key});

  @override
  State<AnaEkran> createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  // Giriş yapmış kullanıcının ID'si
  final String _userUID = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _ekranGirisiniLogla();
  }

  // ÖDEV ŞARTI: Ekranın açılışını logluyoruz
  Future<void> _ekranGirisiniLogla() async {
    await Supabase.instance.client.from('loglar').insert({
      'kullanici_id': _userUID,
      'islem': "Ana Liste (Bahçeler) görüntülendi.",
    });
  }

  // Veritabanından bahçeleri çeken fonksiyon
  Future<List<Map<String, dynamic>>> _bahceleriGetir() async {
    try {
      final response = await Supabase.instance.client
          .from('bahceler')
          .select()
          .order('id', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception("Bahçeler yüklenirken hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hobi Bahçeleri", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilEkrani()),
              );
            },
          ),
        ],
      ),
      // RefreshIndicator: Listeyi aşağı çekince verileri yeniler
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); // FutureBuilder'ı tetikler
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _bahceleriGetir(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.green));
            }

            if (snapshot.hasError) {
              return Center(child: Text("Hata: ${snapshot.error}"));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Henüz kayıtlı bahçe bulunmuyor."));
            }

            final bahceler = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: bahceler.length,
              itemBuilder: (context, index) {
                final bahce = bahceler[index];
                
                final String baslik = bahce['baslik'] ?? "İsimsiz Bahçe";
                final String konum = bahce['konum'] ?? "Konya";
                final String fiyat = bahce['fiyat']?.toString() ?? "0";
                final String durum = bahce['durum'] ?? "Boş";

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: durum == "Boş" ? Colors.green.shade50 : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.yard_outlined, 
                        size: 30,
                        color: durum == "Boş" ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text("$konum\nAylık: $fiyat TL", style: const TextStyle(height: 1.4)),
                    ),
                    isThreeLine: true,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: durum == "Boş" ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            durum,
                            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      // ÖDEV ŞARTI: Tıklama işlemini logla
                      await Supabase.instance.client.from('loglar').insert({
                        'kullanici_id': _userUID,
                        'islem': "$baslik bahçesinin detaylarına bakıldı.",
                      });

                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetayEkrani(bahceVerisi: bahce),
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}