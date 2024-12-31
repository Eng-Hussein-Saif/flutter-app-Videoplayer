// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:husseintube/data.dart';
import 'package:husseintube/screens/home_screen.dart';
import 'package:husseintube/screens/video_screen.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SelectedVideo {
  final Video video;
  final YoutubePlayerController youtubeController;

  SelectedVideo({
    required this.video,
    required this.youtubeController,
  });
}

final selectedVideoProvider = StateProvider<SelectedVideo?>((ref) => null);

final miniPlayerControllerProvider =
    StateProvider.autoDispose<MiniplayerController>(
  (ref) => MiniplayerController(),
);

class NavScreen extends ConsumerStatefulWidget {
  const NavScreen({super.key});

  @override
  _NavScreenState createState() => _NavScreenState();
}

class _NavScreenState extends ConsumerState<NavScreen> {
  static const double _playerMinHeight = 60.0;

  int _selectedIndex = 4;

  final _screens = [
    const Scaffold(body: Center(child: Text('Explore'))),
    const Scaffold(body: Center(child: Text('Add'))),
    const Scaffold(body: Center(child: Text('Subscriptions'))),
    const Scaffold(body: Center(child: Text('Library'))),
    HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedVideo = ref.watch(selectedVideoProvider);
    final miniPlayerController = ref.watch(miniPlayerControllerProvider);

    return Scaffold(
      body: Stack(
        children: _screens
            .asMap()
            .map((i, screen) => MapEntry(
                  i,
                  Offstage(
                    offstage: _selectedIndex != i,
                    child: screen,
                  ),
                ))
            .values
            .toList()
          ..add(
            Offstage(
              offstage: selectedVideo == null,
              child: Miniplayer(
                controller: miniPlayerController,
                minHeight: _playerMinHeight,
                maxHeight: MediaQuery.of(context).size.height,
                builder: (height, percentage) {
                  if (selectedVideo == null) {
                    return const SizedBox.shrink();
                  }

                  if (height <= _playerMinHeight + 50.0) {
                    return Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Row(
                        children: [
                          Image.network(
                            selectedVideo.video.thumbnailUrl,
                            height: _playerMinHeight - 4.0,
                            width: 120.0,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                selectedVideo.video.title,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(color: Colors.white),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              selectedVideo.youtubeController.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (selectedVideo
                                  .youtubeController.value.isPlaying) {
                                selectedVideo.youtubeController.pause();
                              } else {
                                selectedVideo.youtubeController.play();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              ref.read(selectedVideoProvider.notifier).state =
                                  null;
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return VideoScreen(
                    video: selectedVideo.video,
                    youtubeController: selectedVideo.youtubeController,
                    relatedVideos: [], // Add the required relatedVideos parameter
                  );
                },
              ),
            ),
          ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = 4),
        selectedFontSize: 10.0,
        unselectedFontSize: 10.0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined, color: Colors.blue),
            activeIcon: Icon(Icons.person),
            label: 'انت',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined, color: Colors.blue),
            activeIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
            activeIcon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.subscriptions_outlined, color: Colors.blue),
            activeIcon: Icon(Icons.subscriptions),
            label: 'الاشتراكات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, color: Colors.blue),
            activeIcon: Icon(Icons.home),
            label: 'الصفحة الرئيسية',
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:husseintube/data.dart';
// import 'package:husseintube/screens/home_screen.dart';
// import 'package:husseintube/screens/video_screen.dart';
// import 'package:miniplayer/miniplayer.dart';

// final selectedVideoProvider = StateProvider<Video?>((ref) => null);

// final miniPlayerControllerProvider =
// StateProvider.autoDispose<MiniplayerController>(
//       (ref) => MiniplayerController(),
// );

// class NavScreen extends ConsumerStatefulWidget {
//   @override
//   _NavScreenState createState() => _NavScreenState();
// }

// class _NavScreenState extends ConsumerState<NavScreen> {
//   static const double _playerMinHeight = 60.0;

//   int _selectedIndex = 0;

//   final _screens = [
//     HomeScreen(),
//     const Scaffold(body: Center(child: Text('Explore'))),
//     const Scaffold(body: Center(child: Text('Add'))),
//     const Scaffold(body: Center(child: Text('Subscriptions'))),
//     const Scaffold(body: Center(child: Text('Library'))),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final selectedVideo = ref.watch(selectedVideoProvider);
//     final miniPlayerController = ref.watch(miniPlayerControllerProvider);

//     return Scaffold(

//       body: Stack(
//         children: _screens
//             .asMap()
//             .map((i, screen) => MapEntry(
//           i,
//           Offstage(
//             offstage: _selectedIndex != i,
//             child: screen,
//           ),
//         ))
//             .values
//             .toList()
//           ..add(
//             Offstage(
//               offstage: selectedVideo == null,
//               child: Miniplayer(
//                 controller: miniPlayerController,
//                 minHeight: _playerMinHeight,
//                 maxHeight: MediaQuery.of(context).size.height,
//                 builder: (height, percentage) {
//                   if (selectedVideo == null) {
//                     return const SizedBox.shrink();
//                   }

//                   if (height <= _playerMinHeight + 50.0) {
//                     return Container(
//                       color: Theme.of(context).scaffoldBackgroundColor,
//                       child: Column(
//                         children: [
//                           Row(
//                             children: [
//                               Image.network(
//                                 selectedVideo.thumbnailUrl,
//                                 height: _playerMinHeight - 4.0,
//                                 width: 120.0,
//                                 fit: BoxFit.cover,
//                               ),
//                               Expanded(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Flexible(
//                                         child: Text(
//                                           selectedVideo.title,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodySmall!
//                                               .copyWith(
//                                             color: Colors.white,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       Flexible(
//                                         child: Text(
//                                           selectedVideo.author.username,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodySmall!
//                                               .copyWith(
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.play_arrow),
//                                 onPressed: () {},
//                               ),
//                               IconButton(
//                                 icon: const Icon(Icons.close),
//                                 onPressed: () {
//                                   ref
//                                       .read(selectedVideoProvider.notifier)
//                                       .state = null;
//                                 },
//                               ),
//                             ],
//                           ),
//                           const LinearProgressIndicator(
//                             value: 0.4,
//                             valueColor: AlwaysStoppedAnimation<Color>(
//                               Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                   return VideoScreen();
//                 },
//               ),
//             ),
//           ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(

//         type: BottomNavigationBarType.fixed,
//         currentIndex: _selectedIndex,
//         onTap: (i) => setState(() => _selectedIndex = i),
//         selectedFontSize: 10.0,
//         unselectedFontSize: 10.0,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined , color: Colors.blue,),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',


//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.explore_outlined , color: Colors.blue),
//             activeIcon: Icon(Icons.explore),
//             label: 'Explore',
//           ),
//           BottomNavigationBarItem(

//             icon: Icon(Icons.add_circle_outline , color: Colors.blue),
//             activeIcon: Icon(Icons.add_circle),
//             label: 'Add',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.subscriptions_outlined , color: Colors.blue),
//             activeIcon: Icon(Icons.subscriptions),
//             label: 'Subscriptions',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_library_outlined , color: Colors.blue),
//             activeIcon: Icon(Icons.video_library),
//             label: 'Library',
//           ),
//         ],
//       ),
//     );
//   }
// }
