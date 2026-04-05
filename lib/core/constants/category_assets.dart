import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CategoryIcons {
  static const Map<String, IconData> icons = {
    'Food': Iconsax.coffee,
    'Shopping': Iconsax.shopping_bag,
    'Transport': Iconsax.car,
    'Entertainment': Iconsax.game,
    'Health': Iconsax.health,
    'Salary': Iconsax.wallet_money,
    'Investment': Iconsax.chart_2,
    'Gift': Iconsax.gift,
    'Freelance': Iconsax.personalcard,
    'Bills': Iconsax.receipt_2,
    'Rent': Iconsax.house,
    'Education': Iconsax.teacher,
    'Travel': Iconsax.airplane,
    'Pet': Iconsax.pet,
    'Fitness': Iconsax.activity,
    'Insurance': Iconsax.security_safe,
    'Tax': Iconsax.document_text,
    'Beauty': Iconsax.omega_circle,
    'Repair': Iconsax.setting_5,
    'Charity': Iconsax.heart,
    'Other': Iconsax.category,
  };

  static IconData getIcon(int codePoint) {
    try {
      return IconData(codePoint, fontFamily: 'Iconsax', fontPackage: 'iconsax');
    } catch (_) {
      return Iconsax.category;
    }
  }
}

class CategoryColors {
  static const List<Color> colors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF5252), // Red
    Color(0xFF795548), // Brown
    Color(0xFFE91E63), // Pink
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF673AB7), // Deep Purple
    Color(0xFFFFC107), // Amber
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF9E9E9E), // Grey
  ];
}
