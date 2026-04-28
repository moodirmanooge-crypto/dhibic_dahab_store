import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewer extends StatelessWidget {

  final String url;

  const PdfViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Read Book"),
      ),

      body: Center(
        child: Text(
          "PDF ready to open:\n$url",
          textAlign: TextAlign.center,
        ),
      ),

    );

  }

}