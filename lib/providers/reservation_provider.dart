import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:restaurants/models/reservation_class.dart';

class ReservationProvider with ChangeNotifier {
  Future<void> submitReservation(DateTime date,TimeOfDay time,int guestCount, String tableZone,int customerID,int branchID,
  ) async {
   // final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/branch/submitReservation');
    final Uri url = Uri.parse('http://10.0.2.2:5114/api/branch/submitReservation');
    String formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'date': date.toIso8601String(),
        'time': formattedTime,
        'numOfPeople': guestCount,
        'tableZone': tableZone,
        'UserID': customerID,
        'branchID': branchID, 
      }),
    );

    if (response.statusCode == 200) {
      notifyListeners();
    } else {
      throw Exception('Failed to create reservation');
    }
  }


  List<Reservation>? reservations = [];


  Future<void> getReservations(int customerID) async {
   // final response = await http.get(Uri.parse('http://ararizm-003-site3.qtempurl.com/api/getReservation?customerID=$customerID'));
    final response = await http.get(Uri.parse('http://10.0.2.2:5114/api/getReservation?customerID=$customerID'));
    if (response.statusCode == 200) {
      final loadedData = json.decode(response.body) as List?;
      log(loadedData.toString());
      if(loadedData!=null){
           reservations = loadedData.map((r) => Reservation.fromJson(r)).toList();
            sortByDateDescending(reservations!);
      }else{
        reservations=[];
      }
   
      notifyListeners(); 
    } else {
      throw Exception('Failed to fetch reservations');
    }
  }

  void sortByDateDescending(List<Reservation> reservations) {
  reservations.sort((a, b) => b.date.compareTo(a.date));
}
}
