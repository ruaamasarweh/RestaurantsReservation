import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:restaurants/models/review_class.dart';
import 'package:http/http.dart' as http;
class ReviewsProvider with ChangeNotifier{
List<Review>?reviews=[];
 bool isLoading = true;
String? message;


Future<void>loadReviews(int branchID)async{
  reviews=[];
   isLoading = true;
    notifyListeners();

  //final Uri url=Uri.parse('http://ararizm-003-site3.qtempurl.com/api/branch/reviews?branchID=$branchID');
  final Uri url=Uri.parse('http://10.0.2.2:5114/api/branch/reviews?branchID=$branchID');
  
  final response=await http.get(url);
  if(response.statusCode==200){
    final loadedReviews=json.decode(response.body) as List<dynamic>;
    reviews=loadedReviews.map((review)=>Review.fromJson(review)).toList();
    notifyListeners();
  }else{
     message=json.decode(response.body)['message'];
     reviews=[];
     notifyListeners();
  }
   isLoading = false;
    notifyListeners();
}

Future<void>submitReview(int branchID,String review,int rating,int customerID)async {
 // final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/branch/submitReview');
   final Uri url = Uri.parse('http://10.0.2.2:5114/api/branch/submitReview');
  await http.post(
    url,
     headers: {
      'Cookie': 'ASP.NET_SessionId=your-session-id', 
      'Content-Type': 'application/json',
    },
    body: json.encode({
        'UserID':customerID,
        'BranchID':branchID,
        'CustomerReview':review,
        'Rating':rating
    })
  );
  
  loadReviews(branchID);

}
}