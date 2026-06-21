# Food Tracker — CLAUDE.md

## Project Overview
A Flutter mobile app that helps users track daily food intake,
analyze nutrition with AI, and get personalized health suggestions
based on BMI and eating habits.

## Target User
Health-conscious individuals who want to monitor their daily
calorie intake and reduce junk food consumption.

---

## Tech Stack
        - Flutter (Dart) — Mobile UI
      - Supabase — Database & Auth
      - Riverpod (flutter_riverpod) — State Management
      - GoRouter — Navigation
      - flutter_dotenv — Environment variables
      

## Future Tech (V2/V3 only — do NOT add now)
    - Gemini Vision API — Food photo analysis
    - google_generative_ai package

---
## Version Roadmap

### V1 (Current — build this only)
    - Supabase Auth (register / login / logout)
    - Profile setup (full name, weight, height, goal)
    - BMI calculation (local, no API)
    - BMI result display with category & color indicator
    - GoRouter auth guard (logged out → login page)

### V2 (Next — do NOT build yet)
    - Food logging (text input)
    - Daily calorie dashboard
    - Supabase food_logs table

### V3 (Future — do NOT build yet)
    - Gemini Vision API integration
    - Photo food analysis
    - Health suggestions
    - Monthly report

## IMPORTANT
    Do NOT implement anything beyond V1 features.
    Do NOT create food_log or daily_summary tables.
    Do NOT integrate any AI or Gemini API.
    Do NOT add any packages not listed in V1 tech stack.

---

## Architecture — Clean Architecture (strictly)

### Dependency Rule
Presentation → Domain ← Data
Domain layer knows NOTHING about Flutter, Supabase, or any external package.

### 3 Layers per Feature

**Data Layer**
    - datasources/ → Supabase API calls only
    - models/ → JSON serializable classes (extends domain entity)
    - repositories/ → implements domain repository interface

**Domain Layer**
    - entities/ → pure Dart classes only
    - repositories/ → abstract interfaces
    - usecases/ → single responsibility, one usecase per file

**Presentation Layer**
    - providers/ → Riverpod providers (AsyncNotifier)
    - pages/ → full screen widgets
    - widgets/ → reusable UI components

---

## Folder Structure

    lib/
    
    ├── core/
    
    │   ├── constants/
    
    │   │   ├── app_colors.dart
    
    │   │   ├── app_strings.dart
    
    │   │   └── app_endpoints.dart
    
    │   ├── errors/
    
    │   │   └── failures.dart
    
    │   ├── usecases/
    
    │   │   └── usecase.dart
    
    │   └── router/
    
    │       └── app_router.dart
    
    │
    
    ├── features/
    
    │   ├── auth/
    
    │   │   ├── data/
    
    │   │   │   ├── datasources/
    
    │   │   │   │   └── auth_remote_datasource.dart
    
    │   │   │   ├── models/
    
    │   │   │   │   └── user_model.dart
    
    │   │   │   └── repositories/
    
    │   │   │       └── auth_repository_impl.dart
    
    │   │   ├── domain/
    
    │   │   │   ├── entities/
    
    │   │   │   │   └── user.dart
    
    │   │   │   ├── repositories/
    
    │   │   │   │   └── auth_repository.dart
    
    │   │   │   └── usecases/
    
    │   │   │       ├── sign_in.dart
    
    │   │   │       ├── sign_up.dart
    
    │   │   │       └── sign_out.dart
    
    │   │   └── presentation/
    
    │   │       ├── providers/
    
    │   │       │   └── auth_provider.dart
    
    │   │       ├── pages/
    
    │   │       │   ├── login_page.dart
    
    │   │       │   └── register_page.dart
    
    │   │       └── widgets/
    
    │   │           └── auth_text_field.dart
    
    │   │
    
    │   ├── profile/
    
    │   │   ├── data/
    
    │   │   │   ├── datasources/
    
    │   │   │   │   └── profile_remote_datasource.dart
    
    │   │   │   ├── models/
    
    │   │   │   │   └── profile_model.dart
    
    │   │   │   └── repositories/
    
    │   │   │       └── profile_repository_impl.dart
    
    │   │   ├── domain/
    
    │   │   │   ├── entities/
    
    │   │   │   │   └── profile.dart
    
    │   │   │   ├── repositories/
    
    │   │   │   │   └── profile_repository.dart
    
    │   │   │   └── usecases/
    
    │   │   │       ├── save_profile.dart
    
    │   │   │       ├── get_profile.dart
    
    │   │   │       └── calculate_bmi.dart
    
    │   │   └── presentation/
    
    │   │       ├── providers/
    
    │   │       │   └── profile_provider.dart
    
    │   │       ├── pages/
    
    │   │       │   ├── profile_setup_page.dart
    
    │   │       │   └── home_page.dart
    
    │   │       └── widgets/
    
    │   │           ├── bmi_card.dart
    
    │   │           └── bmi_indicator.dart
    
    │
    
    └── main.dart
---

## Supabase Tables — V1 Only

```sql
-- profiles table only
create table profiles (
  id uuid references auth.users primary key,
  full_name text,
  weight numeric,
  height numeric,
  goal text check (goal in ('lose','maintain','gain')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- RLS
alter table profiles enable row level security;

create policy "Users can only access own profile"
on profiles for all
using (auth.uid() = id);
```

---

## Coding Rules

### Must Follow
- Use `const` constructors everywhere possible
- All async states use `AsyncValue` from Riverpod
- Every API call must handle loading / error / success states
- No direct Supabase calls from UI layer ever
- No business logic inside Widget `build()` method
- Use `AsyncNotifier` for providers with async operations
- Environment variables via `flutter_dotenv` — never hardcode keys

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `kConstantName`

### BMI Calculation (local only)
```dart
double calculateBmi(double weight, double height) {
  final heightInMeters = height / 100;
  return weight / (heightInMeters * heightInMeters);
}

String getBmiCategory(double bmi) {
  if (bmi < 18.5) return 'Underweight';
  if (bmi < 25.0) return 'Normal';
  if (bmi < 30.0) return 'Overweight';
  return 'Obese';
}
```

---

## Environment Variables (.env)
    SUPABASE_URL=your-supabase-url
    
    SUPABASE_ANON_KEY=your-anon-key
    
    Never commit `.env` to GitHub — add to `.gitignore`

---

## Git Rules
    - Commit per feature: `feat: add login page`
    - Bug fix: `fix: bmi calculation error`
    - Setup: `chore: add dependencies`