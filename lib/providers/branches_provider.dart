import 'dart:convert';  
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:restaurants/models/branch_class.dart';

class BranchesProvider with ChangeNotifier {
  List<BranchDto> branches = [];
  bool isLoading = true;

  Future<void> fetchBranches(int restaurantId) async {
  isLoading = true;
  notifyListeners();

  //final response = await http.get(Uri.parse('http://ararizm-003-site3.qtempurl.com/api/restaurant/getBranches/?restaurantID=$restaurantId'));
final response = await http.get(Uri.parse('http://10.0.2.2:5114/api/restaurant/getBranches/?restaurantID=$restaurantId'));
  if (response.statusCode == 200) {
    final List<dynamic> branchesData = json.decode(response.body);
    branches = branchesData.map((branch) => BranchDto.fromJson(branch)).toList();
  } else {
    log('Error loading branches: ${response.statusCode}');
  }

  isLoading = false;
  notifyListeners();
}

}
