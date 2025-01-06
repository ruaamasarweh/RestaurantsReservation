// ignore_for_file: use_build_context_synchronously
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:restaurants/restaurants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signup extends StatelessWidget {
  const Signup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: Color.fromARGB(255, 224, 125, 54)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                      child: Text(
                    'Sign up',
                    style: GoogleFonts.merriweather(
                        fontWeight: FontWeight.bold, fontSize: 25),
                  )),
                ),
              ],
            ),
            const SignupForm(),
          ],
        ),
      ),
    );
  }
}

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneNumController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFieldFocused = false;
  bool _isLoading = false;
  int? customerID;
  @override
  void initState() {
    super.initState();
    _passwordFocusNode.addListener(() async {
      //password fieldبتتفعل لما نكبس على
      setState(() {
        _isPasswordFieldFocused = _passwordFocusNode.hasFocus;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        customerID = prefs.getInt('customerID');
      });
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneNumController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _fullNameController,
                      labelText: 'Full Name',
                      icon: Icons.person,
                      obscureText: false,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (val.length < 6) {
                          return 'Name must contain at least 6 characters';
                        }
                        if (RegExp(r'\d').hasMatch(val)) {
                          return 'Full name should not contain numbers';
                        }
                        if (RegExp(r'[_!@#\$%^&*(),.?":{}|<>]').hasMatch(val)) {
                          return 'Full name should not contain special characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      icon: Icons.account_circle,
                      obscureText: false,
                      validator: (val) {
                        if (val!.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (val.length < 6) {
                          return 'Username must contain at least 6 characters';
                        }
                        if (val.contains(' ')) {
                          return 'Username cannot contain spaces';
                        }
                        if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(val)) {
                          return 'Full name should not contain special characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _phoneNumController,
                      labelText: 'Phone Number',
                      icon: Icons.phone,
                      obscureText: false,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(val)) {
                          return 'Please enter a valid 10-digit phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _addressController,
                      labelText: 'Address',
                      icon: Icons.home,
                      obscureText: false,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                      obscureText: false,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(val)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      labelText: 'Password',
                      icon: Icons.lock,
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please enter password';
                        }
                        if (val.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!RegExp(r'^(?=.*[A-Z])').hasMatch(val)) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        return null;
                      },
                    ),
                    if (_isPasswordFieldFocused)
                      const Text(
                        'Password must be at least 8 characters long, contains at least one uppercase letter',
                        style:
                            TextStyle(color: Color.fromARGB(255, 51, 50, 49)),
                      ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFB6B0E),
                              foregroundColor: const Color(0xFFFFFBF8),
                              minimumSize: const Size(140, 40),
                            ),
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });

                              if (_formKey.currentState!.validate()) {
                                //  final Uri url = Uri.parse('http://192.168.159.55:5114/api/user/signup');
                                //  Uri url = Uri.parse('http://ararizm-003-site3.qtempurl.com/api/user/signup'); //for android emulator
                                Uri url = Uri.parse(
                                    'http://10.0.2.2:5114/api/user/signup');
                                try {
                                  var response = await http.post(url,
                                      headers: {
                                        'Content-Type':
                                            'application/json; charset=UTF-8'
                                      },
                                      body: json.encode({
                                        'FullName': _fullNameController.text,
                                        'UserName': _usernameController.text,
                                        'PhoneNum': _phoneNumController.text,
                                        'Address': _addressController.text,
                                        'Email': _emailController.text,
                                        'Password': _passwordController.text
                                      }));

                                  if (response.statusCode == 200) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Signup successful!')));
                                    int customerID = json
                                        .decode(response.body)['customerID'];
                                    String customerName = json
                                        .decode(response.body)['customerName'];
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool('isLoggedIn', true);
                                    await prefs.setInt(
                                        'CustomerID', customerID);
                                    await prefs.setString(
                                        'customerName', customerName);
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Restaurants()));
                                  } else {
                                    String errorMessage =
                                        json.decode(response.body)['message'];
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(errorMessage)),
                                    );
                                    setState(() {
                                      _isLoading = false;
                                    });
                                  }
                                } catch (error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('something went wrong..')));
                                  log(error.toString());
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            icon: const Icon(Icons.login),
                            label: const Text("Sign up"),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField buildTextField(
      {required TextEditingController controller,
      required String labelText,
      required IconData icon,
      required bool obscureText,
      required String? Function(String?)? validator,
      FocusNode? focusNode}) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      decoration: InputDecoration(
        label: Text(labelText),
        prefixIcon: Icon(icon, color: const Color(0xFFFF6D00)),
        contentPadding: const EdgeInsets.all(15),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 17, 17, 17)),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
      ),
      validator: validator,
    );
  }
}
