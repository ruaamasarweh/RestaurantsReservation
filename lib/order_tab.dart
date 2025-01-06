import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/orderpage.dart';

class OrderTab extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;
  final int reservationID;

  const OrderTab({
    super.key,
    required this.restaurant,
    required this.branch,
    required this.reservationID,
  });

  @override
  OrderTabState createState() => OrderTabState();
}

class OrderTabState extends State<OrderTab> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isNavigating = false;
  bool isErrorShown = false; 
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture barcodeCapture) {
                if (isNavigating || isErrorShown) return; 

                final barcode = barcodeCapture.barcodes.first;
                setState(() {
                  result = barcode;
                });

                if (barcode.rawValue == widget.branch.branchID.toString()) {
                  setState(() {
                    isNavigating = true;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(
                        restaurant: widget.restaurant,
                        branch: widget.branch,
                        reservationID: widget.reservationID,
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      isNavigating = false;
                    });
                  });
                } else {
                  setState(() {
                    isErrorShown = true;  
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Wrong QR code, please try again.')),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    setState(() {
                      isErrorShown = false;  
                    });
                  });
                }
              },
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a code'),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:restaurants/models/branch_class.dart';
// import 'package:restaurants/models/resraurant_class.dart';
// import 'package:restaurants/orderpage.dart';
// class OrderTab extends StatelessWidget {
//   final Restaurant restaurant;
//   final BranchDto branch;
//   final int reservationID;
//   const OrderTab({super.key, required this.restaurant,required this.branch, required this.reservationID});

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: (){
//           Navigator.push(context, MaterialPageRoute(builder: (context)=>OrderPage(restaurant: restaurant,branch:branch,reservationID:reservationID)));
//         }, 
//         child: const Text('order'))
//       );
//   }
// }