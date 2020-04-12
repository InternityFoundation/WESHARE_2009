import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medishare/models/bought_product.dart';
import 'package:medishare/models/sell_medicine.dart';
import 'package:medishare/models/user.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class MedicineBoughtPage extends StatefulWidget {
  final SellMedicine med;
  MedicineBoughtPage({@required this.med});
  @override
  _MedicineBoughtPageState createState() => _MedicineBoughtPageState();
}

class _MedicineBoughtPageState extends State<MedicineBoughtPage> {
  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print("SUCCESS: " + response.paymentId);
    Fluttertoast.showToast(
        msg: "SUCCESS: " + response.paymentId, timeInSecForIos: 4);

    await BoughtMedicineService(email: Provider.of<User>(context).email)
        .addBoughtMedicine(BoughtMedicine(
            buyer_email: Provider.of<User>(context).email,
            seller_email: widget.med.seller_email,
            med_name: widget.med.med_name,
            med_qty: widget.med.med_qty,
            med_price: widget.med.med_price,
            seller_location: widget.med.seller_location));

    await SellMedicineService().updateisSold(widget.med.ID);

    print('upload');
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("ERROR: " + response.code.toString() + " - " + response.message);
    Fluttertoast.showToast(
        msg: "ERROR: " + response.code.toString() + " - " + response.message,
        timeInSecForIos: 4);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("EXTERNAL_WALLET: " + response.walletName);
    Fluttertoast.showToast(
        msg: "EXTERNAL_WALLET: " + response.walletName, timeInSecForIos: 4);
  }

  void openCheckout({
    @required int amount,
    @required String email,
  }) async {
    print(email);
    var options = {
      'key': 'rzp_test_5NkvsjTEK1ZBV6',
      'amount': amount * 100,
      'name': 'MediShare',
      'description': 'Transaction to MediShare',
      'prefill': {'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff191919),
          title: Text('Confirm Buy'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'You are about to buy medicine worth ${widget.med.med_price}',
                style: TextStyle(fontSize: 25),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text(
                  'BUY',
                  style: TextStyle(fontSize: 20),
                ),
                color: Colors.brown[800],
                onPressed: () {
                  openCheckout(
                      amount: widget.med.med_price,
                      email: Provider.of<User>(context).email);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
