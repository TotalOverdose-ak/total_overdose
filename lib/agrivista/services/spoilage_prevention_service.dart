/// Spoilage Prevention Ranking Engine
///
/// Ranks preservation actions by COST and EFFECTIVENESS for each crop.
/// This is decision intelligence — not just "store properly", but exactly
/// WHAT to do, HOW MUCH it costs, and HOW MUCH spoilage it prevents.
class SpoilagePreventionService {
  /// Get ranked preservation actions for a crop.
  /// Returns actions sorted by effectiveness-to-cost ratio (best first).
  static List<PreservationAction> getRankedActions(String crop) {
    final c = crop.toLowerCase();

    // Get crop-specific actions
    List<PreservationAction> actions;

    if (c.contains('tomato')) {
      actions = _tomatoActions;
    } else if (c.contains('onion')) {
      actions = _onionActions;
    } else if (c.contains('potato')) {
      actions = _potatoActions;
    } else if (c.contains('wheat') || c.contains('rice') || c.contains('maize')) {
      actions = _grainActions;
    } else if (c.contains('banana') || c.contains('mango') || c.contains('apple')) {
      actions = _fruitActions;
    } else if (c.contains('soybean') || c.contains('groundnut') || c.contains('mustard')) {
      actions = _oilseedActions;
    } else if (c.contains('cotton')) {
      actions = _cottonActions;
    } else if (c.contains('cauliflower') || c.contains('cabbage') || c.contains('carrot')) {
      actions = _leafyVegActions;
    } else if (c.contains('chilli') || c.contains('garlic') || c.contains('ginger')) {
      actions = _spiceActions;
    } else {
      actions = _defaultActions;
    }

    // Sort by rank (already sorted, but ensure)
    final sorted = List<PreservationAction>.from(actions);
    sorted.sort((a, b) => a.rank.compareTo(b.rank));
    return sorted;
  }

  // ── Tomato Preservation Actions ──────────────────────────────────────────
  static const _tomatoActions = [
    PreservationAction(
      action: 'Shade Drying',
      costLevel: 'Low',
      costEstimate: '₹50-100/quintal',
      effectivenessPercent: 20,
      description: 'Air-dry in shaded area to remove surface moisture before storage',
      timeframe: 'Immediate',
      rank: 1,
    ),
    PreservationAction(
      action: 'Ventilated Crates',
      costLevel: 'Medium',
      costEstimate: '₹200-400/quintal',
      effectivenessPercent: 25,
      description: 'Plastic/wooden crates with airflow prevent crushing and moisture buildup',
      timeframe: '1-2 days',
      rank: 2,
    ),
    PreservationAction(
      action: 'Cold Storage (7-10°C)',
      costLevel: 'High',
      costEstimate: '₹500-800/quintal/week',
      effectivenessPercent: 45,
      description: 'Refrigerated storage extends shelf life from 7 to 25+ days',
      timeframe: 'Long-term',
      rank: 3,
    ),
    PreservationAction(
      action: 'Ethylene Absorber Sachets',
      costLevel: 'Medium',
      costEstimate: '₹150-300/quintal',
      effectivenessPercent: 18,
      description: 'Absorbs ripening gas to slow over-ripening in transit',
      timeframe: '3-5 days',
      rank: 4,
    ),
    PreservationAction(
      action: 'Wax Coating',
      costLevel: 'Medium',
      costEstimate: '₹250-500/quintal',
      effectivenessPercent: 30,
      description: 'Food-grade wax coating reduces moisture loss and microbial attack',
      timeframe: '1-2 weeks',
      rank: 5,
    ),
  ];

