import 'dart:convert';
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
  final GenerativeModel _model;

  GeminiDataSourceImpl(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
        );

  @override
  Future<FoodAnalysisResult> analyzeFood(String foodDescription) async {
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

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text?.trim() ?? '{}';

    // Clean markdown code blocks if present
    final jsonString = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return FoodAnalysisResult.fromJson(json);
  }
}
