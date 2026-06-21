---
marp: true
paginate: true
transition: fade
auto-advance: 20
backgroundColor: #121212
color: #fff
---

# Who's my person?
Our target users are people who want to track their daily food intake, monitor calorie consumption, and make healthier eating choices based on their BMI and personal health goals.

---

# Their problem
Users have no easy way to track daily food intake and distinguish between healthy or junk choices. Manually counting calories is tedious and current apps are too complex, lacking personalized targets based on body metrics.

---

# What I built: Bite Balance
A Flutter app featuring AI food logging via Gemini Vision (text/photo), automated calorie calculations, and BMI-based personalized recommendations.
- **V1:** Supabase Auth, Profiles, & BMI Categories
- **V2:** Text Food Logging & Gemini Calories Breakdown
- **V3:** Gemini Vision Photo Analysis & `fl_chart` Weekly Analytics

---

# How I built it (AI + Architecture)
- **MCP:** Supabase MCP (DB & RLS via Claude Code) + Context7 MCP (Flutter/Riverpod Docs)
- **Skill:** Enforced Clean Architecture, AsyncNotifier State, & 2026 Modern Design System
- **Agent:** Specialized Subagents (`v1-developer` & `v3-developer`) for modular feature safely
- **Stack:** Flutter, Riverpod, GoRouter, Supabase, Gemini API, `fl_chart`

---

# Why it matters
Bite Balance removes logging friction via instant AI analysis. It transforms raw data into actionable insights through daily progress, weekly patterns, and monthly bird's-eye views. Beautifully visualized charts allow users to understand habits at a glance and make better food choices every day.

---

# Done checklist

- [x] Repository is strictly PUBLIC
- [x] MCP + Custom Skill + Specialized Agent used
- [x] Completed `report.md` submitted in Team Repo