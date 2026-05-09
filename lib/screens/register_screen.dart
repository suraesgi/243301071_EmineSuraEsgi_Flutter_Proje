import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart'; 

String secilenRol = "Müşteri"; 

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController _adSoyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();

  String? _rolGrubu = "Müşteri"; 
  bool _yukleniyor = false; 

  bool _bilgileriDogrula() {
    final adSoyad = _adSoyadController.text.trim();
    final email = _emailController.text.trim();
    final sifre = _sifreController.text.trim();

    if (adSoyad.isEmpty || email.isEmpty || sifre.isEmpty) {
      _hataMesajiGoster("Lütfen tüm alanları doldurun!");
      return false;
    }

    if (!email.contains('@') || !email.contains('.')) {
      _hataMesajiGoster("Geçerli bir e-posta adresi giriniz!");
      return false;
    }

    if (sifre.length < 6) {
      _hataMesajiGoster("Şifre güvenliğiniz için en az 6 karakter olmalıdır!");
      return false;
    }

    return true; 
  }

  void _hataMesajiGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _kayitOl() async {
    if (!_bilgileriDogrula()) return;

    setState(() => _yukleniyor = true);

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );

      final String? userId = res.user?.id;

      if (userId != null) {
        await Supabase.instance.client.from('kullanicilar').insert({
          'id': userId,
          'ad_soyad': _adSoyadController.text.trim(),
          'eposta': _emailController.text.trim(),
          'rol': _rolGrubu,
        });

        await Supabase.instance.client.from('loglar').insert({
          'kullanici_id': userId,
          'islem': "Yeni kullanıcı kayıt oldu. Rol: $_rolGrubu",
        });

        if (mounted) {
          secilenRol = _rolGrubu!; 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt Başarılı! Giriş Yapabilirsiniz.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); 
        }
      }
    } on AuthException catch (error) {
      if (mounted) _hataMesajiGoster(error.message);
    } catch (error) {
      if (mounted) _hataMesajiGoster("Beklenmedik bir hata oluştu");
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  @override
  void dispose() {
    _adSoyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kayıt"),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator(color: Colors.green)) 
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.person_add_alt_1, size: 60, color: Colors.green),
            const SizedBox(height: 30),

            TextField(
              controller: _adSoyadController, 
              decoration: const InputDecoration(
                labelText: 'Ad Soyad',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _emailController, 
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-posta',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _sifreController, 
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Şifre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 20),

            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Kullanıcı Rolü Seçiniz',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.supervised_user_circle),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text("Müşteri"),
                    value: "Müşteri",
                    groupValue: _rolGrubu,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero, 
                    onChanged: (val) {
                      setState(() {
                        _rolGrubu = val;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("Bahçe Sahibi"),
                    value: "Bahçe Sahibi",
                    groupValue: _rolGrubu,
                    activeColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setState(() {
                        _rolGrubu = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _kayitOl, 
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Kayıt Ol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}