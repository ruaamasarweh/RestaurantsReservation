class DishDto {
  
  final int dishID;
  final String dishName;
  final String dishImageUrl;
  final double price;
  final String? details;
   int quantity;
  DishDto({
    required this.dishID,
    required this.dishName,
    required this.dishImageUrl,
    required this.price,
    this.details,
     this.quantity = 0,
  });

  factory DishDto.fromJson(Map<String, dynamic> json) {
    return DishDto(
      dishID:json['dishID'],
      dishName: json['dishName'],
      dishImageUrl: json['dishImageUrl'],
      price: json['price'].toDouble(),
      details: json['details'],
    );
  }
}