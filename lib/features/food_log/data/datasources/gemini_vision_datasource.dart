import 'dart:convert';
import 'package:cross_file/cross_file.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';

abstract class GeminiVisionDataSource {
  Future<FoodAnalysisResult> analyzeFoodImage(XFile imageFile);
}

class GeminiVisionDataSourceImpl implements GeminiVisionDataSource {
  final GeminiClient _client;

  GeminiVisionDataSourceImpl(GeminiClient client) : _client = client;

  @override
  Future<FoodAnalysisResult> analyzeFoodImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();

      final prompt = TextPart(
        '''Analyze this image and return ONLY a JSON object (no markdown, no code blocks):

Return this exact JSON format:
{
  "is_food": true or false,
  "food_name": "short name of the food",
  "calories": estimated calories as number,
  "is_junk": true or false,
  "reason": "brief reason why it is or isn't junk food"
}

Rules:
- is_food: set to true ONLY if the image shows an actual food or drink item. Set to false for non-food items (electronics, objects, animals, people, places, etc.)
- If is_food is false, set calories to 0, is_junk to false, food_name to a brief description of what the image shows, and reason to explain why it is not food
- Estimate calories for a typical serving size shown
- is_junk should be true for fast food, processed food, sugary snacks, fried food
- is_junk should be false for fruits, vegetables, lean protein, whole grains
- Keep food_name concise''',
      );

      final imagePart = DataPart(
        'image/jpeg',
        bytes,
      );

      final response = await _client.generateContent([
        Content.multi([prompt, imagePart]),
      ]);

      final text = response.text?.trim() ?? '{}';

      final jsonString = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FoodAnalysisResult.fromJson(json);
    } catch (e, stackTrace) {
      AppLogger.error('Gemini API error: analyzeFoodImage', e, stackTrace);
      rethrow;
    }
  }
}
