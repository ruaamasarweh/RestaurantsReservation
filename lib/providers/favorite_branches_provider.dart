import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurants/models/resraurant_class.dart';

class FavoriteBranchesProvider with ChangeNotifier {
  List<Restaurant> favs = [];
  String? message;
  bool isLoading = false;
  
  Future<void> getFavBranches(int userID) async {
    isLoading = true; 
    notifyListeners();
   // final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/branches/GetFavBranches?userID=$userID');
    final Uri url = Uri.parse('http://10.0.2.2:5114/api/branches/GetFavBranches?userID=$userID');
    final response = await http.get(url);
    if (response.statusCode == 200) {
     final List<dynamic> loadedFavBranches = json.decode(response.body);
        favs = loadedFavBranches.map((fav) => Restaurant.fromJson(fav)).toList();
        notifyListeners();
    } else {
      favs = [];
      notifyListeners();
      log('Failed to fetch favorite branches. Status code: ${response.statusCode}');
    }
    isLoading = false;
      notifyListeners(); 
  }

  Future<void> addRemoveFav(int userID, int branchID) async {
    //final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/branches/addRemoveFav');
    final Uri url = Uri.parse('http://10.0.2.2:5114/api/branches/addRemoveFav');
    try {
       var response = await http.post(url,
             headers: {
              'Content-Type':'application/json; charset=UTF-8'
                },
                 body: json.encode({
                  'userID': userID,
                  'branchID': branchID,
                 })
                 );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        message = responseData['message'].toString();
        await getFavBranches(userID); 
      } else {
        log('Failed to add/remove favorite. Status code: ${response.statusCode}');
      }
    } catch (error) {
      log('Error: $error');
    }
  }

 bool isFavorite(int branchID) {
    return favs.any((restaurant) => 
      restaurant.branches?.any((branch) => branch.branchID == branchID) ?? false
    );
  }
}
