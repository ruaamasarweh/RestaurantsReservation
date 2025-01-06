// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/branches.dart';
import 'package:restaurants/customer_reservations.dart';
import 'package:restaurants/main.dart';
import 'package:restaurants/models/resraurant_class.dart';
import 'package:restaurants/providers/favorite_branches_provider.dart';
import 'package:restaurants/providers/restaurants_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Restaurants extends StatefulWidget {
  const Restaurants({super.key});

  @override
  State<Restaurants> createState() => _RestaurantsState();
}

class _RestaurantsState extends State<Restaurants> {
  TextEditingController textController = TextEditingController();
  int? customerID;
  String? customerName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<RestaurantsProvider>(context, listen: false).loadRestaurantsBrief();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        customerID = prefs.getInt('customerID');
        customerName = prefs.getString('customerName');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final restaurantsProvider = Provider.of<RestaurantsProvider>(context);
    final favoriteBranchesProvider = Provider.of<FavoriteBranchesProvider>(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async{
         SystemNavigator.pop();
        return false; 
        },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Restaurants',
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.bold,
              fontSize: 21,
            ),
          ),
          backgroundColor: const Color.fromARGB(146, 246, 245, 245),
        ),
        drawer: SafeArea(
          child: Drawer(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 100,
                  color: const Color.fromARGB(192, 255, 174, 61),
                  child: Center(
                    child: Text(
                      customerName ?? 'Loading...',
                      style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Branches(favs: favoriteBranchesProvider.favs, userID: customerID)),
                    );
                  },
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: const Text('Favorites'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerReservations(customerID: customerID!)),
                    );
                  },
                  leading: const Icon(Icons.restaurant, color: Color.fromARGB(192, 255, 149, 0)),
                  title: const Text('Reservations'),
                ),
                ListTile(
                  onTap: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('isLoggedIn', false); // Log out the user
                    await prefs.setInt('CustomerID', 0);
                    await prefs.setString('customerName', "null");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
                  },
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
          child: Column(
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(56, 149, 148, 148),
                  contentPadding: const EdgeInsets.all(10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Search restaurants, food and places",
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search),
                  prefixIconColor: const Color.fromARGB(255, 202, 81, 0),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    color: const Color.fromARGB(255, 202, 81, 0),
                    onPressed: () {
                      setState(() {
                        textController.clear();
                        Provider.of<RestaurantsProvider>(context, listen: false).searchRestaurants("");
                      });
                    },
                  ),
                ),
                onChanged: (newValue) {
                  Provider.of<RestaurantsProvider>(context, listen: false).searchRestaurants(newValue);
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: restaurantsProvider.loadRestaurants,
                  child: restaurantsProvider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : GridView(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          children: [
                            for (var i in restaurantsProvider.filteredRestaurantsList)
                              ShowRestaurant(restaurant: i)
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShowRestaurant extends StatelessWidget {
  final Restaurant restaurant;
  const ShowRestaurant({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>Branches(restaurant: restaurant,)));
      },
      splashColor: const Color.fromARGB(255, 202, 197, 197),
      borderRadius: BorderRadius.circular(15),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  restaurant.imageFilePath!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image,
                        size: 50, color: Colors.grey);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                restaurant.restaurantName,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
