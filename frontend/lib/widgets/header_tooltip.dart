import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';

class HeaderWithTooltip extends StatelessWidget {
  final String header;
  final String tooltipText;

  const HeaderWithTooltip({
    super.key,
    required this.header,
    required this.tooltipText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(header,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(width: 10.0), // Some spacing between text and icon
        Tooltip(
            message: tooltipText,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(header),
                    content: Text(tooltipText),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(EvaIcons.questionMarkCircleOutline,
                  size: 20.0, color: Colors.white),
            )),
      ],
    );
  }
}
