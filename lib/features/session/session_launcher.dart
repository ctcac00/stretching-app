// Cross-feature entry points to the session player. Keep these signatures.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/navigation.dart';
import '../../core/providers.dart';
import 'session_player_screen.dart';

/// Opens the player for these routine items, in this order, replacing anything
/// above the tabs (including a running session). Does nothing if [itemIds] is
/// empty or the app has no navigator yet.
Future<void> openSession(List<int> itemIds) async {
  final navigator = navigatorKey.currentState;
  if (navigator == null || itemIds.isEmpty) return;
  // Records now rather than after the replaced route has animated away.
  closeRunningSession();
  navigator.popUntil((route) => route.isFirst);
  navigator.push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => SessionPlayerScreen(itemIds: itemIds),
    ),
  );
}

/// Closes a running session, if any, and waits until it is recorded.
Future<void> endRunningSession() async {
  final closing = closeRunningSession();
  if (closing == null) return;
  navigatorKey.currentState?.popUntil((route) => route.isFirst);
  await closing;
}

/// Opens the player for the next-up items, chosen now. A running session is
/// closed first, so what it completed is not chosen again. Opens nothing when
/// all are done.
Future<void> openNextUpSession() async {
  final context = navigatorKey.currentContext;
  if (context == null) return;
  final sessions = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(sessionRepositoryProvider);
  await endRunningSession();
  final items = await sessions.loadNextUp();
  await openSession([for (final item in items) item.id]);
}
