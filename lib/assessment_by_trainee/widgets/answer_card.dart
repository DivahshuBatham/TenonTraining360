import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  final int currentIndex;
  final String optionText;
  final bool isSelected;
  final int? selectedAnswerIndex;
  final int correctAnswerIndex;
  final VoidCallback onTap;

  const AnswerCard({
    super.key,
    required this.currentIndex,
    required this.optionText,
    required this.isSelected,
    required this.selectedAnswerIndex,
    required this.correctAnswerIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letter = String.fromCharCode(97 + currentIndex).toUpperCase();

    Color bgColor = Colors.white;
    Color textColor = Colors.black;

    if (selectedAnswerIndex != null) {
      if (isSelected) {
        bgColor = Colors.purple;
        textColor = Colors.white;
      }
    } else if (isSelected) {
      bgColor = Colors.blue.shade100;
      textColor = Colors.black;
    }

    return InkWell(
      onTap: onTap,
      child: Card(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '$letter. $optionText',
            style: TextStyle(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
