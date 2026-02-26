import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalEcoChallengesService {
  static const String _challengesKey = 'local_eco_challenges';
  static const String _userChallengesKey = 'local_user_challenges';
  
  // Sample data for initialization
  static List<Map<String, dynamic>> _sampleChallenges = [
    {
      'id': '1',
      'title': '30-Day Plastic Free Challenge',
      'description': 'Eliminate single-use plastics from your daily life for 30 days. Track your progress and discover eco-friendly alternatives.',
      'category': 'Waste Reduction',
      'difficultyLevel': 'Medium',
      'pointsReward': 100,
      'durationDays': 30,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'title': 'Energy Saving Challenge',
      'description': 'Reduce your home energy consumption by 20% through simple daily actions and habits.',
      'category': 'Energy Conservation',
      'difficultyLevel': 'Easy',
      'pointsReward': 75,
      'durationDays': 14,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '3',
      'title': 'Zero Waste Week',
      'description': 'Challenge yourself to produce zero waste for one week. Learn to reuse, recycle, and reduce.',
      'category': 'Waste Reduction',
      'difficultyLevel': 'Hard',
      'pointsReward': 150,
      'durationDays': 7,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '4',
      'title': 'Plant-Based Diet Challenge',
      'description': 'Adopt a plant-based diet for 21 days and reduce your carbon footprint significantly.',
      'category': 'Food & Diet',
      'difficultyLevel': 'Medium',
      'pointsReward': 80,
      'durationDays': 21,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '5',
      'title': 'Water Conservation Challenge',
      'description': 'Reduce your daily water usage by implementing water-saving techniques at home.',
      'category': 'Water Conservation',
      'difficultyLevel': 'Easy',
      'pointsReward': 60,
      'durationDays': 14,
      'isActive': true,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
  ];

  // Get all challenges
  static Future<List<Map<String, dynamic>>> getAllChallenges() async {
    final prefs = await SharedPreferences.getInstance();
    final challengesJson = prefs.getString(_challengesKey);
    
    if (challengesJson == null) {
      // Initialize with sample data
      await _initializeSampleData();
      return _sampleChallenges;
    }
    
    final List<dynamic> challengesList = json.decode(challengesJson);
    return challengesList.cast<Map<String, dynamic>>();
  }

  // Get active challenges
  static Future<List<Map<String, dynamic>>> getActiveChallenges() async {
    final allChallenges = await getAllChallenges();
    return allChallenges.where((challenge) => challenge['isActive'] == true).toList();
  }

  // Get challenge by ID
  static Future<Map<String, dynamic>?> getChallengeById(String id) async {
    final allChallenges = await getAllChallenges();
    try {
      return allChallenges.firstWhere((challenge) => challenge['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Create new challenge
  static Future<Map<String, dynamic>> createChallenge(Map<String, dynamic> challengeData) async {
    final allChallenges = await getAllChallenges();
    
    final newChallenge = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      ...challengeData,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    allChallenges.add(newChallenge);
    await _saveChallenges(allChallenges);
    
    return newChallenge;
  }

  // Update challenge
  static Future<Map<String, dynamic>?> updateChallenge(String id, Map<String, dynamic> updateData) async {
    final allChallenges = await getAllChallenges();
    final challengeIndex = allChallenges.indexWhere((challenge) => challenge['id'] == id);
    
    if (challengeIndex == -1) return null;
    
    allChallenges[challengeIndex] = {
      ...allChallenges[challengeIndex],
      ...updateData,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    
    await _saveChallenges(allChallenges);
    return allChallenges[challengeIndex];
  }

  // Delete challenge
  static Future<bool> deleteChallenge(String id) async {
    final allChallenges = await getAllChallenges();
    final challengeIndex = allChallenges.indexWhere((challenge) => challenge['id'] == id);
    
    if (challengeIndex == -1) return false;
    
    allChallenges.removeAt(challengeIndex);
    await _saveChallenges(allChallenges);
    
    // Also remove related user challenges
    await _removeUserChallengesForChallenge(id);
    
    return true;
  }

  // Toggle challenge active status
  static Future<Map<String, dynamic>?> toggleChallengeStatus(String id) async {
    final allChallenges = await getAllChallenges();
    final challengeIndex = allChallenges.indexWhere((challenge) => challenge['id'] == id);
    
    if (challengeIndex == -1) return null;
    
    allChallenges[challengeIndex]['isActive'] = !(allChallenges[challengeIndex]['isActive'] ?? false);
    allChallenges[challengeIndex]['updatedAt'] = DateTime.now().toIso8601String();
    
    await _saveChallenges(allChallenges);
    return allChallenges[challengeIndex];
  }

  // Get challenges by category
  static Future<List<Map<String, dynamic>>> getChallengesByCategory(String category) async {
    final allChallenges = await getAllChallenges();
    return allChallenges.where((challenge) => challenge['category'] == category).toList();
  }

  // USER CHALLENGE METHODS

  // Join a challenge
  static Future<Map<String, dynamic>> joinChallenge(String userId, String challengeId) async {
    final userChallengeData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'challengeId': challengeId,
      'status': 'IN_PROGRESS',
      'progressPercentage': 0,
      'joinedAt': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'notes': '',
      'proofUrl': '',
    };

    final userChallenges = await getUserChallenges(userId);
    
    // Check if user already joined this challenge
    final existingChallenge = userChallenges.firstWhere(
      (uc) => uc['challengeId'] == challengeId,
      orElse: () => <String, dynamic>{},
    );

    if (existingChallenge.isNotEmpty) {
      throw Exception('User already joined this challenge');
    }

    userChallenges.add(userChallengeData);
    await _saveUserChallenges(userId, userChallenges);
    
    return userChallengeData;
  }

  // Get user challenges
  static Future<List<Map<String, dynamic>>> getUserChallenges(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final userChallengesJson = prefs.getString('${_userChallengesKey}_$userId');
    
    if (userChallengesJson == null) {
      return [];
    }
    
    final List<dynamic> userChallengesList = json.decode(userChallengesJson);
    return userChallengesList.cast<Map<String, dynamic>>();
  }

  // Update challenge progress
  static Future<Map<String, dynamic>?> updateChallengeProgress(
    String userId, 
    String challengeId, 
    int progressPercentage, 
    {String notes = ''}
  ) async {
    final userChallenges = await getUserChallenges(userId);
    final challengeIndex = userChallenges.indexWhere(
      (uc) => uc['challengeId'] == challengeId,
    );

    if (challengeIndex == -1) return null;

    userChallenges[challengeIndex] = {
      ...userChallenges[challengeIndex],
      'progressPercentage': progressPercentage,
      'notes': notes,
      'lastUpdated': DateTime.now().toIso8601String(),
      'status': progressPercentage >= 100 ? 'COMPLETED' : 'IN_PROGRESS',
    };

    await _saveUserChallenges(userId, userChallenges);
    return userChallenges[challengeIndex];
  }

  // Complete challenge
  static Future<Map<String, dynamic>?> completeChallenge(
    String userId, 
    String challengeId, 
    {String proofUrl = ''}
  ) async {
    final userChallenges = await getUserChallenges(userId);
    final challengeIndex = userChallenges.indexWhere(
      (uc) => uc['challengeId'] == challengeId,
    );

    if (challengeIndex == -1) return null;

    userChallenges[challengeIndex] = {
      ...userChallenges[challengeIndex],
      'status': 'COMPLETED',
      'progressPercentage': 100,
      'completedAt': DateTime.now().toIso8601String(),
      'proofUrl': proofUrl,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await _saveUserChallenges(userId, userChallenges);
    return userChallenges[challengeIndex];
  }

  // Cancel challenge
  static Future<Map<String, dynamic>?> cancelChallenge(String userId, String challengeId) async {
    final userChallenges = await getUserChallenges(userId);
    final challengeIndex = userChallenges.indexWhere(
      (uc) => uc['challengeId'] == challengeId,
    );

    if (challengeIndex == -1) return null;

    userChallenges[challengeIndex] = {
      ...userChallenges[challengeIndex],
      'status': 'CANCELLED',
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await _saveUserChallenges(userId, userChallenges);
    return userChallenges[challengeIndex];
  }

  // Get user challenges by status
  static Future<List<Map<String, dynamic>>> getUserChallengesByStatus(String userId, String status) async {
    final userChallenges = await getUserChallenges(userId);
    return userChallenges.where((uc) => uc['status'] == status).toList();
  }

  // Get total points earned by user
  static Future<int> getTotalPointsEarned(String userId) async {
    final userChallenges = await getUserChallenges(userId);
    final completedChallenges = userChallenges.where((uc) => uc['status'] == 'COMPLETED').toList();
    
    int totalPoints = 0;
    for (final userChallenge in completedChallenges) {
      final challenge = await getChallengeById(userChallenge['challengeId']);
      if (challenge != null) {
        totalPoints += (challenge['pointsReward'] as int? ?? 0);
      }
    }
    
    return totalPoints;
  }

  // ANALYTICS METHODS

  // Get challenge statistics
  static Future<Map<String, dynamic>> getChallengeStatistics() async {
    final allChallenges = await getAllChallenges();
    final activeChallenges = allChallenges.where((c) => c['isActive'] == true).length;
    
    // Get all user challenges for all users
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_userChallengesKey)).toList();
    
    int totalParticipants = 0;
    int completedChallenges = 0;
    
    for (final key in allKeys) {
      final userChallengesJson = prefs.getString(key);
      if (userChallengesJson != null) {
        final List<dynamic> userChallenges = json.decode(userChallengesJson);
        totalParticipants += userChallenges.length;
        completedChallenges += userChallenges.where((uc) => uc['status'] == 'COMPLETED').length;
      }
    }
    
    return {
      'totalChallenges': allChallenges.length,
      'activeChallenges': activeChallenges,
      'totalParticipants': totalParticipants,
      'completedChallenges': completedChallenges,
    };
  }

  // Get challenge participant count
  static Future<int> getChallengeParticipantCount(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_userChallengesKey)).toList();
    
    int participantCount = 0;
    
    for (final key in allKeys) {
      final userChallengesJson = prefs.getString(key);
      if (userChallengesJson != null) {
        final List<dynamic> userChallenges = json.decode(userChallengesJson);
        final hasChallenge = userChallenges.any((uc) => uc['challengeId'] == challengeId);
        if (hasChallenge) participantCount++;
      }
    }
    
    return participantCount;
  }

  // PRIVATE HELPER METHODS

  static Future<void> _initializeSampleData() async {
    await _saveChallenges(_sampleChallenges);
  }

  static Future<void> _saveChallenges(List<Map<String, dynamic>> challenges) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_challengesKey, json.encode(challenges));
  }

  static Future<void> _saveUserChallenges(String userId, List<Map<String, dynamic>> userChallenges) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_userChallengesKey}_$userId', json.encode(userChallenges));
  }

  static Future<void> _removeUserChallengesForChallenge(String challengeId) async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_userChallengesKey)).toList();
    
    for (final key in allKeys) {
      final userChallengesJson = prefs.getString(key);
      if (userChallengesJson != null) {
        final List<dynamic> userChallenges = json.decode(userChallengesJson);
        userChallenges.removeWhere((uc) => uc['challengeId'] == challengeId);
        await prefs.setString(key, json.encode(userChallenges));
      }
    }
  }

  // Clear all data (for testing purposes)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_challengesKey);
    
    final allKeys = prefs.getKeys().where((key) => key.startsWith(_userChallengesKey)).toList();
    for (final key in allKeys) {
      await prefs.remove(key);
    }
  }
}