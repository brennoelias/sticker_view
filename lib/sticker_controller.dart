import 'dart:async';

// Enum is probably too simplistic for more advanced actions in the future.
// Could be replaced with an AbstractAction that other actions can extend
enum StickersAction { selectNone }

/// Allows communication to the Stickerview
class StickerController {
  final StreamController<StickersAction> _actions = StreamController();
  Stream get stream => _actions.stream;

  /// Fires an action
  void fire(StickersAction action) => _actions.add(action);
}
