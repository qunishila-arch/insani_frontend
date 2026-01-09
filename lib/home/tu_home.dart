import 'package:flutter/material.dart';

class TuHome extends StatelessWidget {
  final String kdPeg;

  const TuHome({super.key, required this.kdPeg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("TU HOME - $kdPeg")));
  }
}
