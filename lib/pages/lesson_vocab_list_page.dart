import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../app_strings.dart';
import 'pronunciation_practice_page.dart';

class LessonVocabListPage extends StatelessWidget {
  final int lessonId;
  final String title;

  const LessonVocabListPage({super.key, required this.lessonId, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Column(
          children: [
            Text(
              "UNIT $lessonId",
              style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: UserData.vocabList,
        builder: (context, vocabList, _) {
          // กรองเอาเฉพาะคำในบทนี้
          final lessonWords = vocabList.where((v) => v['lessonId'] == lessonId).toList();

          if (lessonWords.isEmpty) {
            return Center(
              child: ValueListenableBuilder<String>(
                valueListenable: UserData.appLanguage,
                builder: (context, lang, _) => Text(
                  AppStrings.t('no_vocab_in_lesson'),
                  style: GoogleFonts.kanit(color: Colors.grey),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: lessonWords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = lessonWords[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1CB0F6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.volume_up_rounded, color: Color(0xFF1CB0F6)),
                  ),
                  title: Text(
                    item['word']!,
                    style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF2B3445)),
                  ),
                  subtitle: Text(
                    "${item['romaji']} • ${item['meaning']}",
                    style: GoogleFonts.kanit(color: Colors.grey[600], fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pronunciation Practice Button
                      ValueListenableBuilder<String>(
                        valueListenable: UserData.targetLanguage,
                        builder: (context, targetLang, _) {
                          return ValueListenableBuilder<String>(
                            valueListenable: UserData.appLanguage,
                            builder: (context, appLang, _) => IconButton(
                              icon: const Icon(Icons.mic, color: Color(0xFF58CC02)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PronunciationPracticePage(
                                      word: item['word']!,
                                      language: UserData.targetLanguageToVoiceCode(targetLang),
                                      meaning: item['meaning'],
                                    ),
                                  ),
                                );
                              },
                              tooltip: AppStrings.t('practice_pronunciation'),
                            ),
                          );
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['tag']!,
                          style: GoogleFonts.kanit(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().slideX(begin: 0.2, end: 0, delay: (50 * index).ms, duration: 300.ms, curve: Curves.easeOutQuad);
            },
          );
        },
      ),
    );
  }
}