---
marp: true
paginate: true
transition: fade
# PechaKucha: 6 slides, 20s auto-advance. Do not change the count.
auto-advance: 20
---

<!-- slide 1 -->
# Who's my person?
Our target users are people who want to track their daily food intake, monitor calorie consumption, and make healthier eating choices based on their BMI and personal health goals.
<!-- 20s -->

---

<!-- slide 2 -->
# Their problem
They had no easy way to track what they eat daily, didn't know whether their food choices were healthy or junk, and had no personalized calorie targets based on their body metrics. Manually counting calories is tedious and most apps are too complex.

---

<!-- slide 3 -->
# What I built
Bite Balance — a Flutter mobile app that lets users log food by text or photo, analyzes nutrition with Gemini AI, tracks daily/weekly/monthly calorie intake, and provides personalized health recommendations based on BMI.
V1 — Foundation

Supabase Auth (register, login, logout)
Profile setup (name, weight, height, goal)
BMI calculation and result display with category indicator

V2 — Food Tracking

Food logging via text input
Gemini AI analysis — food name, calories, healthy/junk classification
Daily calorie dashboard with healthy vs junk breakdown

V3 — Intelligence

Photo food analysis via Gemini Vision API
BMI-based personalized daily calorie recommendation
Weekly/monthly analytics with fl_chart charts
Most eaten junk food tracking
Per-user data isolation with Supabase 
---

<!-- slide 4 -->
# How I built it
MCP: Supabase MCP + Context7 MCP
Supabase MCP — Created and managed database tables, RLS policies directly from Claude Code without touching Supabase dashboard
Context7 MCP — Provided latest Flutter, Supabase, and Riverpod documentation to ensure up-to-date API usage throughout development

Skill:  flutter-development, supabase-developer, ui-ux-pro-max
Enforced Clean Architecture patterns across all features
Maintained consistent coding standards (AsyncNotifier, snake_case, const constructors)
Applied modern 2026 design system with global theme and typography

Agent: bite-balance-v1-developer, v3-developer
bite-balance-v1-developer — Handled V1 features with strict Clean Architecture, Riverpod, and GoRouter implementation
v3-developer — Specialized in Gemini Vision API, photo analysis, analytics queries, and chart visualization without breaking V1/V2 features

Tech Stack

Flutter + Dart — Mobile UI
Supabase — Auth + Database 
Riverpod — State management 
GoRouter — Navigation with auth guard
Gemini API — Food analysis + Vision + Recommendations
fl_chart — Analytics charts
Clean Architecture — 3 layers per feature (data/domain/presentation)
---

<!-- slide 5 -->
# Why it matters
Most calorie tracking apps require manual input of nutritional data which is time-consuming and inaccurate. Bite Balance uses AI to instantly analyze food from a photo or text description, removing friction from healthy habit formation. The personalized BMI-based recommendations make it relevant to each individual user rather than generic advice.
Beyond single-meal tracking, Bite Balance gives users a complete picture of their eating habits over time. Daily tracking shows real-time calorie progress against personalized targets so users can adjust the same day. Weekly tracking reveals patterns — which days they overeat, how often junk food appears, and whether they are trending toward their goal. Monthly tracking provides a bird's-eye view of long-term progress, showing total calories consumed, healthy vs junk food ratio, and the most frequently eaten junk foods. All of this is visualized through clean charts so users can understand their habits at a glance rather than reading through logs — turning raw data into actionable insights that help them make better food choices every day.
---

<!-- slide 6 -->
# Done checklist

- [x] repo public
- [x] MCP + skill + agent used
- [x] report.md in team repo
