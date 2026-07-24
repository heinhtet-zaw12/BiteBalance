## AI Tools Used

- **Superpowers plugin** — Orchestrated agents, skills, and MCPs across the development workflow
- **Supabase MCP** — Managed database schema (profiles table creation, RLS policies), executed SQL queries, listed projects and tables
- **Context7 MCP** — Resolved library IDs and queried latest API docs for Flutter, Dart, and Supabase packages during development
- **Chrome DevTools MCP** — Debugged web build issues: inspected console errors, network requests, captured screenshots for responsive layout fixes
- **Vercel MCP** — Configured project settings, deployed Flutter web builds, debugged runtime errors, fetched deployment logs


### Skill (required)

- **path:** `.claude/skills/supabase-developer/SKILL.md`
- **what:** Enforces Supabase best practices — auth setup, PostgreSQL schema design with RLS, migration management, edge functions

- **path:** `.claude/skills/flutter-development/SKILL.md`
- **what:** Flutter & Dart best practices — widget composition, state management with Riverpod, GoRouter navigation, responsive design

- **path:** `.claude/skills/ui-ux-pro-max/SKILL.md`
- **what:** Design toolkit — UI styles, color palettes, font pairings, accessibility checks, dark glassmorphism theming

### Subagent (required)

- **path:** `.claude/agents/v3-gemini-food-dev.md`
- **what:** Integrates Gemini Vision API for photo food analysis, calorie recommendations, chart visualizations, date-based stats queries

- **path:** `.claude/agents/flutter-ui-designer.md`
- **what:** Applies UI/UX polish — Material Design 3 theming, animations, responsive layout, color harmony, micro-interactions

- **path:** `.claude/agents/flutter-error-handler.md`
- **what:** Maps Supabase, network, and auth exceptions to user-friendly messages. Centralized failure classes, SnackBar patterns, error logging

## Trigger / Command

- **Trigger:** Slash command `/supabase-developer` (or `/flutter-development`, `/ui-ux-pro-max`) in Claude Code session
- **Command:** `/<skill-name>` launches the skill's instruction set for the current task

## Tech-Stack Slides

- **Slides path:** `slides/tech-stack.md`
  - 6 slides covering: Stack, Agents, Skills, Methodology, Trigger, Commands
