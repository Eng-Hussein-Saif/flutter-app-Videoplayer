// ignore_for_file: unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:husseintube/widgets/download_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:husseintube/data.dart';

class VideoInfo extends StatelessWidget {
  final Video video;

  const VideoInfo({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    // تنسيق وقت النشر بالعربية
    final formattedTimestamp = timeago.format(video.timestamp, locale: 'ar');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // النصوص تبدأ من اليمين
        textDirection: TextDirection.rtl, // النصوص تظهر باتجاه عربي
        children: [
          Text(
            video.title,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 15.0),
          ),
          const SizedBox(height: 8.0),
          Text(
            '${video.viewCount} مشاهدة •  $formattedTimestamp',
            textAlign: TextAlign.right,
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 14.0),
          ),
          const Divider(),
          _ActionsRow(video: video),
          const Divider(),
          _AuthorInfo(user: video.author),
          const Divider(),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final Video video;

  const _ActionsRow({
    super.key,
    required this.video,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      textDirection: TextDirection.rtl,
      children: [
        _buildActionButton(
            context, Icons.thumb_up_outlined, video.likes, () {}),
        _buildActionButton(
            context, Icons.thumb_down_outlined, video.dislikes, () {}),
        _buildActionButton(context, Icons.reply_outlined, 'مشاركة', () {}),
        _buildActionButton(context, Icons.download_outlined, 'تنزيل', () {
          // downloadVideo(video.id);
          showDownloadDialog(context);
        }),
        _buildActionButton(context, Icons.library_add_outlined, 'حفظ', () {}),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label,
      VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.blue),
          onPressed: onPressed,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _AuthorInfo extends StatelessWidget {
  final User user;

  const _AuthorInfo({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // معالجة مشكلة عدد المشتركين: استبدال "N/A" بقيمة افتراضية
    final subscriberCount = user.subscribers != 'N/A'
        ? '${user.subscribers} مشترك'
        : 'عدد غير متوفر';

    return GestureDetector(
      onTap: () => print('Navigate to profile'),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          CircleAvatar(
            foregroundImage: NetworkImage(user.profileImageUrl),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    user.username,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontSize: 15.0),
                  ),
                ),
                Flexible(
                  child: Text(
                    subscriberCount,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(fontSize: 14.0, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'اشتراك',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }
}

void showDownloadDialog(BuildContext context) {
  String selectedQuality = '720p'; // الجودة الافتراضية
  String downloadPath = ''; // المسار الافتراضي

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('إعدادات التنزيل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر جودة التنزيل:'),
            Column(
              children: ['360p', '480p', '720p', '1080p']
                  .map(
                    (quality) => RadioListTile<String>(
                      title: Text(quality),
                      value: quality,
                      groupValue: selectedQuality,
                      onChanged: (value) {
                        if (value != null) {
                          selectedQuality = value;
                        }
                        Navigator.of(context).pop();
                        showDownloadDialog(context);
                      },
                    ),
                  )
                  .toList(),
            ),
            Divider(),
            ListTile(
              title: Text('اختر مسار التنزيل:'),
              subtitle: Text(
                  downloadPath.isEmpty ? 'لم يتم تحديد المسار' : downloadPath),
              trailing: Icon(Icons.folder_open),
              onTap: () async {
                // هنا يمكن استدعاء مكتبة لتحديد المسار
                downloadPath = '/example/path'; // مسار افتراضي تجريبي
                Navigator.of(context).pop();
                showDownloadDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('إلغاء'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            child: Text('تنزيل'),
            onPressed: () {
              // استدعاء دالة التنزيل مع الجودة والمسار المحددين
              downloadVideo(selectedQuality);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
