import 'dart:convert';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:transport/url.dart';

import '../home/packersucess.dart';
import '../widget/CustomMessage.dart';

class PaymentScreen extends StatefulWidget {
  static const String id = 'payment';
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isApiCallInprogress = false;
  var userId, phoneNo;
  Razorpay pay;

  @override
  void initState() {
    pay = Razorpay();
    pay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    pay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    pay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    final User user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user.uid;
      phoneNo = user.phoneNumber;
    });
    super.initState();
  }

  @override
  void dispose() {
    pay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (response != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return PackerSuccess();
      }));
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    CustomMessage.toast("Payment failed");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print(
        'You have chosen to pay via : ${response.walletName}. It will take some time to reflect your payment.');
  }

  void openCheckOut(var cost) {
    var options = {
      "key": "rzp_test_Fi1BvOwJJZomaI",
      "amount": 100,
      "name": "Transport",
      "description": "Payment for booking ride",
      "prefill": {
        "contact": phoneNo,
        "email": "",
      },
    };

    try {
      pay.open(options);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                // Navigator.push(context, MaterialPageRoute(builder: (context)=> OrdersScreen()));
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 12, bottom: 18, top: 20),
              child: Text(
                'Payment',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        ListTile(
          title: Text('Gofed Credits'),
          subtitle: Text('Total Balance ₹ 0'),
          trailing: Container(
            margin: EdgeInsets.only(left: 10),
            height: height * 0.04,
            width: width * 0.25,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  begin: Alignment(-1.0, -2.0),
                  end: Alignment(1.0, 2.0),
                  colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
            ),
            child: FlatButton(
              onPressed: () {},
              child: Center(
                child: Text(
                  'Add Money',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        Divider(),
        ListTile(
          title: Text('PayTm Wallet'),
          subtitle: Text(
            'New payment account will be created if you do\'not have any',
            style: TextStyle(fontSize: 12),
          ),
          trailing: Container(
            margin: EdgeInsets.only(left: 10),
            height: height * 0.04,
            width: width * 0.25,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  begin: Alignment(-1.0, -2.0),
                  end: Alignment(1.0, 2.0),
                  colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
            ),
            child: FlatButton(
              onPressed:  () {
                      openCheckOut(100);
                    },
              child: Center(
                child: Text(
                  'Link Wallet',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
        Divider()
      ]),
    );
  }

  Future<void> _startTransaction() async {
    var rng = new Random();
    var rn = rng.nextInt(4294967296) +
        rng.nextInt(4294967296) +
        rng.nextInt(4294967296);

    String mid = "hmDMQS60944379519485";
    String merchantId = "WTGcI6b!dlq_O1D9";
    String orderId = "Paytm$rn";
    String amount = "1";
    String txnToken = "null";
    String result = "";
    bool isStaging = true;
    String callbackUrl =
        "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=<$orderId>";
    bool restrictAppInvoke = true;
    var signature = await generatechecksum(orderId);
    // print(signature);

    var token = "${signature.toString()}";
    print(token);
    if (txnToken.isEmpty) {
      return;
    }
    var response = await http.post(
        "https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?mid={$mid}&orderId={$orderId}",
        headers: {
          "Content-Type": "application/json",
          //"signature" : token
        },
        body: jsonEncode({
          "requestType": "Payment",
          "mid": mid,
          "orderId": orderId,
          "txnAmount": amount,
          "callbackUrl": callbackUrl,
          "websiteName": "WEBSTAGING",
          "userInfo": {
            "custId": "CUST_001",
          },
          "signature": token
        }));
    var data = jsonDecode(response.body);
    print(data);
    print(response.statusCode);
    // var sendMap = <String, dynamic>{
    //   "mid": mid,
    //   "orderId": orderId,
    //   "amount": amount,
    //   "txnToken": txnToken,
    //   "callbackUrl": callbackUrl,
    //   "isStaging": isStaging,
    //   "restrictAppInvoke": restrictAppInvoke
    // };
    // print(sendMap);
    // try {
    //   var response = AllInOneSdk.startTransaction(
    //       mid, orderId, amount, txnToken, null, isStaging, restrictAppInvoke);
    //   response.then((value) {
    //     print(value);
    //     setState(() {
    //       result = value.toString();
    //     });
    //     print(result);
    //   }).catchError((onError) {
    //     if (onError is PlatformException) {
    //       setState(() {
    //         result = onError.message + " \n  " + onError.details.toString();
    //       });
    //     } else {
    //       setState(() {
    //         result = onError.toString();
    //       });
    //     }
    //   });
    // } catch (err) {
    //   result = err.message;
    // }
  }

  generatechecksum(var orderId) async {
    var response = await http.post(Uri.parse(generateCheckSumUrl), body: {
      'mid': 'hmDMQS60944379519485',
      'orderid': orderId,
    });

    var res = jsonDecode(response.body);
    var data = res['data'];
    //   print('data is $data');
    return data;
  }
}

// void main() async {
//   var headers = {
//     'Content-Type': 'application/json',
//   };

//   var params = {
//     'mid': '{mid}',
//     'orderId': 'ORDERID_98765',
//   };
//   var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

//   var data = '{"body":{"requestType":"Payment","mid":"{mid}","websiteName":"WEBSTAGING","orderId":"ORDERID_98765","txnAmount":{"value":"1.00","currency":"INR"},"userInfo":{"custId":"CUST_001"},"callbackUrl":"https://merchant.com/callback"},}';

//   var res = await http.post('https://securegw-stage.paytm.in/theia/api/v1/initiateTransaction?$query', headers: headers, body: data);
//   if (res.statusCode != 200) throw Exception('http.post error: statusCode= ${res.statusCode}');
//   print(res.body);
// }
