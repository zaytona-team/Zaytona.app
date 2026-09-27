# 🛒 Zaytona | زيتونة
### Stage 1 Report — Team Formation & Idea Development

> *"The grocery list was never a teamwork effort — and it should be."*

---

## Table of Contents

- [1. Team Overview](#1-team-overview)
- [2. Ideas Explored](#2-ideas-explored)
- [3. How We Chose: Our Evaluation Filters](#3-how-we-chose-our-evaluation-filters)
- [4. Survey Validation](#4-survey-validation)
- [5. Selected MVP Concept](#5-selected-mvp-concept)
- [6. Challenges & Opportunities](#6-challenges--opportunities)

---

## 1. Team Overview

**Team Name:** Zaytona (زيتونة)
**Methodology:** Agile — sprint-based
**Stack:** Flutter (iOS & Android)

### Who We Are

Five people, five different strengths, one shared goal: ship something real and learn the full stack while doing it.

| Member | Role | What They Bring |
|---|---|---|
| **Aljawharah Alammar** | Project Manager & Frontend Lead | Business thinking, pitch presentation, final ownership of the repo and project direction |
| **Reem Alyamani** | Frontend Developer | Defines what gets built and why — owns user research and feature prioritization |
| **Randa Baeshen Hussain** | Frontend Developer | Keeps sprints on track, brings the team together, creative input under deadline pressure |
| **Mousa Alrizqi** | Backend Developer | System design, data architecture, technical depth |
| **Abdullah Almouraibd** | Backend Lead | UI architecture, component structure, technical depth |

Permanent roles exist so every decision has a clear owner. Two backend developers and three frontend developers work in parallel streams, each with a lead driving technical decisions on their side.

### How We Work Together

**Development Tools:** Discord · Jira · GitHub · Miro · Google Drive · Cursor · Claude · ChatGPT
**Learning Tools:** NotebookLM · roadmap.sh · YouTube
**Meeting Cadence:** Daily standup + additional sessions as needed, in-person or online
**Board (Miro — wireframes, flows, retros, decision log):** [INSERT MIRO LINK]

### Our Team Agreements

We didn't want a generic "be respectful" list — we built our agreements around what actually makes teams perform:

> **Psychological safety first.** Google's internal research on team effectiveness (Project Aristotle) found that the #1 predictor of a high-performing team isn't talent — it's whether people feel safe raising concerns, admitting mistakes, or disagreeing. That's our baseline.

- **One DRI per task.** Inspired by Apple's "Directly Responsible Individual" model — every task, no matter how collaborative, has one named person accountable for it getting done.
- **Decision log, not memory.** Every major decision (and the reasoning behind it) gets written down in Miro — so we're not relitigating choices three weeks later.
- **Blameless retrospectives.** When something breaks or slips, we ask "what in our process allowed this?" — never "who messed up?"
- **Full transparency.** No silent disagreements, no side conversations about problems that should be raised with the team.
- **Come prepared.** Meeting agendas are shared in advance; showing up unprepared wastes everyone's time.
- **Green & black points (Miro board).** Green points celebrate wins and effort; black points flag recurring patterns the team needs to address *together*.
- **Mentor as tiebreaker.** When the team reaches a genuine impasse, we bring it to a mentor rather than letting it stall the sprint.
- **AI as a tool, not a replacement.** We use AI the right way — as a study buddy, a rubber duck, and an occasionally overconfident pair programmer. It helps us learn faster and review smarter. It does not write our code while we watch YouTube. We stay in the driver's seat.

---

## 2. Ideas Explored

We considered four ideas before settling on Zaytona. Each one taught us something — even the ones we rejected.

### 💡 Idea 1 — Numo: AI-Powered Digital Learning Platform

A personalized learning platform that adapts difficulty and suggests exercises based on student performance.

**Strengths:**
- Real gap in personalized education
- Strong potential for AI-driven adaptation

**Weaknesses:**
- Requires massive content creation across every subject and grade level
- Schools already rely on entrenched platforms (Google Classroom, Madrasati)
- Differentiation and retention would be extremely difficult

**Why we let it go:** The content-creation burden alone would consume the team's entire timeline before a single user touched the product — and we'd still be competing against platforms schools already trust.

---

### 💡 Idea 2 — Salon Booking Platform

A platform to eliminate long waiting times and unpredictable scheduling at salons.

**Strengths:**
- A genuinely annoying, everyday frustration
- Builds trust through reliable scheduling

**Weaknesses:**
- Classic two-sided marketplace problem — needs salons on board before it has any value
- Several established competitors already serve this space

**Why we let it go:** We'd be spending most of our energy convincing salons to join, not building or learning — and the market is already crowded.

---

### 💡 Idea 3 — Autonomous Robot Cart for Umrah

A self-driving cart concept to assist pilgrims during Umrah, building on hardware one team member previously developed for a university project.

**Strengths:**
- Genuinely unique and high-impact
- A real working hardware prototype already existed

**Weaknesses:**
- Operating autonomous hardware in a sacred, high-density environment raises serious safety and regulatory questions
- Would require institutional partnerships (Haramain authorities) far beyond our timeline
- Liability and crowd-safety testing alone would take longer than our entire project window

**Why we let it go:** This was the hardest idea to walk away from — it had real engineering behind it. But the regulatory and safety stakes were too high for a team-led MVP on this timeline.

---

### ✅ Idea 4 — Zaytona: Family Grocery Coordination

A mobile app that gives every household/group member a voice in the grocery run — before the buyer enters the supermarket.

Why it survived isn't just gut feeling — it's the only idea that passed every filter we set for ourselves, *and* came with a working prototype, real user feedback, and validation data behind it.

---

## 3. How We Chose: Our Evaluation Filters

Every idea — including Zaytona — had to pass four questions, asked honestly as a team:

1. **Is it somewhat unique — not a generic, "everyone's-built-this" idea?**
2. **Is the problem real, and do we personally relate to it?**
3. **Does every team member genuinely want to invest their time and effort here?**
4. **Can we realistically build it as an MVP within 3 months?**

Numo and the Salon app failed filter 1 (too generic, too crowded) and filter 4 (too resource-heavy). The Robot Cart failed filter 4 outright — no version of it fits a 3-month MVP.

**Zaytona came with something the other ideas didn't:** an earlier prototype (built as Zaytona v1, with a demo video), real user feedback from that prototype, and a problem-discovery process one of our team members had already gone through during the Apple Developer Academy program. We weren't starting from zero — we were starting from a validated problem with a first attempt already behind us.

---

## 4. Survey Validation

To check our assumptions against real people — not just our own households — we surveyed **140 strangers** with no connection to the team.

### What We Asked, and What Came Back

| Question | Result |
|---|---|
| How often does your household shop for groceries? | 12% daily · 20% 2–3x/week · 28% every two weeks · **40% monthly** |
| How do you currently manage your grocery list? | **WhatsApp 43%** · Memory 22% · Digital notes 18% · Paper 17% |
| Do you ever buy the same item twice by mistake? | 13% always + 46% sometimes = **59% experience duplicates** |
| Do you forget items when shopping? | 9% always + 19% sometimes = **28% experience forgetting** |
| How hard is it to coordinate what the household needs? | 3% hard · 41% medium · **55% easy** |
| Would you be interested in using a grocery coordination app? | **81% yes** |

### What This Tells Us — Decisions

- **68% of households shop on a longer cycle** (every two weeks or monthly) — this is exactly the window where a "collect requests before the trip" model has time to work. A daily-shopping household wouldn't need this; a monthly one does.
- **Duplicate buying (59%) is the most common pain point in our data** — more common than forgetting items (28%).
- **WhatsApp's 43% share confirms the workaround pattern** — people are already trying to solve this problem with the wrong tool.
- **55% calling coordination "easy" is a signal, not a dismissal** — it means the cost of the current system (duplicates, wasted spend) is *invisible* to people, not absent. Our messaging needs to surface this hidden cost rather than promise to fix a problem people don't feel acutely.
- **81% interest remains directional only** — it tells us people are open to trying something, not that they'll keep using it. Retention will be earned through the product, not promised by the survey.

---

## 5. Selected MVP Concept

### The Moment That Started Everything

It's the last Thursday of the month. The fridge is nearly empty, and tonight is the big grocery run.

The mother has been mentally building the list for days — milk, eggs, the usual staples, whatever she noticed running low while cooking. Around 8pm, the father grabs his keys and the list scribbled on his phone's notes app, and heads out with one of the sons.

Meanwhile, the daughter is in her room, scrolling through a recipe for a cake she's been wanting to bake all week. She needs cocoa powder, condensed milk, a specific cake pan. She didn't even know tonight was *the* grocery night — nobody told her, and she never thought to ask. By the time she hears the car pull back into the driveway, it's too late.

Three days later, she orders the missing ingredients separately from a delivery app — paying delivery fees for items that could have been picked up in the same trip, for free, if anyone had simply asked her.

This happens every month. Not because anyone did anything wrong — but because **the list was never a household effort. It was one person's memory, executed alone.**

### What Zaytona Actually Does

> **Zaytona turns one person's grocery list into the whole household's list — so the person walking through the store buys exactly what everyone needs, in one trip, without anything falling through the cracks.**

### What the MVP Must Nail

The core job of the MVP is **collection**: making sure every household member's request reaches the buyer, with enough detail to act on, *before* the trip happens.

This means:
- Every family member can add items with the details that matter (brand, size, quantity, notes)
- The buyer sees one combined, organized list — not five scattered messages
- Requesters get confirmation that their item made it onto the list

### Why Zaytona Over Existing Apps

Apps like Bring, AnyList, and OurGroceries were built around Western household habits and individual list-making. Reviews from Arab users on these platforms consistently ask for more than translation — they want an experience that fits how Arab households actually shop and coordinate. Zaytona is built from day one around the Saudi monthly grocery ritual, with Arabic as a first-class experience rather than an afterthought.

### Version History

**Zaytona v1** was built in Swift during the Apple Developer Academy program by a five-person team: **Aljawharah Alammar, Joud Alreemi, Dareen Faden, Abdulrahim Zamzami, and Abdullah Alshobaki**. That version proved the core concept worked — the team has a demo video and early user feedback to show for it — but it was built quickly through "vibe coding," which left it with significant technical debt and bugs that made it unmaintainable.

**Zaytona v2** is a ground-up rebuild: a new team, a scoped MVP, a clean Flutter architecture, and the lessons from v1's prototype — without inheriting its problems.

---

## 6. Challenges & Opportunities

### Challenges

| Challenge | What It Means For Us |
|---|---|
| **Coordination feels "easy" to most people (55%)** | The pain is real but invisible — our onboarding and messaging need to make the hidden cost (duplicates, wasted trips) visible, not assume users already feel it |
| **Household adoption** | The app only delivers value if multiple family members install it — single-user value is limited by design |
| **First Flutter project** | The team is learning the framework while building on it — architecture decisions need to account for a learning curve |
| **Scope discipline** | The grocery space is wide; staying focused on the collection problem will require active enforcement every sprint |

### Opportunities

| Opportunity | Why It Matters |
|---|---|
| **A validated, recurring pain point** | 59% experience duplicate purchases — a concrete, quantifiable cost we can point to |
| **WhatsApp fatigue** | Households are already managing this badly with a tool not built for it — the switching cost is behavioral, not financial |
| **Arabic-first localization gap** | Competitor reviews confirm unmet demand for a culturally-fit experience, not just translation |
| **Built-in retention cycle** | 68% of households shop biweekly or monthly — a naturally recurring need that brings users back without artificial engagement tricks |
| **We're not starting from zero** | A working v1 prototype, real user feedback, and a prior problem-discovery process give us a head start most teams don't have |

---

*Zaytona Team · Stage 1 Report*