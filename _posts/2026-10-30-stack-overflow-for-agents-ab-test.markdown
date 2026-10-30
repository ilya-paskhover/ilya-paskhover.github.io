---
layout: post
title: "Does Stack Overflow for Agents improve Claude's answers?"
date: 2026-10-30 12:00:00
topic: AI agents
description: "A small blind A/B test of the Stack Overflow for Agents MCP: almost no change in answer scores, and the real effect was on speed."
---
* TOC
{:toc}

In my 8-question test, Stack Overflow for Agents (SOFA) barely changed Claude's answer scores. Plain web search was almost as good, even on questions picked from SOFA itself. The clearer effect was speed on niche questions, and it came with a catch.

Read this as a small experiment. I picked the 4 niche questions from SOFA posts and based their rubrics on SOFA's unverified claims, so the setup favours SOFA. Each question ran once per setup, and an AI judge did the grading.

## The setup

I asked Claude Code 8 technical troubleshooting questions, 4 niche and 4 common, in three setups. All three had web search, and SOFA access was read-only.

- **No SOFA:** web search only.
- **SOFA:** SOFA available, with no instruction to use it.
- **SOFA + nudge:** a system prompt telling it to search SOFA first.

A separate Claude call graded each answer against a rubric, without knowing the setup. Scores run from 0 to 1.

## Results

| Setup | Niche score | Common score | Runs using SOFA (niche / common) | Mean time (niche / common) |
|---|---|---|---|---|
| No SOFA | 0.958 | 0.875 | 0 of 4 / 0 of 4 | 64s / 17s |
| SOFA | 1.000 | 0.917 | 3 of 4 / 0 of 4 | 59s / 16s |
| SOFA + nudge | 1.000 | 0.875 | 4 of 4 / 4 of 4 | 35s / 23s |

## What I took from it

1. **The score gap is tiny.** On niche questions it is one rubric point out of 24, all on one question. Most answers hit the maximum, so this test can't separate the setups well.
2. **Claude finds SOFA on its own.** It searched SOFA on 3 of the 4 niche questions without being asked, and skipped it on all the common ones. That seems like the right instinct.
3. **The nudge is a trade.** On niche questions, time fell from 64s to 35s and web calls from 7.5 to 1 per run, at about the same API-equivalent cost. On common questions, it cost about 65% more and took about 35% longer, with no better score.
4. **Faster can mean less checked.** On the eBay question, the nudged run relied on one post with no votes or verifications and didn't check eBay's docs. It said so openly, and the rubric gave full marks anyway. The other two setups did open eBay's page.

## What I'll do

Keep SOFA connected read-only, without the nudge (telling it to search SOFA first), and double-check what its posts say. To learn more, I'd need harder questions and rubrics verified independently of SOFA.
