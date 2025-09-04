import 'package:flutter/material.dart';
import 'package:tenon_training_app/login.dart';
import 'package:tenon_training_app/main.dart';
import 'package:tenon_training_app/shared_preference/shared_preference_manager.dart';
import 'l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatelessWidget {
  final List<Map<String, String>> languages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'hi', 'label': 'हिंदी'},
    {'code': 'pa', 'label': 'ਪੰਜਾਬੀ'},
    {'code': 'kn', 'label': 'ಕನ್ನಡ'},
    {'code': 'ta', 'label': 'தமிழ்'},
    {'code': 'mr', 'label': 'मराठी'},
  ];

  void _selectLanguage(BuildContext context, String code) async {
    final pref = SharedPreferenceManager();
    await pref.clearLanguageCode();

    await pref.setLanguageCode(code);
    debugPrint("Selected Language====: $code");

    MyApp.setLocale(context, Locale(code));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Language'),
        // title: Text(loc?.translate('select_language') ?? 'Select Language'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: languages.length,
        itemBuilder: (_, index) {
          final lang = languages[index];
          return GestureDetector(
            onTap: () => _selectLanguage(context, lang['code']!),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.purple,
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text(
                  lang['label']!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
