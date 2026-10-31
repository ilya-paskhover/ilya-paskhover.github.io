---
title: "Teaching an agent about my projects with Open Knowledge Format"
date: 2026-10-31 12:00:00
topic: AI agents
description: "A small Open Knowledge Format example built from my own repos and posts, and what changed when an agent could read it."
---
* TOC
{:toc}

I gave an agent a small Open Knowledge Format bundle about my projects, and its hedged guesses turned into specific, sourced answers. The example is [on GitHub](https://github.com/ilya-paskhover/ilya-paskhover.github.io-okf), with a 5-minute tutorial.

An agent starts every task knowing nothing about my work, as I wrote in [From managing people to managing agents]({% post_url 2026-01-20-from-managing-people-to-managing-agents %}). The facts it needs are spread across READMEs and posts.

## What OKF is

[Open Knowledge Format](https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md) (OKF) is a format from Google Cloud for writing knowledge down so that people and agents can both read it. It is small:

- A bundle is a folder of Markdown files.
- A concept is one file about one idea.
- A concept's ID is its path in the bundle, without `.md`.
- Each concept has YAML frontmatter, and only `type` is required.

There is no registry, server or required tool. It is also not a security model: its trust fields are advisory.

## The example

Claude Code built the bundle from my posts and repo READMEs, following version 0.2 of the spec. It has 12 concepts: 5 projects, 4 practices and 3 topics. One concept covers one idea, not one post, so a practice can draw on two posts written months apart. Each concept links to its sources.

The bundle was written by an agent and I haven't marked any concept as verified, so under OKF's own trust tiers all 12 count as unverified.

## The test

I asked 5 questions, each in two cold runs on the same model. One run had only the repo names and no tools. The other could read the bundle, with one instruction: read the index first, prefer bundle facts over guesses, and name the file to add if a fact is missing.

| Question | Without the bundle | With the bundle |
|---|---|---|
| Which repo uses Python? | Guessed `eth-monitor`, or maybe `invoice-reminders` | `eth-monitor` |
| How do I run `invoice-reminders`? | Generic `npm` or `pip` steps | The exact `docker compose` command and ports |
| What is related to `invoice-reminders`? | Nothing clearly | Two practices and one topic, with reasons |
| Does `eth-monitor` only watch Ethereum? | Could not say | No, it also watches other crypto, stocks and FX |
| How many people use `claude-code-mods`? | Could not say | Could not say, and named the file to add it to |

The [full answers](https://github.com/ilya-paskhover/ilya-paskhover.github.io-okf/blob/main/demo/results.md) and commands are in the repo.

Read this as a demo, not a benchmark. Each question ran once, and I chose the questions for a bundle built from the same material, so it was bound to cover them.

## What I took from it

1. **The agent without the bundle was honest, not wrong.** It mostly said it couldn't know. The bundle turned hedges into answers. It didn't stop any made-up facts, because there were none to stop in this test.
2. **Links carry what names can't.** No repo name says `invoice-reminders` is a proof of concept built by an agent team. A link and one sentence do.
3. **Saying what's missing is the useful failure.** On the last question both runs declined to invent a number, but only the bundle run said where the fact should go.
4. **Writing it down finds stale facts.** My own project list still describes `eth-monitor` as ETH/USD only, while its README covers stocks and FX too. The agent reported that conflict in its answer.

## Try it

The [README](https://github.com/ilya-paskhover/ilya-paskhover.github.io-okf#readme) walks through a minimal concept, a small validator, breaking a file on purpose, asking Claude a question, and adding a concept of your own.
