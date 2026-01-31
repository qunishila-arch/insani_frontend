import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/konstan.dart';
import 'list_surat.dart';

class UploadSuratPage extends StatefulWidget {
  final String kdPeg;
  const UploadSuratPage({super.key, required this.kdPeg});

  @override
  State<UploadSuratPage> createState() => _UploadSuratPageState();
}

class _UploadSuratPageState extends State<UploadSuratPage> {
  final tglController = TextEditingController();
  final judulController = TextEditingController();

  bool loading = false;
  bool loadingPegawai = true;

  String selectedPeg = '-1';

  Uint8List? fileBytes;
  String? fileName;

  List<Map<String, String>> daftarPegawai = [];

  @override
  void initState() {
    super.initState();
    fetchPegawai();

    final now = DateTime.now();
    tglController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    tglController.dispose();
    judulController.dispose();
    super.dispose();
  }

  Future<void> fetchPegawai() async {
    try {
      final res = await http.get(Uri.parse(getKaryawanUrl));
      final jsonRes = jsonDecode(res.body);

      if (jsonRes['status'] == true) {
        setState(() {
          daftarPegawai = [
            {"kd_peg": "-1", "nama": "SEMUA KARYAWAN"},
            ...List<Map<String, String>>.from(
              (jsonRes['data'] as List).map(
                (e) => {
                  "kd_peg": e['kd_peg'].toString(),
                  "nama": e['nama'].toString(),
                },
              ),
            ),
          ];
          loadingPegawai = false;
        });
      } else {
        loadingPegawai = false;
      }
    } catch (_) {
      loadingPegawai = false;
    }
  }

  Future<void> pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      withData: true,
    );

    if (res != null && res.files.single.bytes != null) {
      setState(() {
        fileBytes = res.files.single.bytes!;
        fileName = res.files.single.name;
      });
    } else {
      snack("Gagal mengambil file");
    }
  }

  Future<void> uploadSurat() async {
    if (judulController.text.trim().isEmpty) {
      snack("Judul surat wajib diisi");
      return;
    }

    if (fileBytes == null || fileName == null) {
      snack("File surat wajib dipilih");
      return;
    }

    setState(() => loading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      if (username.isEmpty) {
        snack("Session login tidak ditemukan");
        setState(() => loading = false);
        return;
      }

      final request = http.MultipartRequest("POST", Uri.parse(tataUsahaUrl));

      request.fields['username'] = username;
      request.fields['judul_surat'] = judulController.text.trim();
      request.fields['id_ditujukan_ke'] = selectedPeg;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file_surat',
          fileBytes!,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final json = jsonDecode(respStr);

      if (json['status'] == true) {
        snack(json['message']);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ListSuratPage(kdPeg: widget.kdPeg),
          ),
        );
      } else {
        snack(json['message']);
      }
    } catch (e) {
      snack("Gagal upload: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Surat")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: tglController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: "Tanggal Surat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: judulController,
              decoration: const InputDecoration(
                labelText: "Judul Surat",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            loadingPegawai
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: selectedPeg,
                    decoration: const InputDecoration(
                      labelText: "Ditujukan Untuk",
                      border: OutlineInputBorder(),
                    ),
                    items: daftarPegawai
                        .map(
                          (e) => DropdownMenuItem(
                            value: e['kd_peg'],
                            child: Text(e['nama']!),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedPeg = v!),
                  ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(
                fileName ?? "Pilih File Surat",
                overflow: TextOverflow.ellipsis,
              ),
              onPressed: pickFile,
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : uploadSurat,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPLOAD SURAT"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
