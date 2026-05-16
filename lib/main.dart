import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart'; 
import 'screens/home_screen.dart';
import 'screens/owner_dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hobi Bahçesi',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, 
      ),
      home: session != null ? const OturumKontrolEkrani() : const GirisEkrani(),
    );
  }
}

class OturumKontrolEkrani extends StatelessWidget {
  const OturumKontrolEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return const GirisEkrani();

    return FutureBuilder(

      future: Supabase.instance.client
          .from('kullanicilar')
          .select('rol')
          .eq('id', user.id)
          .maybeSingle(), 
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.green)),
          );
        }
        
        if (snapshot.hasError || snapshot.data == null) {
          return const GirisEkrani(); 
        }

        final rol = snapshot.data!['rol'];
        
        if (rol == "Bahçe Sahibi") {
          return const SahipPaneli();
        } else {
          return const AnaEkran();
        }
      },
    );
  }
}