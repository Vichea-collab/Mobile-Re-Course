import 'package:flutter/material.dart';
import 'package:w3/ui/screens/course_details_screen.dart';

import 'service/lms_system.dart';

void main() {
  final lms = LmsSystem();
  lms.createCourse(courseId: 'C1', courseName: 'Flutter Development');
  lms.createCourse(courseId: 'C2', courseName: 'Dart Programming');
  lms.addStudent(studentId: 'S1', studentName: 'Alice Johnson');
  lms.addStudent(studentId: 'S2', studentName: 'Bob Smith');
  lms.addStudentToCourse(studentId: 'S1', courseId: 'C1');
  lms.addStudentToCourse(studentId: 'S2', courseId: 'C1');
  lms.addScore(courseId: 'C1', studentId: 'S1', score: 17);

  runApp(LmsApp(lms: lms));
}

class LmsApp extends StatelessWidget {
  final LmsSystem lms;

  const LmsApp({super.key, required this.lms});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS',
    
      home: CourseDetailsScreen(
        course: lms.courses[0],
        lms: lms,
      ), 
    );
  }
}
