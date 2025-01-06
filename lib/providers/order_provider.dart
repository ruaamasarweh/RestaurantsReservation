import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:restaurants/models/dish_class.dart';

class OrderProvider with ChangeNotifier {
  Future<void> submitOrder(
    int reservationID,
    int tableNumber,
    List<DishDto> dishes,
  ) async {
    //final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/submitOrder'); 
    final Uri url = Uri.parse('http://10.0.2.2:5114/submitOrder'); 
 
    final List<Map<String, dynamic>> orders = dishes.map((dish) {
      return {
        'dishID': dish.dishID,
        'reservationID': reservationID,
        'TableNumber': tableNumber,
        'Quantity': dish.quantity,
        'Time': DateTime.now().toIso8601String(),
      };
    }).toList();

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(orders), 
      );

      if (response.statusCode == 200) {
        log('Order submitted successfully.');
        notifyListeners();
      } else {
        log('Failed to submit order: ${response.body}');
        throw Exception('Failed to submit order: ${response.body}');
      }
    } catch (error) {
      log('Error submitting order: $error');
      rethrow;
    }
  }
}