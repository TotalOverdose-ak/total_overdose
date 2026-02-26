import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart' as service;

class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? profilePicture;
  final int rank;
  final int totalEcoPoints;
  final double totalCarbonSaved;
  final int completedChallenges;
  final int totalOrders;
  final String? city;
  final String? country;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.profilePicture,
    required this.rank,
    required this.totalEcoPoints,
    required this.totalCarbonSaved,
    required this.completedChallenges,
    required this.totalOrders,
    this.city,
    this.country,
  });

  factory LeaderboardEntry.fromService(service.LeaderboardEntry serviceEntry) {
    return LeaderboardEntry(
      userId: serviceEntry.userId,
      userName: serviceEntry.userName,
      profilePicture: serviceEntry.profilePicture,
      rank: serviceEntry.rank,
      totalEcoPoints: serviceEntry.totalEcoPoints,
      totalCarbonSaved: serviceEntry.totalCarbonSaved,
      completedChallenges: serviceEntry.completedChallenges,
      totalOrders: serviceEntry.totalOrders,
      city: serviceEntry.city,
      country: serviceEntry.country,
    );
  }
}

class LeaderboardProvider extends ChangeNotifier {
  final List<LeaderboardEntry> _globalLeaderboard = [];
  final List<LeaderboardEntry> _ecoPointsLeaderboard = [];
  final List<LeaderboardEntry> _carbonSavedLeaderboard = [];
  final List<LeaderboardEntry> _challengesLeaderboard = [];
  final List<LeaderboardEntry> _monthlyLeaderboard = [];
  
  Map<String, dynamic> _userPosition = {};
  bool _isLoading = false;
  String? _error;
  String _currentTab = 'global'; // global, ecoPoints, carbonSaved, challenges, monthly

  List<LeaderboardEntry> get currentLeaderboard {
    switch (_currentTab) {
      case 'ecoPoints':
        return _ecoPointsLeaderboard;
      case 'carbonSaved':
        return _carbonSavedLeaderboard;
      case 'challenges':
        return _challengesLeaderboard;
      case 'monthly':
        return _monthlyLeaderboard;
      default:
        return _globalLeaderboard;
    }
  }

  List<LeaderboardEntry> get globalLeaderboard => List.from(_globalLeaderboard);
  List<LeaderboardEntry> get ecoPointsLeaderboard => List.from(_ecoPointsLeaderboard);
  List<LeaderboardEntry> get carbonSavedLeaderboard => List.from(_carbonSavedLeaderboard);
  List<LeaderboardEntry> get challengesLeaderboard => List.from(_challengesLeaderboard);
  List<LeaderboardEntry> get monthlyLeaderboard => List.from(_monthlyLeaderboard);
  Map<String, dynamic> get userPosition => Map.from(_userPosition);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentTab => _currentTab;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCurrentTab(String tab) {
    _currentTab = tab;
    notifyListeners();
  }

  // Load global leaderboard from backend
  Future<void> loadGlobalLeaderboard({int limit = 100}) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading global leaderboard from backend...');
      final entries = await service.LeaderboardService.getGlobalLeaderboard(limit: limit);
      
      _globalLeaderboard.clear();
      _globalLeaderboard.addAll(entries.map((e) => LeaderboardEntry.fromService(e)));

      print('✅ Loaded ${_globalLeaderboard.length} entries in global leaderboard');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading global leaderboard: $e');
      _error = 'Failed to load global leaderboard: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load eco points leaderboard from backend
  Future<void> loadEcoPointsLeaderboard({int limit = 100}) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading eco points leaderboard from backend...');
      final entries = await service.LeaderboardService.getLeaderboardByEcoPoints(limit: limit);
      
      _ecoPointsLeaderboard.clear();
      _ecoPointsLeaderboard.addAll(entries.map((e) => LeaderboardEntry.fromService(e)));

