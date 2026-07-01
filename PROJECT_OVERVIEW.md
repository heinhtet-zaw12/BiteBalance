# Bite Balance — Full Project Walkthrough

## What This App Is

Bite Balance is a **Flutter mobile app** that helps you track what you eat, analyze nutrition with AI, and see how healthy your diet is over time. Think of it as a smart food diary — you log meals, it tells you the calories, flags junk food, and shows you trends.

---

## 1. `main.dart` — Where Everything Starts

This is the front door of the app. It does exactly three things in order:

1. **Loads secrets** — reads `.env` (Supabase URL, API keys) using `flutter_dotenv`. This file is git-ignored so credentials never get committed.
2. **Connects to Supabase** — initializes the Supabase client with those credentials. This gives the app access to auth and the database.
3. **Launches the Flutter app** — wraps everything in `ProviderScope` (Riverpod's state management container), then hands off to `MaterialApp.router` which uses GoRouter for navigation and a custom violet-themed design.

After `main()` runs, the first thing the user sees is the **SplashPage** at route `/`.

---

## 2. `core/` — Shared Infrastructure

This folder has no features of its own. It holds **reusable building blocks** that every feature depends on.

### `core/constants/`
- **`app_strings.dart`** — Every user-facing string in one place (app name, button labels, error messages). Change a string here, it updates everywhere.
- **`app_theme.dart`** — The entire visual identity: soft violet primary color (`#7C5CFC`), coral pink secondary, mint green accent, off-white background. Defines how every Material widget looks — cards, buttons, inputs, snackbars, app bars. Also has BMI-specific colors (green for normal, orange for overweight, etc.) and a custom font (Archivo Black).

### `core/errors/`
- **`failures.dart`** — A simple error hierarchy. `Failure` is an abstract class with a `message` string. Three concrete types: `AuthFailure` (login/signup errors), `ServerFailure` (Supabase/API errors), `CacheFailure` (local storage errors). The domain layer returns these instead of throwing exceptions.

### `core/usecases/`
- **`usecase.dart`** — A contract every use case must follow: `UseCase<Type, Params>` has one method `call(params)` that returns `Future<Either<Failure, Type>>`. The `Either` type (from `fpdart`) means the result is *either* a failure or a success — never both, never neither. `NoParams` is a helper for use cases that don't need input.

### `core/router/`
- **`app_router.dart`** — GoRouter configuration. Maps URL paths to pages:

| Path | Page | Purpose |
|---|---|---|
| `/` | SplashPage | First screen — checks if logged in |
| `/login` | LoginPage | Email/password login |
| `/register` | RegisterPage | Create account |
| `/profile-setup` | ProfileSetupPage | Enter name, weight, height, goal |
| `/food-log` | FoodLogPage | Log a meal (push route) |
| `/home` | HomePage | Dashboard with BMI and calories |
| `/dashboard` | DashboardPage | Today's food log breakdown |
| `/analytics` | AnalyticsPage | Daily/weekly/monthly trends |

The last three are wrapped in a `ShellRoute` — that means they share a common navigation bar (bottom bar on mobile, sidebar on desktop) via `MainScaffold`.

### `core/utils/`
- **`responsive.dart`** — Layout helpers that check screen width. Mobile (<600px), tablet (600–1024px), desktop (≥1024px). Used to decide whether to stack things vertically or put them side by side.

---

## 3. Feature Folders — The Meat of the App

Every feature follows the same **3-layer structure**:

```
feature/
├── data/          ← Talks to Supabase/Gemini (external)
├── domain/        ← Pure business logic (no external dependencies)
└── presentation/  ← UI widgets and Riverpod providers
```

The rule: **Presentation → Domain ← Data**. The domain layer never imports Flutter, Supabase, or any package. It only knows about abstractions.

---

### 3a. `features/auth/` — Login & Registration

**What it does:** Lets users create an account and sign in.

**Domain layer** (pure logic):
- `User` entity — just an `id` and `email`. Nothing else.
- `AuthRepository` — an *interface* (abstract class) that says "any auth implementation must support `signIn`, `signUp`, `signOut`, and `currentUser`." It doesn't know *how* — that's the data layer's problem.
- Three use cases: `SignIn`, `SignUp`, `SignOut`. Each takes its parameters, calls the repository, and returns `Either<Failure, User>`.

**Data layer** (Supabase connection):
- `AuthRemoteDataSource` — the actual Supabase auth calls (`signInWithPassword`, `signUp`, `signOut`). Returns `UserModel`.
- `UserModel extends User` — converts Supabase's response into the domain's `User` entity. Handles the JSON mapping.
- `AuthRepositoryImpl implements AuthRepository` — wraps the data source in try/catch. If Supabase throws, it catches it and returns `Left(AuthFailure(...))` instead of crashing.

**Presentation layer** (what the user sees):
- `AuthNotifier` (Riverpod `AsyncNotifier`) — holds the current user state. Exposes `signIn()` and `signUp()` methods that the UI calls. Manages loading/error/success states via `AsyncValue`.
- `LoginPage` — animated form with email + password fields. Calls `authNotifier.signIn()`. Listens for state changes: success → navigate to `/home`, error → show red SnackBar.
- `RegisterPage` — same pattern but with a confirm-password field.
- `AuthTextField` — a reusable text input with animated focus shadows. Used across login, register, and profile setup.

---

### 3b. `features/profile/` — User Profile & BMI

**What it does:** Stores the user's personal info (name, weight, height, goal), calculates BMI, and uses Gemini AI to recommend a daily calorie target.

**Domain layer**:
- `Profile` entity — `id`, `fullName`, `weight`, `height`, `goal` (lose/maintain/gain).
- `CalorieRecommendation` entity — `dailyCalorieTarget`, `healthyRatio`, `reasoning` (AI explanation).
- `ProfileRepository` interface — `getProfile(userId)` and `saveProfile(profile)`.
- `CalculateBmi` — a pure function (not even a use case). Takes weight and height, returns BMI number and category (Underweight/Normal/Overweight/Obese). Runs entirely on-device, no API.
- `GetProfile`, `SaveProfile` — standard use cases delegating to the repository.
- `GetCalorieRecommendation` — sends the user's stats to Gemini AI and gets back a calorie recommendation with reasoning.

**Data layer**:
- `ProfileRemoteDataSource` — Supabase `profiles` table. `getProfile` does a select with `maybeSingle()` (returns null if no profile yet). `saveProfile` does an upsert (insert or update).
- `ProfileModel extends Profile` — maps between Supabase's snake_case columns (`full_name`, `created_at`) and Dart's camelCase fields.
- `GeminiCalorieDataSource` — sends a carefully crafted prompt to Gemini 2.5 Flash Lite: "Given this weight/height/goal, calculate BMR using Mifflin-St Jeor and recommend daily calories." Parses the JSON response.

**Presentation layer**:
- `ProfileNotifier` — loads the current user's profile on startup. Exposes `loadProfile()` and `saveProfile()`.
- `ProfileSetupPage` — form with name, weight (kg), height (cm), and goal dropdown. Staggered entrance animations. On save → navigates to `/home`.
- `HomePage` — the main screen after login. Shows:
  - Greeting with user's name
  - **BMI card** with a gradient-shaded number, category badge, and progress bar
  - **Calorie target card** from Gemini AI
  - **Remaining calories card** (target minus what you've eaten today)
  - Action cards to log food or view dashboard
- `BmiCard`, `BmiIndicator`, `CalorieTargetCard`, `RemainingCaloriesCard` — specialized widgets for each section.

---

### 3c. `features/food_log/` — Logging Meals

**What it does:** The core feature. Users describe a meal (text or photo), AI analyzes it for calories and healthiness, then it gets saved to Supabase.

**Domain layer**:
- `FoodLog` entity — `id`, `userId`, `foodName`, `calories`, `isJunk` (boolean), `mealType` (breakfast/lunch/dinner/snack), `createdAt`.
- `FoodLogRepository` interface — `logFood`, `getDailyLogs`, `deleteFoodLog`.
- `AnalyzeFood` — sends a text description to Gemini. Returns `FoodAnalysisResult` (name, calories, isJunk, reason).
- `AnalyzeFoodImage` — sends a photo to Gemini Vision. Same return format.
- `GetDailyLogs`, `LogFood` — standard use cases.

**Data layer**:
- `FoodLogRemoteDataSource` — Supabase `food_logs` table. Insert, select (filtered by date range), delete.
- `FoodLogModel extends FoodLog` — JSON mapping. Note: `toJson()` excludes `id` for inserts (Supabase auto-generates it).
- `GeminiDataSource` — text analysis. Sends "Analyze this food: [description]. Return JSON with foodName, calories, isJunk, reason."
- `GeminiVisionDataSource` — image analysis. Sends the image bytes as a `DataPart` alongside the same prompt.

**Presentation layer**:
- `FoodLogNotifier` — manages a two-step flow: (1) analyze → (2) save. Tracks `isAnalyzing`, `isSaving`, `analysis` result, and `error`.
- `FoodLogPage` — the full logging experience:
  1. Pick a photo from gallery (optional) or type a description
  2. Select meal type (chips: breakfast/lunch/dinner/snack)
  3. Tap "Analyze" — shows loading spinner while Gemini processes
  4. See the result card: AI badge, food name, calories, healthy/junk tag, reasoning text
  5. Tap "Save to Log" — persists to Supabase

---

### 3d. `features/dashboard/` — Today's Overview

**What it does:** Shows what you ate today in a clean summary. This feature has **no data layer** of its own — it borrows the food_log feature's repository.

**Domain layer**:
- `DailySummary` entity — wraps a list of `FoodLog` entries for one day. Has computed properties: `totalCalories`, `healthyCalories`, `junkCalories`, `healthyCount`, `junkCount`.
- `GetDailySummary` use case — calls `foodLogRepository.getDailyLogs()` and wraps the result in a `DailySummary`.

**Presentation layer**:
- `DashboardNotifier` — loads the summary for a given date.
- `DashboardPage` — shows:
  - Date header
  - **Calorie summary card** — total calories and item count
  - **Healthy vs junk pie chart** — donut chart with percentages (uses `fl_chart`)
  - **Food log list** — each entry as a tile with icon, name, meal type badge, calories, and healthy/junk tag
- Pull-to-refresh to reload.

---

### 3e. `features/analytics/` — Trends Over Time

**What it does:** Shows daily, weekly, and monthly breakdowns of eating habits. The most data-heavy feature.

**Domain layer**:
- `DailyStats`, `WeeklyStats`, `MonthlyStats`, `FoodItemStats` entities — each with computed ratios (healthy % vs junk %). Weekly/monthly stats include a `dailyBreakdown` array and `topJunkFoods` list.
- `AnalyticsRepository` interface — `getDailyStats`, `getWeeklyStats`, `getMonthlyStats`.
- Three use cases, one per time range.

**Data layer**:
- `AnalyticsRemoteDataSource` — one Supabase query: `getLogsByDateRange(userId, start, end)`. Has an extension method on `List<FoodLogModel>` that computes totals and top junk foods.
- `AnalyticsRepositoryImpl` — fetches logs for the date range, groups them by day, then computes stats for each time frame. Weekly = last 7 days. Monthly = full calendar month.

**Presentation layer**:
- Three separate notifiers: `DailyStatsNotifier`, `WeeklyStatsNotifier`, `MonthlyStatsNotifier`.
- `AnalyticsPage` — tabbed interface (Daily / Weekly / Monthly). Each tab shows:
  - **Calorie progress card** — eaten vs target with progress bar
  - **Healthy vs junk pie chart**
  - **Junk food bar chart** — top junk foods by frequency
  - Summary card with totals

---

### 3f. `features/splash/` — Launch Screen

One file. Shows an animated logo (fade + scale) and app name (slide in). After 2 seconds, checks if there's an existing Supabase session:
- **Yes** → go to `/home`
- **No** → go to `/login`

Uses a Hero animation tag `'app_logo'` that transitions smoothly into the login page logo.

---

### 3g. `features/main/` — Navigation Shell

One file. `MainScaffold` is the frame around the three main pages (Home, Dashboard, Analytics):
- **Mobile/tablet** — bottom `NavigationBar` with three icons
- **Desktop** — side navigation bar with logo header and labeled items
- Content area is centered with a max width of 1200px so it doesn't stretch on wide screens

---

## 4. Data Flow — From Tap to Database and Back

Here's the full journey of logging a meal:

```
User types "chicken rice" → taps "Analyze"
        │
        ▼
┌─ Presentation ─────────────────────────────┐
│  FoodLogPage calls:                        │
│    ref.read(foodLogProvider.notifier)      │
│      .analyzeFood("chicken rice")          │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Presentation (Provider) ──────────────────┐
│  FoodLogNotifier.analyzeFood() sets        │
│  isAnalyzing = true, calls AnalyzeFood     │
│  use case                                  │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Domain ───────────────────────────────────┐
│  AnalyzeFood.call(description)             │
│  calls geminiDataSource.analyzeFood()      │
│  (⚠️ direct dependency — architecture      │
│   violation, should go through repository) │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Data ─────────────────────────────────────┐
│  GeminiDataSourceImpl sends HTTP request   │
│  to Gemini 2.5 Flash Lite API              │
│  Parses JSON response into                 │
│  FoodAnalysisResult                        │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Presentation ─────────────────────────────┐
│  FoodLogNotifier updates state:            │
│    analysis = result, isAnalyzing = false  │
│  UI rebuilds → shows result card           │
└────────────────────────────────────────────┘
        │
User taps "Save to Log"
        │
        ▼
┌─ Presentation (Provider) ──────────────────┐
│  FoodLogNotifier.saveFood() sets           │
│  isSaving = true, calls LogFood use case   │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Domain ───────────────────────────────────┐
│  LogFood.call(foodLog)                     │
│  calls foodLogRepository.logFood()         │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Data ─────────────────────────────────────┐
│  FoodLogRepositoryImpl calls               │
│  FoodLogRemoteDataSource.logFood()         │
│  → Supabase INSERT into food_logs table    │
│  Returns Right(FoodLog) on success         │
│  or Left(ServerFailure) on error           │
└────────────────────────────────────────────┘
        │
        ▼
┌─ Presentation ─────────────────────────────┐
│  State updates: isSaving = false           │
│  Shows success SnackBar                    │
│  Navigator.pop() back to home              │
└────────────────────────────────────────────┘
```

**The pattern is always the same:**
1. **UI** calls a method on a Riverpod notifier
2. **Notifier** calls a use case
3. **Use case** calls a repository (or datasource — with an architecture violation)
4. **Repository** calls the datasource
5. **Datasource** talks to Supabase or Gemini
6. Result comes back up the chain as `Either<Failure, Success>`
7. **Notifier** updates state → **UI** rebuilds

---

## 5. The Navigation Flow

```
App Launch
    │
    ▼
SplashPage ──(2 sec animation)──► Has session?
    │                                  │
    │                         No ──────┼──────► Yes
    │                                  │           │
    ▼                                  ▼           ▼
LoginPage ◄──────────────────── RegisterPage    /home
    │                                  ▲           │
    │──► "Create account" ─────────────┘           │
    │                                              │
    │──► Login success ──► Has profile?            │
    │                          │                   │
    │                 No ──────┼──────► Yes        │
    │                          │           │       │
    │                          ▼           ▼       │
    │                   ProfileSetupPage   /home   │
    │                          │           ▲       │
    │                          └───────────┘       │
    │                                              │
    └──── /home ◄─────────────────────────────────┘
              │
              ├─► /dashboard (today's breakdown)
              ├─► /analytics (daily/weekly/monthly trends)
              └─► /food-log (push route, log a meal)
```

---

## 6. Key Packages and What They Do

| Package | Role |
|---|---|
| `supabase_flutter` | Database (Postgres) + Authentication |
| `flutter_riverpod` | State management — providers, notifiers, AsyncValue |
| `go_router` | Declarative routing with path-based URLs |
| `fpdart` | Functional programming — `Either<Failure, Success>` type |
| `google_generative_ai` | Gemini AI for food analysis and calorie recommendations |
| `fl_chart` | Pie charts and bar charts for analytics |
| `image_picker` | Camera/gallery access for food photos |
| `flutter_dotenv` | Loads `.env` file for API keys |
| `google_fonts` | Custom typography (Archivo Black) |

---

## 7. One Thing to Note

The CLAUDE.md file describes a **V1/V2/V3 roadmap** where only V1 (auth + profile + BMI) should be built right now. In reality, the codebase has **already implemented V2 and V3 features** — food logging, daily dashboard, Gemini AI analysis, photo-based food analysis, and full analytics. So the code is ahead of what the project plan says.
