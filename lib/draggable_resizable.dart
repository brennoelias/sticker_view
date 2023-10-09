import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'drag_controller.dart';

/// {@template drag_update}
/// Drag update model which includes the position and size.
/// {@endtemplate}
class DragUpdate {
  /// {@macro drag_update}
  const DragUpdate({
    required this.angle,
    required this.position,
    required this.size,
    required this.constraints,
  });

  /// The angle of the draggable asset.
  final double angle;

  /// The position of the draggable asset.
  final Offset position;

  /// The size of the draggable asset.
  final Size size;

  /// The constraints of the parent view.
  final Size constraints;
}

const _cornerDiameter = 26.0;
const _floatingActionDiameter = 24.0;
const _floatingActionPadding = 28.0;
// const _floatingActionPadding = 0.0;

/// {@template draggable_resizable}
/// A widget which allows a user to drag and resize the provided [child].
/// {@endtemplate}
class DraggableResizable extends StatefulWidget {
  /// {@macro draggable_resizable}
  DraggableResizable({
    Key? key,
    required this.child,
    required this.size,
    BoxConstraints? constraints,
    this.posx,
    this.posy,
    this.width,
    this.height,
    this.angle,
    this.id,
    this.onUpdate,
    this.onLayerTapped,
    this.onEdit,
    this.onDelete,
    this.canTransform = false,
    required this.dragController,
    required this.stickerId,
  })  : constraints = constraints ?? BoxConstraints.loose(Size.infinite),
        super(key: key);

  /// The child which will be draggable/resizable.
  final Widget child;

  // final VoidCallback? onTap;

  /// Drag/Resize value setter.
  final ValueSetter<DragUpdate>? onUpdate;

  /// Delete callback
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onLayerTapped;
  final DragController dragController;
  final String stickerId;

  /// Whether or not the asset can be dragged or resized.
  /// Defaults to false.
  final bool canTransform;

  /// The child's original size.
  final Size size;

  /// The child's constraints.
  /// Defaults to [BoxConstraints.loose(Size.infinite)].
  final BoxConstraints constraints;

  // New properties for save state
  final double? posx;
  final double? posy;
  final double? width;
  final double? height;
  final double? angle;
  final String? id;

  @override
  _DraggableResizableState createState() => _DraggableResizableState();
}

class _DraggableResizableState extends State<DraggableResizable> {
  late Size size;
  late BoxConstraints constraints;
  late double angle;
  late double angleDelta;
  late double baseAngle;

  bool get isTouchInputSupported => true;

  Offset position = Offset.zero;

