# 🥗 Bite Balance

An AI-powered food tracker Flutter app that helps users log daily meals, analyze nutrition with Gemini AI, and track calorie intake with personalized BMI-based health recommendations.

---

## ✨ Features

- 🔐 Register / Login / Logout
- 👤 Profile setup — name, weight, height, goal
- 📊 BMI calculation with category indicator
- 📝 Log food by text or photo
- 🤖 AI food analysis — calories, healthy/junk classification
- 🎯 Personalized daily calorie target based on BMI
- 📈 Daily calorie dashboard with healthy vs junk breakdown
- 📅 Weekly & monthly stats with charts
- 🏆 Most eaten junk food tracking
- 🌐 Responsive — mobile & web support

## 🛠 Tech Stack

| Technology | Usage |
|-----------|-------|
| Flutter + Dart | Mobile & Web UI |
| Supabase | Auth + Database |
| Riverpod | State management |
| GoRouter | Navigation with auth guard |
| Gemini API | Food analysis + Vision |
| fl_chart | Analytics charts |

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/      # Colors, strings, theme
│   ├── errors/         # Failure classes
│   ├── router/         # GoRouter config
│   └── usecases/       # Base usecase class
│
├── features/
│   ├── auth/           # Register, Login, Logout
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/        # Profile setup, BMI
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── food_log/       # Food logging, Gemini analysis
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── analytics/      # Daily/weekly/monthly stats
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart
```

---

## 📸 Screenshots

### Auth
| Login | Sign Up |
|-------|---------|
| ![Login](assets/screenshots/login.png) | ![Sign Up](assets/screenshots/sign_up.png) |

<details>
<summary>👤 Profile & Home (click to expand)</summary>

| Profile Setup | Home |
|---------------|------|
| ![Profile Setup](assets/screenshots/profile_setUp.png) | ![Home](assets/screenshots/home.png) |

</details>

<details>
<summary>🍽️ Food Logging (click to expand)</summary>

| Log Food | Log Food 2 | Log Food 3 |
|----------|------------|------------|
| ![Log Food](assets/screenshots/food_log.png) | ![Log Food 2](assets/screenshots/food_log2.png) | ![Log Food 3](assets/screenshots/food_log3.png) |

</details>

<details>
<summary>📊 Dashboard (click to expand)</summary>

| Dashboard | Dashboard 2 |
|-----------|-------------|
| ![Dashboard](assets/screenshots/dashboard.png) | ![Dashboard 2](assets/screenshots/dashboard2.png) |

</details>

<details>
<summary>📅 Analytics (click to expand)</summary>

| Daily | Weekly | Monthly |
|-------|--------|---------|
| ![Daily](assets/screenshots/daily_analytics.png) | ![Weekly](assets/screenshots/weekly_analytics.png) | ![Monthly](assets/screenshots/monthly_analytics.png) |

</details>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Supabase account
- Gemini API key

### Installation

**1. Clone the repo**
```bash
git clone https://github.com/heinhtet-zaw12/BiteBalance.git
cd BiteBalance
```

**2. Install dependencies**
```bash
flutter pub get
```

**3. Setup environment variables**
```bash
cp .env.example .env
```

```
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
GEMINI_API_KEY=your-gemini-key
```

**4. Setup Supabase**

```sql
create table profiles (
  id uuid references auth.users primary key,
  full_name text,
  weight numeric,
  height numeric,
  goal text check (goal in ('lose','maintain','gain')),
  created_at timestamptz default now()
);

create table food_logs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users,
  food_name text,
  calories numeric,
  is_junk boolean,
  meal_type text,
  created_at timestamptz default now()
);

alter table profiles enable row level security;
alter table food_logs enable row level security;

create policy "Users own profile"
on profiles for all using (auth.uid() = id);

create policy "Users own food logs"
on food_logs for all using (auth.uid() = user_id);
```

**5. Run the app**
```bash
# Mobile
flutter run

# Web
flutter run -d chrome
```

---

## 🤖 Claude Code Setup

This project was built with Claude Code using MCP, Skills, and Agents.

```bash
# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Run in project folder
cd BiteBalance
claude
```

MCP config example in `.mcp.json.example` 👆