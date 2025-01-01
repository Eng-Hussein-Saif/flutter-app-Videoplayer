import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:husseintube/data.dart';
import 'package:husseintube/screens/nav_screen.dart';
import 'package:husseintube/widgets/widgets.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

class VideoScreen extends ConsumerStatefulWidget {
  final Video video;
  final YoutubePlayerController youtubeController;
  final List<Video> relatedVideos; // قائمة الفيديوهات المناسبة

  const VideoScreen({
    super.key,
    required this.video,
    required this.youtubeController,
    required this.relatedVideos, // تمرير الفيديوهات هنا
  });

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  ScrollController? _scrollController;
  double _videoProgress = 0.0;
  double _currentVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    widget.youtubeController.addListener(_updateVideoProgress);

    // الحصول على مستوى الصوت الحالي
    FlutterVolumeController.getVolume().then((volume) {
      setState(() {
        _currentVolume = volume!;
      });
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();

    // إزالة المستمع لتجنب استدعاء setState بعد التخلص من العنصر
    widget.youtubeController.removeListener(_updateVideoProgress);

    super.dispose();
  }

  void _updateVideoProgress() {
    if (!mounted) return;

    final position = widget.youtubeController.value.position.inSeconds;
    final duration = widget.youtubeController.value.metaData.duration.inSeconds;

    setState(() {
      _videoProgress = (position / duration).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ref
          .read(miniPlayerControllerProvider.state)
          .state
          .animateToHeight(state: PanelState.MAX),
      child: Scaffold(
        body: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomScrollView(
            controller: _scrollController,
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          YoutubePlayer(
                            controller: widget.youtubeController,
                            showVideoProgressIndicator: true,
                            onReady: () {
                              print('Player is ready');
                            },
                            onEnded: (metaData) {
                              print('Video has ended');
                            },
                          ),
                          IconButton(
                            iconSize: 40.0,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.yellow),
                            onPressed: () {
                              ref
                                  .read(miniPlayerControllerProvider.state)
                                  .state
                                  .animateToHeight(state: PanelState.MIN);
                            },
                          ),
                        ],
                      ),
                      LinearProgressIndicator(
                        value: _videoProgress,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        backgroundColor: Colors.grey.shade300,
                      ),
                      // شريط التحكم في الصوت
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up, color: Colors.white),
                            Expanded(
                              child: Slider(
                                value: _currentVolume,
                                min: 0.0,
                                max: 6.0,
                                divisions: 60,
                                onChanged: (value) {
                                  setState(() {
                                    _currentVolume = value;
                                  });
                                  FlutterVolumeController.setVolume(
                                      value / 6.0);
                                },
                              ),
                            ),
                            Text(
                              '${(_currentVolume * 100).toInt()}%',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      VideoInfo(video: widget.video),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = widget.relatedVideos[index];
                    return VideoCard(
                      video: video,
                      hasPadding: true,
                      relatedVideos: widget.relatedVideos,
                      onTap: () => _scrollController!.animateTo(
                        0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                      ),
                    );
                  },
                  childCount: widget.relatedVideos.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



