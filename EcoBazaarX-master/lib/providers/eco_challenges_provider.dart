import 'package:flutter/material.dart';
import 'dart:math';
import '../services/eco_challenges_service.dart';

class EcoChallenge {
  final String id;
  final String title;
  final String description;
  final String reward;
  final Color color;
  final IconData icon;
  final int targetValue;
  final String targetUnit;
  final DateTime startDate;
  final DateTime endDate;
  final String category;
  final bool isActive;
  final bool isCompleted;
  final int currentProgress;
  final double progressPercentage;

  EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
    required this.color,
    required this.icon,
    required this.targetValue,
    required this.targetUnit,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.isActive = true,
    this.isCompleted = false,
    this.currentProgress = 0,
    this.progressPercentage = 0.0,
  });

  EcoChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? reward,
    Color? color,
    IconData? icon,
    int? targetValue,
    String? targetUnit,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    bool? isActive,
    bool? isCompleted,
    int? currentProgress,
    double? progressPercentage,
  }) {
    return EcoChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      currentProgress: currentProgress ?? this.currentProgress,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }
}

class EcoChallengesProvider extends ChangeNotifier {
  static EcoChallengesProvider? _instance;
  
  factory EcoChallengesProvider() {
    _instance ??= EcoChallengesProvider._internal();
    return _instance!;
  }
  
  EcoChallengesProvider._internal() {
    print('EcoChallengesProvider initialized');
  }

  final List<EcoChallenge> _challenges = [];
  final List<UserChallengeData> _userChallenges = [];
  int _totalEcoPoints = 0;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<EcoChallenge> get activeChallenges => _challenges.where((c) => c.isActive && !c.isCompleted).toList();
  List<EcoChallenge> get completedChallenges => _challenges.where((c) => c.isCompleted).toList();
  List<EcoChallenge> get allChallenges => List.from(_challenges);
  List<UserChallengeData> get userChallenges => List.from(_userChallenges);
  List<UserChallengeData> get inProgressUserChallenges => _userChallenges.where((uc) => uc.status == 'IN_PROGRESS').toList();
  List<UserChallengeData> get completedUserChallenges => _userChallenges.where((uc) => uc.status == 'COMPLETED').toList();
  int get totalEcoPoints => _totalEcoPoints;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentUserId => _currentUserId;

