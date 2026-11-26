import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTab { today, library, routine, reminders }

/// The visible tab: `ref.read(selectedTabProvider.notifier).select(...)`.
class SelectedTab extends Notifier<AppTab> {
  @override
  AppTab build() => AppTab.today;

  void select(AppTab tab) => state = tab;
}

final selectedTabProvider = NotifierProvider<SelectedTab, AppTab>(
  SelectedTab.new,
);
