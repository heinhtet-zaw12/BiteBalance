import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/core/utils/app_logger.dart';

class CalorieRecommendationResult {
  final double dailyCalorieTarget;
  final double healthyRatio;
  final String reasoning;

  const CalorieRecommendationResult({
    required this.dailyCalorieTarget,
    required this.healthyRatio,
    required this.reasoning,
  });

  factory CalorieRecommendationResult.fromJson(Map<String, dynamic> json) {
    return CalorieRecommendationResult(
      dailyCalorieTarget: (json['daily_calorie_target'] as num).toDouble(),
      healthyRatio: (json['healthy_ratio'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
    );
  }
}

abstract class GeminiCalorieDataSource {
  Future<CalorieRecommendationResult> getCalorieRecommendation({
    required double weightKg,
    required double heightCm,
    required String goal,
  });
}

class GeminiCalorieDataSourceImpl implements GeminiCalorieDataSource {
  final GenerativeModel _model;

  GeminiCalorieDataSourceImpl(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
        );

  @override
  Future<CalorieRecommendationResult> getCalorieRecommendation({
    required double weightKg,
    required double heightCm,
    required String goal,
  }) async {
    try {
      final prompt = '''
Calculate a daily calorie recommendation for this person and return ONLY a JSON object (no markdown, no code blocks):

Weight: ${weightKg}kg
Height: ${heightCm}cm
Goal: $goal (lose weight, maintain weight, or gain weight)

Use the Mifflin-St Jeor equation to calculate BMR, then adjust for activity level (assume moderate activity = 1.55 multiplier) and goal.

Return this exact JSON format:
{
  "daily_calorie_target": number (calories per day),
  "healthy_ratio": number between 0.0 and 1.0 (percentage of calories that should come from healthy food),
  "reasoning": "brief explanation of the calculation"
}

Rules:
- For "lose" goal: subtract 500 calories for ~0.5kg/week weight loss, healthy_ratio should be 0.85+
- For "maintain" goal: use TDEE as is, healthy_ratio should be 0.80
- For "gain" goal: add 300-500 calories for lean bulk, healthy_ratio should be 0.75+
- Minimum target should be 1200 calories for safety
- Keep reasoning concise (1-2 sentences)
''';

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim() ?? '{}';

      final jsonString = text
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return CalorieRecommendationResult.fromJson(json);
    } catch (e, stackTrace) {
      AppLogger.error('Gemini API error: getCalorieRecommendation', e, stackTrace);
      rethrow;
    }
  }
}