      print('✅ Loaded ${_ecoPointsLeaderboard.length} entries in eco points leaderboard');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading eco points leaderboard: $e');
      _error = 'Failed to load eco points leaderboard: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load carbon saved leaderboard from backend
  Future<void> loadCarbonSavedLeaderboard({int limit = 100}) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading carbon saved leaderboard from backend...');
      final entries = await service.LeaderboardService.getLeaderboardByCarbonSaved(limit: limit);
      
      _carbonSavedLeaderboard.clear();
      _carbonSavedLeaderboard.addAll(entries.map((e) => LeaderboardEntry.fromService(e)));

      print('✅ Loaded ${_carbonSavedLeaderboard.length} entries in carbon saved leaderboard');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading carbon saved leaderboard: $e');
      _error = 'Failed to load carbon saved leaderboard: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load challenges leaderboard from backend
  Future<void> loadChallengesLeaderboard({int limit = 100}) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading challenges leaderboard from backend...');
      final entries = await service.LeaderboardService.getLeaderboardByChallenges(limit: limit);
      
      _challengesLeaderboard.clear();
      _challengesLeaderboard.addAll(entries.map((e) => LeaderboardEntry.fromService(e)));

      print('✅ Loaded ${_challengesLeaderboard.length} entries in challenges leaderboard');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading challenges leaderboard: $e');
      _error = 'Failed to load challenges leaderboard: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load monthly leaderboard from backend
  Future<void> loadMonthlyLeaderboard({int limit = 100}) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading monthly leaderboard from backend...');
      final entries = await service.LeaderboardService.getMonthlyLeaderboard(limit: limit);
      
      _monthlyLeaderboard.clear();
      _monthlyLeaderboard.addAll(entries.map((e) => LeaderboardEntry.fromService(e)));

      print('✅ Loaded ${_monthlyLeaderboard.length} entries in monthly leaderboard');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading monthly leaderboard: $e');
      _error = 'Failed to load monthly leaderboard: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load user's position in leaderboard
  Future<void> loadUserPosition(String userId) async {
    try {
      print('🔄 Loading user position from backend...');
      _userPosition = await service.LeaderboardService.getUserPosition(userId);
      
      print('✅ Loaded user position: Rank ${_userPosition['rank']}');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading user position: $e');
      _userPosition = {
        'rank': 0,
        'totalEcoPoints': 0,
        'totalCarbonSaved': 0.0,
        'completedChallenges': 0,
      };
    }
  }

  // Load all leaderboards
  Future<void> loadAllLeaderboards({int limit = 100}) async {
    await Future.wait([
      loadGlobalLeaderboard(limit: limit),
      loadEcoPointsLeaderboard(limit: limit),
      loadCarbonSavedLeaderboard(limit: limit),
      loadChallengesLeaderboard(limit: limit),
      loadMonthlyLeaderboard(limit: limit),
    ]);
  }

  // Initialize sample leaderboard data
  Future<void> initializeSampleData() async {
    try {
      print('🔄 Initializing sample leaderboard data...');
      await service.LeaderboardService.initializeSampleData();
      await loadAllLeaderboards();
      print('✅ Sample leaderboard data initialized');
    } catch (e) {
      print('❌ Error initializing sample leaderboard data: $e');
    }
  }

  // Refresh current leaderboard
  Future<void> refreshCurrentLeaderboard({int limit = 100}) async {
    switch (_currentTab) {
      case 'ecoPoints':
        await loadEcoPointsLeaderboard(limit: limit);
        break;
      case 'carbonSaved':
        await loadCarbonSavedLeaderboard(limit: limit);
        break;
      case 'challenges':
        await loadChallengesLeaderboard(limit: limit);
        break;
      case 'monthly':
        await loadMonthlyLeaderboard(limit: limit);
        break;
      default:
        await loadGlobalLeaderboard(limit: limit);
    }
  }

  // Clear all data
  void clearAllData() {
    _globalLeaderboard.clear();
    _ecoPointsLeaderboard.clear();
    _carbonSavedLeaderboard.clear();
    _challengesLeaderboard.clear();
    _monthlyLeaderboard.clear();
    _userPosition = {};
    _error = null;
    notifyListeners();
  }
}
