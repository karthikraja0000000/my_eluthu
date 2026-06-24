import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DiaryEntry {
  final int? id;
  final String date;
  final String dayName;
  final String title;
  final String snippet;
  final String mood;
  final Color paperColor;
  final double rotation;
  final List<String> tags;

  const DiaryEntry({
    this.id,
    required this.date,
    required this.dayName,
    required this.title,
    required this.snippet,
    required this.mood,
    required this.paperColor,
    required this.rotation,
    required this.tags,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date,
    'dayName': dayName,
    'title': title,
    'snippet': snippet,
    'mood': mood,
    'paperColor': paperColor.value,
    'rotation': rotation,
    'tags': tags.join(','),
  };

  factory DiaryEntry.fromMap(Map<String, dynamic> m) => DiaryEntry(
    id: m['id'] as int?,
    date: m['date'] as String,
    dayName: m['dayName'] as String,
    title: m['title'] as String,
    snippet: m['snippet'] as String,
    mood: m['mood'] as String,
    paperColor: Color(m['paperColor'] as int),
    rotation: (m['rotation'] as num).toDouble(),
    tags: (m['tags'] as String)
        .split(',')
        .where((t) => t.isNotEmpty)
        .toList(),
  );

  static Color randomPaperColor() {
    const colors = [
      Color(0xFFFFFDE7),
      Color(0xFFF3E5F5),
      Color(0xFFE8F5E9),
      Color(0xFFFCE4EC),
      Color(0xFFE3F2FD),
      Color(0xFFFFF3E0),
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  static double randomRotation() =>
      (math.Random().nextDouble() * 3.0) - 1.5;
}