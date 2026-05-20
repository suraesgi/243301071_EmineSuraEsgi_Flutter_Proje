import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BahceEkleEkrani extends StatefulWidget {
  const BahceEkleEkrani({super.key});

  @override
  State<BahceEkleEkrani> createState() => _BahceEkleEkraniState();
}

class _BahceEkleEkraniState extends State<BahceEkleEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _baslikController = TextEditingController();
  final _konumController = TextEditingController();
  final _fiyatController = TextEditingController();
  final _metrekareController = TextEditingController();
  final _gorselUrlController = TextEditingController();

  bool _yukleniyor = false;

  final List<String> _kullanilabilirUrunler = [
    'Domates',
    'Biber',
    'Patates',
    'Soğan',
    'Havuç',
    'Salatalık',
  ];
  final List<String> _kullanilabilirHizmetler = [
    'Çapalama',
    'Budama',
    'Sulama',
    'Gübreleme',
    'İlaçlama',
  ];

  final List<String> _secilenUrunler = [];
  final List<String> _secilenHizmetler = [];

  Future<void> _bahceKaydet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _yukleniyor = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Oturum açık kullanıcı bulunamadı.");

      final bahceResponse = await Supabase.instance.client
          .from('bahceler')
          .insert({
            'baslik': _baslikController.text.trim(),
            'fiyat': double.parse(_fiyatController.text.trim()),
            'konum': _konumController.text.trim(),
            'sahip_id': user.id,
            'kiralayan_id': null,
            'bahce_no': DateTime.now().millisecondsSinceEpoch,
            'metrekare': int.parse(_metrekareController.text.trim()),
            'durum': 'Boş',
            'urunler': _secilenUrunler,
            'hizmetler': _secilenHizmetler,
          })
          .select()
          .single();

      final int yeniBahceId = bahceResponse['id'];

      await Supabase.instance.client.from('loglar').insert({
        'kullanici_id': user.id,
        'islem': "Yeni bahçe ilanı oluşturuldu. İlan ID: $yeniBahceId",
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yeni Hobi Bahçeniz Başarıyla İlan Edildi!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (hata) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sistem Hatası: $hata'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "Yeni Bahçe İlanı Ekle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bahçe Genel Bilgileri",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _baslikController,
                              decoration: const InputDecoration(
                                labelText: 'Bahçe Adı / İlan Başlığı',
                                prefixIcon: Icon(Icons.villa, color: Colors.green),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Lütfen bir başlık girin' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _konumController,
                              decoration: const InputDecoration(
                                labelText: 'Konum / Adres Bilgisi',
                                prefixIcon: Icon(Icons.location_on, color: Colors.green),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Lütfen konum bilgisini girin' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _fiyatController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Aylık Kiralama Bedeli (TL)',
                                prefixIcon: Icon(Icons.monetization_on, color: Colors.green),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Lütfen fiyat girin' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _metrekareController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Bahçe Alanı (m²)',
                                prefixIcon: Icon(Icons.straighten, color: Colors.green),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Lütfen metrekare girin' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Ekilebilir Ürün Seçenekleri",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _kullanilabilirUrunler.map((urun) {
                            final seciliMi = _secilenUrunler.contains(urun);
                            return FilterChip(
                              label: Text(urun),
                              selected: seciliMi,
                              selectedColor: Colors.green.shade100,
                              checkmarkColor: Colors.green.shade800,
                              onSelected: (bool deger) {
                                setState(() {
                                  deger
                                      ? _secilenUrunler.add(urun)
                                      : _secilenUrunler.remove(urun);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Sunulabilecek Ek Hizmetler",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: _kullanilabilirHizmetler.map((hizmet) {
                            final seciliMi = _secilenHizmetler.contains(hizmet);
                            return CheckboxListTile(
                              title: Text(
                                hizmet,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              activeColor: Colors.green.shade700,
                              value: seciliMi,
                              onChanged: (bool? deger) {
                                setState(() {
                                  if (deger == true) {
                                    _secilenHizmetler.add(hizmet);
                                  } else {
                                    _secilenHizmetler.remove(hizmet);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        onPressed: _bahceKaydet,
                        child: const Text(
                          "Bahçeyi Veritabanına Kaydet ve İlan Et",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _baslikController.dispose();
    _konumController.dispose();
    _fiyatController.dispose();
    _metrekareController.dispose();
    _gorselUrlController.dispose();
    super.dispose();
  }
}