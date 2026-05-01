import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart'; // ✅ UPDATED

class PdfViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() =>
      _PdfViewerScreenState();
}

class _PdfViewerScreenState
    extends State<PdfViewerScreen> {
  String? localPath;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    secureScreen();
    loadPdf();
  }

  Future<void> secureScreen() async {
    await FlutterWindowManagerPlus.addFlags( // ✅ UPDATED
      FlutterWindowManagerPlus.FLAG_SECURE, // ✅ UPDATED
    );
  }

  Future<void> loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));

      final dir = await getApplicationDocumentsDirectory();

      final file = File("${dir.path}/temp.pdf");

      await file.writeAsBytes(response.bodyBytes);

      if (!mounted) return;

      setState(() {
        localPath = file.path;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath != null
              ? PDFView(filePath: localPath!)
              : const Center(child: Text("Error loading PDF")),
    );
  }
}