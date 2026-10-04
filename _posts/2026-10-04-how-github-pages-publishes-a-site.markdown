---
layout: post
title:  "How GitHub Pages publishes a site"
date:   2026-10-04 10:00:00
topic: Notes
description: "How GitHub Pages decides what to publish, and why a gh-pages branch is only a convention."
---
* TOC
{:toc}

GitHub Pages turns the files in a repository into a website, and a few settings decide which files and how.

## Two kinds of sites

A user site lives in a repository named `<user>.github.io` and is served at `https://<user>.github.io/`. Every other repository can have a project site, served at `https://<user>.github.io/<repo>/`. This blog is a user site, so it is served from the root of `https://ilya-paskhover.github.io/`.

## The publishing source

The source is chosen in Settings, Pages. There are two options:

- Deploy from a branch: pick a branch and a folder, either `/` (root) or `/docs`.
- GitHub Actions: a workflow builds the site and publishes it.

Historically, project sites used a branch called `gh-pages`. That name is now only a convention. Any branch can be chosen as the source, and a `gh-pages` branch that is not selected as the source publishes nothing.

## Who builds Jekyll

With "Deploy from a branch", GitHub builds Jekyll itself using the `github-pages` gem. That pins Jekyll to a 3.x version and allows only whitelisted plugins. This site uses `jekyll-seo-tag`, `jekyll-feed` and `jekyll-sitemap`, which are all on the list.

With GitHub Actions you choose the Jekyll version and the plugins yourself, at the cost of maintaining the workflow.

## How this site is set up

This site publishes from the root of the `master` branch. A workflow builds the site and validates the HTML on each push and pull request, so a broken page is caught before it is published. The workflow only checks the build and the HTML; the publishing itself is still done by Pages from the branch, so the workflow does not replace the setting described above.

## The CNAME file

A `CNAME` file is only needed for a custom domain you own, and it holds that domain. A plain `github.io` address does not need one, so this site has none.

## A leftover gh-pages branch

An old `gh-pages` branch left over from the early days of a blog is a good example. If the publishing source points at another branch, nothing uses it, and it can be deleted safely.
