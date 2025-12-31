import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../user_data.dart';
import '../app_strings.dart';
import 'public_profile_page.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

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
        title: ValueListenableBuilder(
          valueListenable: UserData.appLanguage,
          builder: (context, _, __) => Text(
            AppStrings.t('leaderboard_title'),
            style: GoogleFonts.kanit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
          ),
        ),
      ),
      body: Column(
        children: [
          // My Rank Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFF58CC02).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1), 
                  blurRadius: 20, 
                  offset: const Offset(0, 10)
                )
              ]
            ),
            child: ValueListenableBuilder(
              valueListenable: UserData.myRankPosition,
              builder: (context, rank, _) {
                return Column(
                  children: [
                    // Avatar with border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF58CC02),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF58CC02).withValues(alpha: 0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ValueListenableBuilder<int>(
                        valueListenable: UserData.avatarIndex,
                        builder: (context, index, _) {
                          return CircleAvatar(
                            radius: 45,
                            backgroundImage: NetworkImage(
                              UserData.avatarTemplates[index.clamp(0, UserData.avatarTemplates.length - 1)]
                            ),
                          );
                        },
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: 12),
                    ValueListenableBuilder(
                      valueListenable: UserData.name,
                      builder: (_, name, __) => Text(
                        name,
                        style: GoogleFonts.kanit(
                          fontSize: 24, 
                          fontWeight: FontWeight.bold, 
                          color: const Color(0xFF2B3445)
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF9600),
                            const Color(0xFFFFB84D),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9600).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          ValueListenableBuilder(
                            valueListenable: UserData.appLanguage,
                            builder: (context, _, __) => Text(
                              "${AppStrings.t('rank')} #$rank",
                              style: GoogleFonts.kanit(
                                fontSize: 16, 
                                fontWeight: FontWeight.bold, 
                                color: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder(
                      valueListenable: UserData.xp,
                      builder: (_, xp, __) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.blue.shade200, width: 1),
                        ),
                        child: Text(
                          "$xp XP",
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // List
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: UserData.leaderboard,
              builder: (context, players, _) {
                if (players.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        ValueListenableBuilder(
                          valueListenable: UserData.appLanguage,
                          builder: (context, _, __) => Text(
                            AppStrings.t('no_data'),
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    int rank = index + 1;
                    
                    Widget? rankIcon;
                    Color? rankColor;
                    
                    if (rank == 1) {
                      rankIcon = const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 32);
                      rankColor = const Color(0xFFFFD700);
                    } else if (rank == 2) {
                      rankIcon = const Icon(Icons.emoji_events_rounded, color: Color(0xFFC0C0C0), size: 30);
                      rankColor = const Color(0xFFC0C0C0);
                    } else if (rank == 3) {
                      rankIcon = const Icon(Icons.emoji_events_rounded, color: Color(0xFFCD7F32), size: 28);
                      rankColor = const Color(0xFFCD7F32);
                    } else {
                      rankIcon = Text(
                        "$rank", 
                        style: GoogleFonts.kanit(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.grey.shade600
                        )
                      );
                      rankColor = null;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: player.isMe 
                            ? const Color(0xFFE8F5E9) 
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: player.isMe 
                            ? Border.all(
                                color: const Color(0xFF58CC02).withValues(alpha: 0.5), 
                                width: 2
                              ) 
                            : Border.all(
                                color: Colors.grey.shade200, 
                                width: 1
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: player.isMe 
                                ? const Color(0xFF58CC02).withValues(alpha: 0.1) 
                                : Colors.grey.withValues(alpha: 0.05), 
                            blurRadius: 10, 
                            offset: const Offset(0, 4)
                          )
                        ],
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicProfilePage(
                                userName: player.name,
                                avatarUrl: player.avatarUrl,
                                xp: player.xp,
                                isMe: player.isMe,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: rankColor?.withValues(alpha: 0.1) ?? Colors.grey.shade100,
                            border: rankColor != null
                                ? Border.all(color: rankColor!, width: 2)
                                : null,
                          ),
                          child: Center(child: rankIcon),
                        ),
                        title: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: player.isMe 
                                      ? const Color(0xFF58CC02) 
                                      : Colors.grey.shade300,
                                  width: player.isMe ? 2 : 1,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(player.avatarUrl),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    player.name, 
                                    style: GoogleFonts.kanit(
                                      fontSize: 16, 
                                      fontWeight: player.isMe ? FontWeight.bold : FontWeight.w600, 
                                      color: const Color(0xFF2B3445)
                                    ), 
                                    overflow: TextOverflow.ellipsis
                                  ),
                                  if (player.isMe)
                                    ValueListenableBuilder(
                                      valueListenable: UserData.appLanguage,
                                      builder: (context, _, __) => Text(
                                        AppStrings.t('you'), 
                                        style: GoogleFonts.kanit(
                                          fontSize: 11, 
                                          color: const Color(0xFF58CC02),
                                          fontWeight: FontWeight.w500,
                                        )
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: player.isMe 
                                ? const Color(0xFF58CC02).withValues(alpha: 0.1)
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: player.isMe 
                                  ? const Color(0xFF58CC02).withValues(alpha: 0.3)
                                  : Colors.blue.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            "${player.xp} XP", 
                            style: GoogleFonts.kanit(
                              fontSize: 14, 
                              fontWeight: FontWeight.bold, 
                              color: player.isMe 
                                  ? const Color(0xFF58CC02)
                                  : Colors.blueAccent
                            )
                          ),
                        ),
                        ),
                      ),
                    ).animate()
                      .slideX(begin: 0.1, end: 0, delay: (50 * index).ms, duration: 300.ms)
                      .fadeIn(delay: (50 * index).ms, duration: 300.ms);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}