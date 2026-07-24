---
marp: true
paginate: true
transition: fade
---

<!-- slide 1 -->
# Stack

**Bite Balance — Full Technical Stack**

- **Frontend:** Flutter (Dart 3.10+) — cross-platform mobile UI
- **Backend:** Supabase — Auth, PostgreSQL database, Row Level Security
- **State Management:** Riverpod (`flutter_riverpod` ^2.6.1 + `fpdart`)
- **Routing:** GoRouter (^14.8.1) — declarative routing with auth guards
- **AI:** Google Gemini (`google_generative_ai` ^0.4.6) — Vision API for photo food analysis
- **Charts:** `fl_chart` ^0.70.2 — line, pie, bar charts for stats
- **UI Enhancements:** Lottie animations, Shimmer loading, Google Fonts
- **Image Picking:** `image_picker` ^1.1.2 — camera & gallery
- **Logging:** `logger` ^2.5.0 — structured app logging
- **Architecture:** Clean Architecture (3-layer: Presentation → Domain ← Data)
- **Hosting:** Vercel (Flutter web build via `flutter build web`)

---

<!-- slide 2 -->
# Agents

**4 Specialized Subagents** — defined in `.claude/agents/`

- **`bite-balance-v1-developer`** 🟢 — V1 feature implementation & review. Enforces Clean Architecture, Supabase Auth, profile CRUD, BMI calculation. Rejects V2/V3 scope creep.

- **`v3-gemini-food-dev`** 🔵 — V3 Gemini Vision API integration, photo food analysis, calorie recommendations, chart visualizations, Supabase date-based stats queries.

- **`flutter-ui-designer`** 🩷 — UI/UX polish, Material Design 3 theming, animations, color harmony, responsive layout, micro-interactions.

- **`flutter-error-handler`** 🔴 — Error handling specialist. Maps Supabase/network/auth exceptions to user-friendly messages, centralized failure classes, SnackBar patterns.

---

<!-- slide 3 -->
# Skills

**3 Custom Skills** — sourced from `.claude/skills/`

- **`supabase-developer`** — Full-stack Supabase development lifecycle: auth, PostgreSQL schema design with RLS, storage, real-time, edge functions, migrations, security best practices.

- **`flutter-development`** — Flutter & Dart best practices: widget composition, state management (Provider/Riverpod), GoRouter navigation, API integration, responsive design patterns.

- **`ui-ux-pro-max`** — Design intelligence toolkit: 50+ UI styles, 21 color palettes, 50 font pairings, 20 chart types, 8 supported stacks (Flutter included), UX guidelines, accessibility checks.

---

<!-- slide 4 -->
# Methodology

**Development Workflow & AI-Assisted Practices**

- **Clean Architecture (strictly enforced):** Domain layer is pure Dart with zero external imports. Data layer handles all Supabase/Gemini calls. Presentation uses Riverpod `AsyncValue` for loading/error/success states.

- **Version-Gated Development:** V1 (auth, profile, BMI) → V2 (food logging, daily dashboard) → V3 (Gemini Vision AI, charts, recommendations). Each agent/Skill enforces the version boundary.

- **MCP Integration:** Supabase MCP for database management + Context7 MCP for latest Flutter/Supabase documentation lookups.

- **AI Prompt Engineering:** Structured agent descriptions with `model: inherit`, `color` coding, and `memory: project`. Each agent has exhaustive `<example>` blocks for context-aware invocation.

- **Persistent Agent Memory:** Each agent maintains its own memory directory under `.claude/agent-memory/` for cross-session institutional knowledge.

- **Error-First Development:** Centralized `Failure` class hierarchy, error code mapping table, SnackBar-based user feedback, never raw exceptions in UI.

---

<!-- slide 5 -->
# Trigger

**How Agents & Skills Are Invoked**

- **Slash Commands:** Skills invoked via `/skill-name` (e.g., `/supabase-developer`, `/flutter-development`, `/ui-ux-pro-max`) — triggers the skill's instruction set for the current task.

- **Agent Tool:** Subagents launched by name via the `Agent` tool when implementing specialized features — e.g., launching `flutter-ui-designer` after V1 auth logic is done, or `v3-gemini-food-dev` for Gemini photo analysis features.

- **Context Prompts:** Each agent's `description` includes concrete `<example>` blocks showing the exact prompts that should trigger that agent, with `<commentary>` explaining why.

- **MCP on Demand:** Supabase MCP tools (`execute_sql`, `apply_migration`, `get_logs`) called during database work; Context7 MCP (`resolve-library-id`, `query-docs`) for latest API reference lookups.

- **Settings Hooks:** `.claude/settings.local.json` enables MCP servers (`supabase`, `context7`) and whitelists git commit/push commands.

---

<!-- slide 6 -->
# Commands

**Essential Terminal & CLI Commands**

```bash
# Run Flutter app (mobile)
flutter run

# Run Flutter app (web)
flutter run -d chrome

# Build for Vercel deployment
flutter build web --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY \
  --dart-define=GEMINI_API_KEY_1=$GEMINI_API_KEY_1 \
  --dart-define=GEMINI_API_KEY_2=$GEMINI_API_KEY_2 \
  --dart-define=GEMINI_API_KEY_3=$GEMINI_API_KEY_3

# Run tests
flutter test

# Generate Supabase TypeScript types
supabase gen types typescript --linked > lib/types/supabase.ts

# Supabase migration
supabase migration new migration_name
supabase db push
```
