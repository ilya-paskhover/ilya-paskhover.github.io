---
title: "Claude Code mods"
date: 2026-10-17 12:00:00
topic: AI agents
description: "Three small mods for Claude Code: a summary of the last turn, a notes pane shared across projects, and a pane of running sessions."
---
* TOC
{:toc}

I spend most of my day in Claude Code, often with several sessions at once. Three things kept slowing me down, so I wrote a small mod for each. They are open source on [GitHub](https://github.com/ilya-paskhover/claude-code-mods).

## turn-pulse: what did the last turn do?

After each turn, a band above the prompt shows how long it took, which files changed, how many tool calls passed or failed, and how much of the 5-hour and weekly usage limits it used. An edit outside the session's folder shows in red, with a toast.

![The turn-pulse band above the prompt, and the session total in the status line](/assets/images/claude-code-mods/turn-pulse.png){: .screenshot}

## notes: keep a thought for later

`/note <text>` saves a note to a list shared across all projects. `/notes` opens it in a side pane, where each note can be checked off as done.

![The Notes side pane with one open note](/assets/images/claude-code-mods/notes.png){: .screenshot}

## sessions: which session needs me?

`/sessions` opens a pane listing every Claude Code session running on this machine, whether each is working or idle, and how long since it last did something. A Switch button jumps to a session the desktop app started.

![The Sessions side pane with two idle sessions and a Switch button](/assets/images/claude-code-mods/sessions.png){: .screenshot width="311"}

## Install

Add the marketplace once, then install the mods you want:

```
claude plugin marketplace add ilya-paskhover/claude-code-mods
claude plugin install turn-pulse@claude-code-mods
claude plugin install notes@claude-code-mods
claude plugin install sessions@claude-code-mods
```

The mod API is marked early access and may change between Claude Code releases. The mods are built and tested on Windows, in the desktop app. The [README](https://github.com/ilya-paskhover/claude-code-mods#readme) lists the known limits of each one.
