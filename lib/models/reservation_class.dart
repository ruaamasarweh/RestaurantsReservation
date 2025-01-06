import 'package:flutter/material.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';

class Reservation {
  final int reservationID;
  final int numOfPeople;
  final DateTime date;
  final TimeOfDay time;
  final String tableZone;
  final BranchDto branch;
  final Restaurant restaurant;
  final String reservationStatus;
  Reservation({
    required this.reservationID,
    required this.numOfPeople,
    required this.date,
    required this.time,
    required this.tableZone,
    required this.branch,
    required this.restaurant,
    required this.reservationStatus
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
  return Reservation(
    reservationID: json['reservationID'],
    numOfPeople: json['numOfPeople'],
    date: DateTime.parse(json['date']),
    time: _parseTime(json['time']),    
    tableZone: json['tableZone'],
    branch: BranchDto.fromJson(json['branch']), 
    restaurant: Restaurant.fromJson(json['restaurant']),
     reservationStatus: json['reservationStatus'],
  );
}


   static TimeOfDay _parseTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) {
    return TimeOfDay.now(); 
  }

  final parts = timeString.split(':');
  final hour = int.parse(parts[0]);
  final minute = int.parse(parts[1]);

  return TimeOfDay(hour: hour, minute: minute);
}

}
