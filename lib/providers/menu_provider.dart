import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:restaurants/models/dishcategory_class.dart';
import 'package:http/http.dart' as http;


class MenuProvider with ChangeNotifier {
  bool isLoading = true;
  List<DishCategoryDto>? dishCategories;

  Future<void> fetchMenu(int restaurantID) async {
    isLoading = true;
    notifyListeners();

    //final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/restaurant/getMenu/?restaurantID=$restaurantID');
    final Uri url = Uri.parse('http://10.0.2.2:5114/api/restaurant/getMenu/?restaurantID=$restaurantID');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      dishCategories = data
          .map((category) => DishCategoryDto.fromJson(category))
          .toList();
      
      isLoading = false;
      notifyListeners();
    } else {
      log('Error loading restaurant menu: ${response.statusCode}');
    }
  }
}
