import '../models/lesson.dart';

class MockLessonsService {
  static List<Lesson> japaneseLessons = [
    Lesson(title: 'พื้นฐานภาษาญี่ปุ่น 1', level: 'N5', progress: 0.40),
    Lesson(title: 'คำศัพท์ในชีวิตประจำวัน', level: 'N4', progress: 0.70),
  ];

  static List<Lesson> englishLessons = [
    Lesson(title: 'Basic Greetings', level: 'Beginner', progress: 0.20),
    Lesson(title: 'Travel Phrases', level: 'Intermediate', progress: 0.55),
  ];

  // TODO: Connect REST API / AI / Voice API here
}