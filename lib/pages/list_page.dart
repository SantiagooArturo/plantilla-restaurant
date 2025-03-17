import 'package:flutter/material.dart';

class ListPage extends StatelessWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Page"),
      ),
      body: const Center(
        child: Text(
          "This is the new list page.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}