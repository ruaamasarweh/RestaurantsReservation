// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/confirm_order.dart';
import 'package:restaurants/models/branch_class.dart';
import 'package:restaurants/models/dish_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/menu_provider.dart';

class OrderPage extends StatefulWidget {
  final Restaurant restaurant;
  final BranchDto branch;
  final int reservationID;
  const OrderPage(
      {super.key,
      required this.restaurant,
      required this.branch,
      required this.reservationID});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<DishDto> orderedItems = [];

  void _increaseQuantity(DishDto item) {
    setState(() {
      item.quantity++;
      _updateOrder(item);
    });
  }

  void _decreaseQuantity(DishDto item) {
    setState(() {
      if (item.quantity > 0) {
        item.quantity--;
        _updateOrder(item);
      }
    });
  }

  void _updateOrder(DishDto item) {
    if (item.quantity > 0 && !orderedItems.contains(item)) {
      orderedItems.add(item);
    } else if (item.quantity == 0) {
      orderedItems.remove(item);
    }
  }

  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false)
          .fetchMenu(widget.restaurant.restaurantID)
          .then((_) {
        final menuProvider = Provider.of<MenuProvider>(context, listen: false);
        if (menuProvider.dishCategories != null &&
            menuProvider.dishCategories!.isNotEmpty) {
          setState(() {
            selectedCategory = menuProvider.dishCategories![0].categoryName;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);
    if (menuProvider.dishCategories == null ||
        menuProvider.dishCategories!.isEmpty ||
        selectedCategory == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Order Now',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [         
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: menuProvider.dishCategories?.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(category.categoryName),
                          selected: category.categoryName == selectedCategory,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = category.categoryName;
                            });
                          },
                          selectedColor:
                              const Color.fromARGB(255, 255, 165, 126),
                          backgroundColor: const Color(0xFFE0E0E0),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ),
            if (selectedCategory != null)
              Expanded(
                child: ListView.builder(
                  itemCount: menuProvider.dishCategories
                          ?.firstWhere((category) =>
                              category.categoryName == selectedCategory)
                          .dishes
                          ?.length ??
                      0,
                  itemBuilder: (context, index) {
                    var selectedDishes = menuProvider.dishCategories
                        ?.firstWhere((category) =>
                            category.categoryName == selectedCategory)
                        .dishes;
                    final item = selectedDishes![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(item.dishImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.dishName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.details ?? 'No details',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${(item.price).toStringAsFixed(2)} JD',
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () => _decreaseQuantity(item),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () => _increaseQuantity(item),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ConfirmOrder(orderedItems: orderedItems,
                              reservationID: widget.reservationID,)));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}