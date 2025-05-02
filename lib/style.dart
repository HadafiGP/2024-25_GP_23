import 'package:flutter/material.dart';

const Color mainColor = Color(0xFF113F67);
const Color backgroundColor = Color(0xFFF3F9FB);

// Font sizes
const double kFontSizeLarge = 24;
const double kFontSizeLarge2 = 20;
const double kFontSizeMedium = 16;
const double kFontSizeSmall = 14;

// Text Styles
const TextStyle kLabelTextStyle = TextStyle(
  fontSize: kFontSizeMedium,
  fontWeight: FontWeight.w600,
  color: Colors.black87,
);

const TextStyle kFieldTextStyle = TextStyle(
  fontSize: kFontSizeSmall,
  color: Colors.black,
);

// Button Styles
// final ButtonStyle kMainButtonStyle = ElevatedButton.styleFrom(
//   backgroundColor: mainColor,
//   foregroundColor: Colors.white,
//   padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20), // ✅ أكبر
//   minimumSize: const Size(double.infinity, 60), // ✅ يعطيه عرض وارتفاع واضح
//   shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.circular(30),
//   ),
//   elevation: 5,
//   shadowColor: Colors.black.withOpacity(0.3),
// );

final ButtonStyle kMainButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: mainColor,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
);

// final ButtonStyle Singlebtn =ElevatedButton.styleFrom(
//     backgroundColor: const Color(0xFF113F67), // نفس لون الزر
//     padding: const EdgeInsets.symmetric(vertical: 14),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8), // نفس الزوايا
//     ),
//     minimumSize: const Size.fromHeight(50), // يأخذ عرض الشاشة بالكامل
//   );

  final ButtonStyle Singlebtn =ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF113F67), // نفس لون الزر
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // نفس الزوايا
    ),
    minimumSize: const Size.fromHeight(50), // يأخذ عرض الشاشة بالكامل
  );

  





final ButtonStyle kSecondaryButtonStyle = ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: mainColor,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(30),
  ),
  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
);

