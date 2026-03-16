import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pinch_zoom_overlay.dart';
import '../../domain/post_model.dart';
import '../providers/feed_provider.dart';

class PostWidget extends StatelessWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PostHeader(post: post),
        _PostMedia(post: post),
        _PostActions(post: post),
        _PostLikeCount(likeCount: post.likeCount),
        _PostCaption(post: post),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PostHeader extends StatelessWidget {
  final Post post;

  const _PostHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
              imageUrl: post.userAvatarUrl,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              placeholder: (_, p) => Container(
                width: 36,
                height: 36,
                color: AppColors.shimmerBase,
              ),
              errorWidget: (_, e, st) => Container(
                width: 36,
                height: 36,
                color: AppColors.shimmerBase,
                child: const Icon(Icons.person, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              post.username,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Icon(Icons.more_horiz, size: 20),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  final Post post;

  const _PostMedia({required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.imageUrls.length > 1) {
      return _CarouselMedia(imageUrls: post.imageUrls);
    }
    return PinchZoomOverlay(
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: CachedNetworkImage(
          imageUrl: post.imageUrls.first,
          fit: BoxFit.cover,
          placeholder: (_, p) => Container(color: AppColors.shimmerBase),
          errorWidget: (_, e, st) => Container(
            color: AppColors.shimmerBase,
            child: const Icon(Icons.broken_image, size: 48),
          ),
        ),
      ),
    );
  }
}

class _CarouselMedia extends StatefulWidget {
  final List<String> imageUrls;

  const _CarouselMedia({required this.imageUrls});

  @override
  State<_CarouselMedia> createState() => _CarouselMediaState();
}

class _CarouselMediaState extends State<_CarouselMedia> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemBuilder: (context, index) {
              return PinchZoomOverlay(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (_, p) =>
                      Container(color: AppColors.shimmerBase),
                  errorWidget: (_, e, st) => Container(
                    color: AppColors.shimmerBase,
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              );
            },
          ),
          // Page indicator dots
          Positioned(
            bottom: 12,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 8 : 6,
                  height: _currentPage == index ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF0095F6)
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                );
              }),
            ),
          ),
          // Page counter badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentPage + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostActions extends ConsumerWidget {
  final Post post;

  const _PostActions({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => ref.read(feedProvider.notifier).toggleLike(post.id),
            child: Icon(
              post.isLiked ? Icons.favorite : Icons.favorite_border,
              size: 28,
              color: post.isLiked ? AppColors.heartRed : AppColors.black,
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showComingSoon(context),
            child: const Icon(Icons.chat_bubble_outline, size: 24),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _showComingSoon(context),
            child: const Icon(Icons.send_outlined, size: 24),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ref.read(feedProvider.notifier).toggleSave(post.id),
            child: Icon(
              post.isSaved ? Icons.bookmark : Icons.bookmark_border,
              size: 28,
            ),
          ),
        ],
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

class _PostLikeCount extends StatelessWidget {
  final int likeCount;

  const _PostLikeCount({required this.likeCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${_formatCount(likeCount)} likes',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _PostCaption extends StatelessWidget {
  final Post post;

  const _PostCaption({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 13),
          children: [
            TextSpan(
              text: post.username,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const TextSpan(text: ' '),
            TextSpan(text: post.caption),
          ],
        ),
      ),
    );
  }
}
