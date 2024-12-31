import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final String username;
  final String profileImageUrl;
  final String subscribers;

  const User({
    required this.username,
    required this.profileImageUrl,
    required this.subscribers,
  });
}

class Video {
  final String id;
  final User author;
  final String title;
  final String thumbnailUrl;
  final String duration;
  final DateTime timestamp;
  final String viewCount;
  final String likes;
  final String dislikes;

  const Video({
    required this.id,
    required this.author,
    required this.title,
    required this.thumbnailUrl,
    required this.duration,
    required this.timestamp,
    required this.viewCount,
    required this.likes,
    required this.dislikes,
  });

  // دالة لتحويل البيانات القادمة من API إلى كائن Video
  factory Video.fromJson(Map<String, dynamic> json, String subscribers) {
    final snippet = json['snippet'] ?? {};
    final contentDetails = json['contentDetails'] ?? {};
    final statistics = json['statistics'] ?? {};

    final id = json['id'] is Map && json['id']['videoId'] != null
        ? json['id']['videoId']
        : json['id'] ?? '';

    return Video(
      id: id,
      author: User(
        username: snippet['channelTitle'] ?? 'Unknown Channel',
        profileImageUrl: snippet['thumbnails']?['default']?['url'] ??
            'https://via.placeholder.com/150',
        subscribers: subscribers,
      ),
      title: snippet['title'] ?? 'No Title',
      thumbnailUrl: snippet['thumbnails']?['high']?['url'] ??
          'https://via.placeholder.com/320x180',
      duration: parseDuration(contentDetails['duration'] ?? 'PT0H0M0S'),
      timestamp:
          DateTime.tryParse(snippet['publishedAt'] ?? '') ?? DateTime.now(),
      viewCount:
          formatViewCount(int.tryParse(statistics['viewCount'] ?? '0') ?? 0),
      likes: statistics['likeCount']?.toString() ?? 'N/A',
      dislikes: statistics['dislikeCount']?.toString() ?? 'N/A',
    );
  }
}

// جلب عدد المشتركين من القناة باستخدام channelId
Future<String> fetchSubscribers(String channelId) async {
  const String apiKey = 'AIzaSyDGX8shj0UhADKsbUrhQAomTkNVtQQgW9A';
  final String apiUrl =
      'https://www.googleapis.com/youtube/v3/channels?part=statistics&id=$channelId&key=$apiKey';

  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['items'] != null && data['items'].isNotEmpty) {
      final subscribersCount =
          data['items'][0]['statistics']['subscriberCount'] ?? '0';
      return formatViewCount(int.tryParse(subscribersCount) ?? 0);
    }
  }

  return 'N/A';
}

Future<List<Video>> fetchTrendingVideos() async {
  try {
    const String apiKey = 'AIzaSyDGX8shj0UhADKsbUrhQAomTkNVtQQgW9A';
    const String apiUrl =
        'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&chart=mostPopular&regionCode=US&maxResults=10&key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['items'] != null) {
        final List videosJson = data['items'];

        final List<Future<Video>> videoFutures = videosJson.map((json) async {
          final channelId = json['snippet']['channelId'] ?? '';
          final subscribers = await fetchSubscribers(channelId);
          return Video.fromJson(json, subscribers);
        }).toList();

        return Future.wait(videoFutures);
      } else {
        throw Exception('No videos found');
      }
    } else {
      throw Exception(
          'Failed to fetch trending videos: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Error fetching trending videos: $e');
    return [];
  }
}

// تحويل مدة الفيديو
String parseDuration(String duration) {
  final regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
  final match = regex.firstMatch(duration);

  if (match == null) return '0:00';

  final hours = int.tryParse(match.group(1)?.replaceAll('H', '') ?? '0') ?? 0;
  final minutes = int.tryParse(match.group(2)?.replaceAll('M', '') ?? '0') ?? 0;
  final seconds = int.tryParse(match.group(3)?.replaceAll('S', '') ?? '0') ?? 0;

  if (hours > 0) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else {
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

// تنسيق عدد المشاهدات أو المشتركين
String formatViewCount(int count) {
  if (count >= 1000000000) {
    return '${(count / 1000000000).toStringAsFixed(1)} مليار';
  } else if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)} مليون';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)} ألف';
  } else {
    return '$count';
  }
}

// Future<List<Video>> fetchRelatedVideos(String videoId) async {
//   const String apiKey = 'AIzaSyDGX8shj0UhADKsbUrhQAomTkNVtQQgW9A';
//   final String apiUrl =
//       'https://www.googleapis.com/youtube/v3/search?part=snippet&relatedToVideoId=$videoId&type=video&maxResults=10&key=$apiKey';

