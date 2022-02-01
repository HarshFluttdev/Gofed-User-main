import 'package:flutter/material.dart';
import 'package:transport/screens/account/accountscreen.dart';
import 'package:transport/screens/home/googlemaps.dart';
import 'package:transport/screens/orders/ordersscreen.dart';
import 'package:transport/screens/payment/paymentscreen.dart';

class BottomNavBar extends StatefulWidget {

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with TickerProviderStateMixin{
  TabController _tabController;
  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(  
          color: Colors.white,
          backgroundBlendMode: BlendMode.plus
        ),
        height: 56,
        width: double.infinity,
        child: TabBar(  
          controller: _tabController,
          indicatorColor: Colors.transparent,
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          tabs: [
            Column(
              children: [
                SizedBox(height: 6),
                Icon(Icons.home),
                Text('Home')
              ]
            ),
            Column(
              children: [
                SizedBox(height: 6),
                Icon(Icons.lock_clock),
                Text('Orders')
              ]
            ),
            Column(
              children: [
                SizedBox(height: 6),
                Icon(Icons.wallet_travel),
                Text('Payments')
              ]
            ),
            Column(
              children: [
                SizedBox(height: 6),
                Icon(Icons.person),
                Text('Account')
              ]
            )
          ],
        ),
      ),
      body: TabBarView(  
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: [
          GoogleMaps(),
          OrdersScreen(),
          PaymentScreen(),
          AccountScreen()
        ],
      ),
    );
  }
}