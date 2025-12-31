import '../models/lesson.dart';
import '../models/user.dart';

List<Lesson> japaneseLessons = [
  Lesson(title: 'บทที่ 1: ตัวอักษร Hiragana', level: 'Beginner', progress: 0.2),
  Lesson(title: 'บทที่ 2: ตัวอักษร Katakana', level: 'Beginner', progress: 0.4),
  Lesson(title: 'บทที่ 3: ประโยคพื้นฐาน', level: 'Intermediate', progress: 0.1),
];

List<Lesson> englishLessons = [
  Lesson(title: 'Lesson 1: Greetings', level: 'Beginner', progress: 0.3),
  Lesson(title: 'Lesson 2: Introductions', level: 'Beginner', progress: 0.5),
];

User mockUser = User(
  username: 'Kitaya Bunrod',
  avatarUrl: 'https://i.pravatar.cc/150?img=3',
  level: 5,
  streakDays: 12,
  progress: 0.6,
);