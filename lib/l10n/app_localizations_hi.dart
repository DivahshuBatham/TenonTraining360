// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get splash_text => 'सक्षम बाय टेनन';

  @override
  String get login => 'लॉग इन करें';

  @override
  String get send_otp => 'ओटीपी भेजें';

  @override
  String get verify_otp => 'ओटीपी सत्यापित करें';

  @override
  String get enterOTP => 'अपना ओटीपी दर्ज करें';

  @override
  String get enterMobileNumber => 'अपना मोबाइल संख्या दर्ज करे';

  @override
  String get mobileNumber => 'मोबाइल नंबर';

  @override
  String get virtualTrainings => 'Virtual Trainings';

  @override
  String get scheduleTraining => 'Schedule Training';

  @override
  String get joinTraining => 'Join Training';

  @override
  String get noVirtualTrainings => 'No virtual trainings found.';

  @override
  String get courseName => 'Course Name';

  @override
  String get trainerName => 'Trainer Name';

  @override
  String get siteName => 'Site Name';

  @override
  String get totalTrainees => 'Total Trainees';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get trainingStatus => 'Training Status';

  @override
  String get totalAttendance => 'Total Attendance';
}
