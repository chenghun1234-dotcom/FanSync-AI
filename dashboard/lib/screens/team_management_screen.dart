import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class TeamManagementScreen extends StatefulWidget {
  const TeamManagementScreen({super.key});

  @override
  State<TeamManagementScreen> createState() => _TeamManagementScreenState();
}

class _TeamManagementScreenState extends State<TeamManagementScreen> {
  final List<Map<String, String>> _members = [
    {'name': 'Alex Kim', 'role': 'Owner', 'status': 'Online'},
    {'name': 'Sarah Chen', 'role': 'Chatter', 'status': 'Away'},
    {'name': 'Hiroshi Sato', 'role': 'Chatter', 'status': 'Offline'},
  ];

  void _generateInviteLink() {
    if (_members.length >= 6) { // 1 Owner + 5 Chatters
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Action Blocked: 5-Chatter limit reached for your agency."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    const inviteUrl = "https://fansync-ai.web.app/invite?token=XYZ_SECURE_TOKEN";
    Clipboard.setData(const ClipboardData(text: inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invite link copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Team Management', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStaffLeaderboard(),
            const SizedBox(height: 32),
            _buildMemberListGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Agency Staffing', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('${_members.where((m) => m['role'] == 'Chatter').length} / 5 Chatter slots used', 
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _generateInviteLink,
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Invite Staff'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildStaffLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chatter Performance (Last 7 Days)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
              columns: const [
                DataColumn(label: Text('Staff Member')),
                DataColumn(label: Text('AI Chats')),
                DataColumn(label: Text('PPV Success Rate')),
                DataColumn(label: Text('Contribution')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('Sarah Chen')),
                  const DataCell(Text('420')),
                  DataCell(Text('18.5%', style: GoogleFonts.inter(color: Colors.green, fontWeight: FontWeight.bold))),
                  const DataCell(Text('\$2,450')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('Hiroshi Sato')),
                  const DataCell(Text('215')),
                  DataCell(Text('12.1%', style: GoogleFonts.inter(color: Colors.blue, fontWeight: FontWeight.bold))),
                  const DataCell(Text('\$1,120')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberListGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 2.5,
      ),
      itemCount: _members.length,
      itemBuilder: (context, index) {
        final member = _members[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF1F5F9),
                child: Text(member['name']![0]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(member['name']!, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    Text(member['role']!, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: member['status'] == 'Online' ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
