import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart'; 
import 'screens/home_screen.dart';
import 'screens/owner_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Başlatma
  await Supabase.initialize(
    url: 'https://uzkdmdkswrdoantrneep.supabase.co',
    anonKey: 'sb_publishable_DguJNCUJnf3bCd_Rngf4wg_q6wkQ0Sw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Aktif oturum kontrolü
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hobi Bahçesi',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, // Modern görünüm için
      ),
      // Session (Oturum) varsa rol kontrolüne, yoksa giriş ekranına git
      home: session != null ? const OturumKontrolEkrani() : const GirisEkrani(),
    );
  }
}

class OturumKontrolEkrani extends StatelessWidget {
  const OturumKontrolEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    // Eğer bir şekilde user null ise (beklenmedik durum) girişe yönlendir
    if (user == null) return const GirisEkrani();

    return FutureBuilder(
      // Kullanıcının rolünü 'kullanicilar' tablosundan sorguluyoruz
      future: Supabase.instance.client
          .from('kullanicilar')
          .select('rol')
          .eq('id', user.id)
          .maybeSingle(), // .single() yerine .maybeSingle() daha güvenlidir
      builder: (context, snapshot) {
        // Veri yüklenirken yeşil bir loading göster
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }
        
        // Hata oluşursa veya veritabanında bu ID'ye ait rol bulunamazsa oturumu kapat ve girişe at
        if (snapshot.hasError || snapshot.data == null) {
          return const GirisEkrani(); 
        }

        final rol = snapshot.data!['rol'];
        
        // ÖDEV ŞARTI: Role göre yönlendirme yapılıyor
        if (rol == "Bahçe Sahibi") {
          return const SahipPaneli();
        } else {
          return const AnaEkran();
        }
      },
    );
  }
}