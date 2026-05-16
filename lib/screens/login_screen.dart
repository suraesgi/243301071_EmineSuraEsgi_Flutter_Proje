import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart'; 
import 'home_screen.dart';
import 'owner_dashboard_screen.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  bool _yukleniyor = false;

  Future<void> _girisYap() async {
    if (_emailController.text.isEmpty || _sifreController.text.isEmpty) {
      _mesajGoster("Lütfen e-posta ve şifrenizi girin!", Colors.orange);
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );

      if (res.user != null) {

        final userData = await Supabase.instance.client
            .from('kullanicilar')
            .select('rol, ad, soyad') 
            .eq('id', res.user!.id)
            .single();

        String gelenRol = userData['rol'];
        String tamAd = "${userData['ad']} ${userData['soyad']}";

        await Supabase.instance.client.from('loglar').insert({
          'kullanici_id': res.user!.id,
          'islem': "Başarılı Giriş yapıldı. Kullanıcı: $tamAd, Rol: $gelenRol",
        });

        if (mounted) {
          _mesajGoster("Hoş geldiniz, $tamAd", Colors.green);
          
          Navigator.pushReplacement(
            context, 
            MaterialPageRoute(
              builder: (context) => gelenRol == "Bahçe Sahibi" 
                  ? const SahipPaneli() 
                  : const AnaEkran()
            )
          );
        }
      }
    } on AuthException catch (error) {
      String mesaj = "Giriş başarısız";
      if (error.message.contains("Invalid login credentials")) {
        mesaj = "E-posta veya şifre hatalı!";
      } else {
        mesaj = "Hata: ${error.message}";
      }
      _mesajGoster(mesaj, Colors.red);
    } catch (error) {
      _mesajGoster("Kullanıcı profili bulunamadı. Lütfen tekrar kayıt olun.", Colors.red);
      debugPrint("Giriş Hatası Detayı: $error");
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
    }
  }

  void _mesajGoster(String mesaj, Color renk) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mesaj), 
          backgroundColor: renk,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator(color: Colors.green)) 
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_florist, size: 100, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    "Hobi Bahçesi Kiralama Sistemi",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const Text(
                    "Kiralama ve Yönetim Sistemine Giriş",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-posta', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _sifreController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Şifre', 
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 25),

                  ElevatedButton(
                    onPressed: _girisYap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => const KayitEkrani())
                    ),
                    child: const Text(
                      "Hesabınız yok mu? Hemen Kayıt Olun", 
                      style: TextStyle(color: Colors.green, fontSize: 15, fontWeight: FontWeight.w600)
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}