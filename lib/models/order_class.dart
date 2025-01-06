class Order {
  final int orderID;
  final int reservationID;
  final int dishID;
  final int tableNumber;
  final DateTime time;
  final String dishName;
  final double price;
  final String imagePath;
  int quantity;

  Order({
      required this.orderID,
      required this.dishName,
      required this.price,
      required this.imagePath,
      required this.reservationID,
      required this.dishID,
      required this.tableNumber,
      required this.time,
      this.quantity=0,
      });

      Map<String, dynamic> toJson() {
    return {
      'orderID':orderID,
      'reservationID': reservationID,
      'dishID': dishID,
      'tableNumber': tableNumber,
      'quantity': quantity,
      'time': time.toIso8601String(),
    };
  }
}
