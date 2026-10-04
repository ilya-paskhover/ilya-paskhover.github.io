# ilya-paskhover.github.io

Personal blog and project showcase by [Ilya Paskhover](https://www.linkedin.com/in/ilyapaskhover/), senior software developer with 15+ years of experience.

## Run with Docker

**Prerequisite:** Docker with Compose.

Start (builds the image, serves the production build of the site):

```bash
docker compose up -d --build --force-recreate --wait
```

Open [http://localhost:14000](http://localhost:14000) in your browser. The container serves a build made at image build time (`--no-watch`), so re-run the command above after changing any file. Set `SITE_PORT` to use another host port.

Stop:

```bash
docker compose down
```

Run a single test file inside the container (the site is already built there):

```bash
docker compose exec -T site bundle exec ruby -Itest test/content_test.rb
```

Replace `content_test.rb` with any file from `test/`, for example `header_test.rb`.

### Keyboard shortcuts

Single-key shortcuts work when no modifier key (Ctrl, Meta, Alt) is held and the focus is not in an input, textarea, select or editable field.

| Key | Action |
| --- | --- |
| `H` | Home |
| `P` | Projects |
| `A` | About |
| `G` | GitHub profile |
| `S` | Open the search on the home page (from other pages, go to it) |
| `R` | Load more posts in the home feed |

Shortcuts can be turned off by setting `localStorage.shortcuts` to `off`.

## Local Development (native Ruby)

**Prerequisites:** Ruby with Devkit ([download](https://rubyinstaller.org/downloads/)), Bundler

```bash
# Install dependencies
bundle install

# Run local dev server (with live reload)
bundle exec jekyll serve --livereload
```

Open [http://localhost:4000](http://localhost:4000) in your browser.

## Writing a Post

Add a Markdown file to `_posts/` following the naming convention:

```
_posts/YYYY-MM-DD-title-of-post.markdown
```

Front matter:

```yaml
---
title: "My Post Title"
date: YYYY-MM-DD HH:MM:SS
topic: Apps                 # topic tab the post is filed under
description: "One sentence shown in the feed and used for SEO."
featured: true              # optional: marks the post as featured
categories: category1 category2  # note: categories become part of the post URL
---
```

- `layout: post` and `author: Ilya Paskhover` are set for every post by `defaults` in `_config.yml`, so they are not needed per post.
- `topic` groups the post under a topic tab on the home page.
- `description` is the summary text for the post.
- `featured: true` marks a post as featured. Several posts may be featured: each shows as a featured row above the list, newest first, and is not repeated in the list. When featured rows are present the list only holds the other posts.
- Reading time is hidden for posts of 1 minute or less (feed rows and the post header); longer posts show it.
- `archived: true` (used by the 2016 notes) shows an "archived note" line on the post.

### Table of contents

Put this marker at the top of the post body to generate a table of contents from the `##` headings:

```markdown
* TOC
{:toc}
```

## Structure

```
_posts/        Blog posts (Markdown)
_layouts/      Page templates (Liquid)
_includes/     Reusable partials (header, footer, head)
_data/         Site data (navigation.yml, profile.yml, projects.yml)
_sass/         SCSS stylesheets
assets/        Static files (JS, HTML apps, images)
test/          Minitest tests, run in the Docker container
docs/          Project spec, task list and progress log
about.md       About page
projects.md    Projects page
index.html     Homepage
```

## Deployment

Pushes to `master` are automatically deployed via GitHub Pages.
