import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/eco_challenges_provider.dart';
import '../../providers/spring_auth_provider.dart';
import '../../services/eco_challenges_service.dart';
import 'add_challenge_screen.dart';

class EcoChallengesScreen extends StatefulWidget {
  const EcoChallengesScreen({super.key});

  @override
  State<EcoChallengesScreen> createState() => _EcoChallengesScreenState();
}

class _EcoChallengesScreenState extends State<EcoChallengesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChallenges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    
    await challengesProvider.initializeChallenges();
    
    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await challengesProvider.loadUserProgress(authProvider.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Eco Challenges',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _loadChallenges(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFB5C7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                color: Color(0xFF22223B),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<EcoChallengesProvider>(
        builder: (context, challengesProvider, child) {
          if (challengesProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
              ),
            );
          }

          if (challengesProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading challenges',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    challengesProvider.error!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadChallenges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5C7F7),
                      foregroundColor: const Color(0xFF22223B),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Retry',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Stats Cards
              Container(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Active',
                        '${challengesProvider.activeChallenges.length}',
                        Icons.play_circle_rounded,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Completed',
                        '${challengesProvider.completedChallenges.length}',
                        Icons.check_circle_rounded,
                        const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Points',
                        '${challengesProvider.totalEcoPoints}',
                        Icons.stars_rounded,
                        const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
              ),

              // Category Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Filter by:',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF22223B),
                            ),
                            items: ['All', ...challengesProvider.categories].map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFB5C7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: const Color(0xFF22223B),
                  unselectedLabelColor: Colors.grey[600],
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Active'),
                    Tab(text: 'Completed'),
                    Tab(text: 'All'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tab Bar View
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildChallengesList(
                      _getFilteredChallenges(challengesProvider.activeChallenges),
                      'No active challenges',
                    ),
                    _buildChallengesList(
                      _getFilteredChallenges(challengesProvider.completedChallenges),
                      'No completed challenges',
                    ),
                    _buildChallengesList(
                      _getFilteredChallenges(challengesProvider.allChallenges),
                      'No challenges available',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddChallengeScreen(),
            ),
          ).then((_) => _loadChallenges());
        },
        backgroundColor: const Color(0xFFB5C7F7),
        foregroundColor: const Color(0xFF22223B),
        elevation: 0,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Challenge',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<EcoChallenge> _getFilteredChallenges(List<EcoChallenge> challenges) {
    if (_selectedCategory == 'All') {
      return challenges;
    }
    return challenges.where((challenge) => challenge.category == _selectedCategory).toList();
  }

  Widget _buildChallengesList(List<EcoChallenge> challenges, String emptyMessage) {
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your eco journey today!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return _buildChallengeCard(challenge);
      },
    );
  }

  Widget _buildChallengeCard(EcoChallenge challenge) {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    
    // Check user challenge status first
    bool hasJoined = false;
    UserChallengeData? userChallenge;
    if (authProvider.userId != null) {
      hasJoined = challengesProvider.hasUserJoinedChallenge(authProvider.userId!, challenge.id);
      userChallenge = challengesProvider.getUserChallengeStatus(authProvider.userId!, challenge.id);
    }
    
    // Calculate progress based on user challenge or default challenge data
    final progressPercentage = (userChallenge?.progressPercentage ?? 0.0).clamp(0.0, 1.0);
    final isCompleted = userChallenge?.status == 'COMPLETED' || challenge.isCompleted;
    final daysLeft = challenge.endDate.difference(DateTime.now()).inDays;


    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: challenge.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  challenge.icon,
                  color: challenge.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (userChallenge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: userChallenge.status == 'COMPLETED' 
                        ? const Color(0xFF4CAF50)
                        : userChallenge.status == 'IN_PROGRESS'
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFFF9800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    userChallenge.status == 'COMPLETED' 
                        ? 'Completed'
                        : userChallenge.status == 'IN_PROGRESS'
                            ? 'In Progress'
                            : userChallenge.status,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                )
              else if (hasJoined)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Joined',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            challenge.description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userChallenge != null 
                          ? '${(userChallenge.progressPercentage * challenge.targetValue / 100).round()}/${challenge.targetValue} ${challenge.targetUnit}'
                          : '0/${challenge.targetValue} ${challenge.targetUnit}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Reward',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      challenge.reward,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              isCompleted ? const Color(0xFF4CAF50) : challenge.color,
            ),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercentage * 100).toInt()}% Complete',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              if (!isCompleted && daysLeft > 0)
                Text(
                  '$daysLeft days left',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: daysLeft <= 3 ? Colors.red : Colors.grey[600],
                    fontWeight: daysLeft <= 3 ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (userChallenge == null) {
                    _showJoinChallengeDialog(challenge);
                  } else if (userChallenge.status == 'IN_PROGRESS') {
                    _updateProgress(challenge);
                  } else if (userChallenge.status == 'COMPLETED') {
                    // Already completed - no action needed
                  } else {
                    _showJoinChallengeDialog(challenge);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: userChallenge == null 
                      ? const Color(0xFF4CAF50)
                      : userChallenge.status == 'COMPLETED'
                          ? Colors.grey
                          : challenge.color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  userChallenge == null 
                      ? 'Join Challenge'
                      : userChallenge.status == 'IN_PROGRESS'
                          ? 'Update Progress'
                          : userChallenge.status == 'COMPLETED'
                              ? 'Completed'
                              : 'Join Challenge',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _updateProgress(EcoChallenge challenge) {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    
    // Check if user has joined this challenge
    if (authProvider.userId != null) {
      final hasJoined = challengesProvider.hasUserJoinedChallenge(authProvider.userId!, challenge.id);
      if (!hasJoined) {
        _showJoinChallengeDialog(challenge);
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Progress',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update progress for "${challenge.title}"',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Progress Percentage',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [10, 25, 50, 75, 100].map((value) {
                return ElevatedButton(
                  onPressed: () => _submitProgressPercentage(challenge, value.toDouble()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: challenge.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    '$value%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinChallengeDialog(EcoChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Join Challenge',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              challenge.icon,
              size: 48,
              color: challenge.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Join "${challenge.title}"?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: challenge.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars_rounded, color: challenge.color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    challenge.reward,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: challenge.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => _joinChallenge(challenge),
            style: ElevatedButton.styleFrom(
              backgroundColor: challenge.color,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Join Challenge',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _joinChallenge(EcoChallenge challenge) async {
    Navigator.pop(context);
    
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    
    if (authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to join challenges',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await challengesProvider.joinChallenge(challenge.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully joined "${challenge.title}"!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            challengesProvider.error ?? 'Failed to join challenge',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitProgressPercentage(EcoChallenge challenge, double progressPercentage) async {
    Navigator.pop(context);
    
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    
    if (authProvider.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please login to update progress',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String notes = 'Progress updated to $progressPercentage% via mobile app';
    if (progressPercentage >= 100) {
      notes = 'Challenge completed! 🎉 Great job on finishing "${challenge.title}"!';
    }

    final success = await challengesProvider.updateChallengeProgress(
      challenge.id, 
      progressPercentage,
      notes: notes,
    );
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            progressPercentage >= 100 
                ? 'Congratulations! Challenge completed! 🎉' 
                : 'Progress updated to $progressPercentage%',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: progressPercentage >= 100 ? Colors.green : Colors.blue,
        ),
      );
      
      // If completed, show completion dialog
      if (progressPercentage >= 100) {
        _showCompletionDialog(challenge);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            challengesProvider.error ?? 'Failed to update progress',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCompletionDialog(EcoChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🎉 Congratulations!',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'You completed "${challenge.title}"!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You earned ${challenge.reward}!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Awesome!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }


}
