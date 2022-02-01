import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transport/screens/widget/CustomMessage.dart';
import 'package:transport/services/shared.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  var loading = false;
  var rdate = "", amount = "";
  var length = 0;
  var pickLocation = "";
  var rDate = "";
  var totalAmount = "";
  var withdraw="";
  var walletData = [];

  getWalletData() async {
    setState(() {
      loading = true;
    });
     var user = await SharedData().getUser();

    try {
      var response =
          await http.post(Uri.parse("http://gofed.in/Partner/wallet"), body: {
        'id': user.toString(),
      });

      if (response.statusCode != 200) {
        CustomMessage.toast('Internal Server Error');
      } else if (response.body != '') {
        var data = jsonDecode(response.body);

        if (data['status'] == 200) {
          setState(() {
            length = data['data'].length;
            rdate = data['data'][0]['rdate'];
            amount = data['data'][0]['amount'];
            withdraw = data['data'][0]['withdraw'];
          });
        } else {}
      }
    } catch (e) {
      print(e);
    }
  
  }


  @override
  void initState() {
    super.initState();
    getWalletData();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        elevation: 0,
        backgroundColor: Color(0xffF5F5F5),
        title: Text(
          'WALLET',
          style: TextStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      body: (loading)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: height * 0.14,
                    width: width * 0.9999,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment(-1.0, 2.0),
                          end: Alignment(-1.0, -2.0),
                          colors: [Color(0xFF6D5DF6), Color(0xFF83B9FF)]),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                    child: Text(
                                  'Balance',
                                  style: TextStyle(color: Colors.white),
                                )),
                                Container(
                                    child: Text(
                                  amount,
                                  style: TextStyle(color: Colors.white),
                                )),
                                Container(
                                  height: height * 0.04,
                                  width: width * 0.35,
                                  alignment: Alignment.centerLeft,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Color(0xff706BF7)),
                                  child: FlatButton(
                                    onPressed: () {},
                                    child: Center(
                                      child: Text(
                                        'Withdraw ₹ $withdraw',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Container(
                                    child: Text(
                                  'Minimum Balance',
                                  style: TextStyle(color: Colors.white),
                                )),
                              ),
                              Container(
                                  child: Text(
                                '₹ 0.0',
                                style: TextStyle(color: Colors.white),
                              )),
                              Container(
                                height: height * 0.04,
                                width: width * 0.35,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(0xff706BF7)),
                                child: TextButton(
                                  onPressed: () {},
                                  child: Center(
                                    child: Text(
                                      'Recharge',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 11),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Container(
                  //     height: height * 0.70,
                  //     child: ListView.builder(
                  //         itemCount: length,
                  //         itemBuilder: (context, index) {
                  //           return Column(
                  //             children: [
                  //               Padding(
                  //                 padding: const EdgeInsets.all(12.0),
                  //                 child: Container(
                  //                     child: CustomWallet(totalAmount, rDate,
                  //                         pickLocation, height)),
                  //               ),
                  //               Divider()
                  //             ],
                  //           );
                  //         }),
                  //   ),
                  // )
                ],
              ),
            ),
    );
  }
}