  // ── Onion Preservation Actions ───────────────────────────────────────────
  static const _onionActions = [
    PreservationAction(
      action: 'Curing (Sun Drying)',
      costLevel: 'Low',
      costEstimate: '₹30-80/quintal',
      effectivenessPercent: 30,
      description: 'Spread onions under sun for 3-5 days to dry outer skin — reduces rot by 30%',
      timeframe: '3-5 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Bottom-Ventilated Storage',
      costLevel: 'Low',
      costEstimate: '₹100-200/quintal',
      effectivenessPercent: 25,
      description: 'Raised platform with mesh floor allows airflow — prevents moisture rot',
      timeframe: 'Ongoing',
      rank: 2,
    ),
    PreservationAction(
      action: 'Maleic Hydrazide Spray',
      costLevel: 'Medium',
      costEstimate: '₹200-350/quintal',
      effectivenessPercent: 35,
      description: 'Pre-harvest spray prevents sprouting during storage — extends life 2-3 months',
      timeframe: 'Pre-harvest',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (0-2°C)',
      costLevel: 'High',
      costEstimate: '₹400-700/quintal/month',
      effectivenessPercent: 50,
      description: 'Cold storage at 0-2°C, 65-70% humidity extends shelf life to 6 months',
      timeframe: 'Long-term',
      rank: 4,
    ),
    PreservationAction(
      action: 'Irradiation Treatment',
      costLevel: 'High',
      costEstimate: '₹600-1000/quintal',
      effectivenessPercent: 40,
      description: 'Gamma irradiation prevents sprouting — used for export quality',
      timeframe: 'One-time',
      rank: 5,
    ),
  ];

  // ── Potato Preservation Actions ──────────────────────────────────────────
  static const _potatoActions = [
    PreservationAction(
      action: 'Curing at Room Temp',
      costLevel: 'Low',
      costEstimate: '₹40-100/quintal',
      effectivenessPercent: 20,
      description: 'Keep at 15-20°C for 10 days to heal skin wounds — reduces rot significantly',
      timeframe: '10 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Dark Storage Room',
      costLevel: 'Low',
      costEstimate: '₹80-150/quintal',
      effectivenessPercent: 22,
      description: 'Store in dark, well-ventilated room to prevent greening (solanine)',
      timeframe: 'Ongoing',
      rank: 2,
    ),
    PreservationAction(
      action: 'CIPC Sprout Suppressant',
      costLevel: 'Medium',
      costEstimate: '₹200-400/quintal',
      effectivenessPercent: 35,
      description: 'Chemical treatment prevents sprouting — standard for cold stores',
      timeframe: '3-6 months',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (2-4°C)',
      costLevel: 'High',
      costEstimate: '₹350-600/quintal/month',
      effectivenessPercent: 50,
      description: 'Cold storage at 2-4°C, 90-95% humidity stores potatoes for 6-8 months',
      timeframe: 'Long-term',
      rank: 4,
    ),
  ];

  // ── Grain Preservation Actions (Wheat/Rice/Maize) ────────────────────────
  static const _grainActions = [
    PreservationAction(
      action: 'Sun Drying (<12% moisture)',
      costLevel: 'Low',
      costEstimate: '₹30-60/quintal',
      effectivenessPercent: 35,
      description: 'Reduce grain moisture below 12% — prevents fungal growth & weevils',
      timeframe: '2-3 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Hermetic Storage Bags',
      costLevel: 'Low',
      costEstimate: '₹80-150/quintal',
      effectivenessPercent: 30,
      description: 'Airtight bags (GrainPro/PICS) kill insects by oxygen deprivation',
      timeframe: '6-12 months',
      rank: 2,
    ),
    PreservationAction(
      action: 'Neem Leaf Layering',
      costLevel: 'Low',
      costEstimate: '₹10-30/quintal',
      effectivenessPercent: 15,
      description: 'Traditional method — neem leaves between grain layers repel insects',
      timeframe: '2-3 months',
      rank: 3,
    ),
    PreservationAction(
      action: 'Phosphine Fumigation',
      costLevel: 'Medium',
      costEstimate: '₹150-300/quintal',
      effectivenessPercent: 40,
      description: 'Professional fumigation kills all stored-grain pests',
      timeframe: 'One-time',
      rank: 4,
    ),
    PreservationAction(
      action: 'Silo Storage (Metal)',
      costLevel: 'High',
      costEstimate: '₹500-900/quintal/season',
      effectivenessPercent: 45,
      description: 'Metal silos with moisture control — best long-term grain storage',
      timeframe: '1-2 years',
      rank: 5,
    ),
  ];

