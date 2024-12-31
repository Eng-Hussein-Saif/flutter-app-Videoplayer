// ignore_for_file: unnecessary_import, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:husseintube/data.dart';
import 'package:husseintube/widgets/video_card.dart';
import 'package:husseintube/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";
  Future<List<Video>>? _videoFuture;

  @override
  void initState() {
    super.initState();
    _loadTrendingVideos();
  }

  void _loadTrendingVideos() {
    setState(() {
      _videoFuture = fetchTrendingVideos();
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (_searchQuery.isEmpty) {
        _loadTrendingVideos();
      } else {
        _videoFuture = fetchVideosBySearch(_searchQuery);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(onSearch: _onSearch), // تمرير البحث
          FutureBuilder<List<Video>>(
            future: _videoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Failed to load videos: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'No trending videos available.'
                          : 'No results found for "$_searchQuery".',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                );
              } else {
                final videos = snapshot.data!;
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final video = videos[index];
                      return VideoCard(video: video, relatedVideos: videos);
                    },
                    childCount: videos.length,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}






// import 'package:flutter/material.dart';
// import 'package:husseintube/data.dart'; // إذا كانت Video في ملف مستقل
// import 'package:husseintube/widgets/widgets.dart';
//
// import '../data.dart'; // ملف يحتوي على دالة fetchTrendingVideos
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           CustomSliverAppBar(),
//           FutureBuilder<List<Video>>(
//             future: fetchTrendingVideos(), // جلب الفيديوهات الديناميكية
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               } else if (snapshot.hasError) {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: Text(
//                       'Failed to load videos: ${snapshot.error}',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 );
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return SliverToBoxAdapter(
//                   child: Center(
//                     child: Text(
//                       'No videos available.',
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                   ),
//                 );
//               } else {
//                 final videos = snapshot.data!;
//                 return SliverPadding(
//                   padding: const EdgeInsets.only(bottom: 60.0),
//                   sliver: SliverList(
//                     delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                         final video = videos[index];
//                         return VideoCard(video: video);
//                       },
//                       childCount: videos.length,
//                     ),
//                   ),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:husseintube/data.dart';
// import 'package:husseintube/widgets/widgets.dart';
//
// class HomeScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           CustomSliverAppBar(),
//           SliverPadding(
//             padding: const EdgeInsets.only(bottom: 60.0),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                 (context, index) {
//                   final video = videos[index];
//                   return VideoCard(video: video);
//                 },
//                 childCount: videos.length,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
