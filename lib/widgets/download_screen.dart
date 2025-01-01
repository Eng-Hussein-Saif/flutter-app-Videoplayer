// ignore_for_file: avoid_print

import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> downloadVideo(String videoId) async {
  final yt = YoutubeExplode();

  try {
    // جلب تفاصيل الفيديو
    final video = await yt.videos.get(videoId);

    // جلب ملفات الصوت والفيديو
    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final streamInfo = manifest.muxed.bestQuality;

    // ignore: unnecessary_null_comparison
    if (streamInfo != null) {
      // الحصول على المسار لتخزين الفيديو
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${video.title}.mp4';

      // فتح البث وتحميل الفيديو
      final fileStream = File(filePath).openWrite();
      final stream = yt.videos.streamsClient.get(streamInfo);
      await stream.pipe(fileStream);

      await fileStream.flush();
      await fileStream.close();

      // ignore:
      print('Video downloaded to $filePath');
    }
  } catch (e) {
    print('Failed to download video: $e');
  } finally {
    yt.close();
  }
}
