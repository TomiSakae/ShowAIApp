import 'package:flutter_test/flutter_test.dart';
import 'package:showai/screens/image_generation_screen.dart';

void main() {
  group('Image Generation Tests', () {
    test('Image size validation', () {
      expect(validateImageSize(512), true);
      expect(validateImageSize(1024), true);
      expect(validateImageSize(128), true);
      expect(validateImageSize(0), false);
      expect(validateImageSize(2048), false);
    });

    test('Prompt validation', () {
      expect(validatePrompt('Test prompt'), true);
      expect(validatePrompt(''), false);
      expect(validatePrompt('   '), false);
    });
  });
}
