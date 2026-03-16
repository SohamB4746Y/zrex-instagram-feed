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

class _PostMedia extends ConsumerStatefulWidget {
  final Post post;

  const _PostMedia({required this.post});

  @override
  ConsumerState<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends ConsumerState<_PostMedia>
    with SingleTickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  bool _heartVisible = false;

  @override
  void initState() {
    super.initState();
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed && mounted) {
          setState(() => _heartVisible = false);
        }
      });
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (!widget.post.isLiked) {
      ref.read(feedProvider.notifier).toggleLike(widget.post.id);
    }
    setState(() => _heartVisible = true);
    _heartCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post.imageUrls.length > 1
        ? _CarouselMedia(imageUrls: widget.post.imageUrls)
        : PinchZoomOverlay(
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: CachedNetworkImage(
                imageUrl: widget.post.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (_, p) =>
                    Container(color: AppColors.shimmerBase),
                errorWidget: (_, e, st) => Container(
                  color: AppColors.shimmerBase,
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),
          );

    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          media,
          if (_heartVisible)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _heartCtrl,
                builder: (context, _) {
                  final t = _heartCtrl.value;
                  final scale = _heartScale(t);
                  final opacity = _heartOpacity(t);
                  return Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: opacity,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 96,
                        shadows: [Shadow(color: Colors.black38, blurRadius: 12)],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  static double _heartScale(double t) {
    if (t < 0.3) return (t / 0.3) * 1.2;
    if (t < 0.5) return 1.2 - ((t - 0.3) / 0.2) * 0.2;
    if (t < 0.72) return 1.0;
    return 1.0 - ((t - 0.72) / 0.28);
  }

  static double _heartOpacity(double t) {
    if (t < 0.15) return t / 0.15;
    if (t < 0.68) return 1.0;
    return 1.0 - ((t - 0.68) / 0.32);
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

class _PostActions extends ConsumerStatefulWidget {
  final Post post;

  const _PostActions({required this.post});

  @override
  ConsumerState<_PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends ConsumerState<_PostActions>
    with SingleTickerProviderStateMixin {
  late final AnimationController _likeCtrl;
  late final Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _likeScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 0.85), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _likeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _likeCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    ref.read(feedProvider.notifier).toggleLike(widget.post.id);
    _likeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: ScaleTransition(
              scale: _likeScale,
              child: Icon(
                widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 28,
                color:
                    widget.post.isLiked ? AppColors.heartRed : AppColors.black,
              ),
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
            onTap: () =>
                ref.read(feedProvider.notifier).toggleSave(widget.post.id),
            child: Icon(
              widget.post.isSaved ? Icons.bookmark : Icons.bookmark_border,
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
