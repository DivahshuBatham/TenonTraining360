import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tenon_training_app/l10n/app_localizations.dart';
import 'package:tenon_training_app/networking/api_config.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import 'package:tenon_training_app/trainee/trainee_dashboard.dart';
import 'package:tenon_training_app/trainner/trainer_dashboard.dart';

import 'environment/Environment.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<Login> {
  final TextEditingController mobile_number = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final SharedPreferenceManager _preferenceManager = SharedPreferenceManager();

  bool _isLoading = false;
  bool otpSent = false;
  bool _loggedIn = false;

  @override
  void dispose() {
    mobile_number.dispose();
    _otp.dispose();
    super.dispose();
  }

  Future<void> _userLogin() async {
    final phone_number = mobile_number.text.trim();

    if (phone_number.isEmpty) {
      ApiConfig.showToastMessage("Please enter mobile number");
      return;
    }

    setState(() => _isLoading = true);

    Dio dio = Dio();

    try {
      final String url = '${AppConfig.baseUrl}${ApiConfig.send_otp}';
      FormData formData = FormData.fromMap({'mobile': phone_number});

      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('Login Response: ${response.data}');
      final responseData = response.data;

      if (responseData['status'] == true) {
        ApiConfig.showToastMessage(responseData['otp'].toString());
        ApiConfig.showToastMessage(
          responseData['message']?.toString() ?? 'OTP sent',
        );

        setState(() {
          otpSent = true;
          _otp.clear(); // Clear OTP field just in case
        });

      } else if (responseData['status'] == 403) {
        ApiConfig.showToastMessage(
          responseData['message']?.toString() ?? 'Access denied',
        );

      } else if (responseData['status'] == 404) {
        ApiConfig.showToastMessage(
          responseData['message']?.toString() ?? 'User not found',
        );

      } else {
        ApiConfig.showToastMessage(
          responseData['message']?.toString() ?? 'Login failed',
        );
      }

    } on DioError catch (e) {
      if (e.response != null && e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null && errors['mobile'] != null && errors['mobile'].isNotEmpty) {
          ApiConfig.showToastMessage(errors['mobile'][0]);
        } else {
          ApiConfig.showToastMessage('Invalid input');
        }
      } else {
        ApiConfig.showToastMessage('An error occurred: ${e.message}');
      }
    } catch (e) {
      ApiConfig.showToastMessage('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  Future<void> _verifyOtp(String mobileNumber, String otp) async {
    if (otp.isEmpty) {
      ApiConfig.showToastMessage("Please enter OTP");
      return;
    }

    setState(() => _isLoading = true);

    Dio dio = Dio();

    try {
      final String url = '${AppConfig.baseUrl}${ApiConfig.verify_otp}';

      // Get device info
      final deviceInfoPlugin = DeviceInfoPlugin();
      String deviceName = 'Unknown Device';
      String deviceModel = 'Unknown Model';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceName = androidInfo.brand ?? 'Unknown';
        deviceModel = androidInfo.model ?? 'Unknown';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceName = iosInfo.name ?? 'Unknown';
        deviceModel = iosInfo.model ?? 'Unknown';
      }

      // Prepare FormData
      FormData formData = FormData.fromMap({
        'mobile': mobileNumber,
        'otp': otp,
        'device_name': deviceName,
        'device_model': deviceModel,
      });

      // Send User-Agent header (optional, can keep for fallback)
      Options options = Options(
        headers: {
          'User-Agent':
          'TenonApp/1.0 (Flutter; ${Platform.operatingSystem} ${Platform.operatingSystemVersion})',
        },
      );

      // Make POST request
      Response response = await dio.post(url, data: formData, options: options);

      debugPrint('OTP Verify Response: ${response.data}');
      final responseData = response.data;

      final status = responseData['status'].toString();

      if (status == 'true') {
        final token = responseData['token'];
        final role = responseData['role'];
        final id = responseData['id'].toString();

        if (role == "trainer") {
          _preferenceManager.clearTrainerID();
          await _preferenceManager.saveTrainerId(id);
        } else {
          _preferenceManager.clearTraineeID();
          await _preferenceManager.saveTraineeId(id);
        }

        await _preferenceManager.clearToken();
        await _preferenceManager.removeRole();
        await _preferenceManager.saveToken(token);
        await _preferenceManager.saveRole(role);

        ApiConfig.showToastMessage(responseData['message']);
        await registerFCMToken();

        setState(() => _loggedIn = true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            role == "trainee" ? TraineeDashboard() : TrainerDashboard(),
          ),
        );
      }
    } on DioError catch (dioError) {
      if (dioError.response != null) {
        final responseData = dioError.response?.data;
        final errorMessage =
            responseData['details']?['message'] ??
                responseData['message'] ??
                "OTP verification failed";
        ApiConfig.showToastMessage(errorMessage);
        debugPrint('OTP Error Response: $responseData');
      } else {
        ApiConfig.showToastMessage('Network error: ${dioError.message}');
      }
    } catch (e) {
      ApiConfig.showToastMessage('An unexpected error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    final local =AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: _loggedIn
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  local.login,
                  style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30.0),
                TextField(
                  controller: mobile_number,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !otpSent,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText:local.enterMobileNumber,
                    labelText: local.mobileNumber,
                    suffixIcon: otpSent ? const Icon(Icons.lock_outline) : null,
                  ),
                ),
                const SizedBox(height: 20.0),
                if (otpSent) ...[
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText:local.enterOTP,
                      labelText: 'OTP',
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (!otpSent) {
                        _userLogin();
                      } else {
                        _verifyOtp(mobile_number.text, _otp.text);
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                    child: Text(
                      !otpSent ? local.send_otp : local.verify_otp,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Save FCM Token to Server
Future<void> registerFCMToken([String? token]) async {
  try {
    token ??= await FirebaseMessaging.instance.getToken();

    if (token == null || token.isEmpty) {
      debugPrint("⚠️ FCM token not received");
      return;
    }

    final pref = SharedPreferenceManager();
    final authToken = await pref.getToken();

    if (authToken == null || authToken.isEmpty) {
      debugPrint("⚠️ Auth token not found");
      return;
    }

    final response = await http.post(
      Uri.parse("${AppConfig.baseUrl}${ApiConfig.saveFcmToken}"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $authToken",
      },
      body: jsonEncode({"fcm_token": token}),
    );

    if (response.statusCode == 200) {
      debugPrint("✅ FCM token saved successfully");
    } else {
      debugPrint("❌ Failed to save FCM token: ${response.body}");
    }
  } catch (e) {
    debugPrint("❌ Error in registerFCMToken: $e");
  }
}
