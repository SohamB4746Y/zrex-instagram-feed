import 'package:flutter/material.dart';

class PinchZoomOverlay extends StatefulWidget {
  final Widget child;

  const PinchZoomOverlay({super.key, required this.child});

  @override
  State<PinchZoomOverlay> createState() => _PinchZoomOverlayState();
}

class _PinchZoomOverlayState extends State<PinchZoomOverlay>
    with SingleTickerProviderStateMixin {
  final _childKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isZooming = false;
  Matrix4 _currentMatrix = Matrix4.identity();
  late AnimationController _animController;
  late Animation<Matrix4> _snapBackAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _removeOverlay();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _removeOverlay(notify: false);
    super.dispose();
  }

  Rect? _getChildRect() {
    final renderBox =
        _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  void _onInteractionStart(ScaleStartDetails details) {
    if (details.pointerCount < 2) return;

    final rect = _getChildRect();
    if (rect == null) return;

    setState(() => _isZooming = true);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _ZoomOverlayWidget(
          rect: rect,
          onMatrixUpdate: (matrix) {
            _currentMatrix = matrix;
          },
          onInteractionEnd: _onOverlayInteractionEnd,
          child: widget.child,
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _onOverlayInteractionEnd() {
    _snapBackAnimation =
        Matrix4Tween(begin: _currentMatrix, end: Matrix4.identity()).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _overlayEntry?.remove();
    _overlayEntry = null;

    final rect = _getChildRect();
    if (rect == null) {
      setState(() => _isZooming = false);
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _SnapBackOverlay(
          animation: _snapBackAnimation,
          rect: rect,
          child: widget.child,
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _animController.forward(from: 0);
  }

  void _removeOverlay({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notify && mounted) {
      setState(() => _isZooming = false);
    } else {
      _isZooming = false;
    }
    _currentMatrix = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: _onInteractionStart,
      child: Opacity(
        key: _childKey,
        opacity: _isZooming ? 0.0 : 1.0,
        child: widget.child,
      ),
    );
  }
}

class _ZoomOverlayWidget extends StatefulWidget {
  final Rect rect;
  final Widget child;
  final ValueChanged<Matrix4> onMatrixUpdate;
  final VoidCallback onInteractionEnd;

  const _ZoomOverlayWidget({
    required this.rect,
    required this.child,
    required this.onMatrixUpdate,
    required this.onInteractionEnd,
  });

  @override
  State<_ZoomOverlayWidget> createState() => _ZoomOverlayWidgetState();
}

class _ZoomOverlayWidgetState extends State<_ZoomOverlayWidget> {
  final _transformController = TransformationController();

  @override
  void initState() {
    super.initState();
    _transformController.addListener(() {
      widget.onMatrixUpdate(_transformController.value);
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.black.withValues(alpha: 0.3)),
        Positioned(
          left: widget.rect.left,
          top: widget.rect.top,
          width: widget.rect.width,
          height: widget.rect.height,
          child: InteractiveViewer(
            transformationController: _transformController,
            clipBehavior: Clip.none,
            minScale: 1.0,
            maxScale: 4.0,
            panEnabled: true,
            scaleEnabled: true,
            onInteractionEnd: (_) => widget.onInteractionEnd(),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Animates the zoomed image back to its original position via a matrix snap-back.
class _SnapBackOverlay extends AnimatedWidget {
  final Rect rect;
  final Widget child;

  const _SnapBackOverlay({
    required Animation<Matrix4> animation,
    required this.rect,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final matrix = (listenable as Animation<Matrix4>).value;
    return Stack(
      children: [
        Positioned(
          left: rect.left,
          top: rect.top,
          width: rect.width,
          height: rect.height,
          child: Transform(
            transform: matrix,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ],
    );
  }
}
