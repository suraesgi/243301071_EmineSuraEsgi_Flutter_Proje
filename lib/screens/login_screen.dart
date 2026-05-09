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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen e-posta ve şifrenizi girin!")),
      );
      return;
    }

    setState(() => _yukleniyor = true);

    try {
      // A. Supabase ile kimlik doğrulama
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
      );

      if (res.user != null) {
        // B. Kullanıcının rolünü veritabanından sorgula
        final userData = await Supabase.instance.client
            .from('kullanicilar')
            .select('rol')
            .eq('id', res.user!.id)
            .single();

        String gelenRol = userData['rol'];

        // C. LOG KAYDI TUT
        await Supabase.instance.client.from('loglar').insert({
          'kullanici_id': res.user!.id,
          'islem': "Giriş yapıldı. Rol: $gelenRol",
        });

        if (mounted) {
          // D. Role göre doğru ekrana yönlendir
          if (gelenRol == "Bahçe Sahibi") {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SahipPaneli()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AnaEkran()));
          }
        }
      }
    } on AuthException catch (error) {
      // Supabase'den gelen hataları Türkçeleştirme
      String mesaj = "Bir hata oluştu";
      if (error.message.contains("Invalid login credentials")) {
        mesaj = "E-posta veya şifre hatalı!";
      } else if (error.message.contains("Email not confirmed")) {
        mesaj = "Lütfen e-posta adresinizi onaylayın!";
      } else {
        mesaj = error.message;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mesaj), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Beklenmedik bir hata oluştu"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _yukleniyor = false);
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
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator(color: Colors.green)) 
        : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_florist, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Hobi Bahçesi Sistemi",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            TextField(
              controller: _emailController,
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
            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _girisYap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Giriş Yap", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KayitEkrani())),
              child: const Text("Hesabınız yok mu? Kayıt Olun", style: TextStyle(color: Colors.green, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}