import 'dart:async';
import 'stickerview.dart';

// Enum is probably too simplistic for more advanced actions in the future.
// Could be replaced with an AbstractAction that other actions can extend
enum StickersAction { selectNone }

/// Allows communication to the Stickerview
class StickerController {
  final StreamController<StickersAction> _actions =
      StreamController.broadcast();
  Stream get stream => _actions.stream.asBroadcastStream();

  List<Sticker> _stickers = [];
  get stickers => _stickers;

  final StreamController<List<Sticker>> _stickersController =
      StreamController.broadcast();
  Stream get stickersStream => _stickersController.stream.asBroadcastStream();

  /// Fires an action
  void fire(StickersAction action) => _actions.add(action);

  void initStickers(List<Sticker>? stickers) {
    _stickers = stickers ?? [];
    _stickersController.sink.add(_stickers);
  }

  void addSticker(Sticker sticker) {
    _stickers.add(sticker);
    _stickersController.sink.add(_stickers);
  }

  void removeSticker(Sticker sticker) {
    _stickers.removeWhere((element) => element.id == sticker.id);
    _stickersController.sink.add(_stickers);
  }

  void updateSticker(Sticker sticker) {
    final index = _stickers.indexWhere((element) => element.id == sticker.id);
    if (index != -1) {
      _stickers[index] = sticker;
    }
    _stickersController.sink.add(_stickers);
  }

  void updateStickerLayer(Sticker sticker) {
    var listLength = _stickers.length;
    var ind = _stickers.indexOf(sticker);
    _stickers.remove(sticker);
    if (ind == listLength - 1) {
      _stickers.insert(0, sticker);
    } else {
      _stickers.insert(listLength - 1, sticker);
    }
    _stickersController.sink.add(_stickers);
  }

  void updateAllStickers(List<Sticker> stickers) {
    _stickers = stickers;
    _stickersController.sink.add(_stickers);
  }

  void dispose() {
    _actions.close();
    _stickersController.close();
  }
}
