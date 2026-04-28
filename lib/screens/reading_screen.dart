import 'package:flutter/material.dart';
import 'reading_books.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() =>
      _ReadingScreenState();
}

class _ReadingScreenState
    extends State<ReadingScreen> {
  String selectedCategory = "all";
  String searchText = "";

  final List<Map<String, String>> categories = [
    {"key": "all", "label": "All"},
    {"key": "school", "label": "School"},
    {"key": "religion", "label": "Religion"},
    {"key": "selfhelp", "label": "Self Help"},
    {"key": "programming", "label": "Programming"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Books"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText =
                      value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search books...",
                prefixIcon:
                    const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection:
                  Axis.horizontal,
              itemCount:
                  categories.length,
              itemBuilder:
                  (context, index) {
                var cat =
                    categories[index];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory =
                          cat["key"]!;
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          selectedCategory ==
                                  cat["key"]
                              ? Colors.green
                              : Colors.grey[200],
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                    child: Center(
                      child: Text(
                        cat["label"]!,
                        style: TextStyle(
                          color:
                              selectedCategory ==
                                      cat["key"]
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: ReadingBooks(
              category:
                  selectedCategory,
              search: searchText,
            ),
          ),
        ],
      ),
    );
  }
}