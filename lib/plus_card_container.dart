import 'package:flutter/material.dart';

class PlusCardContainer extends StatelessWidget {
  final Widget child;
  const PlusCardContainer({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child:child ,);
  }
}
