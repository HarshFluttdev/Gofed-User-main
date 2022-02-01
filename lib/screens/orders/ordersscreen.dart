import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:transport/booking_screens/destinationbottom.dart';
import 'package:transport/screens/home/homescreen.dart';
import 'package:transport/screens/orders/orderDetails.dart';
import 'package:transport/screens/widget/NoOrderWidget.dart';
import 'package:transport/services/shared.dart';
import 'package:transport/url.dart';
import 'package:http/http.dart' as http;

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _progressVisible = false;
  var order;
  var bookride = [];
  var packersride = [];
  var rentalsride = [];

  OrderData() async {
    setState(() {
      _progressVisible = true;
    });
    var user = await SharedData().getUser();
    var response = await http.post(orderList, body: {
      'id': user.toString(),
    });
    var data = jsonDecode(response.body);
    var userdata = data['data'];
    for (var i = 0; i < userdata.length; i++) {
      (userdata[i]['ride_type'] == "Ride")
          ? bookride.add(data['data'][i])
          : (userdata[i]['ride_type'] == "Rentals")
              ? rentalsride.add(data['data'][i])
              : (userdata[i]['ride_type'] == "Packer and mover")
                  ? packersride.add(data['data'][i])
                  : Container();
    }
    setState(() {
      _progressVisible = false;
    });
  }

  @override
  void initState() {
    OrderData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    var currentDate = DateFormat('yyyy-MM-dd').format(now);
    var yesterdayDate =
        DateFormat('yyyy-MM-dd').format(now.subtract(Duration(days: 1)));
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            iconSize: 20,
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            'All Orders',
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              letterSpacing: 1.1,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FlatButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  setState(() {});
                },
                child: Text(
                  "Refresh",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 1.1,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TabBar(
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 20),
                        unselectedLabelColor: Colors.grey,
                        isScrollable: true,
                        labelColor: Color(0xff706BF7),
                        labelStyle: TextStyle(
                          fontSize: 15,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                        indicatorColor: Color(0xff706BF7),
                        tabs: <Widget>[
                          Tab(
                            text: "Ride Order",
                          ),
                          Tab(
                            text: "Packers Order",
                          ),
                          Tab(
                            text: "Rentals Order",
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Expanded(
                          child: TabBarView(children: [
                        (bookride.toString() == '[]')
                            ? NoOrderWidget(height: height, width: width)
                            : Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                height: height,
                                child: ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: bookride.length,
                                    itemBuilder: (BuildContext context, int i) {
                                      int ii = bookride.length - 1 - i;
                                      return Container(
                                        // height: height * 0.25,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderDetails(
                                                          pickup: bookride[i]
                                                              ['pick_location'],
                                                          dropoff: bookride[i]
                                                              ['drop_location'],
                                                          totalamount: bookride[
                                                                  i]
                                                              ['total_amount'],
                                                          date: bookride[i]
                                                              ['rdate'],
                                                          ridestatus:
                                                              bookride[i]
                                                                  ['ride_type'],
                                                          vehicle: bookride[i]
                                                              ['vehicle'],
                                                          distance: bookride[i]
                                                              ['distance'],
                                                        )));
                                          },
                                          child: Card(
                                            color: Color(0xffF3F7FB),
                                            elevation: 3.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 10),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        currentDate.toString() ==
                                                                bookride[ii][
                                                                        'rdate']
                                                                    .toString()
                                                                    .substring(
                                                                        0, 10)
                                                            ? Text(
                                                                'Today  ${bookride[ii]['rdate'].toString().substring(11, 19)} \n${bookride[ii]['vehicle']}',
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700),
                                                              )
                                                            : (yesterdayDate
                                                                        .toString() ==
                                                                    DateFormat(bookride[ii]['rdate']
                                                                            .toString()
                                                                            .substring(0,
                                                                                10))
                                                                        .format(
                                                                            now)
                                                                ? Text(
                                                                    'Yesterday  ${bookride[ii]['rdate'].toString().substring(11, 19)} \n${bookride[ii]['vehicle']}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  )
                                                                : Text(
                                                                    '${bookride[ii]['rdate'].toString().substring(0, 10)}  ${bookride[ii]['rdate'].toString().substring(11, 19)} \n${bookride[ii]['vehicle']}',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700),
                                                                  )),
                                                        Text(
                                                          '₹ ${bookride[ii]['total_amount']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      ],
                                                    ),
                                                    TimelineTile(
                                                      alignment:
                                                          TimelineAlign.start,
                                                      isFirst: true,
                                                      hasIndicator: true,
                                                      beforeLineStyle:
                                                          LineStyle(
                                                        color: Colors.amber,
                                                        thickness: 2,
                                                      ),
                                                      indicatorStyle:
                                                          IndicatorStyle(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 3),
                                                        width: 12,
                                                        color: Colors.green,
                                                      ),
                                                      endChild: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                                vertical: 6.0),
                                                        child: Text(
                                                          bookride[ii]
                                                              ['pick_location'],
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing: 1.4,
                                                            height: 1.5,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    TimelineTile(
                                                      alignment:
                                                          TimelineAlign.start,
                                                      isLast: true,
                                                      hasIndicator: true,
                                                      beforeLineStyle:
                                                          LineStyle(
                                                        color: Colors.amber,
                                                        thickness: 2,
                                                      ),
                                                      indicatorStyle:
                                                          IndicatorStyle(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 3),
                                                        width: 12,
                                                        color: Colors.red,
                                                      ),
                                                      endChild: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0,
                                                                vertical: 6.0),
                                                        child: Text(
                                                          bookride[i]
                                                              ['drop_location'],
                                                          style: TextStyle(
                                                            color: Colors
                                                                .grey[700],
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            letterSpacing: 1.4,
                                                            height: 1.5,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            // Icon(
                                                            //   bookride[i]
                                                            //   ['ride_status'] == 'Cancelled' ? Icons.close : Icons.check,
                                                            //   color: Colors.red,
                                                            // ),
                                                            Text(
                                                              bookride[ii][
                                                                  'ride_status'],
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            DestinationBottom()));
                                                          },
                                                          child: Container(
                                                              height: 40,
                                                              width: 100,
                                                              decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blue,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12)),
                                                              child: Center(
                                                                  child: Text(
                                                                'Book Again',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ))),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )),
                                          ),
                                        ),
                                      );
                                    })),
                        (packersride.toString() == '[]')
                            ? NoOrderWidget(height: height, width: width)
                            : SingleChildScrollView(
                                child: Container(
                                    height: height * 0.9,
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: packersride.length,
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          return Container(
                                            height: height * 0.15,
                                            child: Card(
                                              elevation: 3.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                child: ListTile(
                                                  leading: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20),
                                                    child: CircleAvatar(
                                                      maxRadius: 20,
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: NetworkImage(
                                                          'https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png'),
                                                    ),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('Ride status'),
                                                          Text(
                                                            packersride[i]
                                                                ['ride_status'],
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('Ride Type'),
                                                          Text(packersride[i]
                                                                  ['ride_type']
                                                              .toString()),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('Flat'),
                                                          Text(
                                                            packersride[i]
                                                                    ['flat']
                                                                .toString(),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }))),
                        (rentalsride.toString() == '[]')
                            ? NoOrderWidget(height: height, width: width)
                            : SingleChildScrollView(
                                child: Container(
                                    height: height * 0.9,
                                    child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount: rentalsride.length,
                                        itemBuilder:
                                            (BuildContext context, int i) {
                                          return Container(
                                            height: height * 0.15,
                                            child: Card(
                                              elevation: 3.0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Container(
                                                child: ListTile(
                                                  leading: Container(
                                                    margin: EdgeInsets.only(
                                                        top: 20),
                                                    child: CircleAvatar(
                                                      maxRadius: 20,
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: NetworkImage(
                                                          'https://www.pngkey.com/png/detail/114-1149878_setting-user-avatar-in-specific-size-without-breaking.png'),
                                                    ),
                                                  ),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('Ride status'),
                                                          Text(rentalsride[i]
                                                              ['ride_status']),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('Ride Type'),
                                                          Text(rentalsride[i]
                                                                  ['ride_type']
                                                              .toString()),
                                                        ],
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceAround,
                                                        children: [
                                                          Text('vehicle'),
                                                          Text(rentalsride[i][
                                                                  'vehicle_type']
                                                              .toString()),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }))),
                      ]))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
