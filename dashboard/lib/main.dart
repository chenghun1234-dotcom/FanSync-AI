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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase (Use placeholders for now)
  // await Supabase.initialize(
  //   url: 'YOUR_SUPABASE_URL',
  //   anonKey: 'YOUR_SUPABASE_ANON_KEY',
  // );

  runApp(const FanSyncApp());
}

class FanSyncApp extends StatelessWidget {
  const FanSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FanSync AI',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008FDB)),
        textTheme: GoogleFonts.interTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
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
