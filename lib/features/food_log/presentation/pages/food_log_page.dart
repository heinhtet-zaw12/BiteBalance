import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/features/food_log/presentation/providers/food_log_provider.dart';

class FoodLogPage extends ConsumerStatefulWidget {
  const FoodLogPage({super.key});

  @override
  ConsumerState<FoodLogPage> createState() => _FoodLogPageState();
}

class _FoodLogPageState extends ConsumerState<FoodLogPage> {
  final _foodController = TextEditingController();
  final _imagePicker = ImagePicker();
  String _selectedMealType = 'lunch';
  File? _selectedImage;

  @override
  void dispose() {
    _foodController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  Future<void> _analyzeFood() async {
    final food = _foodController.text.trim();
    if (food.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter food description or take a photo'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_selectedImage != null) {
      await ref.read(foodLogProvider.notifier).analyzeFoodImage(_selectedImage!);
    } else {
      await ref.read(foodLogProvider.notifier).analyzeFood(food);
    }
  }

  Future<void> _saveFoodLog() async {
    final success =
        await ref.read(foodLogProvider.notifier).saveFoodLog(_selectedMealType);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Food logged successfully!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      context.pop();
    }
  }

  void _clearImage() {
    setState(() => _selectedImage = null);
  }

  @override
  Widget build(BuildContext context) {
    final foodLogState = ref.watch(foodLogProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Log Food'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.primaryDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'AI Food Analysis',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe your meal or upload a photo',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photo Section
            if (_selectedImage != null) ...[
              // Image Preview
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _clearImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ] else ...[
              // Gallery Button
              _buildPhotoButton(
                icon: Icons.photo_library_rounded,
                label: 'Pick from Gallery',
                onTap: _pickFromGallery,
              ),
              const SizedBox(height: 16),

              // Divider with "OR"
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Food Input
            TextFormField(
              controller: _foodController,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'Food Description',
                hintText:
                    'e.g., Grilled chicken salad with olive oil dressing',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Meal Type Selection
            Text(
              'Meal Type',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildMealChip(
                    'breakfast', 'Breakfast', Icons.free_breakfast_rounded),
                _buildMealChip('lunch', 'Lunch', Icons.lunch_dining_rounded),
                _buildMealChip(
                    'dinner', 'Dinner', Icons.dinner_dining_rounded),
                _buildMealChip('snack', 'Snack', Icons.cookie_rounded),
              ],
            ),
            const SizedBox(height: 28),

            // Analyze Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: foodLogState.isAnalyzing ? null : _analyzeFood,
                icon: foodLogState.isAnalyzing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                    foodLogState.isAnalyzing ? 'Analyzing...' : 'Analyze'),
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (foodLogState.error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.error_outline_rounded,
                        color: AppTheme.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        foodLogState.error!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

            // Analysis Result Card
            if (foodLogState.analysis != null) ...[
              _buildResultCard(foodLogState),
              const SizedBox(height: 24),

              // Confirm Button
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: foodLogState.isSaving ? null : _saveFoodLog,
                  icon: foodLogState.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label:
                      Text(foodLogState.isSaving ? 'Saving...' : 'Save to Log'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealChip(String value, String label, IconData icon) {
    final isSelected = _selectedMealType == value;
    final selectedColor = AppTheme.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: isSelected,
        selectedColor: selectedColor,
        backgroundColor: AppTheme.surface,
        side: BorderSide(
          color: isSelected ? selectedColor : AppTheme.divider,
          width: 1.5,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedMealType = value);
          }
        },
      ),
    );
  }

  Widget _buildResultCard(FoodLogState foodLogState) {
    final analysis = foodLogState.analysis!;
    final isJunk = analysis.isJunk;
    final statusColor = isJunk ? AppTheme.error : AppTheme.success;

    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: statusColor,
              width: 4,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI Badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primary,
                          AppTheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Analysis',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Food Name
              Text(
                analysis.foodName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),

              // Calories Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.bmiOverweight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: AppTheme.bmiOverweight,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      analysis.calories.toStringAsFixed(0),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: AppTheme.bmiOverweight,
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'kcal',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.bmiOverweight,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Healthy/Junk Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isJunk
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      size: 20,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isJunk ? 'Junk Food' : 'Healthy Food',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: statusColor,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reason
              Text(
                analysis.reason,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
