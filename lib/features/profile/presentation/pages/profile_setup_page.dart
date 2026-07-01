import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bite_balance/core/constants/app_theme.dart';
import 'package:bite_balance/core/utils/error_handler.dart';
import 'package:bite_balance/core/widgets/app_toast.dart';
import 'package:bite_balance/features/profile/presentation/providers/profile_provider.dart';
import 'package:bite_balance/features/auth/presentation/widgets/auth_text_field.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedGoal = 'maintain';

  late final AnimationController _staggerController;
  late final List<Animation<double>> _fadeAnimations;
  late final List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _fadeAnimations = List.generate(7, (index) {
      final start = (index * 0.1).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOut),
      );
    });

    _slideAnimations = List.generate(7, (index) {
      final start = (index * 0.1).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);
      return Tween<Offset>(
        begin: const Offset(0, 0.25),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ));
    });

    _staggerController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(profileProvider.notifier).saveProfile(
          fullName: _nameController.text.trim(),
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text),
          goal: _selectedGoal,
        );
  }

  Widget _buildAnimatedChild(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    ref.listen<AsyncValue<dynamic>>(profileProvider, (previous, next) {
      next.whenOrNull(
        data: (profile) {
          if (profile != null) {
            context.go('/home');
          }
        },
        error: (error, stackTrace) {
          AppToast.show(
            context,
            message: ErrorHandler.message(error),
            backgroundColor: AppTheme.error,
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Setup Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Header with gradient ──
                    _buildAnimatedChild(
                      0,
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              AppTheme.secondary,
                              AppTheme.accent,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.person_add_rounded,
                                size: 26,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tell us about yourself',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'This helps us calculate your BMI',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Name Field ──
                    _buildAnimatedChild(
                      1,
                      AuthTextField(
                        controller: _nameController,
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Weight Field ──
                    _buildAnimatedChild(
                      2,
                      AuthTextField(
                        controller: _weightController,
                        labelText: 'Weight (kg)',
                        hintText: 'Enter your weight',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.monitor_weight_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your weight';
                          }
                          final weight = double.tryParse(value);
                          if (weight == null || weight <= 0) {
                            return 'Please enter a valid weight';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Height Field ──
                    _buildAnimatedChild(
                      3,
                      AuthTextField(
                        controller: _heightController,
                        labelText: 'Height (cm)',
                        hintText: 'Enter your height',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.height,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your height';
                          }
                          final height = double.tryParse(value);
                          if (height == null || height <= 0) {
                            return 'Please enter a valid height';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Goal Dropdown ──
                    _buildAnimatedChild(
                      4,
                      DropdownButtonFormField<String>(
                        initialValue: _selectedGoal,
                        decoration: const InputDecoration(
                          labelText: 'Goal',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'lose',
                            child: Text('Lose Weight'),
                          ),
                          DropdownMenuItem(
                            value: 'maintain',
                            child: Text('Maintain Weight'),
                          ),
                          DropdownMenuItem(
                            value: 'gain',
                            child: Text('Gain Weight'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedGoal = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Save Button ──
                    _buildAnimatedChild(
                      5,
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed:
                              profileState.isLoading ? null : _saveProfile,
                          child: profileState.isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save Profile'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
