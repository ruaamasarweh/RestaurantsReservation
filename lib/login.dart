// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurants/restaurants.dart';
import 'package:restaurants/signup.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
          children: [
            Top(height: screenHeight, width: screenWidth),
            const BackIcon(),
            Bottom(height: screenHeight, width: screenWidth),
          ],
        ),
    );
  }
}

class Top extends StatelessWidget {
  final double height;
  final double width;
  const Top({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: height*0.59,
          width: width,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/login-img.png"), 
                fit: BoxFit.cover),
          ),
        ));
  }
}

class BackIcon extends StatelessWidget {
  const BackIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
            top: 30, 
            left: 10, 
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color.fromARGB(255, 255, 255, 255)),
              onPressed: () {
                Navigator.pop(context); 
              },
            ),
            );
  }
}

class Bottom extends StatelessWidget {
  final double height;
  final double width;
  const Bottom({super.key, required this.height, required this.width});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child:SafeArea(
        child: Container(
            width: width,
            height: height*0.60,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 251, 248, 245),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Login',
                      style: GoogleFonts.merriweather(
                          fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    const SizedBox(
                      height: 50,
                    ),
                    const LoginForm(),
                  ],
                ),
              ),
            ),
          ),
      ),
      );
    
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}
class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isLoading=false;

    @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
          buildTextField(
            controller: emailController,
            labelText: 'Email',
            icon: Icons.email_outlined,
            obscureText: false,
            validator: (val) {
              if (val!.isEmpty) {
                return 'please enter your email';
              }
              if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(val)) {
                 return 'Enter a valid email address';
                }
              return null;
            },
          ),
          const SizedBox(
            height: 40,
          ),
         buildTextField(
            controller: passwordController,
            labelText: 'Password',
            icon: Icons.lock,
            obscureText: true,
            validator: (val) {
              if (val!.isEmpty) {
                return 'please enter your password';
              }
              return null;
            },
          ),
          const SizedBox(
            height: 50,
          ),
          _isLoading?const CircularProgressIndicator()
          :
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFB6B0E),
              foregroundColor: const Color(0xFFFFFBF8),
              minimumSize: const Size(140, 40),
            ),
            onPressed: () async {
              setState(() {
                _isLoading=true;
              });
              if (_formKey.currentState!.validate()) {
              //  final Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/user/login');
                 Uri url = Uri.parse('http://10.0.2.2:5114/api/user/login');
                try {
                  var response = await http.post(
                    url,
                    headers: {'Content-Type': 'application/json; charset=UTF-8'},
                    body: json.encode({
                      'Email': emailController.text,
                      'Password': passwordController.text,
                    }),
                  );
                  log(response.toString());
                  if (response.statusCode == 200) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Login successful!')),
                    );
                    
                     int customerID=json.decode(response.body)['customerID'];
                    String customerName=json.decode(response.body)['customerName'];
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true); 
                      await prefs.setInt('customerID',customerID );
                      await prefs.setString('customerName', customerName);

                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const Restaurants()));
                  } else {
                     String errorMessage = json.decode(response.body)['message'] ;
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)), 
                     );
                    setState(() {
                      _isLoading=false;
                    });
                  }
                } catch (error) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Something went wrong..')),
                   );
                   log(error.toString());
                   setState(() {
                      _isLoading=false;
                    });
                }
              }else{
                setState(() {
                  _isLoading=false;
                });
             
              }
            },
            icon: const Icon(Icons.login),
            label: const Text("Login"),
          ),
          const SizedBox(
            height: 30,
          ),
          const BottomText(),
        ]));
  }
 TextFormField buildTextField({required TextEditingController controller,required String labelText,required IconData icon,required bool obscureText,required String? Function(String?)? validator}){
  return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: const Color(0xffFB6B0E)),
        contentPadding: const EdgeInsets.all(15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 59, 58, 58)),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      validator: validator,
    );
 }
}

class BottomText extends StatelessWidget {
  const BottomText({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'If you don’t have an account: ',
            style: TextStyle(fontSize: 15),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Signup()),
              );
            },
            child: const Text(
              'sign up',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 3, 78, 140),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
