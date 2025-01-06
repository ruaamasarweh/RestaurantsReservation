import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/about.dart';
import 'package:restaurants/models/reservation_class.dart';
import 'package:restaurants/providers/reservation_provider.dart';
import 'package:transparent_image/transparent_image.dart';

class CustomerReservations extends StatefulWidget {
  final int customerID;
  const CustomerReservations({super.key, required this.customerID});

  @override
  State<CustomerReservations> createState() => _CustomerReservationsState();
}

class _CustomerReservationsState extends State<CustomerReservations> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(context, listen: false)
          .getReservations(widget.customerID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservationProvider = Provider.of<ReservationProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservations'),
      ),
      body: reservationProvider.reservations != null
          ? ListView.builder(
              itemCount: reservationProvider.reservations!.length,
              itemBuilder: (context, index) {
                return SpecificReservation(
                  reservation: reservationProvider.reservations![index],
                );
              },
            )
          : const Center(child: Text('No reservations found')),
    );
  }
}

class SpecificReservation extends StatelessWidget {
  final Reservation reservation;
  const SpecificReservation({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    return InkWell(
      onTap: reservation.reservationStatus == "Confirmed" &&
              (reservation.date.year == currentDate.year &&
                  reservation.date.month == currentDate.month &&
                  reservation.date.day == currentDate.day)
          ? () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => About(
                            restaurant: reservation.restaurant,
                            branch: reservation.branch,
                            reservationID: reservation.reservationID,
                          )));
            }
          : () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Alert!'),
                    content: const Text(
                        'Make sure your reservation has been successfully accepted, and today is the reservation date.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.hardEdge,
        elevation: 8,
        child: Column(
          children: [
            Stack(
              children: [
                FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: NetworkImage(reservation.branch.branchImageUrl),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 180,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.restaurant.restaurantName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_pin, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reservation.branch.locationDescription,
                                style: const TextStyle(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.date_range,
                              color: Colors.deepOrange),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('yyyy-MM-dd').format(reservation.date),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.deepOrange),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('HH:mm').format(
                              DateTime(
                                2000,
                                1,
                                1,
                                reservation.time.hour,
                                reservation.time.minute,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.article_outlined,
                              color: Colors.deepOrange),
                          const SizedBox(width: 6),
                          Text(
                            reservation.reservationStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
