/// Developer: Coach: Danilo
class PlayerStats {
  final int pace, shooting, passing, dribbling, defending, physical;

  const PlayerStats({
    required this.pace,
    required this.shooting,
    required this.passing,
    required this.dribbling,
    required this.defending,
    required this.physical,
  });

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        pace: json['pace'] ?? 0,
        shooting: json['shooting'] ?? 0,
        passing: json['passing'] ?? 0,
        dribbling: json['dribbling'] ?? 0,
        defending: json['defending'] ?? 0,
        physical: json['physical'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'pace': pace,
        'shooting': shooting,
        'passing': passing,
        'dribbling': dribbling,
        'defending': defending,
        'physical': physical,
      };
}

class Player {
  final String id;
  final String fullName;
  final String? commonName;
  final String? teamId;
  final String? teamName;
  final String nationality;
  final int age;
  final String preferredFoot;
  final String positionPrimary;
  final List<String> positionsSecondary;

  final int overallRating;
  final int potentialRating;
  final int? initialOverallRating;
  final int? initialPotentialRating;
  final int? maxPotentialProjection;

  final String? photoUrl;
  final bool hasRealFace;

  final double? marketValue;
  final double? wage;

  final bool isWonderkid;
  final bool isHiddenGem;

  final List<String> traits;
  final PlayerStats? stats;

  const Player({
    required this.id,
    required this.fullName,
    this.commonName,
    this.teamId,
    this.teamName,
    required this.nationality,
    required this.age,
    required this.preferredFoot,
    required this.positionPrimary,
    this.positionsSecondary = const [],
    required this.overallRating,
    required this.potentialRating,
    this.initialOverallRating,
    this.initialPotentialRating,
    this.maxPotentialProjection,
    this.photoUrl,
    this.hasRealFace = false,
    this.marketValue,
    this.wage,
    this.isWonderkid = false,
    this.isHiddenGem = false,
    this.traits = const [],
    this.stats,
  });

  String get displayName => commonName ?? fullName;

  /// Deterministic seed so the same player always gets the same
  /// generated-avatar fallback if no real photo is available/licensed.
  String get avatarFallbackSeed => id;

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      commonName: json['common_name'] as String?,
      teamId: json['team_id'] as String?,
      teamName: json['team_name'] as String?,
      nationality: json['nationality'] as String,
      age: json['age'] ?? 0,
      preferredFoot: json['preferred_foot'] ?? 'right',
      positionPrimary: json['position_primary'] as String,
      positionsSecondary: (json['positions_secondary'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      overallRating: json['overall_rating'] ?? 0,
      potentialRating: json['potential_rating'] ?? 0,
      initialOverallRating: json['initial_overall_rating'],
      initialPotentialRating: json['initial_potential_rating'],
      maxPotentialProjection: json['max_potential_projection'],
      photoUrl: json['photo_url'] as String?,
      hasRealFace: json['has_real_face'] ?? false,
      marketValue: (json['market_value'] as num?)?.toDouble(),
      wage: (json['wage'] as num?)?.toDouble(),
      isWonderkid: json['is_wonderkid'] ?? false,
      isHiddenGem: json['is_hidden_gem'] ?? false,
      traits: (json['traits'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      stats: json['player_stats'] != null
          ? PlayerStats.fromJson(json['player_stats'])
          : null,
    );
  }
}
