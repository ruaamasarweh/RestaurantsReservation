import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/branch_details_provider.dart';
import 'package:restaurants/reservation_tab.dart';

class DetailsTab extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;
  final int? reservationID;
  const DetailsTab(
      {super.key,
      required this.restaurant,
      required this.branch,
      this.reservationID});

  @override
  State<DetailsTab> createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BranchDetailsProvider>(context, listen: false)
          .fetchBranchDetails(
              widget.restaurant.restaurantID, widget.branch.branchID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final branchDetaildProvider = Provider.of<BranchDetailsProvider>(context);
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => branchDetaildProvider.fetchBranchDetails(
            widget.restaurant.restaurantID, widget.branch.branchID),
        child: branchDetaildProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.restaurant.restaurantName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_pin,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              branchDetaildProvider.branch!.locationDescription,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            branchDetaildProvider.branch!.phoneNumber!,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${branchDetaildProvider.branch!.formattedOpenTime} - ${branchDetaildProvider.branch!.formattedCloseTime}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.house,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            branchDetaildProvider.branch!.hasIndoorSeating! &&
                                    branchDetaildProvider
                                        .branch!.hasOutdoorSeating!
                                ? 'indoor & outdoor seating'
                                : branchDetaildProvider.branch!.hasIndoorSeating!
                                    ? 'just indoor seating'
                                    : branchDetaildProvider
                                            .branch!.hasOutdoorSeating!
                                        ? 'just outdoor seating'
                                        : 'no seating',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: widget.reservationID==null?Padding(
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 117, 25),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationTab(
                    restaurant: widget.restaurant,
                    branch: widget.branch,
                  ),
                ),
              );
            },
            child: const Text(
              'Book table',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ):null,
    );
  }
}
