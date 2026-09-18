import 'package:flutter/material.dart';

import '../../model/course.dart';
import '../../model/student.dart';
import '../../service/lms_system.dart';
import '../widgets/data_list.dart';
import '../widgets/entity_tile.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;
  final LmsSystem lms;

  const CourseDetailsScreen({
    super.key,
    required this.course,
    required this.lms,
  });

  List<Student> get enrolledStudents => lms.students
      .where((student) => course.studentIds.contains(student.id))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Enrolled students',
          ),
          const SizedBox(height: 8),
          DataList<Student>(
            items: enrolledStudents,
            emptyMessage: 'No students enrolled.',
            itemBuilder: (context, student) => EntityTile<Student>(
              data: student,
              title: (student) => student.name,
              subtitle: (student) => student.id,
            ),
          ),
        ],
      ),
    );
  }
} 