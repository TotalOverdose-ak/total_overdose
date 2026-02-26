import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

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
  final DateTime? lastActivityDate;

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
    this.lastActivityDate,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['userId']?.toString() ?? '',
      userName: map['userName']?.toString() ?? 'Anonymous',
      profilePicture: map['profilePicture']?.toString(),
      rank: map['rank']?.toInt() ?? 0,
      totalEcoPoints: map['totalEcoPoints']?.toInt() ?? 0,
      totalCarbonSaved: map['totalCarbonSaved']?.toDouble() ?? 0.0,
      completedChallenges: map['completedChallenges']?.toInt() ?? 0,
      totalOrders: map['totalOrders']?.toInt() ?? 0,
      city: map['city']?.toString(),
      country: map['country']?.toString(),
      lastActivityDate: map['lastActivityDate'] != null 
          ? DateTime.tryParse(map['lastActivityDate']) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'profilePicture': profilePicture,
      'rank': rank,
      'totalEcoPoints': totalEcoPoints,
      'totalCarbonSaved': totalCarbonSaved,
      'completedChallenges': completedChallenges,
      'totalOrders': totalOrders,
      'city': city,
      'country': country,
      'lastActivityDate': lastActivityDate?.toIso8601String(),
    };
  }
}

class LeaderboardService {
  static const String baseUrl = '${FirebaseConfig.baseApiUrl}/api/leaderboard';

  // Get global leaderboard (top users worldwide)
  static Future<List<LeaderboardEntry>> getGlobalLeaderboard({int limit = 100}) async {
    try {
      print('🔄 Fetching global leaderboard from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/global?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in global leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch global leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching global leaderboard: $e');
      return [];
    }
  }

  // Get leaderboard by eco points
  static Future<List<LeaderboardEntry>> getLeaderboardByEcoPoints({int limit = 100}) async {
    try {
      print('🔄 Fetching leaderboard by eco points from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/by-eco-points?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in eco points leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch eco points leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching eco points leaderboard: $e');
      return [];
    }
  }

  // Get leaderboard by carbon saved
  static Future<List<LeaderboardEntry>> getLeaderboardByCarbonSaved({int limit = 100}) async {
    try {
      print('🔄 Fetching leaderboard by carbon saved from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/by-carbon-saved?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in carbon saved leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch carbon saved leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching carbon saved leaderboard: $e');
      return [];
    }
  }

  // Get leaderboard by completed challenges
  static Future<List<LeaderboardEntry>> getLeaderboardByChallenges({int limit = 100}) async {
    try {
      print('🔄 Fetching leaderboard by challenges from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/by-challenges?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in challenges leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch challenges leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching challenges leaderboard: $e');
      return [];
    }
  }

  // Get user's position in leaderboard
  static Future<Map<String, dynamic>> getUserPosition(String userId) async {
    try {
      print('🔄 Fetching user position from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/position'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Loaded user position: Rank ${data['rank']}');
        return data;
      } else {
        print('❌ Failed to fetch user position: ${response.statusCode}');
        return _getDefaultUserPosition();
      }
    } catch (e) {
      print('❌ Error fetching user position: $e');
      return _getDefaultUserPosition();
    }
  }

  // Get leaderboard by region (city/country)
  static Future<List<LeaderboardEntry>> getLeaderboardByRegion({
    String? city,
    String? country,
    int limit = 100,
  }) async {
    try {
      print('🔄 Fetching regional leaderboard from backend...');
      
      String url = '$baseUrl/by-region?limit=$limit';
      if (city != null) url += '&city=$city';
      if (country != null) url += '&country=$country';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in regional leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch regional leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching regional leaderboard: $e');
      return [];
    }
  }

  // Get monthly leaderboard
  static Future<List<LeaderboardEntry>> getMonthlyLeaderboard({int limit = 100}) async {
    try {
      print('🔄 Fetching monthly leaderboard from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/monthly?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final leaderboard = data.map((json) => LeaderboardEntry.fromMap(json)).toList();
        print('✅ Loaded ${leaderboard.length} entries in monthly leaderboard');
        return leaderboard;
      } else {
        print('❌ Failed to fetch monthly leaderboard: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching monthly leaderboard: $e');
      return [];
    }
  }

  // Initialize sample leaderboard data
  static Future<bool> initializeSampleData() async {
    try {
      print('🔄 Initializing sample leaderboard data in backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/initialize-sample-data'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Sample leaderboard data initialized successfully');
        return true;
      } else {
        print('❌ Failed to initialize sample leaderboard data: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing sample leaderboard data: $e');
      return false;
    }
  }

  // Default user position when backend is unavailable
  static Map<String, dynamic> _getDefaultUserPosition() {
    return {
      'rank': 0,
      'totalEcoPoints': 0,
      'totalCarbonSaved': 0.0,
      'completedChallenges': 0,
      'totalUsers': 0,
      'percentile': 0.0,
    };
  }
}
