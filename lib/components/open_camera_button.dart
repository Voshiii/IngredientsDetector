import 'package:flutter/material.dart';


class OpenCamButton extends StatefulWidget {
  final VoidCallback handleImagePick;

  OpenCamButton({
    super.key,
    required this.handleImagePick,
    });

  @override
  State<OpenCamButton> createState() => _OpenCamButtonState();
}

class _OpenCamButtonState extends State<OpenCamButton> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.handleImagePick,
      child: const Column(
        children: [
          Icon(Icons.camera_alt)
        ],
      ),
    );
  }
}