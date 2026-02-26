import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Quick Backend Integration Tester
/// 
/// Run this to verify backend connectivity
/// Usage: Call testBackendIntegration() from your main.dart or a debug screen

class BackendIntegrationTester {
  /// Test all backend endpoints
  static Future<void> testBackendIntegration() async {
    print('\n🧪 ═══════════════════════════════════════════════════════');
    print('🧪 BACKEND INTEGRATION TEST - EcoBazaarX');
    print('🧪 ═══════════════════════════════════════════════════════\n');
    
    // Print configuration
    ApiConfig.printConfiguration();
    print('\n');
    
    // Test each endpoint
    await _testEcoChallenges();
    await _testEcoDiscounts();
    await _testLeaderboard();
    await _testCarbonFootprint();
    
    print('\n🧪 ═══════════════════════════════════════════════════════');
    print('🧪 TEST COMPLETE');
    print('🧪 ═══════════════════════════════════════════════════════\n');
  }
  
  /// Test Eco Challenges API
  static Future<void> _testEcoChallenges() async {
    print('1️⃣ Testing Eco Challenges API...');
    print('───────────────────────────────────────────────────────');
    
    try {
      // Test 1: Get active challenges
      final response = await http.get(
        Uri.parse(ApiConfig.ECO_CHALLENGES_ACTIVE),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Active Challenges');
        print('   Status Code: ${response.statusCode}');
        print('   Challenges Found: ${data['challenges']?.length ?? 0}');
        if (data['challenges'] != null && data['challenges'].isNotEmpty) {
          print('   Sample Challenge: ${data['challenges'][0]['title']}');
        }
      } else {
        print('❌ FAILED: Status ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
      print('   Is backend running on ${ApiConfig.BASE_URL}?');
    }
    print('');
  }
  
  /// Test Eco Discounts API
  static Future<void> _testEcoDiscounts() async {
    print('2️⃣ Testing Eco Discounts API...');
    print('───────────────────────────────────────────────────────');
    
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.ECO_DISCOUNTS_ACTIVE),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Active Discounts');
        print('   Status Code: ${response.statusCode}');
        print('   Discounts Found: ${data['discounts']?.length ?? 0}');
        if (data['discounts'] != null && data['discounts'].isNotEmpty) {
          print('   Sample Discount: ${data['discounts'][0]['code']} - ${data['discounts'][0]['title']}');
        }
      } else {
        print('❌ FAILED: Status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }
  
  /// Test Leaderboard API
  static Future<void> _testLeaderboard() async {
    print('3️⃣ Testing Leaderboard API...');
    print('───────────────────────────────────────────────────────');
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.LEADERBOARD_GLOBAL}?page=0&size=10'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Global Leaderboard');
        print('   Status Code: ${response.statusCode}');
        print('   Total Users: ${data['totalElements'] ?? 0}');
        print('   Leaderboard Size: ${data['leaderboard']?.length ?? 0}');
      } else {
        print('❌ FAILED: Status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }
  
  /// Test Carbon Footprint API
  static Future<void> _testCarbonFootprint() async {
    print('4️⃣ Testing Carbon Footprint API...');
    print('───────────────────────────────────────────────────────');
    
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.CARBON_HEALTH),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Carbon Footprint Service');
        print('   Status Code: ${response.statusCode}');
        print('   Service Status: ${data['status']}');
        print('   Service Name: ${data['service']}');
        print('   Methodology: ${data['methodology']}');
      } else {
        print('❌ FAILED: Status ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }
  
  /// Test sample carbon calculation
  static Future<void> testCarbonCalculation() async {
    print('🧮 Testing Carbon Footprint Calculation...');
    print('───────────────────────────────────────────────────────');
    
    try {
      final productData = {
        'productName': 'Test Organic Cotton T-Shirt',
        'category': 'Clothing',
        'weight': 0.3,
        'material': 'organic_cotton',
        'manufacturingType': 'eco_friendly',
        'transportationDistance': 150.0,
        'transportationType': 'truck_local',
        'packagingType': 'biodegradable_packaging',
        'isRecycled': false,
        'isOrganic': true,
        'userId': 'test_user_123',
      };
      
      final response = await http.post(
        Uri.parse(ApiConfig.CARBON_CALCULATE),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(productData),
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ SUCCESS: Carbon Calculation');
        print('   Product: ${data['productName']}');
        print('   Total Footprint: ${data['totalCarbonFootprint']} kg CO₂e');
        print('   Carbon Savings: ${data['carbonSavings']} kg CO₂e');
        print('   Eco Rating: ${data['ecoRating']}');
        print('   Trees Equivalent: ${data['equivalentImpacts']['trees_planted']}');
      } else {
        print('❌ FAILED: Status ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ ERROR: $e');
    }
    print('');
  }
  
  /// Initialize backend sample data
  static Future<void> initializeBackendData() async {
    print('🚀 Initializing Backend Sample Data...');
    print('───────────────────────────────────────────────────────');
    
    // Initialize Eco Challenges
    try {
      final response1 = await http.post(
        Uri.parse(ApiConfig.ECO_CHALLENGES_INITIALIZE),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response1.statusCode == 200) {
        print('✅ Eco Challenges sample data initialized');
      } else {
        print('⚠️ Eco Challenges: ${response1.body}');
      }
    } catch (e) {
      print('❌ Eco Challenges initialization failed: $e');
    }
    
    // Initialize Eco Discounts
    try {
      final response2 = await http.post(
        Uri.parse(ApiConfig.ECO_DISCOUNTS_INITIALIZE),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response2.statusCode == 200) {
        print('✅ Eco Discounts sample data initialized');
      } else {
        print('⚠️ Eco Discounts: ${response2.body}');
      }
    } catch (e) {
      print('❌ Eco Discounts initialization failed: $e');
    }
    
    // Initialize Emission Factors
    try {
      final response3 = await http.post(
        Uri.parse(ApiConfig.CARBON_INITIALIZE),
        headers: ApiConfig.defaultHeaders,
      ).timeout(ApiConfig.REQUEST_TIMEOUT);
      
      if (response3.statusCode == 200) {
        print('✅ Emission Factors initialized');
      } else {
        print('⚠️ Emission Factors: ${response3.body}');
      }
    } catch (e) {
      print('❌ Emission Factors initialization failed: $e');
    }
    
    print('\n✅ Backend initialization complete!');
  }
  
  /// Create a test widget to show results in UI
  static Widget buildTestWidget() {
    return Scaffold(
      appBar: AppBar(
        title: Text('🧪 Backend Integration Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Backend Integration Tester',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: () => testBackendIntegration(),
              icon: Icon(Icons.play_arrow),
              label: Text('Run All Tests'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => testCarbonCalculation(),
              icon: Icon(Icons.calculate),
              label: Text('Test Carbon Calculation'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            
            SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: () => initializeBackendData(),
              icon: Icon(Icons.data_array),
              label: Text('Initialize Sample Data'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                backgroundColor: Colors.orange,
              ),
            ),
            
            SizedBox(height: 32),
            
            Text(
              'Check console for results',
              style: TextStyle(color: Colors.grey),
            ),
            
            SizedBox(height: 16),
            
            Text(
              'Backend: ${ApiConfig.BASE_URL}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
