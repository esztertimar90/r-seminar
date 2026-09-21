# Session 5 — AI-assisted coding — DRAFT OUTLINE

**Status:** draft for review. Nothing built yet — this is the plan.
**Topic:** GitHub Copilot in RStudio, other AI coding tools, and how to check their work
**Data:** the cleaned Vienna hotels sample from session 4 (`output/data/`)

---

## Why this session sits at week 5

Two constraints decide the slot. It must come **after** session 4, because
judging an AI suggestion requires being able to read a tidyverse pipeline —
before that, "check what it gave you" is a slogan students can nod at but not
perform. And it must come **before** session 6, so they can actually use what
they learn on the reproducible report, which is the thing that feeds their group
project.

The AI ground rule is set in session 1, not here. By week 5 they have been using
these tools for a month regardless; this session is where it becomes examined
rather than furtive.

---

## Before the session — your prep

- [ ] **Find out whether the computer room runs RStudio Desktop or RStudio Server / Posit Workbench.**
      This is the one that can sink the session: *Copilot is disabled by default
      on Server and Workbench and only an administrator can enable it.* If the
      room runs Server, you need Corvinus IT involved, with lead time. Check now.
- [ ] Confirm the RStudio version in the room is **2023.09.0 or later** — Copilot
      does not exist in the menu before that.
- [ ] Ask in session 4 who has Student Developer Pack approval, so you know the
      size of the fallback group before you walk in.
- [ ] Have your own Copilot working, and a second GitHub account signed out for
      demonstrating the sign-in flow.
- [ ] Prepare the broken script (below) as a file in the repo.

---

## Running order (90 minutes)

| Time | What |
|------|------|
| 0–20 | Setup: Copilot in RStudio, and the fallback for everyone it fails for |
| 20–35 | What it actually is; the three ways to use it |
| 35–60 | **The centrepiece: find the bug in the AI-written script** |
| 60–72 | The failure taxonomy, and a verification routine |
| 72–85 | Other tools, briefly |
| 85–90 | Ground rules restated, commit |

---

## 0–20 · Setup

