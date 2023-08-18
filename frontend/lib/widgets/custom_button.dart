import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.isActive,
      this.bgColor = Colors.white,
      this.textColor = Colors.black});

  final void Function() onPressed;
  final String text;
  final bool isActive;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: isActive ? Colors.purple : bgColor,
        foregroundColor: isActive ? Colors.white : textColor,
        minimumSize: const Size(200, 42),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
        ),
      ),
      child: Text(text),
    );
  }
}
