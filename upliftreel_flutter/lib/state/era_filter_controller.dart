import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/era_filter.dart';

/// Transient Era Selector state. Defaults to [EraFilter.all] (no constraint).
/// Like mood [select], setting an era only updates state — the home screen
/// regenerates the pick after a change. Not persisted, by design (see
/// [EraFilter]).
class EraFilterController extends Notifier<EraFilter> {
  @override
  EraFilter build() => EraFilter.all;

  void select(EraFilter era) => state = era;

  void clear() => state = EraFilter.all;
}

final eraFilterControllerProvider =
    NotifierProvider<EraFilterController, EraFilter>(EraFilterController.new);