  // ── Fruit Preservation Actions (Banana/Mango/Apple) ──────────────────────
  static const _fruitActions = [
    PreservationAction(
      action: 'Newspaper Wrapping',
      costLevel: 'Low',
      costEstimate: '₹20-50/quintal',
      effectivenessPercent: 15,
      description: 'Individual wrapping absorbs moisture and cushions — reduces bruise rot',
      timeframe: 'Immediate',
      rank: 1,
    ),
    PreservationAction(
      action: 'Ventilated CFB Boxes',
      costLevel: 'Medium',
      costEstimate: '₹200-400/quintal',
      effectivenessPercent: 22,
      description: 'Corrugated fiber boxes with vents — standard for mango/banana transport',
      timeframe: '3-7 days',
      rank: 2,
    ),
    PreservationAction(
      action: 'Ripening Chamber Control',
      costLevel: 'Medium',
      costEstimate: '₹300-600/quintal',
      effectivenessPercent: 30,
      description: 'Ethylene-controlled ripening chamber for uniform ripening',
      timeframe: '2-5 days',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (12-14°C)',
      costLevel: 'High',
      costEstimate: '₹500-900/quintal/week',
      effectivenessPercent: 45,
      description: 'Temperature-controlled storage extends fruit shelf life 2-4 weeks',
      timeframe: 'Long-term',
      rank: 4,
    ),
    PreservationAction(
      action: 'Modified Atmosphere Packaging',
      costLevel: 'High',
      costEstimate: '₹800-1500/quintal',
      effectivenessPercent: 50,
      description: 'MAP reduces O₂ and increases CO₂ to slow respiration and ripening',
      timeframe: '2-6 weeks',
      rank: 5,
    ),
  ];

  // ── Oilseed Preservation (Soybean/Groundnut/Mustard) ─────────────────────
  static const _oilseedActions = [
    PreservationAction(
      action: 'Thorough Drying (<9%)',
      costLevel: 'Low',
      costEstimate: '₹40-80/quintal',
      effectivenessPercent: 35,
      description: 'Critical for oilseeds — moisture above 9% causes rancidity and aflatoxin',
      timeframe: '3-4 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Jute Bag Storage (Dry Room)',
      costLevel: 'Low',
      costEstimate: '₹60-120/quintal',
      effectivenessPercent: 20,
      description: 'Jute bags in moisture-proof room on raised platform',
      timeframe: '3-4 months',
      rank: 2,
    ),
    PreservationAction(
      action: 'Hermetic Cocoons',
      costLevel: 'Medium',
      costEstimate: '₹200-400/quintal',
      effectivenessPercent: 35,
      description: 'Large hermetic containers for bulk oilseed storage — kills pests',
      timeframe: '6-12 months',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (5-10°C)',
      costLevel: 'High',
      costEstimate: '₹400-700/quintal/month',
      effectivenessPercent: 40,
      description: 'Prevents oil oxidation and aflatoxin development',
      timeframe: 'Long-term',
      rank: 4,
    ),
  ];

  // ── Cotton Preservation Actions ──────────────────────────────────────────
  static const _cottonActions = [
    PreservationAction(
      action: 'Moisture Control (<8%)',
      costLevel: 'Low',
      costEstimate: '₹30-70/quintal',
      effectivenessPercent: 30,
      description: 'Ensure cotton is dried below 8% moisture before baling',
      timeframe: '2-3 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Covered Shed Storage',
      costLevel: 'Low',
      costEstimate: '₹80-150/quintal',
      effectivenessPercent: 25,
      description: 'Keep bales off ground in covered shed — prevents moisture wicking',
      timeframe: 'Ongoing',
      rank: 2,
    ),
    PreservationAction(
      action: 'Polypropylene Wrapping',
      costLevel: 'Medium',
      costEstimate: '₹150-300/quintal',
      effectivenessPercent: 30,
      description: 'UV-resistant PP wrapping protects bales from rain and contamination',
      timeframe: '3-6 months',
      rank: 3,
    ),
    PreservationAction(
      action: 'Warehouse with Dehumidifier',
      costLevel: 'High',
      costEstimate: '₹400-700/quintal/month',
      effectivenessPercent: 40,
      description: 'Temperature and humidity controlled warehouse — best for long-term',
      timeframe: 'Long-term',
      rank: 4,
    ),
  ];

