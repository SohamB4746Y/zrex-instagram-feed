import '../domain/post_model.dart';

abstract class IPostRepository {
  Future<List<Post>> fetchPosts({required int page, int limit = 10});
  Future<List<StoryUser>> fetchStories();
}

class PostRepositoryImpl implements IPostRepository {
  static const _simulatedDelay = Duration(milliseconds: 1500);

  static const _usernames = [
    'alex.wanderlust',
    'maria_designs',
    'john.creates',
    'sophia.lens',
    'david.eats',
    'emma_fitness',
    'lucas.music',
    'olivia.style',
    'noah.tech',
    'ava.travels',
    'liam.photo',
    'mia.kitchen',
    'ethan.surf',
    'charlotte.art',
    'james.explore',
  ];

  static const _captions = [
    'Golden hour never disappoints ✨ #photography #sunset',
    'Exploring hidden gems in every corner of the city 🏙',
    'Morning coffee and good vibes ☕ #lifestyle',
    'Nature always finds a way 🌿 #outdoors #hiking',
    'Adventures are the best way to learn 🌍',
    'Creating something beautiful today 🎨',
    'The view from up here is incredible 🏔',
    'Simple things make the best memories',
    'Just another day in paradise 🌴',
    'Living my best life, one step at a time 🚶‍♂️',
    'Food is art, and I am the artist',
    'Sundays are for exploring 🗺',
    'Catch me where the wild things are 🌾',
    'Making waves 🌊 #ocean #surf',
    'Chasing light and shadows 📸',
  ];

  // Reliable avatar URLs using UI Faces / randomuser style direct URLs
  static const _avatarUrls = [
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1527980965255-d3b416303d12?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150&h=150&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&h=150&fit=crop&crop=face',
  ];

  // High-quality post images from Unsplash (direct URLs, no API key needed)
  static const _postImageUrls = [
    'https://images.unsplash.com/photo-1682687220742-aba13b6e50ba?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1682687221038-404670f09ef1?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1447752875215-b2761acb3c5d?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1433086966358-54859d0ed716?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1475924156734-496f6cac6ec1?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1540206395-68808572332f?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1546587348-d12660c30c50?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1485470733090-0aae1788d668?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1518173946687-a1e8df1bc6e1?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1504198453319-5ce911bafcde?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1444464666168-49d633b86797?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1558618666-fcd25c85f82e?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1543357480-c60d40007a3f?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1471922694854-ff1b63b20054?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1530789253388-582c481c54b0?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=600&h=750&fit=crop',
    'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=600&h=750&fit=crop',
  ];

  String _postImageUrl(int index) {
    return _postImageUrls[index % _postImageUrls.length];
  }

  String _avatarUrl(int index) {
    return _avatarUrls[index % _avatarUrls.length];
  }

  @override
  Future<List<Post>> fetchPosts({required int page, int limit = 10}) async {
    await Future.delayed(_simulatedDelay);

    final startIndex = page * limit;
    return List.generate(limit, (i) {
      final globalIndex = startIndex + i;
      final userIndex = globalIndex % _usernames.length;
      final isCarousel = globalIndex % 4 == 0;

      final images = isCarousel
          ? List.generate(
              3,
              (imgIdx) => _postImageUrl(globalIndex * 3 + imgIdx),
            )
          : [_postImageUrl(globalIndex)];

      return Post(
        id: 'post_$globalIndex',
        username: _usernames[userIndex],
        userAvatarUrl: _avatarUrl(userIndex),
        imageUrls: images,
        caption: _captions[globalIndex % _captions.length],
        likeCount: (globalIndex * 137 + 42) % 9999,
        timeAgo: '${(globalIndex % 23) + 1}h',
      );
    });
  }

  @override
  Future<List<StoryUser>> fetchStories() async {
    await Future.delayed(const Duration(milliseconds: 800));

    return List.generate(15, (i) {
      return StoryUser(
        username: _usernames[i % _usernames.length],
        avatarUrl: _avatarUrl(i),
        hasUnseenStory: i < 10,
      );
    });
  }
}