  // Load challenges from Spring Boot backend
  Future<void> loadChallenges() async {
    _setLoading(true);
    _error = null;
    
    try {
      print('🔄 Loading eco challenges from backend...');
      final challengesData = await EcoChallengesService.getAllChallenges();
      _challenges.clear();
      
      for (final challengeData in challengesData) {
        final challenge = EcoChallenge(
          id: challengeData.id,
          title: challengeData.title,
          description: challengeData.description,
          reward: '${challengeData.points} Eco Points',
          color: _parseColor(challengeData.color),
          icon: _parseIcon(challengeData.icon),
          targetValue: challengeData.duration,
          targetUnit: 'days',
          startDate: challengeData.startDate ?? DateTime.now(),
          endDate: challengeData.endDate ?? DateTime.now().add(Duration(days: challengeData.duration)),
          category: challengeData.category,
          isActive: challengeData.isActive,
          isCompleted: false, // This will be updated when user progress is loaded
          currentProgress: 0, // This will be updated when user progress is loaded
          progressPercentage: 0.0, // This will be updated when user progress is loaded
        );
        _challenges.add(challenge);
      }
      
      print('✅ Challenges loaded from backend: ${_challenges.length}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading challenges: $e');
      _error = 'Failed to load challenges: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Initialize challenges (load from Spring Boot backend or create sample data)
  Future<void> initializeChallenges() async {
    await loadChallenges();
    
    // If no challenges exist, initialize sample data
    if (_challenges.isEmpty) {
      await EcoChallengesService.initializeSampleChallenges();
      await loadChallenges();
    }
  }

  // Load user progress from Spring Boot backend
  Future<void> loadUserProgress(String userId) async {
    try {
      print('🔄 Loading user challenges for user: $userId');
      _currentUserId = userId;
      
      // Load user's challenges from backend
      final userChallenges = await EcoChallengesService.getUserChallenges(userId);
      _userChallenges.clear();
      _userChallenges.addAll(userChallenges);
      
      // Update challenges with user progress
      for (final userChallenge in userChallenges) {
        final challengeIndex = _challenges.indexWhere((c) => c.id == userChallenge.challengeId);
        if (challengeIndex != -1) {
          final challenge = _challenges[challengeIndex];
          _challenges[challengeIndex] = challenge.copyWith(
            currentProgress: (userChallenge.progressPercentage * challenge.targetValue / 100).toInt(),
            progressPercentage: userChallenge.progressPercentage / 100,
            isCompleted: userChallenge.status == 'COMPLETED',
          );
        }
      }
      
      // Calculate total eco points from completed challenges
      _totalEcoPoints = userChallenges
          .where((uc) => uc.status == 'COMPLETED')
          .fold(0, (sum, uc) => sum + uc.pointsEarned.toInt());
      
      print('✅ Loaded ${userChallenges.length} user challenges, ${_totalEcoPoints} points');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user progress: $e');
    }
  }

  // Join a challenge
  Future<bool> joinChallenge(String challengeId) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      return false;
    }
    
    try {
      print('🎯 Joining challenge: $challengeId');
      final userChallenge = await EcoChallengesService.joinChallenge(_currentUserId!, challengeId);
      
      if (userChallenge != null) {
        _userChallenges.add(userChallenge);
        
        // Update challenge status
        final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
        if (challengeIndex != -1) {
          final challenge = _challenges[challengeIndex];
          _challenges[challengeIndex] = challenge.copyWith(
            currentProgress: 0,
            progressPercentage: 0.0,
            isCompleted: false,
          );
        }
        
        print('✅ Successfully joined challenge');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to join challenge';
        return false;
      }
    } catch (e) {
      print('❌ Error joining challenge: $e');
      _error = 'Failed to join challenge: ${e.toString()}';
      return false;
    }
  }

