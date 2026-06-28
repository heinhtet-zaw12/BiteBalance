# Bite Balance Dark Glassmorphism Redesign

**Date:** 2026-06-28
**Status:** Approved
**Scope:** Full app UI redesign — dark theme, glassmorphism, neon palette, vibrant gradients

---

## 1. Color Palette

### Dark Backgrounds
| Role | Hex | Usage |
|------|-----|-------|
| Background | `#0D0B14` | Scaffold background, page base |
| Surface | `#1A1725` | Cards, nav bars, modals |
| Surface Variant | `#231F30` | Hover states, secondary containers |

### Neon Palette
| Role | Hex | Usage |
|------|-----|-------|
| Primary | `#9B7BFF` | Buttons, active states, icons |
| Primary Light | `#C4B5FD` | Highlights, subtle accents |
| Primary Dark | `#7C5CFC` | Pressed states, depth |
| Secondary | `#FF6B9D` | Gradient mid-point, warnings |
| Accent | `#00F5D4` | Success, progress, health indicators |

### Text
| Role | Hex |
|------|-----|
| Primary | `#F0EEFF` |
| Secondary | `#A09BB5` |
| Tertiary | `#6B6680` |

### Semantic
| Role | Hex |
|------|-----|
| Error | `#FF4757` |
| Success | `#00F5D4` |
| BMI Underweight | `#FFB347` |
| BMI Normal | `#00F5D4` |
| BMI Overweight | `#FF6B9D` |
| BMI Obese | `#FF4757` |

---

## 2. Glass Effect Specification

```dart
// Glass card decoration
BoxDecoration(
  color: AppTheme.surface.withValues(alpha: 0.6),
  borderRadius: BorderRadius.circular(20),
  border: Border.all(
    color: Colors.white.withValues(alpha: 0.08),
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: AppTheme.primary.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ],
)

// Applied with ClipRRect + BackdropFilter for blur
ClipRRect(
  borderRadius: BorderRadius.circular(20),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(/* glass decoration */),
  ),
)
```

**Rules:**
- All cards use glass effect (ClipRRect + BackdropFilter + glass decoration)
- Focused inputs get primary glow border
- Selected nav items get gradient pill indicator
- Dividers: `Colors.white.withValues(alpha: 0.08)`

---

## 3. Gradients

### Hero Gradient (splash, auth panels, page headers)
```dart
LinearGradient(
  colors: [Color(0xFF9B7BFF), Color(0xFFFF6B9D), Color(0xFF00F5D4)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Button Gradient
```dart
LinearGradient(
  colors: [Color(0xFF9B7BFF), Color(0xFF7C5CFC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

### Accent Glow (decorative circles, highlights)
```dart
// Use secondary and accent at low opacity for decorative elements
Colors.white.withValues(alpha: 0.05)  // subtle circles
AppTheme.secondary.withValues(alpha: 0.12)  // pink glow
AppTheme.accent.withValues(alpha: 0.10)  // cyan glow
```

---

## 4. Screen Specifications

### Splash Page
- BG: `#0D0B14`
- Logo: glass container with tri-color gradient glow behind it
- App name: `F0EEFF`, tagline: `A09BB5`
- Spinner: electric violet with glow

### Login & Register Pages
- **Branded panel (wide):** tri-color hero gradient, decorative circles in neon tints, glass feature chips
- **Form side:** dark BG, glass input fields, gradient button with glow
- **Mobile:** dark BG, same form in single column

### Profile Setup Page
- Header: tri-color gradient container with glass overlay
- Inputs: dark glass style
- Goal dropdown: dark glass surface
- Button: gradient with glow

### Home Page
- BG: `#0D0B14`
- BMI Card: glass, BMI colors use neon semantic palette
- Calorie Target Card: glass with accent glow
- Remaining Calories: glass, progress ring in neon cyan
- Goal Card: glass, flag icon in accent
- Action Cards: glass with press glow animation
- FAB: gradient fill

### Dashboard Page
- Date badge: glass chip
- Calorie Summary: glass card
- Healthy/Junk Chart: glass container, neon chart colors
- Food Log Tiles: glass with colored left border
- Empty state: glass card, muted icon

### Analytics Page
- Tab bar: dark surface, violet active indicator
- Progress Cards: glass with gradient progress bars
- Pie/Bar Charts: neon palette colors
- Stats Info: glass with icon badges

### Food Log Page
- Header: tri-color gradient
- Photo button: glass with dashed neon border
- Meal chips: glass unselected, gradient selected
- Analyze button: gradient with glow
- Result card: glass with status left-border
- Error: glass container with red glow

### Main Scaffold
- Bottom Nav: frosted glass (BackdropFilter) with dark tint
- Sidebar (desktop): frosted glass, gradient active pill
- Active indicator: primary color

---

## 5. Component Updates

### GlassCard (new reusable widget)
```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final List<BoxShadow>? boxShadow;

  // Wraps child in ClipRRect + BackdropFilter + glass Container
}
```

### AuthTextField
- Dark fill `#1A1725`
- Border: white 8%
- Focus: primary glow border + shadow
- Text: `F0EEFF`

### NavigationBar / Sidebar
- Glass surface with BackdropFilter
- Active indicator: gradient pill
- Icons: white when active, tertiary when inactive

### Charts (HealthyJunkPieChart, JunkFoodBarChart, etc.)
- Update color constants to neon palette
- Keep chart logic unchanged

---

## 6. Files to Modify

1. `lib/core/constants/app_theme.dart` — full dark theme rewrite
2. `lib/features/splash/presentation/pages/splash_page.dart`
3. `lib/features/auth/presentation/pages/login_page.dart`
4. `lib/features/auth/presentation/pages/register_page.dart`
5. `lib/features/auth/presentation/widgets/auth_text_field.dart`
6. `lib/features/profile/presentation/pages/profile_setup_page.dart`
7. `lib/features/profile/presentation/pages/home_page.dart`
8. `lib/features/profile/presentation/widgets/bmi_card.dart`
9. `lib/features/profile/presentation/widgets/bmi_indicator.dart`
10. `lib/features/profile/presentation/widgets/calorie_target_card.dart`
11. `lib/features/profile/presentation/widgets/remaining_calories_card.dart`
12. `lib/features/dashboard/presentation/pages/dashboard_page.dart`
13. `lib/features/dashboard/presentation/widgets/calorie_summary_card.dart`
14. `lib/features/dashboard/presentation/widgets/healthy_junk_chart.dart`
15. `lib/features/dashboard/presentation/widgets/food_log_tile.dart`
16. `lib/features/analytics/presentation/pages/analytics_page.dart`
17. `lib/features/analytics/presentation/widgets/calorie_progress_card.dart`
18. `lib/features/analytics/presentation/widgets/healthy_junk_pie_chart.dart`
19. `lib/features/analytics/presentation/widgets/junk_food_bar_chart.dart`
20. `lib/features/food_log/presentation/pages/food_log_page.dart`
21. `lib/features/main/presentation/pages/main_scaffold.dart`
22. `lib/main.dart` — ensure dark theme is applied

---

## 7. New Utility

### `lib/core/widgets/glass_card.dart`
Reusable glassmorphism card widget used across all screens. Accepts child, padding, borderRadius, boxShadow. Wraps in ClipRRect + BackdropFilter.

---

## 8. Constraints

- No new packages (BackdropFilter is built-in Flutter)
- Clean architecture layers stay unchanged
- Only presentation layer + theme constants change
- All existing animations preserved
- Responsive layout logic unchanged
