import 'package:intl/intl.dart';

class BranchDto {
  final int branchID;
  final String locationDescription;
  final String branchImageUrl;
  final String? phoneNumber;
  final String? openTime; 
  final String? closeTime; 
  final bool? hasIndoorSeating;
  final bool? hasOutdoorSeating;
  final int? numOfTables;

  BranchDto({
    required this.branchID,
    required this.locationDescription,
    required this.branchImageUrl,
     this.phoneNumber,
     this.openTime,
     this.closeTime,
     this.hasIndoorSeating,
     this.hasOutdoorSeating,
     this.numOfTables,
    
  });

  factory BranchDto.fromJson(Map<String, dynamic> json) {
    return BranchDto(
      branchID: json['branchID'],
      locationDescription: json['locationDescription'],
      branchImageUrl: json['branchImageUrl'],
      phoneNumber: json['phoneNumber'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      hasIndoorSeating: json['hasIndoorSeating'],
      hasOutdoorSeating: json['hasOutdoorSeating'],
      numOfTables: json['numOfTables'],
    );
  }

  String formatTime(String time) {
    try {
      DateTime parsedTime = DateFormat('HH:mm').parse(time); 
      return DateFormat('hh:mm a').format(parsedTime); 
    } catch (e) {
      return time; 
    }
  }

  String get formattedOpenTime {
    return formatTime(openTime!);
  }


  String get formattedCloseTime {
    return formatTime(closeTime!);
  }
}
