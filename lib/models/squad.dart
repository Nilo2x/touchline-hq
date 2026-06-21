/// Developer: Coach: Danilo
class SquadSlot {
  final String id;
  final String? playerId;
  final String slotPosition;
  final int slotIndex;
  final bool isStarting;

  const SquadSlot({
    required this.id,
    this.playerId,
    required this.slotPosition,
    required this.slotIndex,
    this.isStarting = true,
  });

  factory SquadSlot.fromJson(Map<String, dynamic> json) => SquadSlot(
        id: json['id'],
        playerId: json['player_id'],
        slotPosition: json['slot_position'],
        slotIndex: json['slot_index'],
        isStarting: json['is_starting'] ?? true,
      );

  Map<String, dynamic> toInsertJson(String squadId) => {
        'squad_id': squadId,
        'player_id': playerId,
        'slot_position': slotPosition,
        'slot_index': slotIndex,
        'is_starting': isStarting,
      };
}

class Squad {
  final String id;
  final String ownerId;
  final String name;
  final String? managedTeamId;
  final String formation;
  final double? transferBudget;
  final double? wageBudget;
  final String inviteCode;
  final bool isPublic;
  final double ratingAvg;
  final int ratingCount;
  final List<SquadSlot> slots;

  const Squad({
    required this.id,
    required this.ownerId,
    required this.name,
    this.managedTeamId,
    required this.formation,
    this.transferBudget,
    this.wageBudget,
    required this.inviteCode,
    this.isPublic = false,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.slots = const [],
  });

  factory Squad.fromJson(Map<String, dynamic> json) => Squad(
        id: json['id'],
        ownerId: json['owner_id'],
        name: json['name'],
        managedTeamId: json['managed_team_id'],
        formation: json['formation'] ?? '4-3-3',
        transferBudget: (json['transfer_budget'] as num?)?.toDouble(),
        wageBudget: (json['wage_budget'] as num?)?.toDouble(),
        inviteCode: json['invite_code'],
        isPublic: json['is_public'] ?? false,
        ratingAvg: (json['rating_avg'] as num?)?.toDouble() ?? 0,
        ratingCount: json['rating_count'] ?? 0,
        slots: (json['squad_slots'] as List? ?? [])
            .map((s) => SquadSlot.fromJson(s))
            .toList(),
      );

  /// Sum of wages across currently filled slots — used to validate
  /// against wageBudget live as the user builds the squad.
  double committedWage(Map<String, double> playerWageById) {
    double total = 0;
    for (final slot in slots) {
      if (slot.playerId != null) {
        total += playerWageById[slot.playerId] ?? 0;
      }
    }
    return total;
  }
}
