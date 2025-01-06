import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurants/models/branch_class.dart';


class BranchDetailsProvider with ChangeNotifier {
  bool isLoading = true;
  BranchDto? branch;

  Future<void> fetchBranchDetails(int restaurantID, int branchID) async {
    isLoading = true;
    notifyListeners();

   // final response = await http.get(Uri.parse('http://ararizm-003-site3.qtempurl.com/api/restaurant/getBranchDetails/?restaurantID=$restaurantID&branchID=$branchID'));
   final response = await http.get(Uri.parse('http://10.0.2.2:5114/api/restaurant/getBranchDetails/?restaurantID=$restaurantID&branchID=$branchID'));
    if (response.statusCode == 200) {
      final branchData = json.decode(response.body);
      branch = BranchDto.fromJson(branchData);
    } else {
      log('Error loading details: ${response.statusCode}');
    }

    isLoading = false;
    notifyListeners();
  }
}
