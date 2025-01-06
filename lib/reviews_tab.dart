import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/reviews_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewsTab extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;
  const ReviewsTab({super.key, required this.restaurant, required this.branch});

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  final TextEditingController _reviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _currentRating = 5;
  int?customerID;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }


  Future<void> _initializeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerID = prefs.getInt('customerID');
    });

    if (customerID != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<ReviewsProvider>(context, listen: false)
            .loadReviews(widget.branch.branchID);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsProvider = Provider.of<ReviewsProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => reviewsProvider.loadReviews(widget.branch.branchID),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(
                color: Colors.orange,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 100,
                                  child: TextFormField(
                                    controller: _reviewController,
                                    maxLength: 100,
                                    maxLines: 30,
                                    decoration: const InputDecoration(
                                      label: Text('Leave a review'),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    ),
                                    validator: (val) {
                                      if (val == null ||
                                          val.isEmpty ||
                                          val.trim().isEmpty) {
                                        return 'Review cannot be empty';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                RatingBar.builder(
                                  initialRating: _currentRating.toDouble(),
                                  minRating: 1,
                                  direction: Axis.horizontal,
                                  itemCount: 5,
                                  itemPadding: const EdgeInsets.symmetric(
                                      horizontal: 4.0),
                                  itemBuilder: (context, _) => const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                  ),
                                  onRatingUpdate: (rating) {
                                    setState(() {
                                      _currentRating = rating.toInt();
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      reviewsProvider.submitReview(
                                          widget.branch.branchID,
                                          _reviewController.text,
                                          _currentRating,
                                          customerID!);
                                      Navigator.pop(context);
                                      _reviewController.clear();
                                    }
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ]),
            reviewsProvider.isLoading?const Center(child: CircularProgressIndicator()):
            Expanded(
              child: reviewsProvider.reviews!.isEmpty
                      ? const Center(
                          child: Text('No reviews yet for this branch.'))
                      : ListView.builder(
                          itemCount: reviewsProvider.reviews!.length,
                          itemBuilder: (context, index) {
                            final review = reviewsProvider.reviews![index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              child: Card(
                                color: const Color.fromARGB(255, 249, 237, 237),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(review.customerName),
                                      ),
                                      Row(
                                        children: List.generate(
                                          review.rating,
                                          (index) => const Icon(
                                            Icons.star,
                                            color: Color.fromARGB(
                                                255, 255, 193, 61),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(DateFormat('dd-MM-yyyy')
                                          .format(review.reviewDate)),
                                      const SizedBox(height: 4),
                                      Text(review.customerReview),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
