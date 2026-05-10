import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KayitEkrani extends StatefulWidget {
  const KayitEkrani({super.key});

  @override
  State<KayitEkrani> createState() => _KayitEkraniState();
}

class _KayitEkraniState extends State<KayitEkrani> {
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _sifreController = TextEditingController();
  final TextEditingController _telefonController = TextEditingController();
  final TextEditingController _ibanController = TextEditingController();

  String? _rolGrubu = "Müşteri"; 
  bool _yukleniyor = false; 

  bool _bilgileriDogrula() {
    if (_adController.text.trim().isEmpty || 
        _soyadController.text.trim().isEmpty || 
        _emailController.text.trim().isEmpty || 
        _sifreController.text.trim().isEmpty || 
        _telefonController.text.trim().isEmpty) {
      _mesajGoster("Lütfen gerekli tüm alanları doldurun!", Colors.orange);
      return false;
    }
    if (!_emailController.text.contains('@')) {
      _mesajGoster("Geçerli bir e-posta adresi giriniz!", Colors.orange);
      return false;
    }
    if (_sifreController.text.length < 6) {
      _mesajGoster("Şifre en az 6 karakter olmalıdır!", Colors.orange);
      return false;
    }
    if (_rolGrubu == "Bahçe Sahibi" && _ibanController.text.trim().isEmpty) {
      _mesajGoster("Bahçe sahibi için IBAN bilgisi zorunludur!", Colors.orange);
      return false;
    }
    return true; 
  }

  Future<void> _kayitOl() async {
    if (!_bilgileriDogrula()) return;
    setState(() => _yukleniyor = true);

    try {
      // 1. ADIM: Supabase Auth Kaydı
      // 'data' alanı tetikleyicinin (Trigger) çalışması için zorunludur.
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _sifreController.text.trim(),
        data: {
          'ad': _adController.text.trim(),
          'soyad': _soyadController.text.trim(),
          'rol': _rolGrubu,
          'telefon': _telefonController.text.trim(),
          'iban': _rolGrubu == "Bahçe Sahibi" ? _ibanController.text.trim() : null,
        },
      );

      if (res.user != null) {
        // 2. ADIM: Başarı Mesajı ve Giriş Ekranına Yönlendirme
        if (mounted) {
          _mesajGoster("Kayıt Başarılı! Şimdi giriş yapabilirsiniz.", Colors.green);
          
          // Kullanıcının mesajı okuması için kısa bir bekleme
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            // Navigator.pop(context) seni doğrudan GİRİŞ EKRANINA geri gönderir.
            Navigator.pop(context); 
          }
        }
      }
    } on AuthException catch (error) {
      // Kullanıcı zaten varsa doğrudan yönlendirme önerisi sunarız
      if (error.message.contains("already registered")) {
        _mesajGoster("Bu e-posta zaten kayıtlı, lütfen giriş yapın.", Colors.orange);
        Navigator.pop(context);
      } else {
        _mesajGoster("Hata: ${error.message}", Colors.red);
      }
    } catch (error) {
      _mesajGoster("Beklenmedik bir hata oluştu: $error", Colors.red);
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
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _telefonController.dispose();
    _ibanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni Kayıt", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _yukleniyor 
        ? const Center(child: CircularProgressIndicator(color: Colors.green)) 
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Icon(Icons.person_add_alt_1, size: 80, color: Colors.green),
                const SizedBox(height: 30),
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _adController, 
                        decoration: InputDecoration(
                          labelText: 'Ad',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _soyadController, 
                        decoration: InputDecoration(
                          labelText: 'Soyad',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                
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
                  controller: _telefonController, 
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Telefon Numarası',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone),
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

                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı Rolü',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.supervised_user_circle),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text("Müşteri"),
                        value: "Müşteri",
                        groupValue: _rolGrubu,
                        activeColor: Colors.green,
                        onChanged: (val) => setState(() => _rolGrubu = val),
                      ),
                      RadioListTile<String>(
                        title: const Text("Bahçe Sahibi"),
                        value: "Bahçe Sahibi",
                        groupValue: _rolGrubu,
                        activeColor: Colors.green,
                        onChanged: (val) => setState(() => _rolGrubu = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_rolGrubu == "Bahçe Sahibi") ...[
                  TextField(
                    controller: _ibanController,
                    decoration: InputDecoration(
                      labelText: 'IBAN (TR...)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 15),
                ],

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _yukleniyor ? null : _kayitOl, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Kayıt Ol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
    );
  }
}