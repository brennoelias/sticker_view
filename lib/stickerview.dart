import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'draggable_stickers.dart';
import 'sticker_controller.dart';

export 'sticker_controller.dart';

///
/// StickerView
/// A Flutter widget that can rotate, resize, edit and manage layers of widgets.
/// You can pass any widget to it as Sticker's child
///
class StickerView extends StatefulWidget {
  final List<Sticker>? stickerList;
  final double? height; // height of the editor view
  final double? width; // width of the editor view

  final Widget? child;

  /// Optional watermark that will be displayed above all content
  final Positioned? watermark;

  /// Optional sticker controller allowing external interaction
  final StickerController? controller;

  /// Background color
  final Color? backgroundColor;

  // ignore: use_key_in_widget_constructors
  const StickerView(
      {this.stickerList,
      this.height,
      this.width,
      this.child,
      this.watermark,
      this.backgroundColor,
      this.controller});

  // Method for saving image of the editor view as Uint8List
  static Future<Uint8List?> saveAsUint8List({double pixelRatio = 3.0}) async {
    try {
      Uint8List? pngBytes;

      // delayed by few seconds because it takes some time to update the state by RenderRepaintBoundary
      await Future.delayed(const Duration(milliseconds: 700))
          .then((value) async {
        RenderRepaintBoundary boundary = stickGlobalKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        pngBytes = byteData?.buffer.asUint8List();
      });
      // returns Uint8List
      return pngBytes;
    } catch (e) {
      rethrow;
    }
  }

  @override
  StickerViewState createState() => StickerViewState();
}

//GlobalKey is defined for capturing screenshot
final GlobalKey stickGlobalKey = GlobalKey();

class StickerViewState extends State<StickerView> {
  // You have to pass the List of Sticker
  List<Sticker>? stickerList;

  late StickerController controller;

  @override
  void initState() {
    setState(() {
      stickerList = widget.stickerList;
      controller = widget.controller ?? StickerController();
    });
    if (stickerList != null) {
      controller.initStickers(stickerList);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return stickerList != null || controller.stickers.isNotEmpty
        ? Column(
            children: [
              //For capturing screenshot of the widget
              RepaintBoundary(
                  key: stickGlobalKey,
                  child: Container(
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? Colors.grey[200],
                      ),
                      height: widget.height ??
                          MediaQuery.of(context).size.height * 0.7,
                      width: widget.width ?? MediaQuery.of(context).size.width,
                      child: Stack(fit: StackFit.expand, children: [
                        // background content
                        Positioned.fill(
                            child: (widget.child != null)
                                ? widget.child!
                                : Container()),

                        // Draggable stickers
                        Positioned.fill(
                            child: DraggableStickers(
                          controller: controller,
                        )),
                        if (widget.watermark != null) widget.watermark!
                      ]))),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }
}

// Sticker class

// ignore: must_be_immutable
class Sticker extends StatefulWidget {
  /// you can pass any widget to it as child
  Widget? child;

  /// set isText to true if passed Text widget as child
  bool? isText = false;

  // New properties for save state
  double? posx;
  double? posy;
  double? angle;
  double? width;
  double? height;

  /// Aspect ratio of sticker, defaults to 1.0
  double aspectRatio;

  /// Initial scale of sticker, defaults to 3.0
  double initialScale;

  /// every sticker must be assigned with unique id
  String id;

  /// Callback to edit the sticker
  Function()? onEdit;

  Sticker(
      {Key? key,
      required this.id,
      this.child,
      this.isText,
      this.onEdit,
      this.posx,
      this.posy,
      this.angle,
      this.width,
      this.height,
      this.aspectRatio = 1.0,
      this.initialScale = 3.0})
      : super(key: key);
  @override
  _StickerState createState() => _StickerState();
}

class _StickerState extends State<Sticker> {
  @override
  Widget build(BuildContext context) {
    return widget.child != null ? widget.child! : Container();
  }
}
