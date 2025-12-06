import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title;
  
  CustomCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(child: Text(title));
  }
}
