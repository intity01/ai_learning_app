// lib/services/community_service.dart
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/community_room.dart';
import '../models/community_group.dart';

/// Service สำหรับจัดการ Community Rooms และ Groups
class CommunityService {
  static const String _keyRooms = 'community_rooms';
  static const String _keyGroups = 'community_groups';
  
  // Auto-cleanup interval (5 minutes)
  static const Duration _cleanupInterval = Duration(minutes: 5);
  static const Duration _roomMaxLifetime = Duration(hours: 2); // Max room lifetime
  
  Timer? _cleanupTimer;

  CommunityService() {
    _startAutoCleanup();
  }

  /// เริ่ม auto-cleanup timer
  void _startAutoCleanup() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) {
      _cleanupEmptyRooms();
    });
  }

  /// Cleanup rooms ที่ว่างหรือมีคนเดียว
  Future<void> _cleanupEmptyRooms() async {
    final rooms = await getAllRooms();
    final now = DateTime.now();
    
    for (final room in rooms) {
      if (room.shouldDelete || 
          (room.expiresAt != null && now.isAfter(room.expiresAt!))) {
        await deleteRoom(room.id);
      }
    }
  }

  /// สร้างห้องใหม่
  Future<CommunityRoom> createRoom({
    required String creatorId,
    required String creatorName,
    required String title,
    required String description,
    required String language,
    required RoomType type,
    int maxParticipants = 10,
    bool isPublic = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final rooms = await getAllRooms();
    
    final room = CommunityRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorId: creatorId,
      creatorName: creatorName,
      title: title,
      description: description,
      language: language,
      type: type,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(_roomMaxLifetime),
      participantIds: [creatorId], // Creator joins automatically
      maxParticipants: maxParticipants,
      isPublic: isPublic,
    );

    rooms.add(room);
    await _saveRooms(rooms);
    
    return room;
  }

  /// เข้าร่วมห้อง
  Future<bool> joinRoom(String roomId, String userId) async {
    final rooms = await getAllRooms();
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);
    
    if (roomIndex == -1) return false;
    
    final room = rooms[roomIndex];
    if (room.participantIds.contains(userId)) return true;
    if (room.participantCount >= room.maxParticipants) return false;
    
    final updatedParticipantIds = List<String>.from(room.participantIds)..add(userId);
    rooms[roomIndex] = room.copyWith(participantIds: updatedParticipantIds);
    await _saveRooms(rooms);
    
    return true;
  }

  /// ออกจากห้อง
  Future<void> leaveRoom(String roomId, String userId) async {
    final rooms = await getAllRooms();
    final roomIndex = rooms.indexWhere((r) => r.id == roomId);
    
    if (roomIndex == -1) return;
    
    final room = rooms[roomIndex];
    final updatedParticipantIds = List<String>.from(room.participantIds)..remove(userId);
    
    // Auto-delete if empty or single user
    if (updatedParticipantIds.isEmpty || updatedParticipantIds.length == 1) {
      rooms.removeAt(roomIndex);
    } else {
      rooms[roomIndex] = room.copyWith(participantIds: updatedParticipantIds);
    }
    
    await _saveRooms(rooms);
  }

  /// ลบห้อง
  Future<void> deleteRoom(String roomId) async {
    final rooms = await getAllRooms();
    rooms.removeWhere((r) => r.id == roomId);
    await _saveRooms(rooms);
  }

  /// ดึงห้องทั้งหมด
  Future<List<CommunityRoom>> getAllRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = prefs.getStringList(_keyRooms) ?? [];
    
    return roomsJson
        .map((json) => CommunityRoom.fromMap(jsonDecode(json)))
        .where((room) => !room.shouldDelete) // Filter out expired/empty rooms
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // Newest first
  }

  /// ดึงห้องตามภาษา
  Future<List<CommunityRoom>> getRoomsByLanguage(String language) async {
    final rooms = await getAllRooms();
    return rooms.where((r) => r.language == language && r.isPublic).toList();
  }

  /// ดึงห้องที่ user เข้าร่วม
  Future<List<CommunityRoom>> getUserRooms(String userId) async {
    final rooms = await getAllRooms();
    return rooms.where((r) => r.participantIds.contains(userId)).toList();
  }

  /// ดึงห้องตาม ID
  Future<CommunityRoom?> getRoom(String roomId) async {
    final rooms = await getAllRooms();
    try {
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (e) {
      return null;
    }
  }

  /// บันทึก rooms
  Future<void> _saveRooms(List<CommunityRoom> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final roomsJson = rooms.map((r) => jsonEncode(r.toMap())).toList();
    await prefs.setStringList(_keyRooms, roomsJson);
  }

  // ========== Group Methods ==========

  /// สร้างกลุ่มใหม่
  Future<CommunityGroup> createGroup({
    required String creatorId,
    required String creatorName,
    required String name,
    required String description,
    required String language,
    String? imageUrl,
    int maxMembers = 100,
    bool isPublic = true,
    required List<String> tags,
  }) async {
    final groups = await getAllGroups();
    
    final group = CommunityGroup(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      creatorId: creatorId,
      creatorName: creatorName,
      name: name,
      description: description,
      language: language,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
      memberIds: [creatorId], // Creator joins automatically
      maxMembers: maxMembers,
      isPublic: isPublic,
      tags: tags,
    );

    groups.add(group);
    await _saveGroups(groups);
    
    return group;
  }

  /// เข้าร่วมกลุ่ม
  Future<bool> joinGroup(String groupId, String userId) async {
    final groups = await getAllGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);
    
    if (groupIndex == -1) return false;
    
    final group = groups[groupIndex];
    if (group.memberIds.contains(userId)) return true;
    if (group.isFull) return false;
    
    final updatedMemberIds = List<String>.from(group.memberIds)..add(userId);
    groups[groupIndex] = group.copyWith(memberIds: updatedMemberIds);
    await _saveGroups(groups);
    
    return true;
  }

  /// ออกจากกลุ่ม
  Future<void> leaveGroup(String groupId, String userId) async {
    final groups = await getAllGroups();
    final groupIndex = groups.indexWhere((g) => g.id == groupId);
    
    if (groupIndex == -1) return;
    
    final group = groups[groupIndex];
    final updatedMemberIds = List<String>.from(group.memberIds)..remove(userId);
    
    // Delete group if empty (optional - might want to keep empty groups)
    if (updatedMemberIds.isEmpty) {
      groups.removeAt(groupIndex);
    } else {
      groups[groupIndex] = group.copyWith(memberIds: updatedMemberIds);
    }
    
    await _saveGroups(groups);
  }

  /// ดึงกลุ่มทั้งหมด
  Future<List<CommunityGroup>> getAllGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = prefs.getStringList(_keyGroups) ?? [];
    
    return groupsJson
        .map((json) => CommunityGroup.fromMap(jsonDecode(json)))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// ดึงกลุ่มตามภาษา
  Future<List<CommunityGroup>> getGroupsByLanguage(String language) async {
    final groups = await getAllGroups();
    return groups.where((g) => g.language == language && g.isPublic).toList();
  }

  /// ดึงกลุ่มตาม ID
  Future<CommunityGroup?> getGroup(String groupId) async {
    final groups = await getAllGroups();
    try {
      return groups.firstWhere((g) => g.id == groupId);
    } catch (e) {
      return null;
    }
  }

  /// บันทึก groups
  Future<void> _saveGroups(List<CommunityGroup> groups) async {
    final prefs = await SharedPreferences.getInstance();
    final groupsJson = groups.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(_keyGroups, groupsJson);
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
  }
}

