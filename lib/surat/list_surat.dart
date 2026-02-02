import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/konstan.dart';
import 'detail_surat.dart';

class ListSuratPage extends StatefulWidget {
  final String kdPeg;
  const ListSuratPage({super.key, required this.kdPeg});

  @override
  State<ListSuratPage> createState() => _ListSuratPageState();
}

class _ListSuratPageState extends State<ListSuratPage> {
  bool loading = true;
  List dataSurat = [];

  @override
  void initState() {
    super.initState();
    fetchSurat();
  }

  Future<void> fetchSurat() async {
    try {
      final uri = Uri.parse(listSuratUrl)
          .replace(queryParameters: {'kdPeg': widget.kdPeg});

      final res = await http.get(uri);
      final jsonRes = jsonDecode(res.body);

      if (jsonRes['status'] == true) {
        setState(() {
          dataSurat = jsonRes['data'];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Surat")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : dataSurat.isEmpty
              ? const Center(child: Text("Belum ada surat"))
              : ListView.builder(
                  itemCount: dataSurat.length,
                  itemBuilder: (context, i) {
                    final s = dataSurat[i];

                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: const Icon(Icons.description),
                        title: Text(s['judul_surat']),
                        subtitle: Text("Tanggal: ${s['tgl_surat']}"),
                        trailing: const Icon(Icons.chevron_right),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailSuratPage(surat: s),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
