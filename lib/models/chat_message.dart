/// Developer: Coach: Danilo
class ChatMessage {
  final String id;
  final String squadId;
  final String userId;
  final String? displayName;
  final String body;
  final String messageType; // 'text' | 'system' | 'player_share'
  final String? sharedPlayerId;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.squadId,
    required this.userId,
    this.displayName,
    required this.body,
    this.messageType = 'text',
    this.sharedPlayerId,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'],
        squadId: json['squad_id'],
        userId: json['user_id'],
        displayName: json['display_name'],
        body: json['body'],
        messageType: json['message_type'] ?? 'text',
        sharedPlayerId: json['shared_player_id'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toInsertJson() => {
        'squad_id': squadId,
        'user_id': userId,
        'body': body,
        'message_type': messageType,
        'shared_player_id': sharedPlayerId,
      };
}
