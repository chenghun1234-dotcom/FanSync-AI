import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AgencyModel {
  final String id;
  final String name;
  final String status;
  int creditQuota;
  final double currentEarnings;
  final String lastActivity;

  AgencyModel({
    required this.id,
    required this.name,
    required this.status,
    required this.creditQuota,
    required this.currentEarnings,
    required this.lastActivity,
  });
}

class AgencyConsoleScreen extends StatefulWidget {
  const AgencyConsoleScreen({super.key});

  @override
  State<AgencyConsoleScreen> createState() => _AgencyConsoleScreenState();
}

class _AgencyConsoleScreenState extends State<AgencyConsoleScreen> {
  final List<AgencyModel> _models = List.generate(
    12,
    (index) => AgencyModel(
      id: 'model_$index',
      name: 'Model_${String.fromCharCode(65 + index)}${index + 1}',
      status: index % 3 == 0 ? 'Active' : 'Idle',
      creditQuota: 500,
      currentEarnings: (index + 1) * 150.50,
      lastActivity: '${index + 1}m ago',
    ),
  );

  void _updateQuota(int index, int newQuota) {
    setState(() {
      _models[index].creditQuota = newQuota;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text('Agency Management Console', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Register New Model'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 32),
            Expanded(child: _buildModelGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statItem('Total Managed Models', '${_models.length}', Colors.blue),
        const SizedBox(width: 24),
        _statItem('Active Today', '8', Colors.green),
        const SizedBox(width: 24),
        _statItem('Total Agency Revenue', '\$14,240.00', Colors.purple),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13)),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildModelGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.4,
      ),
      itemCount: _models.length,
      itemBuilder: (context, index) => _buildModelCard(_models[index], index),
    );
  }

  Widget _buildModelCard(AgencyModel model, int index) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(model.name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              _statusChip(model.status),
            ],
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Earnings', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  Text('\$${model.currentEarnings}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Activity', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
                  Text(model.lastActivity, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.token_outlined, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text('Quota: ${model.creditQuota} CR', style: GoogleFonts.inter(fontSize: 13)),
              const Spacer(),
              TextButton(
                onPressed: () => _showQuotaDialog(index),
                child: const Text('Edit Quota'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    bool isActive = status == 'Active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showQuotaDialog(int index) {
    final controller = TextEditingController(text: _models[index].creditQuota.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Credit Quota for ${_models[index].name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Allocated Credits'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _updateQuota(index, int.parse(controller.text));
              Navigator.pop(context);
            },
            child: const Text('Apply Quota'),
          ),
        ],
      ),
    );
  }
}
