import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderDetails extends StatefulWidget {
  final String pickup;
  final String dropoff;
  final String date;
  final String distance;
  final String vehicle;
  final String ridestatus;
  final String totalamount;
  OrderDetails(
      {this.pickup,
      this.dropoff,
      this.date,
      this.distance,
      this.vehicle,
      this.ridestatus,
      this.totalamount});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[200],
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: Colors.teal[200],
      body: SingleChildScrollView(
        child: Container(
          height: height * 1.4,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                color: Colors.white,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xffF3F7FB),
                    ),
                    child: Column(children: [
                      Container(
                        height: height * 0.55,
                        width: MediaQuery.of(context).size.width - 10.0,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 18),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Text("Order Details",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          height: 20,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.teal[200],
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(20),
                                                  bottomRight:
                                                      Radius.circular(20))),
                                        ),
                                        DottedLine(
                                          direction: Axis.horizontal,
                                          lineLength: width / 1.2,
                                          lineThickness: 1.0,
                                          dashLength: 4.0,
                                          dashColor: Colors.black,
                                          dashRadius: 0.0,
                                          dashGapLength: 4.0,
                                          dashGapColor: Colors.transparent,
                                          dashGapRadius: 0.0,
                                        ),
                                        Container(
                                          height: 20,
                                          width: 10,
                                          decoration: BoxDecoration(
                                              color: Colors.teal[200],
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(20),
                                                  bottomLeft:
                                                      Radius.circular(20))),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TimelineTile(
                                      alignment: TimelineAlign.start,
                                      isFirst: true,
                                      hasIndicator: true,
                                      afterLineStyle: LineStyle(
                                        color: Colors.amber,
                                        thickness: 0,
                                      ),
                                      indicatorStyle: IndicatorStyle(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 3),
                                        width: 20,
                                        color: Colors.green,
                                      ),
                                      endChild: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 6.0),
                                        child: Text(
                                          widget.pickup,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.4,
                                            height: 1.5,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Dash(
                                          direction: Axis.vertical,
                                          length: 70,
                                          dashLength: 10,
                                          dashColor: Color(0xFF6D5DF6)),
                                    ),
                                    TimelineTile(
                                      alignment: TimelineAlign.start,
                                      isLast: true,
                                      hasIndicator: true,
                                      beforeLineStyle: LineStyle(
                                        color: Colors.amber,
                                        thickness: 0,
                                      ),
                                      indicatorStyle: IndicatorStyle(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 3),
                                        width: 20,
                                        color: Colors.red,
                                      ),
                                      endChild: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 6.0),
                                        child: Text(
                                          widget.dropoff,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.4,
                                            height: 1.5,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: width / 1.2,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Colors.black,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Colors.transparent,
                                        dashGapRadius: 0.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Order Date :-',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            widget.date,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: width / 1.2,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Colors.black,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Colors.transparent,
                                        dashGapRadius: 0.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Total Distance :-',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${widget.distance} KM',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: width / 1.2,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Colors.black,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Colors.transparent,
                                        dashGapRadius: 0.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Vehicle Name :-',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '${widget.vehicle}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 15),
                                      child: DottedLine(
                                        direction: Axis.horizontal,
                                        lineLength: width / 1.2,
                                        lineThickness: 1.0,
                                        dashLength: 4.0,
                                        dashColor: Colors.black,
                                        dashRadius: 0.0,
                                        dashGapLength: 4.0,
                                        dashGapColor: Colors.transparent,
                                        dashGapRadius: 0.0,
                                      ),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Ride Status :-',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              '${widget.ridestatus}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                              ),
                            ]),
                      ),
                    ]))),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10),
              child: Column(children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Color(0xffF3F7FB),
                  ),
                  width: MediaQuery.of(context).size.width - 10.0,
                  child: Container(
                      child: Column(children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(104, 104, 104, 10)),
                        ),
                        Text(
                          '₹ ${widget.totalamount}',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 20,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.teal[200],
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomRight: Radius.circular(20))),
                          ),
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: width / 1.2,
                            lineThickness: 1.0,
                            dashLength: 4.0,
                            dashColor: Colors.black,
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            dashGapRadius: 0.0,
                          ),
                          Container(
                            height: 20,
                            width: 10,
                            decoration: BoxDecoration(
                                color: Colors.teal[200],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20))),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 10.0,
                      child: Container(
                        child: Column(children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 30),
                            height: 40,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Taxes and Tolls',
                                  style: TextStyle(
                                      color: Color(0xff686868),
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '₹ 2000.00',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  'Balance',
                                  style: TextStyle(
                                      color: Color(0xff686868),
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '₹ 1490.00',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                              // behavior: HitTestBehavior.translucent,
                              onTap: () {},
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 20),
                                height: 43,
                                width: 330,
                                decoration: BoxDecoration(
                                    color: Color(0xff1170DE),
                                    borderRadius: BorderRadius.circular(14)),
                                child: Center(
                                    child: Text(
                                  'Pay Amount',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                )),
                              ))
                        ]),
                      ),
                    ),
                  ])),
                ),
              ]),
            ),
            SizedBox(height: 5),
          ]),
        ),
      ),
    );
  }
}



//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           color: Colors.black,
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Order Details',
//           style: TextStyle(color: Colors.black),
//         ),
//       ),
//       body: Container(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//            Container(
//              margin: EdgeInsets.symmetric(horizontal: 20),
//              child: Column(
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: [
//                   TimelineTile(
//                 alignment: TimelineAlign.start,
//                 isFirst: true,
//                 hasIndicator: true,
//                 afterLineStyle: LineStyle(
//                   color: Colors.amber,
//                   thickness: 0,
//                 ),
//                 indicatorStyle: IndicatorStyle(
//                   padding: EdgeInsets.symmetric(vertical: 3),
//                   width: 20,
//                   color: Colors.green,
//                 ),
//                 endChild: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//                   child: Text(
//                     'pick_location',
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 1.4,
//                       height: 1.5,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 10),
//                 child: Dash(
//                    direction: Axis.vertical,
//                           length: 100,
//                           dashLength: 10,
//                           dashColor: Color(0xFF6D5DF6)
//                 ),
//               ),
//               TimelineTile(
//                 alignment: TimelineAlign.start,
//                 isLast: true,
//                 hasIndicator: true,
//                 beforeLineStyle: LineStyle(
//                   color: Colors.amber,
//                   thickness: 0,
//                 ),
//                 indicatorStyle: IndicatorStyle(
//                   padding: EdgeInsets.symmetric(vertical: 3),
//                   width: 20,
//                   color: Colors.red,
//                 ),
//                 endChild: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
//                   child: Text(
//                     'drop_location',
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontWeight: FontWeight.w600,
//                       letterSpacing: 1.4,
//                       height: 1.5,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//               ),
//                ],
//              ),
//            ),
//            SizedBox(height: 10,),
//            Text('Order Description',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 20),),
           
//           ],
//         ),
//       ),
//     );
//   }
// }
