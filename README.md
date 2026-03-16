# Instagram Home Feed Replica (Flutter)

Pixel-perfect Instagram Home Feed replication featuring advanced animations and gesture interactions for the ZREX UI/UX technical challenge.

## Key Features

### ✨ Animations
- **Double-Tap Flying Heart**: 750ms smooth scale-in/hold/fade with custom easing curves on image double-tap
- **Like Button Bounce**: 350ms TweenSequence bounce (1.0 → 1.45 → 0.85 → 1.0) with ScaleTransition on tap
- **Carousel Dot Indicator**: Synchronized page indicator with smooth AnimatedContainer transitions
- **Pinch-to-Zoom Overlay**: Interactive 4× zoom with matrix-based snap-back animation (250ms easing)
- **Shimmer Loading States**: 1.5s initial delay + pagination shimmer with gradient wave effect

### 🎯 Core Functionality
- **Infinite Pagination**: Lazy-loads 10 posts per page when user is 2 posts from bottom
- **Carousel Posts**: Multi-image support with synchronized dot indicator + index badge
- **Local State Interactions**: Like/Save toggle with optimistic UI updates
- **Image Caching**: `cached_network_image` for memory + disk caching (600×750 dimensions for speed)
- **Error Handling**: Graceful fallbacks for failed network images

## State Management

**Riverpod (`flutter_riverpod`)** is used for:
- Clear separation of concerns (UI ↔ Business Logic ↔ Data Layer)
- Testable AsyncNotifier providers with reactive state
- Predictable async handling (loading → success → error)
- Immutable, type-safe notifiers

`FeedNotifier` manages:
- Initial feed fetch with 1.5s simulated latency
- Pagination with `loadMore()` logic
- Post interactions: `toggleLike()`, `toggleSave()`

## Project Architecture

```text
lib/
  core/
    theme/
      app_colors.dart         (Instagram color palette)
    widgets/
      pinch_zoom_overlay.dart (Pinch-to-zoom with snap-back)
  features/
    feed/
      data/
        post_repository.dart  (Mock data + network images)
      domain/
        post_model.dart       (Post, StoryUser models)
      presentation/
        providers/
          feed_provider.dart  (Riverpod notifiers)
        screens/
          home_feed_screen.dart (Main feed UI)
        widgets/
          post_widget.dart    (Post component + animations)
          story_tray.dart     (Stories carousel)
          feed_shimmer.dart   (Loading skeletons)
```

## Implementation Details

### Double-Tap Heart Animation
```dart
// In _PostMediaState (ConsumerStatefulWidget)
void _onDoubleTap() {
  if (!widget.post.isLiked) {
    ref.read(feedProvider.notifier).toggleLike(widget.post.id);
  }
  setState(() => _heartVisible = true);
  _heartCtrl.forward(from: 0);  // 750ms animation
}
```
- Uses `AnimationController` with custom easing curves
- Scales from 1.0 → 1.2 (pop), holds, then fades out
- IgnorePointer prevents interaction during animation

### Like Button Bounce
```dart
// In _PostActionsState (ConsumerStatefulWidget)
_likeScale = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
  TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.85), weight: 30),
  TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 30),
]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeInOut));
```
- Triggers on every tap (not just on state change)
- Provides tactile feedback with visual squash/stretch
- Applied via `ScaleTransition`

### Pinch-to-Zoom
```dart
// _SnapBackOverlay (AnimatedWidget)
// Animates matrix from zoomed state back to identity via easeOutCubic
```
- Uses `TransformationController` for InteractiveViewer
- Overlay positioned at original rect coordinates
- Snap-back animation runs until completion, then removes overlay

## Performance Optimizations

| Optimization | Benefit |
|---|---|
| Image dimensions (600×750) | ~3× faster than 1080×1350 URLs |
| `cached_network_image` | Memory+disk caching prevents reload |
| `ListView.builder` | Only renders visible posts |
| Shimmer instead of spinner | More polished loading state |
| `Physics: NeverScrollableScrollPhysics` | No double-scroll on shimmer |

## Run Instructions

### Prerequisites
```bash
flutter --version  # 3.11.1+
dart --version     # included with Flutter
```

### Install Dependencies
```bash
flutter pub get
```

### Run on Simulator/Device
```bash
# Debug mode (fastest build)
flutter run

# Specific device
flutter run -d "iPhone 17 Pro Max"

# Hot reload in terminal
# Press 'r' to hot reload, 'R' to restart, 'q' to quit
```

### Quality Checks
```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Check dependencies
flutter pub outdated
```

## Video Demo

The app demonstrates:
1. **Loading State**: Shimmer effect appears for 1.5s
2. **Infinite Scroll**: Pull to bottom → pagination shimmer → 10 new posts
3. **Double-Tap Heart**: Tap image twice → flying heart scales in/out
4. **Like Button Bounce**: Tap heart icon → bounce animation + like count update
5. **Pinch-to-Zoom**: Two-finger pinch on image → 4× zoom overlay
6. **Carousel**: Swipe multi-image posts → page dots sync smoothly

## Submission Checklist

- ✅ GitHub repo: https://github.com/SohamB4746Y/zrex-instagram-feed
- ✅ Clean README with state management explanation
- ✅ Pixel-perfect UI (spacing, typography, colors match Instagram)
- ✅ Smooth animations (no jank, 60fps target)
- ✅ Advanced interactions (pinch-zoom, double-tap, infinite scroll)
- ✅ Proper architecture (Riverpod, separation of concerns)
- ✅ Code is production-ready (flutter analyze: 0 issues)

## Technical Decisions

1. **Riverpod over Provider/GetX**: Immutability, async-first design, testability
2. **AnimationController over implicit animations**: Fine-grained control over complex sequences
3. **Custom AnimatedWidget for snap-back**: Direct matrix manipulation for smooth easing
4. **picsum.photos for images**: High-quality, consistent, fast fallback
5. **Shimmer over CircularProgressIndicator**: More polished, matches Instagram's design language