  @override
  void initState() {
    super.initState();
    size = (widget.width != null && widget.height != null ? Size(widget.width!, widget.height!) : widget.size);
    constraints = const BoxConstraints.expand(width: 1, height: 1);
    angle = widget.angle ?? 0;
    baseAngle = 0;
    angleDelta = 0;
    position = (widget.posx != null && widget.posy != null ? Offset(widget.posx!, widget.posy!) : Offset.zero);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.size.width / widget.size.height;
    return LayoutBuilder(
      builder: (context, constraints) {
        position = position == Offset.zero
            ? Offset(
                constraints.maxWidth / 2 - (size.width / 2),
                constraints.maxHeight / 2 - (size.height / 2),
              )
            : position;

        final normalizedWidth = size.width;
        final normalizedHeight = normalizedWidth / aspectRatio;
        final newSize = Size(normalizedWidth, normalizedHeight);

        if (widget.constraints.isSatisfiedBy(newSize)) size = newSize;

        final normalizedLeft = position.dx;
        final normalizedTop = position.dy;

        void onUpdate() {
          final normalizedPosition = Offset(
            normalizedLeft + (_floatingActionPadding / 2) + (_cornerDiameter / 2),
            normalizedTop + (_floatingActionPadding / 2) + (_cornerDiameter / 2),
          );
          widget.onUpdate?.call(
            DragUpdate(
              position: Offset(position.dx, position.dy),
              size: size,
              constraints: Size(constraints.maxWidth, constraints.maxHeight),
              angle: angle,
            ),
          );
          // widget.onUpdate();
        }

        // void onDragTopLeft(Offset details) {
        //   final mid = (details.dx + details.dy) / 2;
        //   final newHeight = math.max((size.height - (2 * mid)), 0.0);
        //   final newWidth = math.max(size.width - (2 * mid), 0.0);
        //   final updatedSize = Size(newWidth, newHeight);

        //   if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

        //   final updatedPosition = Offset(position.dx + mid, position.dy + mid);

        //   setState(() {
        //     size = updatedSize;
        //     position = updatedPosition;
        //   });

        //   onUpdate();
        // }

        // ignore: unused_element
        void onDragTopRight(Offset details) {
          final mid = (details.dx + (details.dy * -1)) / 2;
          final newHeight = math.max(size.height + (2 * mid), 0.0);
          final newWidth = math.max(size.width + (2 * mid), 0.0);
          final updatedSize = Size(newWidth, newHeight);

          if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

          final updatedPosition = Offset(position.dx - mid, position.dy - mid);

          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });

          onUpdate();
        }

        // ignore: unused_element
        void onDragBottomLeft(Offset details) {
          final mid = ((details.dx * -1) + details.dy) / 2;

          final newHeight = math.max(size.height + (2 * mid), 0.0);

          final newWidth = math.max(size.width + (2 * mid), 0.0);

          final updatedSize = Size(newWidth, newHeight);

          // if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

          final updatedPosition = Offset(position.dx - mid, position.dy - mid);

          // if (updatedSize > Size(100, 100)) {
          setState(() {
            size = updatedSize;
            position = updatedPosition;
          });
          // }

          onUpdate();
        }

        void onDragBottomRight(Offset details) {
          final mid = (details.dx + details.dy) / 2;
          final newHeight = math.max(size.height + (2 * mid), 0.0);
          final newWidth = math.max(size.width + (2 * mid), 0.0);
          final updatedSize = Size(newWidth, newHeight);

          // if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

          final updatedPosition = Offset(position.dx - mid, position.dy - mid);
          // minimum size of the sticker should be Size(32,32)
          if (updatedSize > const Size(32, 32)) {
            setState(() {
              size = updatedSize;
              position = updatedPosition;
            });
          }

          onUpdate();
        }

        final decoratedChild = Container(
          key: const Key('draggableResizable_child_container'),
          alignment: Alignment.center,
          height: normalizedHeight + _cornerDiameter + _floatingActionPadding,
          width: normalizedWidth + _cornerDiameter + _floatingActionPadding,
          child: Container(
            height: normalizedHeight,
            width: normalizedWidth,
            decoration: BoxDecoration(
              border: widget.dragController.hasTwoFingers
                  ? Border.all(
                      width: 2,
                      color: Colors.transparent,
                    )
                  : Border.all(
                      width: 2,
                      color: widget.canTransform ? Colors.blue : Colors.red,
                    ),
            ),
            child: Center(child: widget.child),
          ),
        );
        final topLeftCorner = _FloatingActionIcon(
          key: const Key('draggableResizable_edit_floatingActionIcon'),
          iconData: Icons.edit,
          onTap: () {
            widget.dragController.setTwoFingers(true);
          },
          scaleFactor: size.width / widget.size.width,
        );

        final topCenter = _FloatingActionIcon(
          key: const Key('draggableResizable_layer_floatingActionIcon'),
          iconData: Icons.layers,
          onTap: widget.onLayerTapped,
          scaleFactor: size.width / widget.size.width,
        );
        // final topLeftCorner = _ResizePoint(
        //   key: const Key('draggableResizable_topLeft_resizePoint'),
        //   type: _ResizePointType.topLeft,
        //   onDrag: onDragTopLeft,
        // );

        // final topRightCorner = _ResizePoint(
        //   key: const Key('draggableResizable_topRight_resizePoint'),
        //   type: _ResizePointType.topRight,
        //   onDrag: onDragTopRight,
        // );

        // final bottomLeftCorner = _ResizePoint(
        //   key: const Key('draggableResizable_bottomLeft_resizePoint'),
        //   type: _ResizePointType.bottomLeft,
        //   onDrag: onDragBottomLeft,
        //   // iconData: Icons.zoom_out_map,
        // );

        final bottomRightCorner = _ResizePoint(
          key: const Key('draggableResizable_bottomRight_resizePoint'),
          type: _ResizePointType.bottomRight,
          onDrag: onDragBottomRight,
          iconData: Icons.zoom_out_map,
          scaleFactor: size.width / widget.size.width,
        );

        final deleteButton = _FloatingActionIcon(
          key: const Key('draggableResizable_delete_floatingActionIcon'),
          iconData: Icons.delete,
          onTap: widget.onDelete,
          scaleFactor: size.width / widget.size.width,
        );

        final center = Offset(
          -((normalizedHeight / 2) + (_floatingActionDiameter / 2) + (_cornerDiameter / 2) + (_floatingActionPadding / 2)),
          // (_floatingActionDiameter + _cornerDiameter) / 2,
          (normalizedHeight / 2) + (_floatingActionDiameter / 2) + (_cornerDiameter / 2) + (_floatingActionPadding / 2),
        );

        final rotateAnchor = GestureDetector(
          key: const Key('draggableResizable_rotate_gestureDetector'),
          onScaleStart: (details) {
            final offsetFromCenter = details.localFocalPoint - center;

            setState(() => angleDelta = baseAngle - offsetFromCenter.direction - _floatingActionDiameter);
          },
          onScaleUpdate: (details) {
            final offsetFromCenter = details.localFocalPoint - center;
            setState(
              () {
                angle = offsetFromCenter.direction + angleDelta * 1;
              },
            );
            onUpdate();
          },
          onScaleEnd: (_) => setState(() => baseAngle = angle),
          child: _FloatingActionIcon(
            key: const Key('draggableResizable_rotate_floatingActionIcon'),
            iconData: Icons.rotate_90_degrees_ccw,
            scaleFactor: size.width / widget.size.width,
            onTap: () {},
          ),
        );

        if (this.constraints != constraints) {
          this.constraints = constraints;
          onUpdate();
        }

        return Stack(
          children: <Widget>[
            Positioned(
              top: normalizedTop,
              left: normalizedLeft,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scale(1.0)
                  ..rotateZ(angle),
                child: _DraggablePoint(
                  key: const Key('draggableResizable_child_draggablePoint'),
                  onTap: onUpdate,
                  onTapDown: () {
                    widget.dragController.setSelectedAssetId(widget.stickerId);
                  },
                  onTapUp: () {},
                  state: widget.dragController.hasTwoFingers ? null : widget.dragController,
                  onlyOneFinger: true,
                  onDrag: (d) {
                    if (widget.canTransform && isTouchInputSupported) {
                      setState(() {
                        position = Offset(position.dx + d.dx, position.dy + d.dy);
                      });
                      onUpdate();
                    }
                  },
                  onScale: (s) {
                    if (widget.canTransform && isTouchInputSupported) {
                      final updatedSize = Size(
                        widget.size.width * s,
                        widget.size.height * s,
                      );

                      // if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

                      final midX = position.dx + (size.width / 2);
                      final midY = position.dy + (size.height / 2);
                      final updatedPosition = Offset(
                        midX - (updatedSize.width / 2),
                        midY - (updatedSize.height / 2),
                      );

                      setState(() {
                        size = updatedSize;
                        position = updatedPosition;
                      });
                      onUpdate();
                    }
                  },
                  onRotate: (a) {
                    if (widget.canTransform && isTouchInputSupported) {
                      setState(() => angle = a * 1);
                      onUpdate();
                    }
                  },
                  onSecondaryTap: () {},
                  child: Stack(
                    children: [
                      decoratedChild,
                      if (widget.canTransform && isTouchInputSupported) ...[
                        Positioned(
                          top: _floatingActionPadding / 2,
                          left: _floatingActionPadding / 2,
                          child: widget.dragController.hasTwoFingers ? Container() : topLeftCorner,
                        ),
                        Positioned(
                          right: (normalizedWidth / 2) - (_floatingActionDiameter / 2) + (_cornerDiameter / 2) + (_floatingActionPadding / 2),
                          child: widget.dragController.hasTwoFingers ? Container() : topCenter,
                        ),
                        Positioned(
                          bottom: _floatingActionPadding / 2,
                          left: _floatingActionPadding / 2,
                          child: widget.dragController.hasTwoFingers ? Container() : deleteButton,
                        ),
                        Positioned(
                          top: normalizedHeight + _floatingActionPadding / 2,
                          left: normalizedWidth + _floatingActionPadding / 2,
                          child: widget.dragController.hasTwoFingers ? Container() : bottomRightCorner,
                        ),
                        Positioned(
                          top: _floatingActionPadding / 2,
                          right: _floatingActionPadding / 2,
                          child: widget.dragController.hasTwoFingers ? Container() : rotateAnchor,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (widget.dragController.hasTwoFingers && widget.dragController.selectedAssetId == widget.stickerId)
              Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: [
                    _DraggablePoint(
                      onSecondaryTap: () {
                        log('secondary contact on');
                      },
                      onTapDown: () {},
                      onlyOneFinger: false,
                      state: widget.dragController,
                      onTapUp: () {},
                      key: const Key('draggable_fullscreen'),
                      onTap: () {
                        log('tapped one');
                        onUpdate();
                      },
                      onDrag: (d) {
                        if (widget.dragController.onDrag(widget.stickerId) == true) {
                          setState(() {
                            position = Offset(position.dx + d.dx, position.dy + d.dy);
                          });
                        }
                        onUpdate();
                      },
                      onScale: (s) {
                        log('scaling');
                        widget.dragController.setScale(s);
                        final updatedSize = Size(
                          widget.size.width * s,
                          widget.size.height * s,
                        );

                        // if (!widget.constraints.isSatisfiedBy(updatedSize)) return;

                        final midX = position.dx + (size.width / 2);
                        final midY = position.dy + (size.height / 2);
                        final updatedPosition = Offset(
                          midX - (updatedSize.width / 2),
                          midY - (updatedSize.height / 2),
                        );

                        setState(() {
                          size = updatedSize;
                          position = updatedPosition;
                        });
                      },
                      onRotate: (a) {
                        if (widget.dragController.onDrag(widget.stickerId) == true) {
                          setState(() => angle = a * 0.9);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _ResizePointType {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

const _cursorLookup = <_ResizePointType, MouseCursor>{
  _ResizePointType.topLeft: SystemMouseCursors.resizeUpLeft,
  _ResizePointType.topRight: SystemMouseCursors.resizeUpRight,
  _ResizePointType.bottomLeft: SystemMouseCursors.resizeDownLeft,
  _ResizePointType.bottomRight: SystemMouseCursors.resizeDownRight,
};

class _ResizePoint extends StatelessWidget {
  const _ResizePoint({Key? key, required this.onDrag, required this.type, this.onScale, this.scaleFactor = 1.0, required this.iconData})
      : super(key: key);

  final ValueSetter<Offset> onDrag;
  final ValueSetter<double>? onScale;
  final double scaleFactor;
  final _ResizePointType type;
  final IconData iconData;

  MouseCursor get _cursor {
    return _cursorLookup[type]!;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _cursor,
      child: _DraggablePoint(
          onSecondaryTap: () {},
          onTapDown: () {},
          onTapUp: () {},
          mode: _PositionMode.local,
          onDrag: onDrag,
          onScale: onScale,
          child: _FloatingActionIcon(iconData: iconData, scaleFactor: scaleFactor)),
    );
  }
}

enum _PositionMode { local, global }

class _DraggablePoint extends StatefulWidget {
  const _DraggablePoint({
    Key? key,
    this.child,
    this.onDrag,
    this.onScale,
    this.onRotate,
    this.onTap,
    this.mode = _PositionMode.global,
    this.state,
    this.onlyOneFinger = false,
    required this.onTapDown,
    required this.onTapUp,
    required this.onSecondaryTap,
  }) : super(key: key);

  final Widget? child;
  final _PositionMode mode;
  final ValueSetter<Offset>? onDrag;
  final ValueSetter<double>? onScale;
  final ValueSetter<double>? onRotate;
  final VoidCallback? onTap;
  final bool? onlyOneFinger;
  final DragController? state;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onSecondaryTap;

  @override
  _DraggablePointState createState() => _DraggablePointState();
}

class _DraggablePointState extends State<_DraggablePoint> {
  late Offset initPoint;
  var baseScaleFactor = 1.0;
  var scaleFactor = 1.0;
  var baseAngle = 0.0;
  var angle = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          widget.onTap?.call();
        },
        onDoubleTap: () => {
              widget.state?.setTwoFingers(true),
            },
        onForcePressStart: (value) {
          log('started force press');
        },
        onTapCancel: () {
          widget.onTapUp?.call();
        },
        onTapDown: (details) {
          log('padded down');
          widget.state?.setFingerCount(1);
          widget.onTapDown?.call();
        },
        onScaleEnd: (details) {
          widget.state?.setFingerCount(details.pointerCount);
          if (details.pointerCount == 0) {
            widget.state?.setTwoFingers(false);
          }
        },
        onScaleStart: (details) {
          widget.state?.setFingerCount(details.pointerCount);

          switch (widget.mode) {
            case _PositionMode.global:
              initPoint = details.focalPoint;
              break;
            case _PositionMode.local:
              initPoint = details.localFocalPoint;
              break;
          }
          if (details.pointerCount > 1) {
            if (widget.onlyOneFinger == false) {
              widget.state?.setTwoFingers(true);
            }
            baseAngle = angle;
            baseScaleFactor = scaleFactor;
            widget.onRotate?.call(baseAngle);
            widget.onScale?.call(baseScaleFactor);
          }
          // else {
          //   widget.state?.setTwoFingers(false);
          // }
        },
        onScaleUpdate: (details) {
          switch (widget.mode) {
            case _PositionMode.global:
              final dx = details.focalPoint.dx - initPoint.dx;
              final dy = details.focalPoint.dy - initPoint.dy;
              initPoint = details.focalPoint;
              widget.onDrag?.call(Offset(dx, dy));
              break;
            case _PositionMode.local:
              final dx = details.localFocalPoint.dx - initPoint.dx;
              final dy = details.localFocalPoint.dy - initPoint.dy;
              initPoint = details.localFocalPoint;
              widget.onDrag?.call(Offset(dx, dy));
              break;
          }
          if (widget.onlyOneFinger == false) {
            widget.state?.setFingerCount(details.pointerCount);
          }

          if (details.pointerCount > 1) {
            if (widget.onlyOneFinger == false) {
              widget.state?.setTwoFingers(true);
            }
            scaleFactor = baseScaleFactor * details.scale;
            widget.onScale?.call(scaleFactor);
            angle = baseAngle + details.rotation;
            widget.onRotate?.call(angle);
          }

          // else {
          //   widget.state?.setTwoFingers(false);
          // }
        },
        child: widget.child);
    // return GestureDetector(
    //   onTap: widget.onTap,
    //   onScaleStart: (details) {
    //     widget.state?.setFingerCount(details.pointerCount);
    //     switch (widget.mode) {
    //       case _PositionMode.global:
    //         initPoint = details.focalPoint;
    //         break;
    //       case _PositionMode.local:
    //         initPoint = details.localFocalPoint;
    //         break;
    //     }
    //     if (details.pointerCount > 1) {
    //       if (widget.onlyOneFinger == false) {
    //         widget.state?.setTwoFingers(true);
    //       }
    //       baseAngle = angle;
    //       baseScaleFactor = scaleFactor;
    //       widget.onRotate?.call(baseAngle);
    //       widget.onScale?.call(baseScaleFactor);
    //     }
    //   },
    //   onDoubleTap: () => {
    //     widget.state?.setTwoFingers(true),
    //   },
    //   onForcePressStart: (value) {
    //     log('started force press');
    //   },
    //   onTapCancel: () {
    //     widget.onTapUp?.call();
    //   },
    //   onTapDown: (details) {
    //     log('padded down');
    //     widget.state?.setFingerCount(1);
    //     widget.onTapDown?.call();
    //   },
    //   onScaleUpdate: (details) {
    //     switch (widget.mode) {
    //       case _PositionMode.global:
    //         final dx = details.focalPoint.dx - initPoint.dx;
    //         final dy = details.focalPoint.dy - initPoint.dy;
    //         initPoint = details.focalPoint;
    //         widget.onDrag?.call(Offset(dx, dy));
    //         break;
    //       case _PositionMode.local:
    //         final dx = details.localFocalPoint.dx - initPoint.dx;
    //         final dy = details.localFocalPoint.dy - initPoint.dy;
    //         initPoint = details.localFocalPoint;
    //         widget.onDrag?.call(Offset(dx, dy));
    //         break;
    //     }
    //     if (widget.onlyOneFinger == false) {
    //       widget.state?.setFingerCount(details.pointerCount);
    //     }
    //     if (details.pointerCount > 1) {
    //       if (widget.onlyOneFinger == false) {
    //         widget.state?.setTwoFingers(true);
    //       }
    //       scaleFactor = baseScaleFactor * details.scale;
    //       widget.onScale?.call(scaleFactor);
    //       angle = baseAngle + details.rotation;
    //       widget.onRotate?.call(angle);
    //     }
    //   },
    //   child: widget.child,
    // );
  }
}

class _FloatingActionIcon extends StatelessWidget {
  const _FloatingActionIcon({
    Key? key,
    required this.iconData,
    this.onTap,
    this.scaleFactor = 1.0,
  }) : super(key: key);

  final IconData iconData;
  final VoidCallback? onTap;
  final double scaleFactor;

  @override
  Widget build(BuildContext context) {
    double scale = scaleFactor;
    if (scaleFactor < 1.0) {
      scale = 1.0;
    } else if (scaleFactor > 1.5) {
      scale = 1.5;
    }

    return Material(
      color: Colors.white,
      clipBehavior: Clip.hardEdge,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _floatingActionDiameter * scale,
          width: _floatingActionDiameter * scale,
          child: Center(
            child: Icon(
              iconData,
              color: Colors.blue,
              size: 16 * scale,
            ),
          ),
        ),
      ),
    );
  }
}
