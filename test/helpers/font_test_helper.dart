import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper to ensure Golden tests are consistent across OS environments
/// by globally disabling GoogleFonts runtime fetching and providing a 
/// baseline fallback.
class FontTestHelper {
  static void initialize() {
    // Disable runtime fetching which causes environmental mismatch
    GoogleFonts.config.allowRuntimeFetching = false;
  }

  /// Loads a mock font for testing purposes if custom text rendering is needed.
  /// Standard golden tests will often use a fallback font (like Roboto)
  /// that is bundled with the Flutter tester.
  static Future<void> loadTestFonts() async {
    // In many environments, matching against 'Roboto' or a generic font
    // is enough as long as runtime fetching is disabled.
  }
}