//   final response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);

//     if (data['items'] != null) {
//       final List videosJson = data['items'];

//       // استخراج تفاصيل الفيديوهات ذات الصلة
//       final videoIds = videosJson
//           .map((result) => result['id']['videoId'])
//           .where((id) => id != null)
//           .join(',');

//       if (videoIds.isEmpty) {
//         throw Exception('No video IDs found');
//       }

//       final String detailsApiUrl =
//           'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=$videoIds&key=$apiKey';

//       final detailsResponse = await http.get(Uri.parse(detailsApiUrl));

//       if (detailsResponse.statusCode == 200) {
//         final detailsData = json.decode(detailsResponse.body);

//         if (detailsData['items'] != null) {
//           final List relatedVideosJson = detailsData['items'];

//           final List<Future<Video>> relatedVideoFutures =
//               relatedVideosJson.map((json) async {
//             final channelId = json['snippet']['channelId'] ?? '';
//             final subscribers = await fetchSubscribers(channelId);
//             return Video.fromJson(json, subscribers);
//           }).toList();

//           return Future.wait(relatedVideoFutures);
//         } else {
//           throw Exception('No related video details found');
//         }
//       } else {
//         throw Exception(
//             'Failed to fetch related video details: ${detailsResponse.statusCode}');
//       }
//     } else {
//       throw Exception('No related videos found');
//     }
//   } else {
//     throw Exception('Failed to fetch related videos: ${response.statusCode}');
//   }
// }

Future<List<Video>> fetchVideosBySearch(String query) async {
  const String apiKey = 'AIzaSyDGX8shj0UhADKsbUrhQAomTkNVtQQgW9A';
  final String searchApiUrl =
      'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=$query&maxResults=10&key=$apiKey';

  final response = await http.get(Uri.parse(searchApiUrl));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['items'] != null) {
      final List searchResults = data['items'];

      // استخراج videoIds من نتائج البحث
      final videoIds = searchResults
          .map((result) => result['id']['videoId'])
          .where((id) => id != null)
          .join(',');

      if (videoIds.isEmpty) {
        throw Exception('No video IDs found');
      }

      // استدعاء API لجلب التفاصيل باستخدام الفيديوهات المستخرجة
      final String detailsApiUrl =
          'https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics,contentDetails&id=$videoIds&key=$apiKey';

      final detailsResponse = await http.get(Uri.parse(detailsApiUrl));

      if (detailsResponse.statusCode == 200) {
        final detailsData = json.decode(detailsResponse.body);

        if (detailsData['items'] != null) {
          final List videosJson = detailsData['items'];

          // جلب عدد المشتركين لكل قناة
          final List<Future<Video>> videoFutures = videosJson.map((json) async {
            final channelId = json['snippet']['channelId'] ?? '';
            final subscribers = await fetchSubscribers(channelId);
            return Video.fromJson(json, subscribers); // تمرير الوسيطين
          }).toList();

          return Future.wait(videoFutures); // انتظار كل الطلبات
        } else {
          throw Exception('No video details found');
        }
      } else {
        throw Exception(
            'Failed to fetch video details: ${detailsResponse.statusCode}');
      }
    } else {
      throw Exception('No items found in search results');
    }
  } else {
    throw Exception('Failed to fetch videos: ${response.statusCode}');
  }
}



// Future<List<Video>> fetchVideosBySearch(String query) async {
//   const String apiKey =
//       'AIzaSyDGX8shj0UhADKsbUrhQAomTkNVtQQgW9A'; // استبدل بمفتاح API الخاص بك
//   final String apiUrl =
//       'https://www.googleapis.com/youtube/v3/search?part=snippet&type=video&q=$query&maxResults=1000&key=$apiKey';

//   final response = await http.get(Uri.parse(apiUrl));

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);

//     // تأكد من وجود 'items' في الاستجابة
//     if (data['items'] != null) {
//       final List videosJson = data['items'];
//       return videosJson.map((json) => Video.fromJson(json)).toList();
//     } else {
//       throw Exception('No items found in search results');
//     }
//   } else {
//     throw Exception('Failed to fetch videos: ${response.statusCode}');
//   }
// }







//===============================================================================

