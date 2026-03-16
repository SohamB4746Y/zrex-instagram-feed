class Post {
  final String id;
  final String username;
  final String userAvatarUrl;
  final List<String> imageUrls;
  final bool isLiked;
  final bool isSaved;
  final String caption;
  final int likeCount;
  final String timeAgo;

  const Post({
    required this.id,
    required this.username,
    required this.userAvatarUrl,
    required this.imageUrls,
    this.isLiked = false,
    this.isSaved = false,
    this.caption = '',
    this.likeCount = 0,
    this.timeAgo = '1h',
  });

  Post copyWith({
    String? id,
    String? username,
    String? userAvatarUrl,
    List<String>? imageUrls,
    bool? isLiked,
    bool? isSaved,
    String? caption,
    int? likeCount,
    String? timeAgo,
  }) {
    return Post(
      id: id ?? this.id,
      username: username ?? this.username,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      caption: caption ?? this.caption,
      likeCount: likeCount ?? this.likeCount,
      timeAgo: timeAgo ?? this.timeAgo,
    );
  }
}

class StoryUser {
  final String username;
  final String avatarUrl;
  final bool hasUnseenStory;

  const StoryUser({
    required this.username,
    required this.avatarUrl,
    this.hasUnseenStory = true,
  });
}
