import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/konstan.dart';

class DetailSuratPage extends StatefulWidget {
  final Map surat;

  const DetailSuratPage({super.key, required this.surat});

  @override
  State<DetailSuratPage> createState() => _DetailSuratPageState();
}

class _DetailSuratPageState extends State<DetailSuratPage> {
  bool showPdf = false;
  WebViewController? _controller;

  bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();

    if (isMobile &&
        widget.surat['nama_file'] != null &&
        widget.surat['nama_file'].toString().isNotEmpty) {
      final url = "$baseFileUrl${widget.surat['nama_file']}";

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));
    }
  }

  Future<void> _openFile() async {
    final file = widget.surat['nama_file'];

    if (file == null || file.toString().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("File tidak tersedia")));
      return;
    }

    final url = "$baseFileUrl$file";

    if (isMobile) {
      setState(() => showPdf = !showPdf);
    } else {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final surat = widget.surat;

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Surat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surat['judul_surat'] ?? '-',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 18),
                        const SizedBox(width: 8),
                        Text(surat['tgl_surat'] ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 8),
                        Text("Dibuat oleh: ${surat['user_input'] ?? '-'}"),
                      ],
                    ),
                    const Divider(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          isMobile
                              ? (showPdf ? Icons.close : Icons.picture_as_pdf)
                              : Icons.open_in_browser,
                        ),
                        label: Text(
                          isMobile
                              ? (showPdf
                                    ? "Tutup File Surat"
                                    : "Buka File Surat")
                              : "Buka File Surat",
                        ),
                        onPressed: _openFile,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (showPdf && isMobile && _controller != null) ...[
              const SizedBox(height: 12),
              Expanded(
                child: Card(child: WebViewWidget(controller: _controller!)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
