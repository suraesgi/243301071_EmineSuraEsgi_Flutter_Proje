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
  final String _userUID = Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _ekranGirisiniLogla();
  }

  Future<void> _ekranGirisiniLogla() async {
    await Supabase.instance.client.from('loglar').insert({
      'kullanici_id': _userUID,
      'islem': "Ana Liste (Bahçeler) görüntülendi.",
    });
  }

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
      backgroundColor: Colors.grey.shade50,
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {}); 
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
                
                // --- KRİTİK MANTIK: Bahçe Dolu mu? ---
                final bool isDolu = durum == "Dolu";

                return Opacity(
                  // Eğer doluysa kartı biraz soluklaştırıyoruz (0.7 opaklık)
                  opacity: isDolu ? 0.7 : 1.0,
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    elevation: isDolu ? 1 : 4, // Doluysa gölgeyi azaltıyoruz
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDolu ? Colors.grey.shade200 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDolu ? Icons.lock_outline : Icons.yard_outlined, 
                          size: 30,
                          color: isDolu ? Colors.grey : Colors.green,
                        ),
                      ),
                      title: Text(
                        baslik, 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          decoration: isDolu ? TextDecoration.lineThrough : null, // Doluysa üstünü çiz
                        )
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text("$konum\nAylık: $fiyat TL", style: const TextStyle(height: 1.4)),
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isDolu ? Icons.not_interested : Icons.arrow_forward_ios, 
                            size: 14, 
                            color: Colors.grey
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDolu ? Colors.red.shade400 : Colors.green,
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
                        // --- SAVUNMACI KONTROL ---
                        if (isDolu) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bu bahçe şu an doludur, detaylara erişilemez."),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return; // Fonksiyondan çık, sayfaya gitme
                        }

                        // Eğer boşsa logla ve detaya git
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