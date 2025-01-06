import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:restaurants/login.dart';
import 'package:restaurants/signup.dart';
import 'package:restaurants/restaurants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurants/providers/branch_details_provider.dart';
import 'package:restaurants/providers/branches_provider.dart';
import 'package:restaurants/providers/favorite_branches_provider.dart';
import 'package:restaurants/providers/menu_provider.dart';
import 'package:restaurants/providers/order_provider.dart';
import 'package:restaurants/providers/reservation_provider.dart';
import 'package:restaurants/providers/restaurants_provider.dart';
import 'package:restaurants/providers/reviews_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) => runApp(
            MultiProvider(
              providers: [
                ChangeNotifierProvider(create: (_) => RestaurantsProvider()),
                ChangeNotifierProvider(create: (_) => BranchesProvider()),
                ChangeNotifierProvider(create: (_) => BranchDetailsProvider()),
                ChangeNotifierProvider(create: (_) => MenuProvider()),
                ChangeNotifierProvider(create: (_) => ReviewsProvider()),
                ChangeNotifierProvider(create: (_) => ReservationProvider()),
                ChangeNotifierProvider(create: (_) => FavoriteBranchesProvider()),
                ChangeNotifierProvider(create: (_) => OrderProvider())
              ],
              child: const MyApp(),
            ),
          ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    log('isLoggedIn value: $isLoggedIn');
    return isLoggedIn ?? false; 
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data == true) {
            return const Restaurants(); 
          } else {
            return const HomePage(); 
          }
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(color: Color(0xFFFB6B0E), fontSize: 30),
            ),
            const SizedBox(height: 20),
            Image.asset(
              "images/logo1.png",
              height: 270,
              width: 270,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 117, 25),
                foregroundColor: const Color(0xFFFFFBF8),
                minimumSize: const Size(140, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text("Login"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 117, 25),
                foregroundColor: const Color(0xFFFFFBF8),
                minimumSize: const Size(140, 40),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Signup()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text("Sign up"),
            ),
          ],
        ),
      ),
    );
  }
}
