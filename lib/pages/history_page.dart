import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../app_strings.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
            ]
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Color(0xFF2B3445)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          AppStrings.t('history_title'),
          style: GoogleFonts.kanit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2B3445),
          ),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: UserData.history,
        builder: (context, historyList, _) {
          if (historyList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppStrings.t('history_empty'),
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'เริ่มเรียนเพื่อดูประวัติการเรียนของคุณ',
                    style: GoogleFonts.kanit(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              // ข้อมูลเก็บในรูปแบบ "Title|Timestamp" เราต้องแยกออกมา
              final item = historyList[index];
              final parts = item.split('|');
              final title = parts.isNotEmpty ? parts[0] : 'Unknown';
              final time = parts.length > 1 ? parts[1] : '-';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF58CC02).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF58CC02), size: 24),
                  ),
                  title: Text(
                    title,
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF2B3445),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          'เสร็จสิ้นเมื่อ: $time',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().slideX(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms, curve: Curves.easeOutQuad);
            },
          );
        },
      ),
    );
  }
}