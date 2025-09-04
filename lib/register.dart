
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import 'package:tenon_training_app/login.dart';
import 'environment/Environment.dart';


class Register extends StatefulWidget{
  const Register({super.key});
  @override
  State<StatefulWidget> createState() => RegisterPageState();
}

class RegisterPageState extends State<Register> {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final TextEditingController role = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                vertical: 40.0, horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30.0),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Please enter your name',
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Please enter your email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: mobile,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mobile',
                    hintText: 'Please enter your mobile number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Please enter your password',
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Confirm Password',
                    hintText: 'Please confirm your password',
                  ),
                ),
                const SizedBox(height: 20.0),
                TextField(
                  controller: role,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Role',
                    hintText: 'Please enter your role',
                  ),
                ),
                const SizedBox(height: 30.0),
                OutlinedButton(
                  onPressed: () {
                    userRegister(
                      context,
                      name.text,
                      email.text,
                      mobile.text,
                      password.text,
                      confirmPassword.text,
                      role.text,
                    );
                  },
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> userRegister(BuildContext context, String name,String email,
    String mobile,
    String password,
    String confirmPassword,
    String role,
    ) async {
  Dio dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (status) => status != null && status < 500, // Accept all status codes < 500
    ),
  );

  try {
    final url = '${AppConfig.baseUrl}${ApiConfig.register}';

    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'mobile': mobile,
      'password': password,
      'password_confirmation': confirmPassword,
      'role': role,
    };

    Response response = await dio.post(url, data: requestBody);

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = response.data;

      if (responseData['error'] != null) {
        ApiConfig.showToastMessage(responseData['message']);
      } else {
        ApiConfig.showToastMessage('Registration successful');
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }
      }
    } else if (response.statusCode == 409) {
      ApiConfig.showToastMessage('Username or Email already exists.');
    } else if (response.statusCode == 422) {
      // Validation errors
      var errors = response.data['errors'];
      if (errors != null && errors is Map<String, dynamic>) {
        // Show first validation error
        String firstError = errors.entries.first.value[0];
        ApiConfig.showToastMessage(firstError);
      } else {
        ApiConfig.showToastMessage('Validation error occurred.');
      }
    } else {
      ApiConfig.showToastMessage('Registration failed. Please try again.');
    }
  } catch (e) {
    if (e is DioException) {
      print('DioException: ${e.response?.data}');
      ApiConfig.showToastMessage('Network error. Please check your connection.');
    } else {
      print('Unexpected error: $e');
      ApiConfig.showToastMessage('An unexpected error occurred.');
    }
  }
}





