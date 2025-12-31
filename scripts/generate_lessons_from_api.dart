// scripts/generate_lessons_from_api.dart
// Script สำหรับสร้างบทเรียนจาก API จริงๆ และบันทึกไว้

import 'dart:io';
import 'dart:convert';
import '../lib/services/lesson_preloader.dart';

void main() async {
  print('🚀 เริ่มสร้างบทเรียนจาก API...');
  print('⏳ กระบวนการนี้อาจใช้เวลาสักครู่...\n');
  
  try {
    // ใช้ LessonPreloader เพื่อสร้างบทเรียนทั้งหมด
    await LessonPreloader.preloadAllLessons();
    
    print('\n✅ สร้างบทเรียนเสร็จสิ้น!');
    print('📁 ไฟล์ถูกบันทึกไว้ใน assets/data/');
    print('\n📋 ไฟล์ที่สร้าง:');
    print('  - jp_n5_lessons.json');
    print('  - jp_n4_lessons.json');
    print('  - jp_n3_lessons.json');
    print('  - en_beginner_lessons.json');
    print('  - en_intermediate_lessons.json');
    print('  - en_advanced_lessons.json');
    print('  - cn_hsk1_lessons.json');
    print('  - cn_hsk2_lessons.json');
    print('  - kr_topik1_lessons.json');
    print('  - kr_topik2_lessons.json');
  } catch (e) {
    print('❌ เกิดข้อผิดพลาด: $e');
    exit(1);
  }
}


