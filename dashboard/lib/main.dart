import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/content_studio_screen.dart';
import 'screens/style_learning_screen.dart';
import 'screens/agency_console_screen.dart';
import 'screens/billing_screen.dart';
import 'screens/style_analysis_screen.dart';
import 'screens/revenue_report_screen.dart';
import 'screens/team_management_screen.dart';

import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://abclfexwwxulczcuubia.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2xmZXh3d3h1bGN6Y3V1YmlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY2NjQ5MTgsImV4cCI6MjA5MjI0MDkxOH0.OTpZICqQd7DCNEV-PWCdur2aPq7lY-ybDkV_tmbZ0XY',
  );

  runApp(const FanSyncApp());
}

class FanSyncApp extends StatelessWidget {
  const FanSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FanSync AI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008FDB)),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      initialRoute: session == null ? '/login' : '/dashboard',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/content-studio': (context) => const ContentStudioScreen(),
        '/style-learning': (context) => const StyleLearningScreen(),
        '/agency': (context) => const AgencyConsoleScreen(),
        '/billing': (context) => const BillingScreen(),
        '/style-analysis': (context) => const StyleAnalysisScreen(),
        '/revenue': (context) => const RevenueReportScreen(),
        '/team': (context) => const TeamManagementScreen(),
      },
    );
  }
}