// factory Video.fromJson(Map<String, dynamic> json) {
//   return Video(
//     id: json['id'],
//     author: User(
//       username: json['snippet']['channelTitle'],
//       profileImageUrl: json['snippet']['thumbnails']['default']['url'] ?? CircleAvatar(
//         backgroundColor: Colors.blue,
//         child: Text('Hs'),
//
//       ),
//       subscribers: 'N/A', // غير متوفر في API للبيانات الرائجة مباشرةً
//     ),
//     title: json['snippet']['title'],
//     thumbnailUrl: json['snippet']['thumbnails']['high']['url'],
//     duration: parseDuration(json['contentDetails']['duration']),
//     timestamp: DateTime.parse(json['snippet']['publishedAt']),
//     viewCount: json['statistics']?['viewCount'] ?? 'N/A',
//     likes: json['statistics']?['likeCount'] ?? 'N/A',
//     dislikes: 'N/A', // غير متوفر في API
//   );
// }
// }

// ========================



// class User {
//   final String username;
//   final String profileImageUrl;
//   final String subscribers;
//
//   const User({
//     required this.username,
//     required this.profileImageUrl,
//     required this.subscribers,
//   });
// }
//
// const User currentUser = User(
//   username: 'Marcus Ng',
//   profileImageUrl:
//       'https://yt3.ggpht.com/ytc/AAUvwniE2k5PgFu9yr4sBVEs9jdpdILdMc7ruiPw59DpS0k=s88-c-k-c0x00ffffff-no-rj',
//   subscribers: '100K',
// );
//
// class Video {
//   final String id;
//   final User author;
//   final String title;
//   final String thumbnailUrl;
//   final String duration;
//   final DateTime timestamp;
//   final String viewCount;
//   final String likes;
//   final String dislikes;
//
//   const Video({
//     required this.id,
//     required this.author,
//     required this.title,
//     required this.thumbnailUrl,
//     required this.duration,
//     required this.timestamp,
//     required this.viewCount,
//     required this.likes,
//     required this.dislikes,
//   });
// }
//
// final List<Video> videos = [
//   Video(
//     id: 'x606y4QWrxo',
//     author: currentUser,
//     title: 'Flutter Clubhouse Clone UI Tutorial | Apps From Scratch',
//     thumbnailUrl: 'https://i.ytimg.com/vi/x606y4QWrxo/0.jpg',
//     duration: '8:20',
//     timestamp: DateTime(2021, 3, 20),
//     viewCount: '10K',
//     likes: '958',
//     dislikes: '4',
//   ),
//   Video(
//     author: currentUser,
//     id: 'vrPk6LB9bjo',
//     title:
//         'Build Flutter Apps Fast with Riverpod, Firebase, Hooks, and Freezed Architecture',
//     thumbnailUrl: 'https://i.ytimg.com/vi/vrPk6LB9bjo/0.jpg',
//     duration: '22:06',
//     timestamp: DateTime(2021, 2, 26),
//     viewCount: '8K',
//     likes: '485',
//     dislikes: '8',
//   ),
//   Video(
//     id: 'ilX5hnH8XoI',
//     author: currentUser,
//     title: 'Flutter Instagram Stories',
//     thumbnailUrl: 'https://i.ytimg.com/vi/ilX5hnH8XoI/0.jpg',
//     duration: '10:53',
//     timestamp: DateTime(2020, 7, 12),
//     viewCount: '18K',
//     likes: '1k',
//     dislikes: '4',
//   ),
// ];
//
// final List<Video> suggestedVideos = [
//   Video(
//     id: 'rJKN_880b-M',
//     author: currentUser,
//     title: 'Flutter Netflix Clone Responsive UI Tutorial | Web and Mobile',
//     thumbnailUrl: 'https://i.ytimg.com/vi/rJKN_880b-M/0.jpg',
//     duration: '1:13:15',
//     timestamp: DateTime(2020, 8, 22),
//     viewCount: '32K',
//     likes: '1.9k',
//     dislikes: '7',
//   ),
//   Video(
//     id: 'HvLb5gdUfDE',
//     author: currentUser,
//     title: 'Flutter Facebook Clone Responsive UI Tutorial | Web and Mobile',
//     thumbnailUrl: 'https://i.ytimg.com/vi/HvLb5gdUfDE/0.jpg',
//     duration: '1:52:12',
//     timestamp: DateTime(2020, 8, 7),
//     viewCount: '190K',
//     likes: '9.3K',
//     dislikes: '45',
//   ),
//   Video(
//     id: 'h-igXZCCrrc',
//     author: currentUser,
//     title: 'Flutter Chat UI Tutorial | Apps From Scratch',
//     thumbnailUrl: 'https://i.ytimg.com/vi/h-igXZCCrrc/0.jpg',
//     duration: '1:03:58',
//     timestamp: DateTime(2019, 10, 17),
//     viewCount: '358K',
//     likes: '20k',
//     dislikes: '85',
//   ),
// ];
