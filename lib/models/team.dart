/// Developer: Coach: Danilo
class League {
  final String id;
  final String name;
  final String country;
  final int tier;
  final String? logoUrl;

  const League({
    required this.id,
    required this.name,
    required this.country,
    required this.tier,
    this.logoUrl,
  });

  factory League.fromJson(Map<String, dynamic> json) => League(
        id: json['id'],
        name: json['name'],
        country: json['country'],
        tier: json['tier'] ?? 1,
        logoUrl: json['logo_url'],
      );
}

class Team {
  final String id;
  final String name;
  final String? shortName;
  final String? crestUrl;
  final String? leagueId;
  final String? leagueName;
  final int? overallRating;
  final double? wageBudget;
  final double? transferBudget;
  final String? country;

  const Team({
    required this.id,
    required this.name,
    this.shortName,
    this.crestUrl,
    this.leagueId,
    this.leagueName,
    this.overallRating,
    this.wageBudget,
    this.transferBudget,
    this.country,
  });

  factory Team.fromJson(Map<String, dynamic> json) => Team(
        id: json['id'],
        name: json['name'],
        shortName: json['short_name'],
        crestUrl: json['crest_url'],
        leagueId: json['league_id'],
        leagueName: json['league_name'],
        overallRating: json['overall_rating'],
        wageBudget: (json['wage_budget'] as num?)?.toDouble(),
        transferBudget: (json['transfer_budget'] as num?)?.toDouble(),
        country: json['country'],
      );
}
