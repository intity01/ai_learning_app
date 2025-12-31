import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart'; 
import 'package:gap/gap.dart';
import 'dart:math'; 
import '../user_data.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

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
        title: Text(
          'สถิติการเรียน',
          style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Overview Cards
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: UserData.xp,
                    builder: (_, xp, __) => _buildStatBox("Total XP", "$xp", Icons.star_rounded, Colors.blue)
                  )
                ),
                const Gap(15),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: UserData.streak,
                    builder: (_, streak, __) => _buildStatBox("Streak", "$streak วัน", Icons.local_fire_department_rounded, Colors.orange)
                  )
                ),
              ],
            ).animate().slideY(begin: 0.2, duration: 400.ms, curve: Curves.easeOut),
            
            const Gap(15),
            
            // Words Learned
            ValueListenableBuilder(
              valueListenable: UserData.vocabList,
              builder: (context, vocab, _) {
                int count = vocab.length; 
                return _buildWideStatBox("คำศัพท์ที่รู้", "$count คำ", Icons.book_rounded, const Color(0xFF58CC02));
              }
            ).animate().slideY(begin: 0.2, delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),

            const Gap(30),

            // 2. Activity Chart (กราฟจริงจาก WeeklyXP)
            Text("กิจกรรมรายสัปดาห์ (XP)", style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
            const Gap(15),
            
            ValueListenableBuilder(
              valueListenable: UserData.weeklyXP,
              builder: (context, weeklyData, _) {
                double maxY = weeklyData.reduce(max).toDouble();
                if (maxY < 100) maxY = 100;

                return Container(
                  height: 250,
                  padding: const EdgeInsets.fromLTRB(10, 25, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY * 1.2, 
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.blueAccent,
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${rod.toY.round()} XP',
                              GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              const days = ['จ', 'อ', 'พ', 'พฤ', 'ศ', 'ส', 'อา'];
                              if (value.toInt() >= 0 && value.toInt() < days.length) {
                                 return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    days[value.toInt()],
                                    style: GoogleFonts.kanit(color: Colors.grey, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(7, (index) {
                        bool isToday = (DateTime.now().weekday - 1) == index;
                        return _makeBarGroup(
                          index, 
                          weeklyData[index].toDouble(), 
                          isToday ? const Color(0xFF1CB0F6) : Colors.blue.shade100
                        );
                      }),
                    ),
                  ),
                );
              }
            ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),

            const Gap(30),

            // 🔥 3. Learning Progress (แก้ใหม่ ลบ Mock Data ทิ้งหมด!)
            Text("ความคืบหน้าการเรียน", style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
            const Gap(15),
            
            ValueListenableBuilder(
              valueListenable: UserData.lessonProgress,
              builder: (context, progress, _) {
                // คำนวณจริง
                int totalLessons = 5;
                int completed = progress.values.where((p) => p >= 1.0).length;
                double lessonPercent = completed / totalLessons;
                if (lessonPercent > 1.0) lessonPercent = 1.0;

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      // วงกลมใหญ่ (คิดจาก Lesson ล้วนๆ เพราะเป็น Core หลัก)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100, height: 100,
                            child: CircularProgressIndicator(
                              value: lessonPercent,
                              strokeWidth: 12,
                              backgroundColor: Colors.grey.shade100,
                              color: const Color(0xFF58CC02),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${(lessonPercent * 100).toInt()}%",
                                style: GoogleFonts.kanit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445), height: 1),
                              ),
                              Text("รวม", style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                      const Gap(30),
                      
                      // Progress Bar ย่อย (ข้อมูลจริงเท่านั้น)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. บทเรียนที่จบ (Lesson Progress)
                            _buildAccuracyItem("บทเรียนที่จบ ($completed/$totalLessons)", lessonPercent, Colors.blue),
                            
                            const Gap(20),
                            
                            // 2. ระดับเลเวล (XP Progress)
                            ValueListenableBuilder(
                              valueListenable: UserData.xp, 
                              builder: (_, xpVal, __) {
                                // สมมติ Master ที่ 2000 XP
                                double levelProgress = (xpVal / 2000).clamp(0.0, 1.0);
                                return _buildAccuracyItem("ระดับเลเวล (XP)", levelProgress, Colors.orange);
                              }
                            ),
                            
                            // ❌ ลบ "การฟัง" (Mock Data) ทิ้งไปแล้วครับ!
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }
            ).animate().fade(delay: 400.ms, duration: 500.ms),
            
            const Gap(50),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: BorderRadius.circular(8),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100, 
            color: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const Gap(10),
          Text(value, style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445))),
          Text(label, style: GoogleFonts.kanit(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWideStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const Gap(15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(label, style: GoogleFonts.kanit(fontSize: 14, color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccuracyItem(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.kanit(color: Colors.grey.shade700)),
            Text("${(value * 100).toInt()}%", style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const Gap(4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: color.withValues(alpha: 0.1),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}