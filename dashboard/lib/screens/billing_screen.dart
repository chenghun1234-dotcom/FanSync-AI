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
        Text('Select Recharge Package', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildRechargePackages(context),
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
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Available Balance', style: GoogleFonts.inter(color: Colors.white60, fontSize: 16)),
              const SizedBox(height: 8),
              Text('\$4,520.00', style: GoogleFonts.outfit(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.bolt, color: Colors.yellow, size: 20),
                const SizedBox(width: 8),
                Text('Unlimited Potential', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),
      Row(
        children: [
          _miniStat('This Month', '+\$1,240.50'),
          const SizedBox(width: 48),
          _miniStat('Pending Payouts', '\$240.00'),
          const SizedBox(width: 48),
          _miniStat('Active AI Models', '12 Creators'),
        ],
      ),
    ],
  ),
);
}

Widget _buildRechargePackages(BuildContext context) {
return Row(
  children: [
    _tierCard(context, 'Starter', '100', 10.00, Colors.blueGrey, false),
    const SizedBox(width: 20),
    _tierCard(context, 'Growth', '600', 50.00, const Color(0xFF008FDB), true),
    const SizedBox(width: 20),
    _tierCard(context, 'Pro', '1,300', 100.00, const Color(0xFF8A2BE2), false),
    const SizedBox(width: 20),
    _tierCard(context, 'Agency', '7,000', 500.00, const Color(0xFFFFD700), false, isBestValue: true),
  ],
);
}

Widget _tierCard(BuildContext context, String name, String credits, double price, Color color, bool isPopular, {bool isBestValue = false}) {
return Expanded(
  child: Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: isPopular ? Border.all(color: color, width: 2) : Border.all(color: Colors.transparent),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
    ),
    child: Column(
      children: [
        if (isPopular || isBestValue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
            child: Text(isPopular ? 'POPULAR' : 'BEST VALUE', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        const SizedBox(height: 16),
        Text(name, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('$credits Credits', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
        Text(r'$' + price.toStringAsFixed(2), style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        PayPalPaymentButton(
          amount: price,
          onSuccess: (paymentId) => _showSuccessDialog(context, paymentId, price),
        ),
      ],
    ),
  ),
    );
  }

  void _showSuccessDialog(BuildContext context, String paymentId, double amount) {
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: const Icon(Icons.check_circle, color: Colors.green, size: 64),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Payment Successful!', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text(r'Your agency wallet has been topped up with $' + amount.toStringAsFixed(2) + '.', textAlign: TextAlign.center, style: GoogleFonts.inter()),
        const SizedBox(height: 16),
        Text('Ref: $paymentId', style: GoogleFonts.firaCode(fontSize: 11, color: Colors.grey)),
      ],
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Great!')),
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
