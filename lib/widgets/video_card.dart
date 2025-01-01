import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:husseintube/data.dart';
import 'package:husseintube/screens/video_screen.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../screens/nav_screen.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final bool hasPadding;
  final VoidCallback? onTap;
  final List<Video> relatedVideos; // قائمة الفيديوهات المناسبة

  const VideoCard({
    Key? key,
    required this.video,
    this.hasPadding = false,
    this.onTap,
    required this.relatedVideos, // تمرير الفيديوهات هنا
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        return GestureDetector(
          onTap: () {
            final youtubeController = YoutubePlayerController(
              initialVideoId: video.id,
              flags: const YoutubePlayerFlags(
                autoPlay: true,
                mute: false,
                enableCaption: false, // تعطيل الترجمة
                forceHD: false, // عدم إجبار الفيديو على دقة عالية جدًا
                loop: false, // منع تكرار الفيديو
                useHybridComposition: true, // تحسين الأداء على نظام Android
                showLiveFullscreenButton: true,
              ),
            );

            ref.read(selectedVideoProvider.notifier).state = SelectedVideo(
              video: video,
              youtubeController: youtubeController,
            );

            ref
                .read(miniPlayerControllerProvider)
                .animateToHeight(state: PanelState.MAX);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoScreen(
                  video: video,
                  youtubeController: youtubeController,
                  relatedVideos: relatedVideos, // تمرير الفيديوهات المناسبة
                ),
              ),
            );

            if (onTap != null) onTap!();
          },
          child: Column(
            children: [
              Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hasPadding ? 12.0 : 0,
                    ),
                    child: Image.network(
                      video.thumbnailUrl,
                      height: 220.0,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 8.0,
                    right: hasPadding ? 20.0 : 8.0,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      color: Colors.black,
                      child: Text(
                        video.duration,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  textDirection: TextDirection.rtl,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => print('Navigate to profile'),
                      child: CircleAvatar(
                        foregroundImage:
                            NetworkImage(video.author.profileImageUrl),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              video.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 15.0),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '${video.author.username.toString()}  •  ${video.viewCount} مشاهدة  • ${timeago.format(video.timestamp, locale: 'ar')}',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontSize: 14.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => print('More options tapped'),
                      child: const Icon(Icons.more_vert, size: 20.0),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
