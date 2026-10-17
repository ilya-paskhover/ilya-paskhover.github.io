---
title: "Fresh design and content with AI agents"
date: 2026-10-17 10:00:00
topic: AI agents
description: "How this site got a fresh design and new content from AI agents: a small agent team, written plans, tests as the contract, and a human approving each step."
featured: true
---
* TOC
{:toc}

This site got a fresh design and new content, both built by AI agents. My part was the rules, the plans and the approvals.

## A small team, not one agent

I use a setup I call poc-dev-team. A planner agent writes a spec and a task list, developer agents each own one part of the code, and a QA agent tests every task on its own. QA runs the checks, walks the pages in a browser and never edits a file. A command runs one task at a time, commits each task that passes, and stops after three failed attempts.

## Tests as the contract

Every task has a check that must pass: here, a test suite that reads the built site. One rule was tested from the first task: the game in `shallow-whale/` must not change.

## A human approves each step

Agents stop and ask before anything that matters: the plan, a blocker, a commit. Once, QA's browser left two screenshots in the repo. The run stopped and waited for me instead of committing them.

That was about the only surprise. Small, checked steps left little room for others.
