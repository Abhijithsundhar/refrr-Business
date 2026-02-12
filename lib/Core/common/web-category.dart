import 'package:flutter/material.dart';

class CircleAvatharList extends StatelessWidget {
  final String label;
  final String? imageUrl;
  final IconData? icon;
  final bool isSelected;
  const CircleAvatharList(String s, {super.key, required this.label, this.imageUrl, this.icon, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
              isSelected ? Border.all(color: Colors.black, width: 1) : null,
              color: Colors.grey[100],
            ),
            child: imageUrl != null
                ? ClipOval(
              child: Image.network(
                imageUrl??"",
                fit: BoxFit.cover,
              ),
            ): Icon(icon, color: Colors.black),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 60,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
