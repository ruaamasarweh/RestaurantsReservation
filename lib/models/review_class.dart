class Review{
   final int reviewID;
  final String customerReview;
  final int rating;
  final String  customerName;
  final int branchID;
  final DateTime reviewDate;

  Review({
    required this.reviewID,
    required this.customerReview,
    required this.rating,
    required this.customerName,
    required this.branchID,
    required this.reviewDate,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewID: json['reviewID'],
      customerReview: json['customerReview'],
      rating: json['rating'],
      customerName: json['customerName'],
      branchID: json['branchID'],
      reviewDate: DateTime.parse(json['reviewDate']),  
    );
  }
}