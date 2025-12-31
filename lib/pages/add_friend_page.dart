// lib/pages/add_friend_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_data.dart';
import '../app_strings.dart';
import '../services/friend_service.dart';
import '../models/friend.dart';

class AddFriendPage extends StatefulWidget {
  const AddFriendPage({super.key});

  @override
  State<AddFriendPage> createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final TextEditingController _searchController = TextEditingController();
  final FriendService _friendService = FriendService();
  bool _isSearching = false;

  String get _userId => UserData.name.value;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FD),
        elevation: 0,
        title: ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('add_friend'),
            style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF2B3445)),
          ),
        ),
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
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.t('search_by_name_or_email'),
                hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _isSearching = false);
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              style: GoogleFonts.kanit(),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() => _isSearching = true);
                }
              },
            ),
          ),
          // Search Results
          Expanded(
            child: _isSearching && _searchController.text.isNotEmpty
                ? _buildSearchResults()
                : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    // Mock suggestions - ในระบบจริงควรดึงจาก database
    final suggestions = [
      {'name': 'Alice', 'email': 'alice@example.com', 'avatar': null},
      {'name': 'Bob', 'email': 'bob@example.com', 'avatar': null},
      {'name': 'Charlie', 'email': 'charlie@example.com', 'avatar': null},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('recommend_friend'),
            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
          ),
        ),
        const SizedBox(height: 16),
        ...suggestions.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildSearchResults() {
    // Mock search results - ในระบบจริงควรค้นหาจาก database
    final results = [
      {'name': _searchController.text, 'email': '${_searchController.text.toLowerCase()}@example.com', 'avatar': null},
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ValueListenableBuilder<String>(
          valueListenable: UserData.appLanguage,
          builder: (context, lang, _) => Text(
            AppStrings.t('search_results'),
            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF2B3445)),
          ),
        ),
        const SizedBox(height: 16),
        ...results.map((user) => _buildUserCard(user)),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user['avatar'] != null ? NetworkImage(user['avatar']) : null,
          child: user['avatar'] == null
              ? Text(user['name'][0].toUpperCase(), style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold))
              : null,
        ),
        title: Text(user['name'], style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(user['email'], style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey.shade600)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF58CC02)),
          onPressed: () => _sendFriendRequest(user),
          child: ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => Text(
              AppStrings.t('add'),
              style: GoogleFonts.kanit(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendFriendRequest(Map<String, dynamic> user) async {
    final friend = Friend(
      id: user['email'], // Use email as ID temporarily
      name: user['name'],
      email: user['email'],
      avatarUrl: user['avatar'],
      targetLanguage: UserData.targetLanguage.value,
    );

    final success = await _friendService.sendFriendRequest(_userId, friend);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ValueListenableBuilder<String>(
            valueListenable: UserData.appLanguage,
            builder: (context, lang, _) => Text(
              success ? AppStrings.t('friend_request_sent') : AppStrings.t('friend_request_exists'),
              style: GoogleFonts.kanit(),
            ),
          ),
          backgroundColor: success ? Colors.green : Colors.orange,
        ),
      );
    }
  }
}

