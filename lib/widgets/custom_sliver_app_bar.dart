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


