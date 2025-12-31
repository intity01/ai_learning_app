import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'dart:async';
import 'signup_login_page.dart';
import '../app_strings.dart';
import '../user_data.dart';

/// หน้า Loading Plan - แสดงว่า AI กำลังสร้างแผนการเรียน
class LoadingPlanPage extends StatefulWidget {
  final String nativeLanguage;
  final String targetLanguage;
  final String currentLevel;
  final int dailyGoalMinutes;

  const LoadingPlanPage({
    super.key,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.currentLevel,
    required this.dailyGoalMinutes,
  });

  @override
  State<LoadingPlanPage> createState() => _LoadingPlanPageState();
}

class _LoadingPlanPageState extends State<LoadingPlanPage> {
  int _currentTip = 0;
  
  List<String> get _tips => [
    AppStrings.t('loading_plan_analyzing'),
    AppStrings.t('loading_plan_creating'),
    AppStrings.t('loading_plan_preparing'),
    AppStrings.t('loading_plan_almost_done'),
  ];

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() {
    // เปลี่ยน tip ทุก 1.5 วินาที
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          if (_currentTip < _tips.length - 1) {
            _currentTip++;
          } else {
            timer.cancel();
            // หลังจาก 6 วินาที ไปหน้า Sign Up/Login
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignUpLoginPage(
                      nativeLanguage: widget.nativeLanguage,
                      targetLanguage: widget.targetLanguage,
                      currentLevel: widget.currentLevel,
                      dailyGoalMinutes: widget.dailyGoalMinutes,
                    ),
                  ),
                );
              }
            });
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: UserData.appLanguage,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // AI Icon with Animation
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFCE82FF), Color(0xFF9F4BF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFCE82FF).withValues(alpha: 0.4),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 60,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        duration: 2000.ms,
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(1.1, 1.1),
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        duration: 2000.ms,
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(1.0, 1.0),
                        curve: Curves.easeInOut,
                      ),

                  Gap(40),

                  // Loading Text
                  Text(
                    AppStrings.t('loading_plan_title'),
                    style: GoogleFonts.kanit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2B3445),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Gap(20),

                  // Current Tip
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _tips[_currentTip],
                      key: ValueKey(_currentTip),
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Gap(40),

                  // Progress Indicator
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: (_currentTip + 1) / _tips.length,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF58CC02),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

