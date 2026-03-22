# ilya-paskhover.github.io

Personal blog and project showcase by [Ilya Paskhover](https://www.linkedin.com/in/ilyapaskhover/) — senior software developer with 15+ years of experience.

## Local Development

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

Minimum front matter:

```yaml
---
layout: post
title: "My Post Title"
date: YYYY-MM-DD HH:MM:SS
categories: category1 category2
---
```

## Structure

```
_posts/        Blog posts (Markdown)
_layouts/      Page templates (Liquid)
_includes/     Reusable partials (header, footer, head)
_sass/         SCSS stylesheets
assets/        Static files (HTML apps, images)
about.md       About page
index.html     Homepage
```

## Deployment

Pushes to `main` are automatically deployed via GitHub Pages.
