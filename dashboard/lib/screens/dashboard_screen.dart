import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildStatsGrid(),
                  const SizedBox(height: 48),
                  Text(
                    'Managed Models',
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  _buildModelList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF008FDB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sync, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text('FanSync AI', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 48),
          _sidebarItem(context, Icons.dashboard_rounded, 'Dashboard', isActive: true, onTap: () => Navigator.pushNamed(context, '/dashboard')),
          _sidebarItem(context, Icons.camera_alt_rounded, 'Content Studio', onTap: () => Navigator.pushNamed(context, '/content-studio')),
          _sidebarItem(context, Icons.psychology_rounded, 'Style Learning', onTap: () => Navigator.pushNamed(context, '/style-learning')),
          _sidebarItem(context, Icons.analytics_outlined, 'Style Analysis', onTap: () => Navigator.pushNamed(context, '/style-analysis')),
          _sidebarItem(context, Icons.bar_chart_rounded, 'Revenue Reports', onTap: () => Navigator.pushNamed(context, '/revenue')),
          _sidebarItem(context, Icons.groups_rounded, 'Team Management', onTap: () => Navigator.pushNamed(context, '/team')),
          _sidebarItem(context, Icons.business_center_rounded, 'Agency Console', onTap: () => Navigator.pushNamed(context, '/agency')),
          _sidebarItem(context, Icons.payments_rounded, 'Billing', onTap: () => Navigator.pushNamed(context, '/billing')),
          _sidebarItem(context, Icons.people_alt_rounded, 'Models', onTap: () => Navigator.pushNamed(context, '/team')),
          _sidebarItem(context, Icons.analytics_rounded, 'Earnings', onTap: () => Navigator.pushNamed(context, '/revenue')),
          _sidebarItem(context, Icons.settings_rounded, 'Settings', onTap: () => Navigator.pushNamed(context, '/settings')),
          const Spacer(),
          _sidebarItem(context, Icons.logout_rounded, 'Sign Out', onTap: () => _signOut(context)),
          const SizedBox(height: 16),
          _buildCreditCard(),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String label, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF008FDB).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isActive ? const Color(0xFF008FDB) : Colors.grey[400]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? const Color(0xFF008FDB) : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, Agency Admin', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold)),
            Text('Here is what\'s happening with your models today.', style: GoogleFonts.inter(color: Colors.grey[600])),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddModelDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add New Model'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  void _showAddModelDialog(BuildContext context) {
    final nameController = TextEditingController();
    String persona = 'Gyaru';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Creator Model', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Model Name / Handle'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: persona,
              decoration: const InputDecoration(labelText: 'Initial Persona'),
              items: ['Gyaru', 'Tsundere', 'Mature'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => persona = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                await Supabase.instance.client.from('models').insert({
                  'agency_id': Supabase.instance.client.auth.currentUser!.id,
                  'name': name,
                  'persona_settings': {'tone': persona}
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Model added successfully!')),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client.from('revenue_logs').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        double total = 0;
        if (snapshot.hasData) {
          for (var row in snapshot.data!) {
            total += (row['amount'] as num).toDouble();
          }
        }

        return Row(
          children: [
            _statCard('Total Earnings', r'$' + total.toStringAsFixed(2), Icons.payments_rounded, Colors.green),
            const SizedBox(width: 24),
            _statCard('AI Conversations', 'Live', Icons.chat_bubble_rounded, Colors.blue),
            const SizedBox(width: 24),
            _statCard('Active Models', snapshot.hasData ? snapshot.data!.length.toString() : '...', Icons.trending_up_rounded, Colors.orange),
          ],
        );
      }
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 20),
            Text(value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
            Text(label, style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client.from('models').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          
          final models = snapshot.data ?? [];
          
          return Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1),
            },
            children: [
              _tableHeader(),
              ...models.map((m) => _tableRow(
                m['name'] ?? 'Unknown',
                'Active',
                'Synced',
                'Just now',
              )),
            ],
          );
        }
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      children: ['Model Name', 'Status', 'Credits', 'Last Seen'].map((e) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(e, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600])),
      )).toList(),
    );
  }

  TableRow _tableRow(String name, String status, String credits, String time) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(20), child: Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        Padding(padding: const EdgeInsets.all(20), child: Row(
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(status),
          ],
        )),
        Padding(padding: const EdgeInsets.all(20), child: Text(credits)),
        Padding(padding: const EdgeInsets.all(20), child: Text(time)),
      ],
    );
  }

  Widget _buildCreditCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF008FDB), Color(0xFF00C2FF)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Agency Wallet', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('Unlimited Credits', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Top Up', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