  // Update challenge progress
  Future<bool> updateChallengeProgress(String challengeId, double progressPercentage, {String? notes}) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      return false;
    }
    
    try {
      print('📈 Updating challenge progress: $challengeId to $progressPercentage%');
      final userChallenge = await EcoChallengesService.updateChallengeProgress(
        _currentUserId!,
        challengeId,
        progressPercentage,
        notes: notes,
      );
      
      if (userChallenge != null) {
        // Update user challenge in list
        final userChallengeIndex = _userChallenges.indexWhere((uc) => uc.challengeId == challengeId);
        if (userChallengeIndex != -1) {
          _userChallenges[userChallengeIndex] = userChallenge;
        }
        
        // Update challenge display
        final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
        if (challengeIndex != -1) {
          final challenge = _challenges[challengeIndex];
          _challenges[challengeIndex] = challenge.copyWith(
            currentProgress: (progressPercentage * challenge.targetValue / 100).toInt(),
            progressPercentage: progressPercentage / 100,
            isCompleted: userChallenge.status == 'COMPLETED',
          );
        }
        
        print('✅ Progress updated successfully');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update progress';
        return false;
      }
    } catch (e) {
      print('❌ Error updating progress: $e');
      _error = 'Failed to update progress: ${e.toString()}';
      return false;
    }
  }

  // Complete a challenge
  Future<bool> completeChallenge(String challengeId, {String? notes, String? proofUrl}) async {
    if (_currentUserId == null) {
      _error = 'User not authenticated';
      return false;
    }
    
    try {
      print('🏆 Completing challenge: $challengeId');
      final userChallenge = await EcoChallengesService.completeChallenge(
        _currentUserId!,
        challengeId,
        notes: notes,
        proofUrl: proofUrl,
      );
      
      if (userChallenge != null) {
        // Update user challenge in list
        final userChallengeIndex = _userChallenges.indexWhere((uc) => uc.challengeId == challengeId);
        if (userChallengeIndex != -1) {
          _userChallenges[userChallengeIndex] = userChallenge;
        }
        
        // Update challenge display
        final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
        if (challengeIndex != -1) {
          final challenge = _challenges[challengeIndex];
          _challenges[challengeIndex] = challenge.copyWith(
            currentProgress: challenge.targetValue,
            progressPercentage: 1.0,
            isCompleted: true,
          );
        }
        
        // Update total points
        _totalEcoPoints += userChallenge.pointsEarned.toInt();
        
        print('✅ Challenge completed! Points earned: ${userChallenge.pointsEarned}');
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to complete challenge';
        return false;
      }
    } catch (e) {
      print('❌ Error completing challenge: $e');
      _error = 'Failed to complete challenge: ${e.toString()}';
      return false;
    }
  }

  void resetChallenge(String challengeId) {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      _challenges[challengeIndex] = _challenges[challengeIndex].copyWith(
        currentProgress: 0,
        progressPercentage: 0.0,
        isCompleted: false,
      );
      notifyListeners();
    }
  }

  void addCustomChallenge(EcoChallenge challenge) {
    print('Adding custom challenge: ${challenge.title}');
    _challenges.add(challenge);
    print('Total challenges now: ${_challenges.length}');
    print('Active challenges: ${activeChallenges.length}');
    notifyListeners();
  }

  List<EcoChallenge> getChallengesByCategory(String category) {
    return _challenges.where((c) => c.category == category).toList();
  }

  List<String> get categories {
    return _challenges.map((c) => c.category).toSet().toList();
  }

  int getCompletedChallengesCount() {
    return completedChallenges.length;
  }

  int getActiveChallengesCount() {
    return activeChallenges.length;
  }

  double getOverallProgress() {
    if (_challenges.isEmpty) return 0.0;
    final totalProgress = _challenges.fold(0.0, (sum, challenge) => sum + challenge.progressPercentage);
    return totalProgress / _challenges.length;
  }

  // Simulate daily progress updates
  void simulateDailyProgress(String userId) {
    for (final challenge in activeChallenges) {
      if (Random().nextDouble() < 0.3) { // 30% chance of progress
        final progress = Random().nextInt(3) + 1; // 1-3 progress points
        updateProgress(challenge.id, progress, userId);
      }
    }
  }

  // Load sample progress for demonstration
  void loadSampleProgress(String userId) {
    updateProgress('zero_waste_week', 4, userId);
    updateProgress('carbon_footprint_reduction', 12, userId);
    updateProgress('local_shopping', 2, userId);
    updateProgress('water_conservation', 350, userId);
    updateProgress('energy_saving', 8, userId);
    updateProgress('plant_based_meals', 6, userId);
    updateProgress('plastic_free_living', 8, userId);
    updateProgress('eco_transport', 12, userId);
  }

  // Force initialize challenges (for debugging)
  void forceInitialize() {
    if (_challenges.isEmpty) {
      print('Force initializing challenges...');
      initializeChallenges();
      print('Challenges initialized: ${_challenges.length}');
    }
  }

  // Create a new challenge
  Future<bool> createChallenge({
    required String userId,
    required String title,
    required String description,
    required String reward,
    required Color color,
    required IconData icon,
    required int targetValue,
    required String targetUnit,
    required String category,
    required int durationDays,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await EcoChallengesService.createChallenge(
        userId: userId,
        title: title,
        description: description,
        reward: reward,
        color: color,
        icon: icon,
        targetValue: targetValue,
        targetUnit: targetUnit,
        category: category,
        durationDays: durationDays,
      );
      
      if (result['success']) {
        await loadChallenges();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to create challenge: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update challenge progress
  Future<bool> updateProgress(String challengeId, int progress, String userId) async {
    try {
      final result = await EcoChallengesService.updateChallengeProgressLegacy(
        userId: userId,
        challengeId: challengeId,
        progressValue: progress,
      );
      
      if (result != null && result['success']) {
        await loadUserProgress(userId);
        return true;
      } else {
        _setError(result != null ? result['message'] : 'Failed to update progress');
        return false;
      }
    } catch (e) {
      _setError('Failed to update progress: ${e.toString()}');
      return false;
    }
  }

  // Delete a challenge
  Future<bool> deleteChallenge(String challengeId, String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await EcoChallengesService.deleteChallenge(
        challengeId: challengeId,
        userId: userId,
      );
      
      if (result['success']) {
        await loadChallenges();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to delete challenge: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }


  IconData _parseIcon(String iconName) {
    final iconMap = {
      'recycling_rounded': Icons.recycling_rounded,
      'eco_rounded': Icons.eco_rounded,
      'store_rounded': Icons.store_rounded,
      'water_drop_rounded': Icons.water_drop_rounded,
      'electric_bolt_rounded': Icons.electric_bolt_rounded,
      'restaurant_rounded': Icons.restaurant_rounded,
      'no_drinks_rounded': Icons.no_drinks_rounded,
      'directions_bike_rounded': Icons.directions_bike_rounded,
      'local_florist_rounded': Icons.local_florist_rounded,
      'park_rounded': Icons.park_rounded,
      'forest_rounded': Icons.forest_rounded,
      'local_drink_rounded': Icons.local_drink_rounded,
      'directions_bus_rounded': Icons.directions_bus_rounded,
      'directions_walk_rounded': Icons.directions_walk_rounded,
      'lightbulb_rounded': Icons.lightbulb_rounded,
      'solar_power_rounded': Icons.solar_power_rounded,
      'brush_rounded': Icons.brush_rounded,
      'spa_rounded': Icons.spa_rounded,
      'book_rounded': Icons.book_rounded,
      'face_rounded': Icons.face_rounded,
      'fitness_center_rounded': Icons.fitness_center_rounded,
      'local_cafe_rounded': Icons.local_cafe_rounded,
    };
    
    return iconMap[iconName] ?? Icons.eco_rounded;
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present and parse hex color
      String hexColor = colorString.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor'; // Add alpha channel
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      print('Error parsing color: $colorString, using default');
      return const Color(0xFF4CAF50); // Default green color
    }
  }

  // User Challenges Methods
  
  // Set current user ID
  void setCurrentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }

  // Load user challenges from backend
  Future<void> loadUserChallenges(String userId) async {
    if (_isLoading) return;
    
    _setLoading(true);
    _error = null;
    
    try {
      print('🔄 Loading user challenges for user: $userId');
      final userChallenges = await EcoChallengesService.getUserChallenges(userId);
      
      _userChallenges.clear();
      _userChallenges.addAll(userChallenges);
      
      // Calculate total points earned
      _totalEcoPoints = _userChallenges
          .where((uc) => uc.status == 'COMPLETED')
          .fold(0, (sum, uc) => sum + uc.pointsEarned);
      
      print('✅ Loaded ${_userChallenges.length} user challenges');
      print('💰 Total eco points: $_totalEcoPoints');
      
    } catch (e) {
      print('❌ Error loading user challenges: $e');
      _setError('Failed to load user challenges: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }



  // Quit a challenge
  Future<bool> quitChallenge(String userId, String challengeId) async {
    try {
      _setLoading(true);
      print('🔄 Quitting challenge $challengeId for user $userId');
      
      final success = await EcoChallengesService.quitChallenge(userId, challengeId);
      
      if (success) {
        // Remove from local list
        _userChallenges.removeWhere((uc) => 
            uc.userId == userId && uc.challengeId == challengeId);
        notifyListeners();
        print('✅ Successfully quit challenge');
        return true;
      } else {
        _setError('Failed to quit challenge');
        return false;
      }
    } catch (e) {
      print('❌ Error quitting challenge: $e');
      _setError('Failed to quit challenge: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user's status for a specific challenge
  UserChallengeData? getUserChallengeStatus(String userId, String challengeId) {
    try {
      return _userChallenges.firstWhere((uc) => 
          uc.userId == userId && uc.challengeId == challengeId);
    } catch (e) {
      return null;
    }
  }

  // Check if user has joined a challenge
  bool hasUserJoinedChallenge(String userId, String challengeId) {
    return _userChallenges.any((uc) => 
        uc.userId == userId && uc.challengeId == challengeId);
  }
}