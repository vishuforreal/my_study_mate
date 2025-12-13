import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({super.key, required this.pdfUrl, required this.title});

  Future<void> _openPDF() async {
    try {
      String finalUrl = pdfUrl;
      
      // Convert Google Drive sharing link to direct view
      if (pdfUrl.contains('drive.google.com')) {
        final fileId = _extractGoogleDriveFileId(pdfUrl);
        if (fileId.isNotEmpty) {
          finalUrl = 'https://drive.google.com/file/d/$fileId/view';
        }
      }

      final Uri url = Uri.parse(finalUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _extractGoogleDriveFileId(String url) {
    final regex = RegExp(r'/d/([a-zA-Z0-9-_]+)');
    final match = regex.firstMatch(url);
    return match?.group(1) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    // Automatically open PDF and go back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPDF();
      Navigator.pop(context);
    });

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Opening PDF...'),
          ],
        ),
      ),
    );
  }
}