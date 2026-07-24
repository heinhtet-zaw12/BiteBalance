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

**Superpower-Driven Development Workflow**

- **Superpowers Plugin:** The entire workflow is orchestrated by the `superpowers@claude-plugins-official` plugin (enabled in `.claude/settings.json`). It manages the interplay between specialized agents, custom skills, and MCP servers — turning Claude Code into a purpose-built AI development team for this project.

- **Agent-as-Teammate Architecture:** Instead of one monolithic prompt, this project defines 4 specialized subagents (V1 dev, V3 Gemini dev, UI designer, error handler). Each has pinned context, version scope, color coding, and persistent agent memory — so the right specialist handles the right task without context bleed.

- **Skill-as-Playbook System:** Reusable skill files (`.claude/skills/`) encode expert playbooks for Supabase, Flutter, and UI/UX design. Invoked via slash commands (`/skill-name`), they inject latest best practices without manual research — especially critical for Supabase RLS policies and Flutter state management.

- **MCP-as-Toolbelt:** Supabase MCP provides direct database operations (SQL execution, migration management, log inspection) and Context7 MCP supplies up-to-date API documentation — all accessed on demand within the coding flow, eliminating context-switching to browser tabs.

- **Orchestration Flow:** User request → Superpowers plugin resolves intent → routes to the appropriate agent (via `Agent` tool) with relevant skill loaded and MCP tools available → agent executes with Clean Architecture enforcement → result reviewed, committed, pushed — all within a single session.

- **Version-Gated Execution:** Superpowers enforces the V1→V2→V3 roadmap at the agent level. `bite-balance-v1-developer` rejects V2/V3 requests outright; `v3-gemini-food-dev` only activates for authorized V3 work. No scope creep, no accidental feature sprawl.

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
