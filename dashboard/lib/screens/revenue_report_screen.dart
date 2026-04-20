import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client.from('revenue_logs').stream(primaryKey: ['id']),
      builder: (context, snapshot) {
        double totalRevenue = 0;
        if (snapshot.hasData) {
          for (var row in snapshot.data!) {
            totalRevenue += (row['amount'] as num).toDouble();
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: Text('Agency Revenue Analytics', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRevenueSummary(totalRevenue),
                const SizedBox(height: 32),
                Text('Real-time Earnings Trend', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                _buildRevenueChart(snapshot.data ?? []),
                const SizedBox(height: 32),
                _buildTrafficFunnel(),
                const SizedBox(height: 32),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildModelRankingList(snapshot.data ?? [])),
                    const SizedBox(width: 32),
                    Expanded(flex: 1, child: _buildFanTierDistribution()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevenueSummary(double total) {
    return Row(
      children: [
        _kpiCard("Today's Total", r"$" + total.toStringAsFixed(2), "Live", Colors.green),
        const SizedBox(width: 16),
        _kpiCard("AI Sales Ratio", "84.2%", "+5.1%", Colors.blue),
        const SizedBox(width: 16),
        _kpiCard("Top Persona", "Tsundere", "HOT", Colors.orange),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String trend, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(trend, style: GoogleFonts.inter(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart(List<Map<String, dynamic>> data) {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data.isEmpty
                ? [const FlSpot(0, 0)]
                : List.generate(data.length, (i) => FlSpot(i.toDouble(), (data[i]['amount'] as num).toDouble())),
              isCurved: true,
              color: const Color(0xFF3B82F6),
              barWidth: 5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF3B82F6).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelRankingList(List<Map<String, dynamic>> logs) {
    // Group logs by model_id to show ranking
    final Map<String, double> modelTotals = {};
    for (var log in logs) {
      final mid = log['model_id']?.toString() ?? 'Unknown';
      modelTotals[mid] = (modelTotals[mid] ?? 0) + (log['amount'] as num).toDouble();
    }

    final sortedModels = modelTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Model Revenue Performance', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedModels.length.clamp(0, 5),
            separatorBuilder: (context, index) => const Divider(height: 32),
            itemBuilder: (context, index) {
              final entry = sortedModels[index];
              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF1F5F9),
                    child: Text('${index + 1}', style: const TextStyle(color: Colors.blue)),
                  ),
                  const SizedBox(width: 16),
                  Text('Model (${entry.key.substring(0, 8)})', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text(r'$' + entry.value.toStringAsFixed(2), style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFanTierDistribution() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fan Base Distribution', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(value: 5, color: const Color(0xFFFF00FF), title: 'VVIP', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 15, color: const Color(0xFF8A2BE2), title: 'VIP', radius: 45, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 30, color: const Color(0xFFFFD700), title: 'Gold', radius: 40, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  PieChartSectionData(value: 50, color: const Color(0xFFC0C0C0), title: 'Slvr', radius: 35, titleStyle: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _tierLegend('VVIP', r'>$2000', const Color(0xFFFF00FF)),
          _tierLegend('VIP', r'>$1000', const Color(0xFF8A2BE2)),
          _tierLegend('Gold', r'>$500', const Color(0xFFFFD700)),
          _tierLegend('Silver', r'>$100', const Color(0xFFC0C0C0)),
        ],
      ),
    );
  }

  Widget _buildTrafficFunnel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Social Traffic Funnel (Growth Hacking)', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Row(
            children: [
              _funnelStep("X Impressions", "45,200", "Viral", Colors.blue),
              _funnelArrow(),
              _funnelStep("Profile Clicks", "2,140", "4.7% CTR", Colors.purple),
              _funnelArrow(),
              _funnelStep("OF Conversions", "124", "Success", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _funnelStep(String title, String value, String sub, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(sub, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _funnelArrow() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFE2E8F0), size: 16),
    );
  }

  Widget _tierLegend(String label, String bracket, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(bracket, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}