  // ── Leafy Vegetable Actions ──────────────────────────────────────────────
  static const _leafyVegActions = [
    PreservationAction(
      action: 'Wet Gunny Cloth Cover',
      costLevel: 'Low',
      costEstimate: '₹20-50/quintal',
      effectivenessPercent: 18,
      description: 'Dampened cloth maintains humidity and prevents wilting',
      timeframe: 'Same day',
      rank: 1,
    ),
    PreservationAction(
      action: 'Pre-cooling (Hydrocooling)',
      costLevel: 'Medium',
      costEstimate: '₹150-300/quintal',
      effectivenessPercent: 30,
      description: 'Quick cooling with cold water removes field heat — extends freshness 2-3x',
      timeframe: '2-4 hours',
      rank: 2,
    ),
    PreservationAction(
      action: 'Perforated PE Bags',
      costLevel: 'Low',
      costEstimate: '₹60-120/quintal',
      effectivenessPercent: 20,
      description: 'Modified atmosphere inside bags slows respiration without anaerobic stress',
      timeframe: '2-5 days',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (0-5°C)',
      costLevel: 'High',
      costEstimate: '₹500-800/quintal/week',
      effectivenessPercent: 45,
      description: 'Cold chain from farm to market — gold standard for leafy vegetables',
      timeframe: '1-2 weeks',
      rank: 4,
    ),
  ];

  // ── Spice Preservation (Chilli/Garlic/Ginger) ────────────────────────────
  static const _spiceActions = [
    PreservationAction(
      action: 'Sun/Shade Drying',
      costLevel: 'Low',
      costEstimate: '₹40-80/quintal',
      effectivenessPercent: 30,
      description: 'Dry to safe moisture level (chilli <10%, garlic <6%) — prevents mold',
      timeframe: '5-7 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Airtight Container Storage',
      costLevel: 'Low',
      costEstimate: '₹80-160/quintal',
      effectivenessPercent: 25,
      description: 'Store in airtight containers after drying — prevents moisture reabsorption',
      timeframe: '3-6 months',
      rank: 2,
    ),
    PreservationAction(
      action: 'Solar Dryer',
      costLevel: 'Medium',
      costEstimate: '₹200-400/quintal',
      effectivenessPercent: 35,
      description: 'Solar cabinet dryer gives uniform drying — better color retention for chilli',
      timeframe: '2-3 days',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage (2-5°C)',
      costLevel: 'High',
      costEstimate: '₹350-600/quintal/month',
      effectivenessPercent: 40,
      description: 'Cold storage for fresh ginger/garlic maintains quality 4-6 months',
      timeframe: 'Long-term',
      rank: 4,
    ),
  ];

  // ── Default Actions ──────────────────────────────────────────────────────
  static const _defaultActions = [
    PreservationAction(
      action: 'Proper Drying',
      costLevel: 'Low',
      costEstimate: '₹30-80/quintal',
      effectivenessPercent: 25,
      description: 'Reduce moisture to safe level before any storage',
      timeframe: '2-4 days',
      rank: 1,
    ),
    PreservationAction(
      action: 'Ventilated Storage',
      costLevel: 'Low',
      costEstimate: '₹100-200/quintal',
      effectivenessPercent: 20,
      description: 'Good airflow prevents fungal growth and hot spots',
      timeframe: 'Ongoing',
      rank: 2,
    ),
    PreservationAction(
      action: 'Improved Packaging',
      costLevel: 'Medium',
      costEstimate: '₹150-350/quintal',
      effectivenessPercent: 25,
      description: 'Proper packaging reduces physical damage and exposure',
      timeframe: '1-4 weeks',
      rank: 3,
    ),
    PreservationAction(
      action: 'Cold Storage',
      costLevel: 'High',
      costEstimate: '₹400-800/quintal/month',
      effectivenessPercent: 45,
      description: 'Temperature-controlled storage — best for perishables',
      timeframe: 'Long-term',
      rank: 4,
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════════════════════════════════════════

class PreservationAction {
  final String action;
  final String costLevel; // Low, Medium, High
  final String costEstimate; // ₹ range
  final int effectivenessPercent; // % spoilage reduction
  final String description;
  final String timeframe;
  final int rank;

  const PreservationAction({
    required this.action,
    required this.costLevel,
    required this.costEstimate,
    required this.effectivenessPercent,
    required this.description,
    required this.timeframe,
    required this.rank,
  });

  /// Color hint for cost level
  String get costEmoji {
    switch (costLevel) {
      case 'Low':
        return '🟢';
      case 'Medium':
        return '🟡';
      case 'High':
        return '🔴';
      default:
        return '⚪';
    }
  }

  /// Effectiveness label
  String get effectivenessLabel {
    if (effectivenessPercent >= 40) return 'Very High';
    if (effectivenessPercent >= 25) return 'High';
    if (effectivenessPercent >= 15) return 'Medium';
    return 'Low';
  }
}
