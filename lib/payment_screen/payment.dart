import 'package:flutter/material.dart';
import 'package:tenon_training_app/payment_screen/payment_screen.dart';

class Payment extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
      ),
      body: Center(
        child: Column(
         mainAxisSize: MainAxisSize.min,
          children: [
            Text('No Payment Found'),

            Text('Please make a payment of 200 to continue'),

            ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>PaymentScreen()));
                }, child: Text('Payment')
            )

          ],
        ),
      ),

    );
  }

}