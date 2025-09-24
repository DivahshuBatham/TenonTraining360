import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiConfig{
  // static const String baseUrl = "http://122.187.19.156:8000/api/";
  static const String send_otp = "send-otp";
  static const String verify_otp = "verify-otp";
  static const String resend_otp = "resend-otp";
  static const String register = "register";
  static const String send_notification = "send-notification";
  static const String userLogout = "logout";
  static const String userLogoutAllDevice = "logout_all_device";

  static const String saveFcmToken = "save-fcm-token";
  static const String mcqQuestion = "mcq-questions";
  static const String getTrainers = "staff_master";
  static const String getTrainees = "guard_master"; 
  static const String selectVirtualCourses = "virtual_courses";
  static const String selectPhysicalCourses = "physical_courses";
  static const String getPhysicalTrainingById =  "physical-trainings/";
  static const String getPhysicalTrainingByTraineeId =  "physical-trainings_trainee/";
  static const String getPhysicalTrainingByTrainerId =  "physical_trainee_data/";
  static const String schedulePhysicalTraining = "schedule_physical_training";
  static const String scheduleVirtualTraining = "schedule_virtual_training";
  static const String getVirtualTrainingById =  "virtual_trainee_data/";

  static const String checkMarkJoin = "mark-joined";
  static const String traineesStatus = "trainees-status?";
  static const String punch_in = "punch-in";
  static const String punch_out = "punch-out";
  static const String createVirtualCourse = "virtual_courses";
  static const String createPhysicalCourse = "physical_courses";

  static const String virtualCourseFilterById="filter_virtual_course?id=";
  static const String physicalCourseFilterById = "filter_physical_course?id=";
  static const String updateStatusTrainer="mark-status-completed/";
  static const String virtualType = "virtual";
  static const String physicalType = "physical";

  static const String filterTraineeList = "filter_trainee_list";

  static const String createCourse = "create_course";
  static const String getCourse = "get_course_data";

  static const String updateTraineeStatus = "update_trainee_status";
  static const String getFeedbackQuestions = "feedback";

  static void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

}