import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:http/http.dart' as http;


class RestaurantsProvider with ChangeNotifier {
  bool isLoading = true;
  List<Restaurant> restaurantsList = [];
  List<Restaurant> filteredRestaurantsList = [];

  Future<void> loadRestaurantsBrief() async {
    //final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/restaurant/getRestaurantsBrief');
    final Uri url = Uri.parse('http://10.0.2.2:5114/api/restaurant/getRestaurantsBrief');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final loadedData = json.decode(response.body) as List<dynamic>;
      restaurantsList = loadedData.map((data) => Restaurant.fromJson(data)).toList();
      filteredRestaurantsList=restaurantsList;
      isLoading = false;
      notifyListeners();
    } else {
      log('Error loading brief restaurants: ${response.statusCode}');
    }
    loadRestaurants();
  }

  Future<void> loadRestaurants() async { 
  final Uri url =Uri.parse('http://10.0.2.2:5114/api/restaurant/getRestaurants');
  //final Uri url =Uri.parse('http://ararizm-003-site3.qtempurl.com/api/restaurant/getRestaurants');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final loadedData = json.decode(response.body) as List<dynamic>;
      final availableRestaurants = loadedData.map((restaurantData) => Restaurant.fromJson(restaurantData)).toList();
      
   //   log(loadedData.toString());

        restaurantsList = availableRestaurants;
        filteredRestaurantsList = restaurantsList;
        isLoading = false;
        
        notifyListeners();  

    } else {
      log('Error loading restaurants: ${response.statusCode}');
    }
  }

  void searchRestaurants(String text) {
    isLoading=true;
  text = text.toLowerCase(); 
  
  if (text.isEmpty) {
    filteredRestaurantsList = List.from(restaurantsList); 
  } else {
    filteredRestaurantsList = restaurantsList.where((restaurant) {
      final restaurantNameMatch = restaurant.restaurantName.toLowerCase().contains(text);
      final dishCategoryMatch = restaurant.dishCategories?.any((category) {
        final categoryNameMatch = category.categoryName.toLowerCase().contains(text);
        final dishNameMatch = category.dishes?.any((dish) =>
            dish.dishName.toLowerCase().contains(text)) ?? false;
        return categoryNameMatch || dishNameMatch;
      }) ?? false;

      final branchLocationMatch = restaurant.branches?.any((branch) =>
          branch.locationDescription.toLowerCase().contains(text)) ?? false;

      return restaurantNameMatch || dishCategoryMatch || branchLocationMatch;
    }).toList();
  }
isLoading=false;
  notifyListeners(); 
}
}