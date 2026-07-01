import 'dart:convert';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FoodAnalysisResult {
  final String foodName;
  final double calories;
  final bool isJunk;
  final String reason;
  final bool isFood;

  const FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.isJunk,
    required this.reason,
    this.isFood = true,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] as String,
      calories: (json['calories'] as num).toDouble(),
      isJunk: json['is_junk'] as bool,
      reason: json['reason'] as String,
      isFood: json['is_food'] as bool? ?? true,
    );
  }
}

abstract class GeminiDataSource {
  Future<FoodAnalysisResult> analyzeFood(String foodDescription);
}

class GeminiDataSourceImpl implements GeminiDataSource {
  final GeminiClient _client;

  GeminiDataSourceImpl(GeminiClient client) : _client = client;

  @override
  Future<FoodAnalysisResult> analyzeFood(String foodDescription) async {
    try {
      final prompt = '''
Analyze this food and return ONLY a JSON object (no markdown, no code blocks):

Food: "$foodDescription"

Return this exact JSON format:
{
  "is_food": true or false,
  "food_name": "short name of the food",
  "calories": estimated calories as number,
  "is_junk": true or false,
  "reason": "brief reason why it is or isn't junk food"
}

Rules:
- is_food: set to true ONLY if the input is an actual food or drink item. Set to false for non-food items (electronics, objects, animals, people, places, etc.)
- If is_food is false, set calories to 0, is_junk to false, food_name to the input text, and reason to explain why it is not food
- Estimate calories for a typical serving size
- is_junk should be true for fast food, processed food, sugory snacks, fried food
- is_junk should be false for fruits, vegetables, lean protein, whole grains
- Keep food_name concise
''';

      final response = await _client.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '{}';

      final jsonString = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FoodAnalysisResult.fromJson(json);
    } catch (e, stackTrace) {
      AppLogger.error('Gemini API error: analyzeFood', e, stackTrace);
      rethrow;
    }
  }
}
