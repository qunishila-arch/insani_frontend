import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/konstan.dart';

class VerifCutiPage extends StatefulWidget {
  final String kdPeg;

  const VerifCutiPage({super.key, required this.kdPeg});

  @override
  State<VerifCutiPage> createState() => _VerifCutiPageState();
}

class _VerifCutiPageState extends State<VerifCutiPage> {
  bool isLoading = true;
  List cutiList = [];

  @override
  void initState() {
    super.initState();
    fetchCuti();
  }

  Future<void> fetchCuti() async {
    try {
      final res = await http.get(
        Uri.parse("$cutiUrl?action=list_atasan&kd_peg=${widget.kdPeg}"),
      );

      final jsonRes = json.decode(res.body);

      if (jsonRes['status'] == true) {
        setState(() {
          cutiList = jsonRes['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> verifCuti(String idCuti, String status) async {
    await http.post(
      Uri.parse("$cutiUrl?action=verif"),
      body: {"id": idCuti, "status": status},
    );

    fetchCuti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Verifikasi Cuti")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cutiList.isEmpty
          ? const Center(child: Text("Belum ada Pengajuan Cuti"))
          : ListView.builder(
              itemCount: cutiList.length,
              itemBuilder: (context, index) {
                final c = cutiList[index];
                return Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c['nm_peg'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Jenis Cuti : ${c['jenis_cuti']}"),
                        Text(
                          "Tanggal   : ${c['tgl_mulai']} - ${c['tgl_selesai']}",
                        ),
                        Text("Alasan    : ${c['alasan']}"),
                        const SizedBox(height: 12),

                        if (c['status'] == 'PENDING')
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed: () =>
                                      verifCuti(c['id'], 'APPROVE'),
                                  child: const Text("APPROVE"),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () => verifCuti(c['id'], 'REJECT'),
                                  child: const Text("REJECT"),
                                ),
                              ),
                            ],
                          )
                        else
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: c['status'] == 'APPROVE'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Status: ${c['status']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
