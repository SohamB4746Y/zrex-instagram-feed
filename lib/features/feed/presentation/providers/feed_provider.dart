import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/post_repository.dart';
import '../../domain/post_model.dart';

final postRepositoryProvider = Provider<IPostRepository>((ref) {
  return PostRepositoryImpl();
});

final feedProvider = AsyncNotifierProvider<FeedNotifier, List<Post>>(
  FeedNotifier.new,
);

class FeedNotifier extends AsyncNotifier<List<Post>> {
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  Future<List<Post>> build() async {
    _currentPage = 0;
    _isLoadingMore = false;
    _hasMore = true;
    final repo = ref.read(postRepositoryProvider);
    return repo.fetchPosts(page: 0);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    final repo = ref.read(postRepositoryProvider);
    _currentPage++;

    try {
      final newPosts = await repo.fetchPosts(page: _currentPage);
      if (newPosts.isEmpty) {
        _hasMore = false;
      } else {
        final currentPosts = state.valueOrNull ?? [];
        state = AsyncData([...currentPosts, ...newPosts]);
      }
    } catch (e) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  void toggleLike(String postId) {
    final currentPosts = state.valueOrNull;
    if (currentPosts == null) return;

    state = AsyncData(
      currentPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(
            isLiked: !post.isLiked,
            likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount + 1,
          );
        }
        return post;
      }).toList(),
    );
  }

  void toggleSave(String postId) {
    final currentPosts = state.valueOrNull;
    if (currentPosts == null) return;

    state = AsyncData(
      currentPosts.map((post) {
        if (post.id == postId) {
          return post.copyWith(isSaved: !post.isSaved);
        }
        return post;
      }).toList(),
    );
  }
}

final storiesProvider = FutureProvider<List<StoryUser>>((ref) async {
  final repo = ref.read(postRepositoryProvider);
  return repo.fetchStories();
});
