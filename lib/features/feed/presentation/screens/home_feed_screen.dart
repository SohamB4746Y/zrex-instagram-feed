import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feed_provider.dart';
import '../widgets/feed_shimmer.dart';
import '../widgets/post_widget.dart';
import '../widgets/story_tray.dart';

class HomeFeedScreen extends ConsumerStatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  ConsumerState<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends ConsumerState<HomeFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        title: const Text(
          'Instagram',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 28,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.favorite_border, size: 28),
          ),
          IconButton(
            onPressed: () => _showComingSoon(context),
            icon: const Icon(Icons.chat_bubble_outline, size: 24),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: feedState.when(
        data: (posts) => ListView.builder(
          itemCount: posts.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                children: const [
                  StoryTray(),
                  Divider(height: 1, thickness: 0.5),
                ],
              );
            }

            final postIndex = index - 1;
            if (postIndex >= posts.length - 2) {
              ref.read(feedProvider.notifier).loadMore();
            }

            if (postIndex >= posts.length) {
              final notifier = ref.read(feedProvider.notifier);
              if (notifier.hasMore) {
                return const PaginationLoadingIndicator();
              }
              return const SizedBox(height: 64);
            }

            return PostWidget(post: posts[postIndex]);
          },
        ),
        loading: () => SingleChildScrollView(
          child: Column(
            children: const [
              StoryTray(),
              Divider(height: 1, thickness: 0.5),
              FeedShimmer(),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(feedProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Feature coming soon',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
