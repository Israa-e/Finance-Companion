import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String subtitle;
  final Color accent;
  final Widget illustration;

  const OnboardingPageModel({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.illustration,
  });
}
