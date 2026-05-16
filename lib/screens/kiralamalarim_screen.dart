import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KiralamalarimEkrani extends StatelessWidget {
  const KiralamalarimEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text("Kiralama Geçmişim", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: Supabase.instance.client
            .from('bahceler')
            .select('*, musteri_hizmetleri(*, hizmetler(*))')
            .eq('kiralayan_id', user!.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Hata: ${snapshot.error}"));
          }

          final kiralamalar = snapshot.data as List?;

          if (kiralamalar == null || kiralamalar.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text("Henüz bir kiralama yapmadınız.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: kiralamalar.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final kiralama = kiralamalar[index];
              final ekHizmetler = kiralama['musteri_hizmetleri'] as List;
              
              // Toplam ücret hesaplama
              double bahceFiyat = (kiralama['fiyat'] ?? 0).toDouble();
              double hizmetToplami = 0;
              for (var h in ekHizmetler) {
                hizmetToplami += (h['hizmetler']['fiyat'] ?? 0).toDouble();
              }
              double genelToplam = bahceFiyat + hizmetToplami;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.yard_outlined, color: Colors.green),
                      ),
                      title: Text(kiralama['baslik'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("Konum: ${kiralama['konum']}"),
                      trailing: Text("$genelToplam TL", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                    ),
                    if (ekHizmetler.isNotEmpty) ...[
                      const Divider(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Alınan Ek Hizmetler:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            const SizedBox(height: 4),
                            ...ekHizmetler.map((h) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("• ${h['hizmetler']['hizmet_adi']}", style: const TextStyle(fontSize: 13)),
                                  Text("${h['hizmetler']['fiyat']} TL", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}