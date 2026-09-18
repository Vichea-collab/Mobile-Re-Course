import 'package:test/test.dart';
import 'package:w3/service/lms_system.dart';

void main() {
  group('LMS system', () {
    test('creates a course', () {
      final lms = LmsSystem();

      lms.createCourse(courseId: 'C1', courseName: 'Flutter');

      expect(lms.courses.length, 1);
      expect(lms.courses.first.name, 'Flutter');
    });
  });

  test('adds a student to a course', () {
    final lms = LmsSystem();

    lms.createCourse(courseId: 'C1', courseName: 'Flutter');
    lms.addStudent(studentId: 'S1', studentName: 'Alice');
    lms.addStudentToCourse(studentId: 'S1', courseId: 'C1');

    bool studentIsOnCourse = lms.courses[0].studentIds.contains('S1');

    expect(studentIsOnCourse, true);
  });

  test('adds a score for a student', () {
    final lms = LmsSystem();

    lms.createCourse(courseId: 'C1', courseName: 'Flutter');
    lms.addStudent(studentId: 'S1', studentName: 'Alice');
    lms.addStudentToCourse(studentId: 'S1', courseId: 'C1');

    lms.addScore(courseId: 'C1', studentId: 'S1', score: 17);

    expect(lms.results.length, 1);
    expect(lms.results.first.score, 17);
  });

  test('removing a student also removes related data', () {
    final lms = LmsSystem();

    lms.createCourse(courseId: 'C1', courseName: 'Flutter');
    lms.addStudent(studentId: 'S1', studentName: 'Alice');
    lms.addStudentToCourse(studentId: 'S1', courseId: 'C1');

    lms.addScore(courseId: 'C1', studentId: 'S1', score: 17);
    lms.removeStudent( studentId: 'S1');

    expect(lms.students, isEmpty);
    expect(lms.courses.first.studentIds, isEmpty);
    expect(lms.results, isEmpty);
  });
}
