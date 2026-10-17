---
title: "Evaluating AI agents before you trust them"
date: 2026-06-25 10:00:00
topic: AI agents
description: "A small, repeatable way to check an AI agent before trusting it with real work."
---
* TOC
{:toc}

An agent that works in a demo has passed one test, picked by the person who wanted it to pass.

## A small task set and a grader

Collect a few dozen real tasks with known good results. Grade them with code where you can: did the file change, did the tests pass, is the number right. Use a model as a judge only where code cannot decide, and check a sample of its grades by hand.
{% comment %}TODO confirm: add your own opinion or example, if any.{% endcomment %}

## Run it on every change

A new prompt, model or tool can fix one case and break three others. Run the set on every change and compare with the last run.

## Read the failures

The score tells you whether something changed. The failed cases tell you what. Read them, because that is where the next task for the set comes from.
