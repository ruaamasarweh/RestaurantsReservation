// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/providers/branch_details_provider.dart';
import 'package:restaurants/providers/reservation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';

class ReservationTab extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;

  const ReservationTab({super.key, required this.restaurant, required this.branch});

  @override
  State<ReservationTab> createState() => _ReservationTabState();
}

class _ReservationTabState extends State<ReservationTab> {
  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = const TimeOfDay(hour: 19, minute: 30);
  int guestCount = 4;
  String? selectedTableZone;
  int? customerID;

  @override
  void initState() {
    super.initState();
    _loadCustomerID();
  }

  Future<void> _loadCustomerID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerID = prefs.getInt('customerID');
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

Future<void> _selectTime(BuildContext context, String openTime, String closeTime) async {
  final openTimeParts = openTime.split(':');
  final closeTimeParts = closeTime.split(':');

  final openDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    int.parse(openTimeParts[0]),
    int.parse(openTimeParts[1]),
  );

  final closeDateTime = DateTime(
    selectedDate.year,
    selectedDate.month,
    selectedDate.day,
    int.parse(closeTimeParts[0]),
    int.parse(closeTimeParts[1]),
  );


  final TimeOfDay? selected = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(hour: openDateTime.hour, minute: openDateTime.minute),
  );

  if (selected != null) {
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selected.hour,
      selected.minute,
    );

    if (selectedDateTime.isBefore(openDateTime) || selectedDateTime.isAfter(closeDateTime)) {
      _showTimeErrorDialog(context, openTime, closeTime);
    } else {
      setState(() {
        selectedTime = selected;
      });
    }
  }
}

void _showTimeErrorDialog(BuildContext context, String openTime, String closeTime) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Invalid Time'),
        content: Text(
          'Please choose a time between $openTime and $closeTime.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}



  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  String getFormattedTime(){
     return"${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
     }

  void _incrementGuestCount(){
    setState(() => guestCount++);
    }
  void _decrementGuestCount(){
    setState(() => guestCount > 1 ? guestCount-- : guestCount);
    }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final branchDetailsProvider=Provider.of<BranchDetailsProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10.0),
              const Center(child: Text("Find your table", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0))),
              const SizedBox(height: 50.0),
              _buildDateField(),
              const SizedBox(height: 25.0),
              _buildTimeField(branchDetailsProvider.branch!.openTime!,branchDetailsProvider.branch!.closeTime!),
              const SizedBox(height: 25.0),
              _buildGuestsField(),
              const SizedBox(height: 40.0),
              _buildTableField(),
              const SizedBox(height: 40.0),
              _buildConfirmButton(reservationProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("DATE", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        InkWell(
          onTap: () => _selectDate(context),
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today, color: Color.fromARGB(255, 255, 117, 25)),
              border: OutlineInputBorder(),
            ),
            child: Text(formatDate(selectedDate)),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeField(String openTime, String closedTime) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("TIME", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10.0),
        InkWell(
          onTap: () => _selectTime(context,openTime,closedTime),
          child: InputDecorator(
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.access_time, color: Color.fromARGB(255, 255, 117, 25)),
              border: OutlineInputBorder(),
            ),
            child: Text(getFormattedTime()),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GUESTS",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10.0),
              InputDecorator(
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.person,
                      color: Color.fromARGB(255, 255, 117, 25)),
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: _decrementGuestCount,
                    ),
                    Text('$guestCount'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _incrementGuestCount,
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget _buildTableField() {
    return widget.branch.hasIndoorSeating! || widget.branch.hasOutdoorSeating!
        ? Row(
            children: [
              if (widget.branch.hasIndoorSeating!)
                _buildTableZoneRadio('Inside'),
              if (widget.branch.hasOutdoorSeating!)
                _buildTableZoneRadio('Outside'),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildTableZoneRadio(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: selectedTableZone,
          onChanged: (String? value) => setState(() => selectedTableZone = value),
        ),
        Text(value),
      ],
    );
  }

  Widget _buildConfirmButton(ReservationProvider reservationProvider) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              await reservationProvider.submitReservation(
                selectedDate,
                selectedTime,
                guestCount,
                selectedTableZone ?? 'No preference',
                customerID!,
                widget.branch.branchID,
              );
              _showSuccessDialog();
            } catch (e) {
              _showErrorDialog();
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 255, 117, 25),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Text("Confirm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Success!'),
        content: const Text('Your reservation has been created successfully.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

void _showErrorDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('Failed to create reservation. Please try again.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
}
