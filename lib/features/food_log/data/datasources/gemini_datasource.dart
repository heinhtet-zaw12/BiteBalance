import 'dart:convert';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class FoodAnalysisResult {
  final String foodName;
  final double calories;
  final bool isJunk;
  final String reason;

  const FoodAnalysisResult({
    required this.foodName,
    required this.calories,
    required this.isJunk,
    required this.reason,
  });

  factory FoodAnalysisResult.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisResult(
      foodName: json['food_name'] as String,
      calories: (json['calories'] as num).toDouble(),
      isJunk: json['is_junk'] as bool,
      reason: json['reason'] as String,
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
  "food_name": "short name of the food",
  "calories": estimated calories as number,
  "is_junk": true or false,
  "reason": "brief reason why it is or isn't junk food"
}

Rules:
- Estimate calories for a typical serving size
- is_junk should be true for fast food, processed food, sugary snacks, fried food
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
