---
title: "A proof of concept should answer one question"
date: 2023-12-28 10:00:00
topic: Notes
description: "A proof of concept is worth building when it answers one question, such as whether a new gateway can do what its datasheet says."
---
* TOC
{:toc}

Looking back at the proofs of concept I have built and reviewed, the useful ones had one thing in common: they answered a single question.

## The one question

Write it down before writing code. "Can this gateway do what the datasheet says, with our kind of data?" is a good one. "Let's see what the new sensor can do" is not, because it never ends.
{% comment %}TODO confirm: a generic example from your own work, if you want one.{% endcomment %}

## Build only what answers it

Everything else can be faked: a hard-coded config, a script instead of a service, a spreadsheet instead of a dashboard. A small team and a short deadline help, because they make faking the default.

## Then decide

The result is a decision, not the code. Write down the answer, what it means for the product, and what is still unknown. Then throw the code away, or keep it knowing it was never built to last.
