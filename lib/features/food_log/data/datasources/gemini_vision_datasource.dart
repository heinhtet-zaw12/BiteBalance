import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';

abstract class GeminiVisionDataSource {
  Future<FoodAnalysisResult> analyzeFoodImage(File imageFile);
}

class GeminiVisionDataSourceImpl implements GeminiVisionDataSource {
  final GenerativeModel _model;

  GeminiVisionDataSourceImpl(String apiKey)
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash-lite',
          apiKey: apiKey,
        );

  @override
  Future<FoodAnalysisResult> analyzeFoodImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();

    final prompt = TextPart(
      '''Analyze this food image and return ONLY a JSON object (no markdown, no code blocks):

Return this exact JSON format:
{
  "food_name": "short name of the food",
  "calories": estimated calories as number,
  "is_junk": true or false,
  "reason": "brief reason why it is or isn't junk food"
}

Rules:
- Estimate calories for a typical serving size shown
- is_junk should be true for fast food, processed food, sugary snacks, fried food
- is_junk should be false for fruits, vegetables, lean protein, whole grains
- Keep food_name concise''',
    );

    final imagePart = DataPart(
      'image/jpeg',
      bytes,
    );

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

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
