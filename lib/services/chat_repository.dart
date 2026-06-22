import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_message.dart';
import 'supabase_client.dart';

/// Developer: Coach: Danilo
class ChatRepository {
  final _db = AppSupabase.client;

  /// Returns the current user's id, or throws a readable error instead
  /// of an unreadable null-check crash if no one is signed in yet.
  String get _requireUserId {
    final user = _db.auth.currentUser;
    if (user == null) {
      throw Exception('No signed-in user yet. Check your internet connection and try again.');
    }
    return user.id;
  }

  Future<List<ChatMessage>> history(String squadId, {int limit = 50}) async {
    final rows = await _db
        .from('chat_messages')
        .select('*, profiles(display_name)')
        .eq('squad_id', squadId)
        .order('created_at', ascending: true)
        .limit(limit);

    return (rows as List).map((r) {
      final map = Map<String, dynamic>.from(r as Map);
      map['display_name'] = (r['profiles'] as Map?)?['display_name'];
      return ChatMessage.fromJson(map);
    }).toList();
  }

  Future<void> sendMessage({
    required String squadId,
    required String body,
    String messageType = 'text',
    String? sharedPlayerId,
  }) async {
    final userId = _requireUserId;
    await _db.from('chat_messages').insert({
      'squad_id': squadId,
      'user_id': userId,
      'body': body,
      'message_type': messageType,
      'shared_player_id': sharedPlayerId,
    });
  }

  /// Live message stream — Postgres CDC via Supabase Realtime.
  /// No polling, no manual refresh; new rows arrive the instant
  /// any participant inserts a chat message.
  Stream<List<Map<String, dynamic>>> watchMessages(String squadId) {
    return _db
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('squad_id', squadId)
        .order('created_at');
  }

  /// Presence channel — shows who's currently active in the Tactical Room.
  /// `onSync` receives the flattened list of currently-present user payloads
  /// (each payload is whatever map was passed to `channel.track()` by that
  /// user's device — typically {'user_id': ..., 'display_name': ...}).
  RealtimeChannel presenceChannel(
    String squadId, {
    required void Function(List<Map<String, dynamic>> onlineUsers) onSync,
  }) {
    final channel = _db.channel('presence:squad:$squadId');
    channel.onPresenceSync((_) {
      final state = channel.presenceState(); // List<SinglePresenceState>
      final flattened = state
          .expand((s) => s.presences)
          .map((p) => Map<String, dynamic>.from(p.payload))
          .toList();
      onSync(flattened);
    });
    channel.subscribe((status, _) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        final userId = _db.auth.currentUser?.id;
        if (userId != null) {
          await channel.track({'user_id': userId});
        }
      }
    });
    return channel;
  }
}
