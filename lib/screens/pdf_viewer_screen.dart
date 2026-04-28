import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final bool isAdmin;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.isAdmin = false,
  });

  @override
  State<PdfViewerScreen> createState() =>
      _PdfViewerScreenState();
}

class _PdfViewerScreenState
    extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(
        Uri.parse(widget.pdfUrl),
      );

      if (response.statusCode != 200) {
        throw Exception("PDF download failed");
      }

      final dir =
          await getApplicationDocumentsDirectory();

      final safeTitle = widget.title
          .replaceAll(" ", "_")
          .replaceAll("/", "_");

      final file = File(
        "${dir.path}/$safeTitle.pdf",
      );

      await file.writeAsBytes(
        response.bodyBytes,
        flush: true,
      );

      if (!mounted) return;

      setState(() {
        localPath = file.path;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F0C8),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFFD4AF37),
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (widget.isAdmin)
            const Padding(
              padding:
                  EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  "ADMIN",
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : hasError
              ? const Center(
                  child: Text(
                    "Failed to load PDF",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                )
              : localPath != null
                  ? PDFView(
                      filePath: localPath!,
                    )
                  : const Center(
                      child: Text(
                        "PDF not found",
                      ),
                    ),
    );
  }
}