The verified path (Posit's own documentation):

1. **Tools → Global Options → Assistant** — note the menu is *Assistant*, not
   *Copilot*; students hunting for "Copilot" won't find it
2. Choose **GitHub Copilot** from the dropdown
3. Download and install the Copilot Agent components when prompted
4. **Sign In** — a verification code appears
5. Go to <https://github.com/login/device>, paste the code, authorise
6. Open any `.R` file; suggestions appear as grey **ghost text**
7. **Tab** accepts, **Enter** ignores

The device-code flow in steps 4–5 needs a second window or their phone. Say so
before they start, or you'll spend ten minutes on it.

### Fallback — plan for this, don't improvise it

Some students will not have Copilot: Pack application refused, still pending, or
a lab machine where it can't be enabled. **Everything in this session works with
a browser AI assistant and copy-paste.** It is slower and slightly less magical,
and it makes no difference to the point being taught. Pair anyone without access
with someone who has it, and give the pair the browser-based version of each
exercise.

Do not let setup eat the session. Twenty minutes, then move whether or not
everyone is running.

---

## 20–35 · What it is, and three ways to use it

**Say plainly what it is:** autocomplete trained on a very large amount of public
code. It predicts what usually comes next. It is not checking your work, it does
not know your data, and it has no idea whether the answer is right.

> **Important limitation for planning:** RStudio's integration is **inline
> completions only** — there is no Copilot chat panel in RStudio. For anything
> conversational ("explain this", "why did this fail") they use a browser
> assistant. Worth stating, or they'll look for a chat box that isn't there.

The three modes, each with a short exercise on the hotels data:

| Mode | What it looks like | Exercise |
|------|-------------------|----------|
| **Completion** | Write a comment describing what you want, press Enter, let it write the code | "plot price per night against distance, coloured by star rating" |
| **Explanation** | Paste code you don't understand into a browser assistant | The regex from session 4: `gsub('[^0-9\\.]', '', center1distance)` |
| **Debugging** | Give it the code *and* the error message | Deliberately break a pipe and ask |

The completion exercise is where the comment-driven habit gets taught: a vague
comment gets vague code. `# make a plot` produces something; `# scatter plot of
price_per_night against distance, coloured by starrating, with a linear fit and
axis labels in EUR` produces something you might keep.

---

## 35–60 · The centrepiece — find the bug

This is the part of the session that matters. Everything before it is setup.

Give them a script that **looks completely reasonable and is wrong**, presented
honestly as what an assistant produces from a plausible prompt. Ask, in pairs:
*this reports the average price of a four-star hotel in Vienna. Is the number
right?* Fifteen minutes, then discuss.

```r
# Prompt used: "clean the Vienna hotel data and report the average
#               price per night for four-star hotels"

hotels_clean <- hotels |>
  na.omit() |>
  filter(starrating == 4)

mean(hotels_clean$price_per_night)
```

**What's wrong:**

1. **`na.omit()` drops every row with a missing value in *any* column.** In this
   data the missing values are overwhelmingly guest ratings — and session 4
   showed, with `table()` and two histograms, that those hotels are *not* a
   random subset. The sample silently shrinks and the mean is biased. Nothing in
   the output says this happened.
2. **The row count is never reported.** No `nrow()` before or after, so the
   damage is invisible.
3. **`starrating == 4`** — after session 4's recoding it's a factor, and the
   comparison is doing something subtler than it looks.

The lesson lands because they already did the work that catches it. Bug 1 is
exactly the NA investigation from session 4, and they can go back and rerun it.

> The point to make out loud: **the code ran, produced a plausible number, and
> threw no error.** This is the failure mode that matters. It is not that AI
> writes code that crashes — you would notice that. It is that it writes code
> that quietly answers a slightly different question.

---

## 60–72 · The failure taxonomy, and what to do about it

Five failures, each demonstrable live:

1. **Silent sample changes** — a drop, a filter, or a join that changes the
   number of rows without saying so. The most dangerous, and the least visible.
2. **Deprecated code.** It is trained on years of old code, so it will happily
   suggest `gather()`, `spread()`, `separate()`, `aes(size = )`. Easy to
   demonstrate, and they can catch it themselves against sessions 3 and 4 —
   which makes it a satisfying confidence-builder.
3. **Invented functions and arguments.** Plausible names that don't exist. The
   giveaway is an error; the risk is when a real function accepts the argument
   and ignores it.
4. **Wrong by default.** `mean()` without `na.rm`, a join on the wrong key, a
   regex that works on the ten rows you looked at.
5. **Confident interpretation.** Ask it what a coefficient means and it will tell
   you, fluently, whether or not it's right. This one belongs to the *other*
   seminar strand and the lectures — but flag it.

**The routine, which is the actual deliverable of this session:**

```r
nrow(data)                  # before
colSums(is.na(data))        # before
# ... the suggested code ...
nrow(data)                  # after — did this change, and did I mean it to?
colSums(is.na(data))        # after
```

Plus: read it before you run it; try it on ten rows first; and if it uses a
function you have never seen, look that function up *before* accepting, not
after.

---

## 72–85 · Other tools, briefly

Keep this short and non-committal — the landscape moves faster than the course.

- **Browser assistants** (ChatGPT, Claude, Gemini) — better than Copilot for
  explanation, debugging and "why doesn't this work", because you can have a
  conversation. Worse for writing code in place. Most students already have one.
- **R packages and RStudio addins** that put an assistant in the IDE. These
  generally need an API key, which costs money — mention that they exist, don't
  make anyone set one up.
- **Positron**, Posit's newer IDE, if anyone asks what's next after RStudio.

> Check this section against what actually exists a week before the session.
> Anything written here in September may be stale by the time you teach it.

---

## 85–90 · Close

Restate the rule from session 1, now that it means something concrete:

> You may use these tools. You must be able to explain any line you hand in.
> After today you also know *how* to check one — so "the AI wrote it" stops
> being an explanation.

Commit checkpoint. Next session: RMarkdown and reproducible reports — where they
will use all of this on a real write-up.

---

## Open questions for Eszter

- Is the broken-script exercise the right centrepiece, or too negative a framing
  for a session students will be looking forward to?
- Should the exercises use the hotels data (continuity, and they know where the
  bodies are buried) or something fresh?
- Do you want a prepared "good prompt / bad prompt" handout, or is the
  comment-driven demo enough?
