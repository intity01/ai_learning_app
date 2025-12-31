class MockLessonService {
  static Map<String, List<Map<String, dynamic>>> lessons = {
    'Japanese': [
      {'title': 'บทที่ 1: พื้นฐาน', 'level': 'Beginner', 'progress': 0.3},
      {'title': 'บทที่ 2: ประโยคทั่วไป', 'level': 'Beginner', 'progress': 0.6},
      {'title': 'บทที่ 3: การสนทนา', 'level': 'Intermediate', 'progress': 0.2},
    ],
    'English': [
      {'title': 'Lesson 1: Basics', 'level': 'Beginner', 'progress': 0.4},
      {'title': 'Lesson 2: Daily Conversation', 'level': 'Intermediate', 'progress': 0.1},
    ],
  };
}