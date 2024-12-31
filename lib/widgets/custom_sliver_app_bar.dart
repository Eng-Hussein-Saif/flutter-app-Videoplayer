import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final Function(String) onSearch; // تمرير دالة البحث
  const CustomSliverAppBar({super.key, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      leadingWidth: 200.0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12.0),
        child: Row(
          children: [
            Image.asset(
              'assets/logo3.png',
              fit: BoxFit.fill,
              width: 50.0,
              height: 40.0,
            ),
            const SizedBox(
              child: Text(
                " HusseinTube",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.cast, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.blue),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearchDelegate(onSearch: onSearch),
            );
          },
        ),
        IconButton(
          iconSize: 40.0,
          icon: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text('HS'),
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch; // دالة لاستدعاء نتائج البحث
  CustomSearchDelegate({required this.onSearch});

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // إغلاق نافذة البحث
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildResults(BuildContext context) {
    // استخدام WidgetsBinding لتأجيل التنفيذ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      close(context, query); // إغلاق نافذة البحث بعد انتهاء البناء
      onSearch(query); // استدعاء عملية البحث
    });

    // عرض مؤشر انتظار أثناء البحث
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text("Search for '$query'"),
          onTap: () {
            close(context, query);
            onSearch(query);
          },
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:husseintube/widgets/video_card.dart';
//
// import '../data.dart';
//
// class CustomSliverAppBar extends StatelessWidget {
//   const CustomSliverAppBar({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       floating: true,
//       leadingWidth: 100.0,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 12.0),
//         child: Image.asset('assets/yt_logo_dark.png'),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.cast, color: Colors.blue),
//           onPressed: () {},
//         ),
//         // عند النقر على أيقونة البحث، يتم فتح نافذة البحث باستخدام SearchDelegate
//         IconButton(
//           icon: const Icon(Icons.search, color: Colors.blue),
//           onPressed: () {
//             // فتح نافذة البحث
//             showSearch(
//               context: context,
//               delegate: CustomSearchDelegate(),
//             );
//           },
//         ),
//         IconButton(
//           iconSize: 40.0,
//           icon: CircleAvatar(
//             backgroundColor: Colors.blue,
//             child: Text('HS'),
//           ),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }
//
// class CustomSearchDelegate extends SearchDelegate<String> {
//   // هذه الدالة تُنفذ عندما يتم النقر على زر العودة أو "X"
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back), // أو يمكنك وضع Icon(Icons.clear) لإظهار "X"
//       onPressed: () {
//         close(context, ''); // إغلاق البحث
//       },
//     );
//   }
//
//   // هذه الدالة تُنفذ عندما يتم البحث
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     // زر X لمسح النص المدخل
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = ''; // مسح النص المدخل
//         },
//       ),
//     ];
//   }
//
//   // بناء نتائج البحث
//   @override
//   Widget buildResults(BuildContext context) {
//     // عندما يبدأ المستخدم بالبحث، نقوم باستخدام دالة `fetchVideosBySearch` لعرض النتائج
//     return FutureBuilder<List<Video>>(
//       future: fetchVideosBySearch(query),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text(
//               'Failed to load videos: ${snapshot.error}',
//               style: TextStyle(color: Colors.red),
//             ),
//           );
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return Center(child: Text('No results found.'));
//         } else {
//           final videos = snapshot.data!;
//           return ListView.builder(
//             itemCount: videos.length,
//             itemBuilder: (context, index) {
//               final video = videos[index];
//               return VideoCard(video: video); // عرض الفيديو باستخدام `VideoCard`
//             },
//           );
//         }
//       },
//     );
//   }
//
//   // بناء اقتراحات البحث أثناء الكتابة
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = query.isEmpty
//         ? ['Suggested video 1', 'Suggested video 2', 'Suggested video 3']
//         : ['Search result 1 for $query', 'Search result 2 for $query'];
//
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(suggestions[index]),
//           onTap: () {
//             // عند اختيار اقتراح البحث، يتم تنفيذ البحث مع هذا النص
//             query = suggestions[index];
//             showResults(context);
//           },
//         );
//       },
//     );
//   }
//
//   // بناء شريط النص في حقل البحث
//   Widget buildSearchField(BuildContext context) {
//     return TextField(
//       controller: TextEditingController(text: query),
//       autofocus: true,
//       decoration: InputDecoration(
//         hintText: 'Search for videos...',
//         border: InputBorder.none,
//       ),
//       onChanged: (value) {
//         query = value;
//         showSuggestions(context); // تحديث الاقتراحات أثناء الكتابة
//       },
//     );
//   }
// }


// class CustomSearchDelegate extends SearchDelegate<String> {
//   // هذه الدالة تُنفذ عندما يتم النقر على زر العودة أو "X"
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back), // أو يمكنك وضع Icon(Icons.clear) لإظهار "X"
//       onPressed: () {
//         close(context, ''); // إغلاق البحث
//       },
//     );
//   }
//

//   // هذه الدالة تُنفذ عندما يتم البحث
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     // زر X لمسح النص المدخل
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = ''; // مسح النص المدخل
//         },
//       ),
//     ];
//   }
//
//   // بناء نتائج البحث
//   @override
//   Widget buildResults(BuildContext context) {
//     // هنا يمكنك تنفيذ المنطق الخاص بك لعرض نتائج البحث بناءً على query
//     return Center(
//       child: Text('Results for: $query'),
//     );
//   }
//
//   // بناء اقتراحات البحث أثناء الكتابة
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final suggestions = query.isEmpty
//         ? ['Suggested video 1', 'Suggested video 2', 'Suggested video 3']
//         : ['Search result 1 for $query', 'Search result 2 for $query'];
//
//     return ListView.builder(
//       itemCount: suggestions.length,
//       itemBuilder: (context, index) {
//         return ListTile(
//           title: Text(suggestions[index]),
//           onTap: () {
//             // عند اختيار اقتراح البحث، يتم تنفيذ البحث مع هذا النص
//             query = suggestions[index];
//             showResults(context);
//           },
//         );
//       },
//     );
//   }
//
//   // بناء شريط النص في حقل البحث
//   @override
//   Widget buildSearchField(BuildContext context) {
//     return TextField(
//       controller: TextEditingController(text: query),
//       autofocus: true,
//       decoration: InputDecoration(
//         hintText: 'Search for videos...',
//         border: InputBorder.none,
//       ),
//       onChanged: (value) {
//         query = value;
//         showSuggestions(context); // تحديث الاقتراحات أثناء الكتابة
//       },
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:husseintube/data.dart';
//
// class CustomSliverAppBar extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       floating: true,
//       leadingWidth: 100.0,
//       leading: Padding(
//         padding: const EdgeInsets.only(left: 12.0),
//         child: Image.asset('assets/yt_logo_dark.png'),
//       ),
//       actions: [
//         IconButton(
//           icon: const Icon(Icons.cast , color: Colors.blue),
//           onPressed: () {},
//         ),
//         // IconButton(
//         //   icon: const Icon(Icons.notifications_outlined),
//         //   onPressed: () {},
//         // ),
//         IconButton(
//           icon: const Icon(Icons.search , color: Colors.blue),
//           onPressed: () {},
//         ),
//         IconButton(
//           iconSize: 40.0,
//           icon: CircleAvatar(
//             backgroundColor: Colors.blue,
//             child: Text('HS'),
//           ),
//           onPressed: () {},
//         ),
//       ],
//     );
//   }
// }
