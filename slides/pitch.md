---
marp: true
paginate: true
transition: fade
# PechaKucha: 6 slides, 20s auto-advance. Do not change the count.
auto-advance: 20
---

<!-- slide 1 -->
# Who's my person?

People who want to eat healthier but has no easy way to track daily food intake or know whether what they eat is good or bad for their body.

---

<!-- slide 2 -->
# Their problem

- No easy way to track daily calories
- Can't tell healthy food from junk food
- No personalized targets based on their BMI
- Manual calorie counting is too tedious to stick with

---

<!-- slide 3 -->
# What I built

**Bite Balance** — AI-powered food tracker

- 📝 Log food by text or photo
- 🤖 Gemini AI analyzes calories + healthy/junk
- 🎯 BMI-based personalized daily calorie target
- 📊 Daily / Weekly / Monthly stats with charts

---

<!-- slide 4 -->
# How I built it

- **MCP:** Supabase MCP (database + RLS) + Context7 (latest docs)
- **Skill:** supabase-developer — enforces Supabase best practices
- **Agent:** v3-gemini-food-dev — Gemini Vision + analytics specialist
- Flutter + Supabase + Riverpod + GoRouter + Clean Architecture

---

<!-- slide 5 -->
# Why it matters

Bite Balance tracks eating habits daily, weekly, and monthly — turning raw food logs into clear visual insights. AI removes the friction of manual calorie counting. Personalized BMI-based targets make advice relevant to each user, helping them build healthier habits over time.

---

<!-- slide 6 -->
# Done checklist

- [x] repo public
- [x] MCP + skill + agent used
- [x] report.md in team repo