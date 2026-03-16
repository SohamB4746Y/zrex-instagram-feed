import 'package:flutter/material.dart';

class PinchZoomOverlay extends StatefulWidget {
  final Widget child;

  /// Optional double-tap callback. When provided, the same GestureDetector
  /// that handles pinch-to-zoom also handles double-tap, avoiding arena
  /// conflicts with a separate outer GestureDetector.
  final VoidCallback? onDoubleTap;

  const PinchZoomOverlay({super.key, required this.child, this.onDoubleTap});

  @override
  State<PinchZoomOverlay> createState() => _PinchZoomOverlayState();
}

class _PinchZoomOverlayState extends State<PinchZoomOverlay>
    with SingleTickerProviderStateMixin {
  final _childKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  bool _isZooming = false;

  // Live transform values — mutated on every gesture event,
  // read by the OverlayEntry builder via markNeedsBuild().
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startFocalPoint = Offset.zero;
  late Rect _childRect;

  // Snap-back animation (played after fingers lift).
  late AnimationController _snapCtrl;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _offsetAnim;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _snapCtrl.addListener(_onSnapTick);
    _snapCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) _cleanUp();
    });
  }

  void _onSnapTick() {
    // Drive the overlay with the animated values.
    _scale = _scaleAnim.value;
    _offset = _offsetAnim.value;
    _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Rect? _getChildRect() {
    final rb = _childKey.currentContext?.findRenderObject() as RenderBox?;
    if (rb == null || !rb.attached) return null;
    return rb.localToGlobal(Offset.zero) & rb.size;
  }

  // ── Gesture callbacks ─────────────────────────────────────────────────────

  void _onScaleStart(ScaleStartDetails details) {
    // Only activate for genuine pinch (2+ fingers).
    if (details.pointerCount < 2) return;
    if (_isZooming) return; // guard against duplicate starts

    final rect = _getChildRect();
    if (rect == null) return;

    _childRect = rect;
    _scale = 1.0;
    _offset = Offset.zero;
    _startFocalPoint = details.focalPoint;

    setState(() => _isZooming = true);

    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (!_isZooming) return;
    _scale = details.scale.clamp(1.0, 4.0);
    _offset = details.focalPoint - _startFocalPoint;
    _overlayEntry?.markNeedsBuild();
  }

  void _onScaleEnd(ScaleEndDetails details) {
    if (!_isZooming) return;

    // Tween from current state back to identity.
    _scaleAnim = Tween<double>(
      begin: _scale,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));
    _offsetAnim = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _snapCtrl, curve: Curves.easeOutCubic));

    _snapCtrl.forward(from: 0);
  }

  void _cleanUp() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _scale = 1.0;
    _offset = Offset.zero;
    if (mounted) setState(() => _isZooming = false);
  }

  // ── Overlay builder ───────────────────────────────────────────────────────

  Widget _buildOverlay() {
    // Dim the background proportionally to how much the user has zoomed.
    final bgOpacity = ((_scale - 1.0) / 3.0 * 0.82).clamp(0.0, 0.82);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dimming layer
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: bgOpacity)),
          ),
          // Zoomed image, translated to follow the pinch focal point.
          Positioned(
            left: _childRect.left + _offset.dx,
            top: _childRect.top + _offset.dy,
            width: _childRect.width,
            height: _childRect.height,
            child: Transform.scale(scale: _scale, child: widget.child),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Only scale callbacks — no tap callbacks — so single-touch gestures
      // (double-tap, PageView swipe) propagate to parent detectors freely.
      onScaleStart: _onScaleStart,
      onScaleUpdate: _onScaleUpdate,
      onScaleEnd: _onScaleEnd,
      onDoubleTap: widget.onDoubleTap,
      child: Opacity(
        key: _childKey,
        // Hide the original while the overlay is live so there's no ghost.
        opacity: _isZooming ? 0.0 : 1.0,
        child: widget.child,
      ),
    );
  }
}
