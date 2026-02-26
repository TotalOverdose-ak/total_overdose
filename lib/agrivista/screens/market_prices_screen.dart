import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/mandi_provider.dart';
import '../providers/language_provider.dart';
import '../services/mandi_ai_service.dart';
import '../theme/app_colors.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return Consumer<MandiProvider>(
      builder: (context, mandi, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E7D32),
            elevation: 0,
            title: Text(
              '💹 ${lang.tr('mandi_hub')}',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            actions: [
              // Language selector
              PopupMenuButton<String>(
                icon: const Icon(Icons.translate, color: Colors.white),
                tooltip: 'Language',
                onSelected: (lang) => mandi.setChatLanguage(lang),
                itemBuilder: (_) => MandiAIService.supportedLanguages.keys
                    .map(
                      (lang) => PopupMenuItem(
                        value: lang,
                        child: Row(
                          children: [
                            if (mandi.chatLanguage == lang)
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: AppColors.primaryGreen,
                              )
                            else
                              const SizedBox(width: 16),
                            const SizedBox(width: 8),
                            Text(
                              lang,
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              if (mandi.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => mandi.fetchMandiPrices(),
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: lang.tr('tab_prices')),
                Tab(text: lang.tr('tab_ai_chat')),
                Tab(text: lang.tr('tab_bargain')),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _PricesTab(mandi: mandi, searchController: _searchController),
              _AIChatTab(mandi: mandi),
              _BargainTab(mandi: mandi),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1: LIVE PRICES
// ═══════════════════════════════════════════════════════════════════════════════
class _PricesTab extends StatelessWidget {
  final MandiProvider mandi;
  final TextEditingController searchController;

  const _PricesTab({required this.mandi, required this.searchController});

  @override
  Widget build(BuildContext context) {
    final prices = mandi.prices;
    final lastUpdated = mandi.lastUpdated;

    String updatedText = 'Fetching...';
    if (lastUpdated != null) {
      final h = lastUpdated.hour.toString().padLeft(2, '0');
      final m = lastUpdated.minute.toString().padLeft(2, '0');
      updatedText = 'Updated: $h:$m';
    }

    return Column(
      children: [
        // Header strip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
            ),
          ),
          child: Row(
            children: [
              Text(
                updatedText,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
              ),
              const Spacer(),
              if (mandi.errorMessage != null)
                Text(
                  mandi.errorMessage!,
                  style: GoogleFonts.poppins(
                    color: Colors.yellow.shade200,
                    fontSize: 10,
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${prices.length} items',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: TextField(
            controller: searchController,
            onChanged: (q) => mandi.setSearchQuery(q),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: '🔍  Search market, crop, district...',
              hintStyle: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 13,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.5,
                ),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        mandi.setSearchQuery('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Commodity chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            itemCount: mandi.availableCommodities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final commodity = mandi.availableCommodities[i];
              final selected = mandi.selectedCommodity == commodity;
              return GestureDetector(
                onTap: () => mandi.setCommodityFilter(commodity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryGreen
                          : AppColors.divider,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primaryGreen.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    commodity,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: selected ? Colors.white : AppColors.textMedium,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // State chips
        if (mandi.availableStates.length > 2)
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: mandi.availableStates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final state = mandi.availableStates[i];
                final selected = mandi.selectedState == state;
                return GestureDetector(
                  onTap: () => mandi.setStateFilter(state),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF1B5E20)
                          : AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      state,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: selected ? Colors.white : AppColors.textMedium,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 4),

        // Price list
        Expanded(child: _buildPriceList(prices)),
      ],
    );
  }

  Widget _buildPriceList(List<LiveMandiPrice> prices) {
    if (mandi.isLoading && prices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 12),
            Text('Fetching live mandi prices...'),
          ],
        ),
      );
    }

    if (prices.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📭', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(
              'No prices found',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => mandi.fetchMandiPrices(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryGreen,
      onRefresh: () => mandi.fetchMandiPrices(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
        itemCount: prices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _LivePriceCard(price: prices[i]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2: AI CHAT (Market Assistant)
// ═══════════════════════════════════════════════════════════════════════════════
class _AIChatTab extends StatefulWidget {
  final MandiProvider mandi;
  const _AIChatTab({required this.mandi});

  @override
  State<_AIChatTab> createState() => _AIChatTabState();
}

class _AIChatTabState extends State<_AIChatTab> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickQuestions = [
    'Aaj tomato ka rate kya hai?',
    'Onion store kaise karein?',
    'Best time to sell wheat?',
    'How to check potato quality?',
    'Soybean ka season kab hai?',
  ];

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    widget.mandi.sendChatMessage(text).then((_) {
      // Scroll after AI response arrives
      Future.delayed(const Duration(milliseconds: 150), _scrollToBottom);
    });
    // Scroll immediately after user message
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.mandi.chatMessages;
    final isLoading = widget.mandi.isChatLoading;

    return Column(
      children: [
        // Language badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: AppColors.mintGreen,
          child: Row(
            children: [
              const Text('🗣️', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                'Chat in: ${widget.mandi.chatLanguage}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryGreen,
                ),
              ),
              const Spacer(),
              if (messages.isNotEmpty)
                GestureDetector(
                  onTap: () => widget.mandi.clearChat(),
                  child: Text(
                    'Clear',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.riskHigh,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: messages.isEmpty
              ? _buildEmptyChat()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == messages.length && isLoading) {
                      return _buildTypingIndicator();
                    }
                    return _ChatBubble(message: messages[i]);
                  },
                ),
        ),

        // Quick suggestions
        if (messages.isEmpty)
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: _quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                return GestureDetector(
                  onTap: () {
                    _msgController.text = _quickQuestions[i];
                    _send();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mintGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _quickQuestions[i],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 6),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _msgController,
                  onSubmitted: (_) => _send(),
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Ask about prices, tips, storage...',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: isLoading ? null : _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLoading ? Icons.hourglass_top : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'AI Market Assistant',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ask about prices, quality, storage,\nnegotiation tips — in any language!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mintGreen,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Thinking...',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chat Bubble ──────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryGreen : AppColors.cardWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: isUser ? Colors.white : AppColors.textDark,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3: BARGAIN HELPER (Negotiation + Smart Phrases + Price Insight)
// ═══════════════════════════════════════════════════════════════════════════════
class _BargainTab extends StatefulWidget {
  final MandiProvider mandi;
  const _BargainTab({required this.mandi});

  @override
  State<_BargainTab> createState() => _BargainTabState();
}

class _BargainTabState extends State<_BargainTab> {
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _itemController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mandi = widget.mandi;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Negotiation Input Card ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🤝', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(
                      'Bargain Assistant',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Get AI bargaining tips in ${mandi.chatLanguage}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 14),
                // Item input
                TextField(
                  controller: _itemController,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Item name',
                    hintText: 'e.g. Tomato, Onion, Wheat',
                    prefixIcon: const Icon(
                      Icons.eco,
                      color: AppColors.primaryGreen,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Price input
                TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.text,
                  style: GoogleFonts.poppins(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Vendor\'s asking price',
                    hintText: 'e.g. ₹50/kg or ₹3000/quintal',
                    prefixIcon: const Icon(
                      Icons.currency_rupee,
                      color: AppColors.primaryGreen,
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Buttons row
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: mandi.isNegotiationLoading
                            ? null
                            : () {
                                if (_itemController.text.trim().isEmpty) return;
                                mandi.fetchNegotiationAdvice(
                                  item: _itemController.text.trim(),
                                  vendorPrice:
                                      _priceController.text.trim().isEmpty
                                      ? 'not specified'
                                      : _priceController.text.trim(),
                                );
                              },
                        icon: mandi.isNegotiationLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 18),
                        label: Text(
                          'Get Advice',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: mandi.isPhrasesLoading
                            ? null
                            : () {
                                if (_itemController.text.trim().isEmpty) return;
                                mandi.fetchSmartPhrases(
                                  item: _itemController.text.trim(),
                                );
                              },
                        icon: mandi.isPhrasesLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primaryGreen,
                                ),
                              )
                            : const Icon(Icons.chat_bubble_outline, size: 18),
                        label: Text(
                          'Phrases',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Negotiation Advice Result ─────────────────────────────
          if (mandi.negotiationAdvice != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'AI Advice',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    mandi.negotiationAdvice!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Smart Phrases ─────────────────────────────────────────
          if (mandi.smartPhrases.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🗣️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 6),
                      Text(
                        'Ready-to-use Phrases',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        mandi.chatLanguage,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...mandi.smartPhrases.map(
                    (phrase) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💬 ', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Text(
                                phrase,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Price Insight Section ──────────────────────────────────
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 6),
                    Text(
                      'AI Price Insight',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: mandi.isPriceInsightLoading
                          ? null
                          : () {
                              if (_itemController.text.trim().isEmpty) return;
                              mandi.fetchPriceInsight(
                                item: _itemController.text.trim(),
                              );
                            },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: mandi.isPriceInsightLoading
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Analyze',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                if (mandi.priceInsight != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    mandi.priceInsight!,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.95),
                      height: 1.5,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  Text(
                    'Enter an item above and tap "Analyze" to get AI-powered price insights.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _LivePriceCard extends StatelessWidget {
  final LiveMandiPrice price;
  const _LivePriceCard({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(price.commodityEmoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      price.commodity,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      '${price.market} • ${price.district}, ${price.state}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${price.modalPrice.toStringAsFixed(0)}/q',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: price.isGoodPrice
                          ? AppColors.riskLow.withValues(alpha: 0.15)
                          : AppColors.riskHigh.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      price.isGoodPrice ? '↑ Good' : '↓ Low',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: price.isGoodPrice
                            ? AppColors.riskLow
                            : AppColors.riskHigh,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _PricePill(
                label: 'Min',
                value: '₹${price.minPrice.toStringAsFixed(0)}',
                color: AppColors.riskHigh,
              ),
              const SizedBox(width: 6),
              Expanded(child: _PriceRangeBar(price: price)),
              const SizedBox(width: 6),
              _PricePill(
                label: 'Max',
                value: '₹${price.maxPrice.toStringAsFixed(0)}',
                color: AppColors.riskLow,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (price.variety.isNotEmpty && price.variety != 'Other')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    price.variety,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              const Spacer(),
              Icon(Icons.calendar_today, size: 11, color: AppColors.textLight),
              const SizedBox(width: 4),
              Text(
                price.arrivalDate,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PriceRangeBar extends StatelessWidget {
  final LiveMandiPrice price;
  const _PriceRangeBar({required this.price});

  @override
  Widget build(BuildContext context) {
    final range = price.maxPrice - price.minPrice;
    final modalPosition = range > 0
        ? (price.modalPrice - price.minPrice) / range
        : 0.5;

    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final indicatorX = (modalPosition * width).clamp(4.0, width - 4.0);

          return Stack(
            children: [
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEF5350),
                        Color(0xFFFFCA28),
                        Color(0xFF66BB6A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: indicatorX - 4,
                top: 2,
                child: Container(
                  width: 8,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PricePill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
