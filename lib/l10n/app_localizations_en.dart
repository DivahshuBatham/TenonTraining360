// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get splash_text => 'Saksham By Tenon';

  @override
  String get login => 'login';

  @override
  String get send_otp => 'Send OTP';

  @override
  String get verify_otp => 'Verify OTP';

  @override
  String get enterOTP => 'Enter your OTP';

  @override
  String get enterMobileNumber => 'Enter your mobile number';

  @override
  String get mobileNumber => 'Mobile Number';

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
