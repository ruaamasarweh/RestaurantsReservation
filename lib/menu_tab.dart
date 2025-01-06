// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/models/dish_class.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/menu_provider.dart';

class MenuTab extends StatefulWidget {
  final Restaurant restaurant;
  const MenuTab({super.key, required this.restaurant});

  @override
  State<MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<MenuTab> {
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


  Future<void> _refreshMenu() async {
    Provider.of<MenuProvider>(context, listen: false)
        .fetchMenu(widget.restaurant.restaurantID);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context); 
    final screenWidth = mediaQuery.size.width; 
    const crossAxisCount = 2; 
    final aspectRatio = (screenWidth / crossAxisCount) / 217;
    
    final menuProvider = Provider.of<MenuProvider>(context);
    
     if (menuProvider.dishCategories == null || menuProvider.dishCategories!.isEmpty||selectedCategory==null) {
      return const Center(child: Text('Menu'));
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshMenu,
        child: menuProvider.isLoading
            ? const Center(
                child: Center(child: Text('Menu')),
              )
            : Padding(       
              padding: const EdgeInsets.all(10),
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
                                  selected:category.categoryName == selectedCategory,
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
                    Flexible(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: aspectRatio,
                        ),
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
                          return ShowDish(dish: selectedDishes![index]);
                        },
                      ),
                    ),
                  ],
                ),
            ),
      ),
    );
  }
}

class ShowDish extends StatelessWidget {
  final DishDto dish;
  const ShowDish({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.network(
              dish.dishImageUrl,
              fit: BoxFit.cover,
              height: 124,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.broken_image,
                    size: 50, color: Colors.grey);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dish.dishName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dish.details ?? 'No details',
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${dish.price.toString()} JD',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
