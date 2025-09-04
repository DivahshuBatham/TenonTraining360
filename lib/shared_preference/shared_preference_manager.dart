
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceManager{

  static const String _languageCodeKey = 'language_code';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }


  Future<void> saveCourseId(int courseId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('course_id', courseId);
  }

  Future<int?> getCourseId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('course_id');
  }

  Future<void> clearCourse() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('course_id');
  }

  // for save the role in shared preference

  Future<void> saveRole(String role) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }

  Future<String?> getRole() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  Future<void> removeRole() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('role');

  }

  Future<void> saveTrainerId(String name) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', name);
  }

  Future<String?> getTrainerID() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }
  Future<void> clearTrainerID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
  }

  Future<void> saveTraineeId(String name) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', name);
  }

  Future<String?> getTraineeID() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }
  Future<void> clearTraineeID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('id');
  }


  Future<void> saveScheduleTrainingID(String id) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id',id);
  }

  Future<String?> getScheduleTrainingID() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<void> saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }


  Future<void> saveFCMToken(String fcm_token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', fcm_token);
  }

  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  Future<void> clearFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
  }
  /// Save language code
  Future<void> setLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, code);
  }

  /// Retrieve language code
  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageCodeKey);
  }

  /// Clear saved language code (optional)
  Future<void> clearLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
  }

  Future<void> savePhysicalTrainingID(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('training_id',id);
  }

  Future<String?> getPhysicalTrainingID() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('training_id');
  }

  Future<void> clearPhysicalTrainingID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('training_id');
  }


}