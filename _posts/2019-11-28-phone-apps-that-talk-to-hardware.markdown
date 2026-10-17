---
title: "Phone apps that talk to hardware"
date: 2019-11-28 10:00:00
topic: Apps
description: "What I learned building native iOS and Android apps that talk to devices over Bluetooth, WiFi and USB."
---
* TOC
{:toc}

Looking back at two years of native apps whose main job was to talk to a device, not to show screens.

## Why native

The phone's radios and ports sit behind platform APIs. Objective C on iOS and Java on Android give direct access to them, with fewer layers to debug when a connection fails.
{% comment %}TODO confirm: which of Bluetooth, WiFi and USB were used, and for what (generic level).{% endcomment %}

## The link is the hard part

Bluetooth links drop. WiFi setup has a moment when the phone leaves its usual network to join the device. USB depends on the phone, the cable and the permissions dialog. So every screen needs an answer to one question: what happens when the device goes away right now?

## Test on real devices

Simulators do not have the radios that matter. The tests that count run on real phones, next to real hardware.
