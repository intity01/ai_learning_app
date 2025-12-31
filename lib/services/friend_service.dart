// lib/services/friend_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/friend.dart';

class FriendService {
  static const String _keyFriends = 'friends_list';
  static const String _keyFriendRequests = 'friend_requests';

  /// ส่งคำขอเพื่อน
  Future<bool> sendFriendRequest(String fromUserId, Friend newFriend) async {
    final requests = await getFriendRequests();
    
    // ตรวจสอบว่ามีคำขออยู่แล้วหรือไม่
    final exists = requests.any((r) => 
      r['from'] == fromUserId && r['to'] == newFriend.id ||
      r['from'] == newFriend.id && r['to'] == fromUserId
    );
    
    if (exists) return false;

    requests.add({
      'from': fromUserId,
      'to': newFriend.id,
      'friend': newFriend.toMap(),
      'sentAt': DateTime.now().toIso8601String(),
    });
    
    await _saveFriendRequests(requests);
    return true;
  }

  /// ยอมรับคำขอเพื่อน
  Future<void> acceptFriendRequest(String requestId, String userId) async {
    final requests = await getFriendRequests();
    final request = requests.firstWhere((r) => r['to'] == userId && r['from'] == requestId);
    
    if (request == null) return;
    
    final friend = Friend.fromMap(request['friend']);
    await addFriend(friend);
    requests.removeWhere((r) => r['from'] == requestId && r['to'] == userId);
    await _saveFriendRequests(requests);
  }

  /// ปฏิเสธคำขอเพื่อน
  Future<void> rejectFriendRequest(String requestId, String userId) async {
    final requests = await getFriendRequests();
    requests.removeWhere((r) => r['from'] == requestId && r['to'] == userId);
    await _saveFriendRequests(requests);
  }

  /// เพิ่มเพื่อน
  Future<void> addFriend(Friend friend) async {
    final friends = await getAllFriends();
    if (!friends.any((f) => f.id == friend.id)) {
      friends.add(friend.copyWith(status: FriendStatus.accepted));
      await _saveFriends(friends);
    }
  }

  /// ลบเพื่อน
  Future<void> removeFriend(String friendId) async {
    final friends = await getAllFriends();
    friends.removeWhere((f) => f.id == friendId);
    await _saveFriends(friends);
  }

  /// บล็อกเพื่อน
  Future<void> blockFriend(String friendId) async {
    final friends = await getAllFriends();
    final index = friends.indexWhere((f) => f.id == friendId);
    if (index != -1) {
      friends[index] = friends[index].copyWith(status: FriendStatus.blocked);
      await _saveFriends(friends);
    }
  }

  /// ดึงเพื่อนทั้งหมด
  Future<List<Friend>> getAllFriends() async {
    final prefs = await SharedPreferences.getInstance();
    final friendsJson = prefs.getStringList(_keyFriends) ?? [];
    
    return friendsJson
        .map((json) => Friend.fromMap(jsonDecode(json)))
        .where((f) => f.status == FriendStatus.accepted)
        .toList();
  }

  /// ดึงคำขอเพื่อน
  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getStringList(_keyFriendRequests) ?? [];
    
    return requestsJson.map((json) => jsonDecode(json) as Map<String, dynamic>).toList();
  }

  /// ดึงคำขอที่ส่งมาให้ฉัน
  Future<List<Map<String, dynamic>>> getIncomingRequests(String userId) async {
    final requests = await getFriendRequests();
    return requests.where((r) => r['to'] == userId).toList();
  }

  /// บันทึกเพื่อน
  Future<void> _saveFriends(List<Friend> friends) async {
    final prefs = await SharedPreferences.getInstance();
    final friendsJson = friends.map((f) => jsonEncode(f.toMap())).toList();
    await prefs.setStringList(_keyFriends, friendsJson);
  }

  /// บันทึกคำขอเพื่อน
  Future<void> _saveFriendRequests(List<Map<String, dynamic>> requests) async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = requests.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList(_keyFriendRequests, requestsJson);
  }
}

extension FriendExtension on Friend {
  Friend copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? targetLanguage,
    bool? isOnline,
    DateTime? lastSeen,
    FriendStatus? status,
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      status: status ?? this.status,
    );
  }
}


