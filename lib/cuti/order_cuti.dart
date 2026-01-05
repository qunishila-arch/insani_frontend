import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'list_order_cuti.dart';

class OrderCutiPage extends StatefulWidget {
  const OrderCutiPage({super.key});

  @override
  State<OrderCutiPage> createState() => _OrderCutiPageState();
}

class _OrderCutiPageState extends State<OrderCutiPage> {
  List<Map<String, dynamic>> jenisCutiList = [];
  String? selectedCuti;

  final TextEditingController tglMulaiController = TextEditingController();
  final TextEditingController tglSelesaiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchJenisCuti();
  }

  @override
  void dispose() {
    tglMulaiController.dispose();
    tglSelesaiController.dispose();
    keteranganController.dispose();
    super.dispose();
  }

  Future<void> fetchJenisCuti() async {
    try {
      final response = await http.get(
        Uri.parse("http://192.168.43.87/insani/API/cuti.php?action=jenis_cuti"),
      );

      final result = jsonDecode(response.body);

      if (result['status'] == true) {
        setState(() {
          jenisCutiList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (_) {
      _notif("Gagal ambil jenis cuti");
    }
  }

  Future<void> pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Future<void> submitCuti() async {
    if (selectedCuti == null ||
        tglMulaiController.text.isEmpty ||
        tglSelesaiController.text.isEmpty ||
        keteranganController.text.isEmpty) {
      _notif("Lengkapi semua data");
      return;
    }

    setState(() => isLoading = true);

    final body = {
      "action": "submit",
      "kd_peg": "PEG000002",
      "kd_jenis_cuti": selectedCuti!,
      "tgl_mulai": tglMulaiController.text,
      "tgl_selesai": tglSelesaiController.text,
      "keterangan": keteranganController.text,
    };

    try {
      final response = await http.post(
        Uri.parse("http://192.168.43.87/insani/API/cuti.php"),
        body: body,
      );

      final result = jsonDecode(response.body);

      setState(() => isLoading = false);

      _notif(result['message']);

      if (result['status'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ListOrderCutiPage(kdPeg: "PEG000002"),
          ),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      _notif("Gagal submit cuti");
    }
  }

  void _notif(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pengajuan Cuti")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCuti,
              decoration: const InputDecoration(labelText: "Jenis Cuti"),
              items: jenisCutiList.map<DropdownMenuItem<String>>((
                Map<String, dynamic> e,
              ) {
                return DropdownMenuItem<String>(
                  value: e['fs_kd_jenis_cuti'].toString(),
                  child: Text(e['fs_nm_jenis_cuti'].toString()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCuti = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tglMulaiController,
              readOnly: true,
              onTap: () => pickDate(tglMulaiController),
              decoration: const InputDecoration(labelText: "Tanggal Mulai"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tglSelesaiController,
              readOnly: true,
              onTap: () => pickDate(tglSelesaiController),
              decoration: const InputDecoration(labelText: "Tanggal Selesai"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganController,
              decoration: const InputDecoration(labelText: "Keterangan"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isLoading ? null : submitCuti,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("SUBMIT"),
            ),
          ],
        ),
      ),
    );
  }
}
