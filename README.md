# Instagram Home Feed Replica (Flutter)

Pixel-focused Instagram Home Feed replication for the ZREX UI/UX technical challenge.

## State Management Choice

This project uses **Riverpod (`flutter_riverpod`)** because it gives:
- clear separation between UI and business/data logic,
- testable providers/notifiers,
- predictable async state handling for loading, success, pagination, and error states.

`FeedNotifier` manages:
- initial feed fetch,
- pagination (`loadMore`),
- local post interactions (`toggleLike`, `toggleSave`).

## Implemented Deliverables

- Instagram-like top bar + stories tray + feed layout
- Mock data repository with **1.5s simulated latency**
- Shimmer loading states (stories + feed + pagination)
- Network image strategy with `cached_network_image` (no bundled post assets)
- Carousel posts with synchronized dot indicator + index badge
- Pinch-to-zoom image overlay with snap-back animation
- Local state toggles for **Like** and **Save**
- Custom floating snackbar for unimplemented actions (Comments/Share/Header actions)
- Infinite scroll pagination (loads when user reaches the final 2 posts)
- Network image failure fallbacks for avatars and post media

## Project Structure

```text
lib/
  core/
    theme/
    widgets/
  features/
    feed/
      data/
      domain/
      presentation/
        providers/
        screens/
        widgets/
```

## Run Instructions

### Prerequisites
- Flutter SDK (stable)
- Dart SDK (bundled with Flutter)

### Install dependencies
```bash
flutter pub get
```

### Run app
```bash
flutter run
```

### Analyze
```bash
flutter analyze
```

### Test
```bash
flutter test
```

## Notes for Submission

- This repository includes all requested deliverables except the demo video.
- Replace this line with your final public GitHub URL after publishing.
