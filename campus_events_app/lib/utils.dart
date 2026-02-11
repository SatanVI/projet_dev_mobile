import 'dart:convert';
import 'package:flutter/material.dart';

void showMessage(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
}

Widget displayImage(
  String? path, {
  double? width,
  double? height,
  double radius = 0,
}) {
  if (path == null || path.isEmpty) {
    return _placeholder(width, height, radius);
  }

  try {
    ImageProvider image;
    if (path.startsWith('http')) {
      image = NetworkImage(path);
    } else if (path.startsWith('assets/')) {
      image = AssetImage(path);
    } else {
      image = MemoryImage(base64Decode(path));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _placeholder(width, height, radius),
      ),
    );
  } catch (e) {
    return _placeholder(width, height, radius);
  }
}

Widget _placeholder(double? width, double? height, double radius) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      "assets/images/logorond.jpg",
      width: width,
      height: height,
      fit: BoxFit.cover,
    ),
  );
}
