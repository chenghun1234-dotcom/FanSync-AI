import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class PayPalPaymentButton extends StatelessWidget {
  final double amount;
  final Function(String) onSuccess;

  const PayPalPaymentButton({super.key, required this.amount, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF008FDB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => PaypalCheckoutView(
              sandboxMode: false, // 라이브 서비스 모드 활성화
              clientId: "AaYKv62WtnXRON10MfUmybSFKWpr-86UkvMx-ZztM7pn92CH8x7Ruz6Nt93xLNLg60gL7nGPyQbUlufX",
              secretKey: "EBlqzwUHucm1tQpR_wtkye-cu-uj69O9m4ZiyOBHr4tbsVD6rovXxRzr9dgP78Ma_Y1lJF4aBt1yLb86",
              transactions: [
                {
                  "amount": {
                    "total": amount.toString(),
                    "currency": "USD",
                    "details": {
                      "subtotal": amount.toString(),
                      "shipping": '0',
                      "shipping_discount": 0
                    }
                  },
                  "description": "FanSync AI Credit Recharge",
                  "item_list": {
                    "items": [
                      {
                        "name": "500 AI Credits",
                        "quantity": 1,
                        "price": amount.toString(),
                        "currency": "USD"
                      }
                    ],
                  }
                }
              ],
              note: "Contact us for any questions.",
              onSuccess: (Map params) async {
                // 결제 성공 시 호출
                onSuccess(params['paymentId']);
                Navigator.pop(context);
              },
              onError: (error) {
                debugPrint("onError: $error");
                Navigator.pop(context);
              },
              onCancel: () {
                debugPrint('cancelled');
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: const Text('PayPal로 크레딧 충전'),
    );
  }
}
