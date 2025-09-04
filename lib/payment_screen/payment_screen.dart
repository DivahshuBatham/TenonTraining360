import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:tenon_training_app/trainee/trainee_dashboard.dart';
import '../shared_preference/shared_preference_manager.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);

    // Automatically trigger payment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openCheckout();
    });
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag',
      'amount': 20000,
      'name': 'Acme Corp.',
      'description': 'Fine T-Shirt',
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      }
    };
    _razorpay.open(options);
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {

    final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();
    await _preferenceManager.saveToken(response.paymentId!);

    if(response.paymentId!= null){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TraineeDashboard()),
      );
      // print("Payment Successful: ${response.paymentId}");
      // Navigator.pop(context);
    }
    // Handle success
    // print("Payment Successful: ${response.paymentId}");
    // Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Handle error
    print("Payment Failed: ${response.code} - ${response.message}");

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _razorpay.clear(); // always clear listeners
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*Text('Payment flow has been initiated'),*/
                // OutlinedButton(
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => TrainingScreen()),
                //     );
                //   },
                //   child: Text('Training'),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




