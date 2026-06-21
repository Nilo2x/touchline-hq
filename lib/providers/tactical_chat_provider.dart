import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../services/chat_repository.dart';

/// Developer: Coach: Danilo

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());

/// Live stream of chat messages for a given squad's Tactical Room.
/// Backed by Supabase Realtime — new messages from any participant on
/// any device appear immediately, no refresh needed.
final tacticalChatStreamProvider =
    StreamProvider.autoDispose.family<List<ChatMessage>, String>((ref, squadId) {
  final repo = ref.watch(chatRepositoryProvider);
  return repo.watchMessages(squadId).map(
        (rows) => rows.map((r) => ChatMessage.fromJson(r)).toList(),
      );
});

class ChatComposerNotifier extends StateNotifier<bool> {
  final ChatRepository _repo;
  ChatComposerNotifier(this._repo) : super(false); // false = not sending

  Future<void> send({
    required String squadId,
    required String body,
    String? sharedPlayerId,
  }) async {
    if (body.trim().isEmpty && sharedPlayerId == null) return;
    state = true;
    try {
      await _repo.sendMessage(
        squadId: squadId,
        body: body.trim(),
        messageType: sharedPlayerId != null ? 'player_share' : 'text',
        sharedPlayerId: sharedPlayerId,
      );
    } finally {
      state = false;
    }
  }
}

final chatComposerProvider =
    StateNotifierProvider.autoDispose<ChatComposerNotifier, bool>(
  (ref) => ChatComposerNotifier(ref.watch(chatRepositoryProvider)),
);
