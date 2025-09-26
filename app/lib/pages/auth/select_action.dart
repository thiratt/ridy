import 'package:flutter/material.dart';

class SelectActionPage extends StatefulWidget {
  const SelectActionPage({super.key});

  @override
  State<SelectActionPage> createState() => _SelectActionPageState();
}

class _SelectActionPageState extends State<SelectActionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Action Page')),
      body: const Center(child: Text('Welcome to the Select Action Page!')),
    );
  }
}
