// Cross-feature entry points to the routine builder. Keep these signatures.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/providers.dart';
import 'routine_item_editor.dart';

/// Opens the editor for a routine item, e.g. right after the library adds one.
/// Completes once the editor is closed and its change is saved.
Future<void> openRoutineItemEditor(BuildContext context, int itemId) async {
  final repository = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(routineRepositoryProvider);
  final item = await repository.get(itemId);
  if (item == null || !context.mounted) return;
  final result = await showModalBottomSheet<RoutineEdit>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => RoutineItemEditor(item),
  );
  if (result == null) return; // Closed without saving.
  if (result.remove) {
    await repository.delete(itemId);
  } else {
    await repository.update(result.item);
  }
}
