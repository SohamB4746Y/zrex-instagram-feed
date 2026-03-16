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

  static const _avatarUrls = [
    'https://i.pravatar.cc/150?img=1',
    'https://i.pravatar.cc/150?img=2',
    'https://i.pravatar.cc/150?img=3',
    'https://i.pravatar.cc/150?img=4',
    'https://i.pravatar.cc/150?img=5',
    'https://i.pravatar.cc/150?img=6',
    'https://i.pravatar.cc/150?img=7',
    'https://i.pravatar.cc/150?img=8',
    'https://i.pravatar.cc/150?img=9',
    'https://i.pravatar.cc/150?img=10',
    'https://i.pravatar.cc/150?img=11',
    'https://i.pravatar.cc/150?img=12',
    'https://i.pravatar.cc/150?img=13',
    'https://i.pravatar.cc/150?img=14',
    'https://i.pravatar.cc/150?img=15',
  ];

  static const _imageBaseUrls = ['https://picsum.photos/seed/'];

  String _postImageUrl(int seed, {int width = 600, int height = 750}) {
    return '${_imageBaseUrls[0]}post_$seed/$width/$height';
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
              (imgIdx) => _postImageUrl(globalIndex * 10 + imgIdx),
            )
          : [_postImageUrl(globalIndex * 10)];

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
