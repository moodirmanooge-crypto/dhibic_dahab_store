import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewer extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewer({
    super.key,
    required this.url,
    this.title = "Read Book",
  });

  @override
  State<PdfViewer> createState() =>
      _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

  Future<void> downloadFile() async {
    try {
      final response = await http.get(
        Uri.parse(widget.url),
      );

      if (response.statusCode != 200) {
        throw "Download failed";
      }

      final dir =
          await getApplicationDocumentsDirectory();

      final safeTitle = widget.title
          .replaceAll(" ", "_")
          .replaceAll("/", "_");

      final file =
          File("${dir.path}/$safeTitle.pdf");

      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      if (!mounted) return;

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : localPath != null
              ? PDFView(filePath: localPath!)
              : const Center(
                  child: Text("Failed to load PDF"),
                ),
    );
  }
}