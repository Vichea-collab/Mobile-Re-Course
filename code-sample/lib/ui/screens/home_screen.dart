import 'package:flutter/material.dart';

import '../../model/course.dart';
import '../../service/lms_system.dart';
import '../widgets/data_list.dart';
import '../widgets/entity_tile.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatelessWidget {
  final LmsSystem lms;

  const HomeScreen({super.key, required this.lms});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('LMS Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  label: 'Students',
                  value: '${lms.students.length}',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Courses',
                  value: '${lms.courses.length}',
                ),
              ),
              Expanded(
                child: SummaryCard(
                  label: 'Results',
                  value: '${lms.results.length}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Courses'),
          const SizedBox(height: 8),

          DataList<Course>(
            items: lms.courses,
            emptyMessage: 'No courses available.',
            itemBuilder: (context, course) => EntityTile<Course>(
              data: course,
              title: (course) => course.name,
              subtitle: (course) => '${course.id} - ${course.studentIds.length} students',
            ),
          ),
        ],
      ),
    );
  }
}
 