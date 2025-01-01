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
