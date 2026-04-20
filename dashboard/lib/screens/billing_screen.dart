import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/paypal_payment_button.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Billing & Agency Revenue', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRevenueSummary(),
            const SizedBox(height: 48),
            Text('Payout & Refill', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildPaymentMethods()),
                const SizedBox(width: 32),
                Expanded(flex: 3, child: _buildTransactionHistory()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSummary() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Balance', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
              const SizedBox(height: 8),
              Text('\$4,520.00', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _miniStat('This Month', '+\$1,240.50'),
                  const SizedBox(width: 32),
                  _miniStat('Pending Payouts', '\$240.00'),
                ],
              ),
            ],
          ),
          PayPalPaymentButton(
            amount: 50.00,
            onSuccess: (paymentId) {
              debugPrint('Payment Successful: $paymentId');
            },
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white38, fontSize: 13)),
        Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Automated Billing', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          _paymentCard('PayPal', 'agency-admin@paypal.com', Icons.account_balance_wallet_rounded, true),
          const SizedBox(height: 16),
          _paymentCard('Stripe', 'Mastercard **** 4242', Icons.credit_card_rounded, false),
          const SizedBox(height: 32),
          Text(
            'Success-Fee Policy',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
          ),
          const SizedBox(height: 8),
          Text(
            'FanSync AI deducts a 3% service fee from all PPV sales generated via AI responses.',
            style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard(String name, String detail, IconData icon, bool isDefault) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: isDefault ? Border.all(color: Colors.blue) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(detail, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
            ],
          ),
          const Spacer(),
          if (isDefault) const Icon(Icons.check_circle, color: Colors.blue, size: 20),
        ],
      ),
    );
  }

  Widget _buildTransactionHistory() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transaction Audit Log', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          _transactionRow('Quota Refill (Agency)', '+\$500.00', '2026-04-19', true),
          _transactionRow('Service Fee (Model_Sana)', '-\$12.40', '2026-04-18', false),
          _transactionRow('Service Fee (Model_Yui)', '-\$8.10', '2026-04-18', false),
          _transactionRow('Payout Success', '-\$1,200.00', '2026-04-15', false),
        ],
      ),
    );
  }

  Widget _transactionRow(String label, String amount, String date, bool isPlus) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(date, style: GoogleFonts.inter(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isPlus ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
