# POC spec: jekyll-ui-redesign

Slug: `jekyll-ui-redesign`
Mode: adopt an existing app.
User OS: Windows 10 (commands run in Git Bash, a POSIX shell; forward slashes in paths).

## 1. Goal

Redesign the personal Jekyll site (ilya-paskhover.github.io) so it looks modern and polished to clients and architects, with good UX, and make small content improvements. Static site only: no backend, no database. Nothing inside `shallow-whale/` may change.

### Design direction (from the user's claude.dev screenshots)

The reference is the claude.dev blog, shown in two screenshots the user shared (home and post page). We adapt its visual language and do **not** copy Anthropic branding: no mascot, no logos, no "claude.dev" or "Try Claude Code" wording. We use **no invented artwork at all**: no pixel art, no logo mark, no icons. The brand is a plain monospace text wordmark.

- **Dark-first.** Near-black background (`#141414`), off-white text, hairline dividers, and one muted terracotta accent for small highlights (chips, active states, focus rings, hover). Light mode is a secondary toggle.
- **Terminal-style chrome in monospace.** The wordmark, nav, dates, labels, chips, meta, buttons and hints are monospace. Body text and titles use a clean grotesque sans.
- **Header.**
  - Left: the mono text wordmark "Ilya Paskhover".
  - Nav items with bracketed keyboard hints: `[H] HOME`, `[P] PROJECTS`, `[A] ABOUT`, `[G] GITHUB`. The active item is bold, and the shortcuts really work.
  - Right: one solid light CTA button, "Get in touch", with a text chevron.
- **Home.** Two columns.
  - Left: the mono name and a short tagline.
  - Right:
    - Uppercase mono topic tabs (ALL / topics), with a `[S] SEARCH` action on the right.
    - A featured row: a "Featured" chip, the title, author and topic, and the reading time on the right.
    - Hairline-divided rows: a mono date column, the sans title, and the reading time ("3 minutes") right-aligned.
    - "LOAD MORE", with the hint "Press R to load more".
  - Below the two columns: a "Featured projects" strip.
- **Post page.**
  - A wide header: topic chip, large sans title, lead paragraph.
  - A 3-column meta grid: AUTHOR / PUBLISHED / READING TIME. The labels are uppercase mono, and a `└` glyph precedes each value.
  - Below a hairline, on the left: a sticky "TREE" table of contents (current section bold, others dim, `└` connectors), a text scroll-progress bar (`░░░░ 00%`), and the hint "PRESS ↑ / ↓ TO SCROLL".
  - The body is a narrow centred column with generous line-height and bordered inline-code chips.
- **Concept mapping.**
  - "Mods" become a `/projects/` page.
  - Categories become a `topic` front-matter field. Not `category`, which would change Jekyll post URLs.
  - The CTA "Get in touch" goes to LinkedIn.

## 2. Stack (as found, kept)

- **Site generator:** Jekyll through the `github-pages` gem: Jekyll 3.10, Liquid 4, kramdown with the GFM parser and auto heading ids, Rouge, and libsass via `jekyll-sass-converter` 1.x.
  - The gem applies GitHub Pages' configuration locally (safe mode and the plugin whitelist), so local builds behave like Pages.
  - It also turns on Pages' default plugins (`jekyll-optional-front-matter`, `jekyll-titles-from-headings`, `jekyll-readme-index`, `jekyll-relative-links`, `jekyll-default-layout`). That is one reason `docs/`, `test/` and `README.md` are excluded.
- **Deploy:** classic GitHub Pages from `master`. CI (`.github/workflows/jekyll.yml`) builds with Ruby 3.2 and validates HTML with proof-html.
- **Styles:** SCSS in `_sass/`, imported by `css/main.scss` and compiled to `/css/main.css`.
- **Templates:** Liquid in `_layouts/` (`default`, `page`, `post`) and `_includes/` (`head`, `header`, `footer`).
- **Content:** `_posts/*.markdown`, `about.md`, `index.html`, `feed.xml` (replaced by jekyll-feed in T09), and `assets/html_apps/math_bubbles.html`.
- **Not ours, never edited:** `shallow-whale/` (a separately deployed PWA, copied as static files) and `googlec97749bedfe403e3.html` (Google verification).
- **Backend / database:** none. There are no API endpoints and no test database.
- **Client:** the existing Jekyll front end, plus one small vanilla JS file, `/assets/js/site.js`. It does only what Jekyll cannot (section 13). There is no framework and no JS build step.
- **Added for the POC:**
  - A Docker wrapper (Ruby 3.2, the same as CI).
  - A small Ruby test suite (minitest + Nokogiri) that inspects the built `_site`.

Why Docker instead of native Ruby on Windows:
- `github-pages` pulls native gems (sassc, eventmachine, commonmarker) that need Devkit compilation on Windows.
- A background `jekyll serve` is hard to stop reliably from Git Bash.
- Native `bundle exec jekyll serve` keeps working as the README describes, but no `verify` depends on it.

## 3. Local infrastructure

- `Dockerfile` (repo root), guidance:
  ```
  FROM ruby:3.2-slim
  RUN apt-get update && apt-get install -y --no-install-recommends build-essential && rm -rf /var/lib/apt/lists/*
  WORKDIR /srv/site
  ENV LANG=C.UTF-8 JEKYLL_ENV=production PAGES_REPO_NWO=ilya-paskhover/ilya-paskhover.github.io
  COPY Gemfile ./
  RUN bundle install
  COPY . .
  RUN bundle exec jekyll build
  EXPOSE 4000
  CMD ["bundle","exec","jekyll","serve","--host","0.0.0.0","--port","4000","--skip-initial-build","--no-watch"]
  ```
  - `PAGES_REPO_NWO` stops jekyll-github-metadata from failing when `.git` is not in the build context.
  - If `jekyll serve` fails with `cannot load such file -- webrick`, add `gem 'webrick'` to the Gemfile.
- `docker-compose.yml`:
  - Top-level `name: jekyll-ui-redesign`.
  - One service, `site`, built from `.`, with ports `"${SITE_PORT:-14000}:4000"`.
  - A healthcheck that needs no curl: `["CMD","ruby","-rnet/http","-e","exit(Net::HTTP.get_response(URI('http://127.0.0.1:4000/')).code == '200' ? 0 : 1)"]`, with interval 3s, timeout 3s, retries 20 and start_period 10s.
- `.dockerignore`: `.git`, `_site`, `.jekyll-cache`, `.sass-cache`, `.jekyll-metadata`, `Gemfile.lock`, `.claude`, `.github`, `.vscode`, `docs`, `.poc-artifacts`, `vendor`, `node_modules`, `.env*`, `*.pem`. It must NOT exclude `test/` or `shallow-whale/`.
- **Host port:** 14000 (below 49152). The container port is 4000. Site URL: http://localhost:14000/
- **Builds:** the image runs the production build. Every `verify` rebuilds through `docker compose up -d --build --force-recreate --wait`, then runs tests inside the running container with `docker compose exec -T`. No `verify` runs `jekyll build` a second time.
- **First build:** the first image build compiles sassc and can take several minutes. Per the platform notes, a long `verify` goes to the background; judge it by its exit code.

**Start:** `docker compose up -d --build --force-recreate --wait`

**Stop:** `docker compose down`

Prerequisites on the host: Docker Desktop running, and Git Bash (provides `curl` and `git`). Ruby is NOT needed on the host.

## 4. Where dependencies live

- **Ruby gems:** inside the Docker image. Nothing is installed on the host.
- **Gemfile:** keeps `github-pages`, which already bundles jekyll-seo-tag, jekyll-feed and jekyll-sitemap. T00 adds a test group:
  ```ruby
  group :test do
    gem 'minitest', '~> 5.0'
    gem 'nokogiri'
  end
  ```
  GitHub Pages ignores the Gemfile, and CI installs the extra group harmlessly.
- **Optional native path (README only):** `bundle config set --local path vendor/bundle`. `vendor/` is gitignored.
- **Fonts:** system font stacks only (section 9). There are no web-font requests, so the site works offline and the browser console stays clean.
- **No other toolchains:** no npm, no Node, no Python, no virtual environment.

## 5. Environment

- `.env.example` (T00): comments plus `SITE_PORT=14000`. Compose reads `.env` if the user creates one. The `curl` in T00's verify assumes 14000.
- No secrets, no external APIs, no keys.

## 6. Tests

- **Framework and command:** minitest + Nokogiri, run inside the container with `docker compose exec -T site bundle exec ruby -Itest test/<name>_test.rb`.
- **What tests read:** only `/srv/site/_site` and `/srv/site` sources. They may also make HTTP GETs to `http://127.0.0.1:4000` inside the container. There is no database to reset.
- **`test/test_helper.rb` (T00) provides:**
  - `SITE = File.expand_path("../_site", __dir__)` and `SRC = File.expand_path("..", __dir__)`.
  - `page(url_path)`: a Nokogiri document for a URL. `"/"` maps to `_site/index.html`, `"/about/"` to `_site/about/index.html`, and `"/x.html"` to `_site/x.html`. A missing file fails the test.
  - `css`, `css_compact` (whitespace removed), and `js` (`_site/assets/js/site.js`, or an empty string if it is missing).
  - `http_get(path)` and `own_pages` (every `_site/**/*.html` except `shallow-whale/**`, `assets/html_apps/**` and `googlec*.html`).
- **Matching:** visible label text is matched case-insensitively, because CSS uppercases the mono labels. Tests never rely on JS-produced DOM; acceptance steps cover JS behaviour.
- **Tests are additive.** Never delete or weaken an earlier task's test.
  - Tests must not assert the old site title `Ilya Paskhover's blog/projects`.
  - The smoke test must not depend on redesigned markup, or on the format of `/feed.xml` beyond HTTP 200.

## 7. Content model (no database; all Jekyll-native data)

| Source | Purpose | Fields |
|---|---|---|
| `_data/profile.yml` | name, role, links, intro copy | `name`, `role`, `tagline`, `facts[]`, `linkedin`, `github`, `cta_label` |
| `_data/navigation.yml` | header nav and shortcuts | list of `{ title, url, key, external }` |
| `_data/projects.yml` | projects page and featured strip | list of `{ title, kind, description, url, external, tags[], featured }` |
| Post front matter | feed, featured row, post header | `title`, `date`, `topic`, `description`, `featured` (one post), `archived` (2016 posts) |
| `_config.yml` `defaults:` | front-matter defaults for posts (T05) | `scope: { path: "", type: posts }` sets `values: { layout: post, author: Ilya Paskhover }` |
| `about.md` front matter | About page | `layout: about`, `title: About`, `permalink: /about/`, `description`, `focus_areas: [{ title, text }]` |
| `projects.md` front matter | Projects page | `layout: projects` (`page` in the T02 stub), `title: Projects`, `permalink: /projects/`, `description` |

Values to use:

- **`profile.yml`:**
  - `name: Ilya Paskhover`
  - `role: Senior software developer`
  - `tagline: "Notes, apps and AI agents from a senior software developer with more than 15 years of experience."`
  - `facts: ["Senior software developer", "15+ years of experience", "AI agents, apps and engineering notes"]`
  - `linkedin: https://www.linkedin.com/in/ilyapaskhover/`
  - `github: https://github.com/ilya-paskhover`
  - `cta_label: Get in touch`
- **`navigation.yml`:**
  - Home, `/`, key `h`
  - Projects, `/projects/`, key `p`
  - About, `/about/`, key `a`
  - GitHub, the profile.github URL, key `g`, external
- **Post front matter:**

  | Post | `topic` | Other flags | `description` |
  |---|---|---|---|
  | vibe-coding-apps | Apps | `featured: true` | "Small browser apps built by vibe coding, starting with Math Bubbles, a 30-second arithmetic game." |
  | ai-agents | AI agents | none | "AI agents I have built, starting with a Gemini gem that summarizes YouTube videos." |
  | base44-projects | Apps | none | "Apps I built on Base44: an interactive AI CV and an epoch time converter." |
  | the three 2016 posts | Notes | `archived: true` | none |

  `topic` is a custom key. Never set `category`/`categories` on the 2025 posts, and never change the 2016 posts' existing `categories`. Both would change URLs.
- **`projects.yml`, in this order** (descriptions in the list below the table):

  | # | Title | Kind | URL | Link | Tags | Featured |
  |---|---|---|---|---|---|---|
  | 1 | Shallow Whale | `Web game` | `/shallow-whale/` | internal | Game, PWA | yes |
  | 2 | Interactive AI CV | `Web app` | `https://ilyas-ai-cv.base44.app` | external | Base44, AI | yes |
  | 3 | YouTube Videos Summarizer | `AI agent` | `https://gemini.google.com/gem/1TxqGF2P6zAIuV9c5rC9PMW7NFHq7XqG7?usp=sharing` | external | Gemini, AI agent | yes |
  | 4 | Epoch Converter | `Web app` | `https://epochconverter.base44.app/` | external | Base44, Utility | no |
  | 5 | Math Bubbles | `Browser game` | `/assets/html_apps/math_bubbles.html` | internal | Game, Vibe coding | no |

  Descriptions:
  1. Shallow Whale: "A simulated crypto trading game. No ads, no purchases, no real money."
  2. Interactive AI CV: "My CV as an interactive, AI-assisted app, built with Base44."
  3. YouTube Videos Summarizer: "A Gemini gem that summarizes YouTube videos."
  4. Epoch Converter: "Convert between Unix timestamps and readable dates. Built with Base44."
  5. Math Bubbles: "A 30-second arithmetic game: pick ×2, ×3, +N or −N each round to push your number as high as you can."
- **Copy must not invent facts.** All of it comes from the existing posts, `about.md`, `_config.yml` and the Shallow Whale manifest. The user reviews it (section 11).

## 8. Pages and URLs (no API; these are the routes)

Existing URLs must not change:

| URL | Source |
|---|---|
| `/` | `index.html` |
| `/projects/` | `projects.md` (new; stub in T02, full page in T04) |
| `/about/` | `about.md` |
| `/2025/11/22/vibe-coding-apps.html` | post |
| `/2025/06/24/ai-agents.html` | post |
| `/2025/05/23/base44-projects.html` | post |
| `/jekyll/update/2016/03/17/small-summary-for-linux-kernel-course.html` | post (archived) |
| `/jekyll/update/2016/03/17/about-this-blog.html` | post (archived) |
| `/jekyll/update/2016/03/17/welcome-to-jekyll.html` | post (archived) |
| `/feed.xml` | hand-written RSS until T09; generated by jekyll-feed (Atom) after |
| `/sitemap.xml` | new in T09, generated by jekyll-sitemap |
| `/css/main.css` | compiled SCSS |
| `/assets/js/site.js` | new (T02, extended later) |
| `/favicon.svg` | new in T09 (text monogram) |
| `/shallow-whale/` | static, untouched |
| `/assets/html_apps/math_bubbles.html` | static, untouched |

`_config.yml` gets an explicit `exclude:` list in T00. Jekyll 3 replaces the default list, so the defaults are repeated: `Gemfile`, `Gemfile.lock`, `README.md`, `Dockerfile`, `docker-compose.yml`, `docs`, `test`, `vendor`, `node_modules`, `.poc-artifacts`.

## 9. Design system (T01 defines; later tasks use only these tokens)

CSS custom properties live in `_sass/_tokens.scss`. **Dark is the default** on `:root`, and `[data-theme="light"]` overrides it. `<html>` is rendered with `data-theme="dark"`. The toggle is the only way to switch; the system preference is not followed.

| Token | Dark (default) | Light |
|---|---|---|
| `--color-bg` | `#141414` | `#FAFAF7` |
| `--color-surface` | `#1C1C1B` | `#FFFFFF` |
| `--color-text` | `#EDEDEA` | `#141414` |
| `--color-text-muted` | `#8F8F8A` | `#5C5C57` |
| `--color-text-dim` | `#5F5F5A` | `#A3A39E` |
| `--color-border` | `#2A2A28` | `#E3E3DE` |
| `--color-accent` | `#D9825B` | `#B4532F` |
| `--color-cta-bg` | `#F2F2EE` | `#141414` |
| `--color-cta-text` | `#141414` | `#FAFAF7` |

- **Contrast:**
  - `--color-text-dim` fails AA. It is only for decorative glyphs and connector lines (`[H]` hints, `└`, `░`), which are `aria-hidden` or drawn with CSS borders.
  - Inactive nav and TREE entries use `--color-text-muted` (about 5.7:1 on dark).
  - The accent passes AA in both themes.
- **Fonts:**
  - `--font-mono: "JetBrains Mono", "IBM Plex Mono", "Cascadia Mono", "Cascadia Code", "SF Mono", "SFMono-Regular", Menlo, Consolas, "Liberation Mono", monospace;`
  - `--font-sans: "Inter", "Geist", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;`
  - Mono is for the wordmark, nav, dates, chips, labels, tabs, meta, buttons, hints, code and the TREE. Sans is for the body, post titles, row titles and leads.
- **Mono label:** `.label` is mono, `0.8125rem`, uppercase, `letter-spacing: .04em`.
- **Type scale:**
  - Post h1: `clamp(2rem, 1.4rem + 2.4vw, 3rem)`, weight 500, `-0.02em`.
  - Home name (mono): `clamp(1.75rem, 1.4rem + 1.2vw, 2.25rem)`.
  - Row title: `1.125rem`, weight 500.
  - Body: `1.0625rem`, line-height 1.75.
  - Small: `0.875rem`.
- **Spacing:** `--space-1..--space-9` are 4, 8, 12, 16, 24, 32, 48, 64 and 96 px.
- **Shapes:**
  - `--radius: 4px`.
  - Chips and inline code are 1px-bordered boxes.
  - The CTA is a solid rectangle with a 2px radius.
  - No shadows. Hairlines are 1px `--color-border`.
- **Widths:**
  - `--width-page: 1600px`, with `--gutter: clamp(16px, 3vw, 32px)`.
  - `--width-prose: 66ch`.
  - Home and projects grid at ≥1024 px: `minmax(260px, 1fr) 2fr`.
  - Post layout at ≥1024 px: `minmax(220px, 1fr) minmax(0, 66ch) 1fr`.
- **Breakpoints:** `$bp-md: 768px` (the nav collapses below it) and `$bp-lg: 1024px` (two columns and the sticky TREE from here up).
- **Focus:** `:focus-visible { outline: 2px solid var(--color-accent); outline-offset: 3px; }`.
- **Motion:** 120 to 200 ms transitions. No looping animations. Everything is off under `prefers-reduced-motion: reduce`.
- **libsass limits:**
  - Keep `@import`; do not use `@use`.
  - Avoid CSS `min()`/`max()`. Use `clamp()`, or `unquote("min(...)")`.
  - Custom properties, `clamp()` and `:where()` pass through.
  - Do not use the CSS `content: "x" / ""` alt-text syntax.

## 10. Markup contract (tests and implementation agree on these)

**Global**
- `<html lang="en" data-theme="dark">`.
- The first focusable element in `<body>` is `a.skip-link[href="#main"]`, "Skip to content".
- There is exactly one `main#main`.
- `.visually-hidden` is the screen-reader-only utility.
- Decorative text glyphs (`.kbd-hint`, `.tree-glyph`, `.progress-glyphs`, chevrons, `↗`) carry `aria-hidden="true"`.

**Head**
- An inline script runs before the stylesheet. It sets `data-theme="light"` if `localStorage.theme === "light"`, and adds class `js` to `<html>`.
- `<script src="/assets/js/site.js" defer>`.
- No web-font links.
- From T09: `{% seo %}`, `{% feed_meta %}`, the favicon link and theme-color.

**Header (`_includes/header.html`)**
- `header.site-header` is not sticky.
- DOM order:
  1. `a.site-brand[href="/"]`, a mono text wordmark `{{ site.data.profile.name }}` (text only).
  2. `button.nav-toggle[aria-controls="site-nav-menu"][aria-expanded="false"]`, "Menu". Shown only under 768 px, with JS.
  3. `nav.site-nav[aria-label="Primary"]` holding `#site-nav-menu`. Inside it:
     - One `a.nav-link` per `site.data.navigation` item, each with `aria-keyshortcuts="{{ item.key }}"` and an inner `span.kbd-hint` (`[H]` etc.) before the title.
     - Then `a.nav-cta`: `profile.cta_label` plus `span.chevron[aria-hidden="true"]` "›", linking to `profile.linkedin`, with `target="_blank"`, `rel="noopener noreferrer"` and a visually hidden " (opens in a new tab)".
  4. `button#theme-toggle` with `aria-label` "Switch to light theme" or "Switch to dark theme".
- `aria-current="page"` is set with Liquid (`page.url == item.url`). Home is current only on `/`, Projects on `/projects/` and About on `/about/`. No link is current on posts.

**Shortcuts and behaviour (`assets/js/site.js`)**
- `h`, `p`, `a`, `g` follow the nav links.
- On home, `s` opens search (T14) and `r` loads more (T05). Elsewhere, `s` goes to `/#search`.
- Shortcuts are ignored in `input`/`textarea`/`select`/`[contenteditable]`, when Ctrl/Meta/Alt is held, and when `localStorage.shortcuts === "off"` (T11).
- Menu toggle: updates `aria-expanded`, closes on Escape (focus returns to the button) and on link click.
- Theme toggle: flips `data-theme`, saves `localStorage.theme`, updates the label.
- No console errors.

**Home (`index.html`)**
- `div.home-grid`: two columns from 1024 px.
- Left: `aside.home-intro`, containing:
  - `h1.home-title` "Ilya Paskhover" (mono).
  - `p.home-tagline`.
  - `ul.home-facts > li`, each starting with `span.tree-glyph` "└".
- Right: `section#writing.home-feed`, containing:
  - `h2.visually-hidden` "Writing".
  - `div.feed-toolbar` with `div.topic-tabs[aria-label="Filter by topic"]`. Its tabs are `button.topic-tab[data-topic]`:
    - First, `all` "All" with `aria-pressed="true"`.
    - Then one per topic, from `site.posts | map: "topic" | compact | uniq | sort`, with `data-topic` set to `topic | slugify` and `aria-pressed="false"`.
  - `article.post-featured[data-topic][data-search]`, the first of `site.posts | where: "featured", true`. It contains:
    - `span.chip` "Featured".
    - `h3 > a.post-link`.
    - `p.post-featured-meta` (`post.author` and the topic, mono).
    - `span.reading-time`.
  - `ol.post-list > li.post-row[data-topic][data-search]` for `site.posts | where_exp: "p", "p.featured != true"`, newest first. Each row has:
    - `time.post-date[datetime]`: `date_to_xmlschema`, text from `date: "%b %d, %Y"`.
    - `h3 > a.post-link`.
    - `span.reading-time`, "1 minute" or "N minutes".
  - `div.load-more-row` with `button.load-more[data-page-size="3"]` "Load more" and `p.load-more-hint` "Press R to load more".
- `data-search` is built by Liquid. It is title, topic and description joined, then `downcase | escape`.
- JS shows 3 rows, then 3 more per click or `r`, and hides the row when all are shown. Without JS, every row shows and the load-more row is hidden.
- Topic tabs set `aria-pressed`, show only matching rows (including the featured row) and hide load-more. "All" restores paging.
- Below the grid: `section#featured-projects` with `h2` "Featured projects".
  - The cards are built by `{% assign featured = site.data.projects | where: "featured", true %}` and `{% for p in featured limit: 3 %}{% include project-card.html project=p %}{% endfor %}` (T06).
  - Each `article.project-card` has `p.project-kind`, `h3.project-title > a` (a stretched link) and `p.project-description`.
  - After the cards: `a.view-all[href="/projects/"]` "View all projects".

**Projects page (`_layouts/projects.html`, T04)**
- Left: `h1` "Projects" and `p.page-tagline` (page description).
- Right: `ol.project-list > li.project-row` from `{% include project-row.html project=p %}`, in data order. Each row has:
  - `h2.project-title > a` (a stretched link).
  - `p.project-description`.
  - `ul.project-tags > li.chip`.
  - `span.project-kind` (mono, right).
- External links get `target="_blank"`, `rel="noopener noreferrer"`, a visually hidden " (opens in a new tab)" and `span[aria-hidden="true"]` "↗".

**Post (`_layouts/post.html`, T07)**
- `article.post > header.post-hero`, containing:
  - `a.back-link[href="/"]` "All writing".
  - `span.chip.post-topic`.
  - `h1.post-title`.
  - `p.post-lead` (`page.description`, falling back to `page.excerpt | strip_html | truncatewords: 30`).
  - `p.post-archived-note` "This is an archived note from 2016." when `page.archived`.
  - `dl.post-meta-grid`: three `div`s, each holding a `dt.label` (Author / Published / Reading time) and a `dd` with `span.tree-glyph` "└" plus the value: `page.author`, `time[datetime]` (for example "Jun 24, 2025"), or "N min".
- A full-width hairline.
- `div.post-layout`, containing:
  - `aside.post-aside` (sticky at ≥1024 px), containing:
    - `p.label` "Tree".
    - `nav.post-tree[aria-label="Table of contents"]`. It holds kramdown's generated `ul#markdown-toc > li > a[href="#<heading-id>"]`, moved out of the body by the layout (section 13). With no kramdown TOC, it holds `ul.post-tree-fallback > li > a[href="#post-body"]` "Overview" instead.
    - The `└` connectors are drawn with a CSS `::before` box (left and bottom borders in `--color-text-dim`), not text. Screen readers therefore hear nothing extra.
    - `div.read-progress[role="progressbar"][aria-label="Reading progress"][aria-valuemin="0"][aria-valuemax="100"][aria-valuenow="0"]`, containing `span.progress-glyphs` (20 glyphs, `█` and `░`) and `span.progress-value` "00%".
    - `p.scroll-hint` "Press ↑ / ↓ to scroll".
  - `div.post-content#post-body`. It does not contain `#markdown-toc`.
- JS updates the progress (100% if the body fits the viewport) and marks the current TREE link `aria-current="location"` plus `.is-active` (bold).
- Then `nav.post-nav[aria-label="More posts"]` from `page.previous` / `page.next`: `a.post-nav-older` ("Older" + title) and `a.post-nav-newer` ("Newer" + title).
- Then `aside.cta`: heading "Let's work together", text "Have a project or a role in mind? I'm happy to talk.", and a link "Get in touch" to LinkedIn.

**About (`_layouts/about.html`, T08)**
- `header.post-hero` styling, containing:
  - `span.chip` "About".
  - `h1` "About".
  - `p.post-lead` (page.description: "Senior software developer. AI agents, apps and engineering notes.").
  - `dl.post-meta-grid`: Role ("Senior software developer"), Experience ("15+ years"), and Elsewhere (LinkedIn and GitHub links).
- `div.about-intro`.
- `section.focus-areas`: `h2` "What I work on", then three `div.focus-row` (h3 + text via `markdownify`) from `page.focus_areas`.
- `section.about-projects`: `h2` "Selected projects", then the featured `project-card` includes.
- `aside.cta` with "Get in touch" (LinkedIn) and "GitHub".

**Footer (`_includes/footer.html`, T03)**
- `footer.site-footer`: mono, small, with a hairline top.
- The mono wordmark "Ilya Paskhover" and the role.
- A "Site" column from `site.data.navigation` (Home, Projects, About), plus RSS `/feed.xml`.
- An "Elsewhere" column: GitHub, LinkedIn.
- `p.footer-copyright`: "© {{ site.time | date: '%Y' }} Ilya Paskhover. Built with Jekyll."
- T11 adds `button#shortcuts-toggle`.

## 11. Steps for the user

1. Have Docker Desktop running before `Start:`.
2. Review the new copy: tagline, facts, project descriptions, post leads and intros, the About intro and focus areas, and the featured post ("Vibe coding apps").
3. Optional: self-host JetBrains Mono and Inter (both OFL) under `assets/fonts/` with `@font-face`. The stacks already list them first.
4. Deploying is yours: push `master`. After T09, feed readers that already subscribed to `/feed.xml` may show the existing posts once more as new items (see section 13). You may set `check_favicon: true` in CI after T09; this is not planned as a task.

## 12. Task notes (T00 to T14)

### T00 Scaffold: Docker build, test harness, smoke test (backend-infra-dev, M)
- Add `Dockerfile`, `docker-compose.yml`, `.dockerignore` and `.env.example` as in sections 3 and 5.
- Add the Gemfile test group, and add `exclude:` to `_config.yml` (section 8). Make no other config change.
- Append to `.gitignore`, keeping its 3 lines: `.env*`, `!.env.example`, `*.pem`, `*.key`, `.poc-artifacts/`, `vendor/`, `.bundle/`, `node_modules/`, `.jekyll-cache/`, `.jekyll-metadata`, `coverage/`.
- Write `test/test_helper.rb` (section 6) and `test/smoke_test.rb`. The smoke test checks:
  - HTTP 200 for `/`, `/about/`, `/feed.xml`, `/css/main.css`, `/shallow-whale/`, `/assets/html_apps/math_bubbles.html` and all six post URLs.
  - `_site/shallow-whale/index.html` is byte-identical to `shallow-whale/index.html`.
  - `_site` has no `docs/`, `test/`, `README.md`, `Dockerfile` or `Gemfile`.
  - Every root-relative `href`/`src` in `own_pages` resolves to a file in `_site`. Ignore `#fragment` and `href="#"`; directory URLs resolve to `index.html`.
- The smoke test does not assert markup or the site title.
- The verify also fails if anything under `shallow-whale/` is modified, staged or untracked.

### T01 Dark-first tokens, font stacks, base typography, page shell (web-dev, M)
- `_sass/_tokens.scss` (section 9).
- Rewrite `_sass/_base.scss`, covering:
  - Reset and typography.
  - Links.
  - Lists and blockquote.
  - Inline `code` as a bordered mono chip.
  - `pre` on `--color-surface` with a hairline and `overflow-x: auto`.
  - `.visually-hidden`, `.label` and `.chip`.
- Update the `css/main.scss` imports.
- Restyle `_sass/_syntax-highlighting.scss` with a muted token palette.
- `_layouts/default.html`: `<html lang="en" data-theme="dark">`, the skip link and `<main id="main">`.
- `_includes/head.html`: the inline theme/`js` script, and no web-font links.
- `test/foundation_test.rb` checks:
  - `css_compact` (case-insensitive) has `--color-bg:#141414`, `--color-accent:`, `--font-mono:`, `--font-sans:`, `[data-theme="light"]` (or unquoted), `prefers-reduced-motion:reduce` and `:focus-visible`.
  - On `/` and `/about/`: `html[lang="en"][data-theme="dark"]`, the first body `a` is `a.skip-link[href="#main"]`, and there is exactly one `main#main`.
  - No own page contains `fonts.googleapis.com`.

### T02 Header: text wordmark, bracketed nav, CTA, shortcuts, mobile menu, theme toggle (web-dev, M)
- Create `_data/profile.yml`, `_data/navigation.yml` and `_data/projects.yml` (section 7).
- Create a stub `projects.md` (`layout: page`, `title: Projects`, `permalink: /projects/`) listing `site.data.projects` titles. T04 replaces its layout.
- Rewrite `_includes/header.html` (section 10). The nav is a Liquid loop over `site.data.navigation`.
- Create `assets/js/site.js` (shortcuts, menu, theme) and `_sass/_header.scss`.
- Remove the old `.menu-icon` menu and the `site.pages` loop.
- `test/header_test.rb`, on `/`, `/about/` and the AI agents post:
  - `header.site-header`.
  - `a.site-brand[href="/"]` whose text is "Ilya Paskhover" and which contains no `svg` or `img`.
  - `nav.site-nav[aria-label="Primary"]` with 4 `a.nav-link`: `aria-keyshortcuts` h, p, a, g, and hrefs `/`, `/projects/`, `/about/` and the GitHub URL. Each has a `span.kbd-hint[aria-hidden="true"]` `[H]`/`[P]`/`[A]`/`[G]`.
  - `aria-current="page"` on Home for `/`, on About for `/about/`, and on none for the post.
  - `a.nav-cta` text contains "Get in touch", with a LinkedIn href.
  - `button.nav-toggle[aria-controls="site-nav-menu"][aria-expanded="false"]`, `#site-nav-menu` and `button#theme-toggle[aria-label]`.
  - `script[src="/assets/js/site.js"][defer]`, and no `.menu-icon`.
  - `js` contains `keydown`, `localStorage` and `aria-expanded`.
  - `/projects/` lists all five project titles.

### T03 Footer (web-dev, S)
- Rewrite `_includes/footer.html` (section 10). The Site column loops over `site.data.navigation`. Remove the Twitter block.
- `test/footer_test.rb`, on `/`:
  - `footer.site-footer` has links `/`, `/projects/`, `/about/`, `/feed.xml`, GitHub and LinkedIn, and contains no `svg` or `img`.
  - `p.footer-copyright` contains the current year and "Ilya Paskhover".

### T04 Projects page (web-dev, S)
- Create `_includes/project-row.html` and `_includes/project-card.html` (include parameter `project`; the card is used later by home and About) and `_layouts/projects.html`.
- Switch `projects.md` to `layout: projects`, `description: "Apps, games and AI agents I have built."`.
- `test/projects_test.rb`, on `/projects/`:
  - One `h1` "Projects", and the Projects nav link has `aria-current="page"`.
  - `ol.project-list > li.project-row` ×5 in data order. Each row has `h2.project-title a`, a non-empty `.project-description`, `.project-kind` and at least one `.project-tags li.chip`.
  - The Shallow Whale link is `/shallow-whale/` with no `target`.
  - Every `http` link has `target="_blank"`, `rel` containing `noopener`, and the text "(opens in a new tab)".
  - No `svg` inside `.project-list`.

### T05 Home feed: topic tabs, featured row, hairline rows, load more (web-dev, M)
- Add `topic`, `description`, `featured` and `archived` front matter (section 7).
- Add the `_config.yml` `defaults:` block for posts (layout `post`, author `Ilya Paskhover`). You may then remove `layout: post` from the posts.
- Create `_includes/reading-time.html` with parameters `content` and `format`. It is pure Liquid: `number_of_words`, then `plus: 199 | divided_by: 200`, with a minimum of 1. `long` gives "1 minute" or "N minutes"; `short` gives "N min".
- Replace the old list on `/` with `section#writing` (section 10), built with `where`, `where_exp`, `map`, `uniq`, `sort` and `slugify`. Remove the old `h1` "Posts". A placeholder `aside.home-intro` without an h1 may stand until T06.
- Extend `site.js` with tab filtering and load more (click and `r`).
- `test/writing_test.rb`, on `/`:
  - `section#writing` with `h2` "Writing".
  - Tab texts are All, AI agents, Apps, Notes. The first is `aria-pressed="true"`, the rest "false". The `data-topic` values are `all`, `ai-agents`, `apps`, `notes`.
  - `article.post-featured[data-topic="apps"]` has a `.chip` "Featured", link text "Vibe coding apps", `.post-featured-meta` containing "Ilya Paskhover" and "Apps", and `.reading-time` "1 minute".
  - `ol.post-list > li.post-row` count is 5, in this order: AI agents; Base44 projects; A small summary of 'Linux Kernel' course - day 2!; About this blog!; Welcome to Jekyll!.
  - Each row has a `data-topic` among the topic slugs, a non-empty lowercase `data-search` containing the lowercased title, and `time.post-date[datetime]` text matching `/\A[A-Z][a-z]{2} \d{2}, \d{4}\z/`.
  - Each row's `.reading-time` matches `/\A\d+ minutes?\z/`.
  - `button.load-more[data-page-size="3"]`, and `.load-more-hint` containing "R".
  - `js` contains `load-more` and `topic-tab`.

### T06 Home two-column intro and featured projects strip (web-dev, S)
- Fill `aside.home-intro` from `site.data.profile`.
- Add `section#featured-projects`: `{% assign featured = site.data.projects | where: "featured", true %}`, loop with `limit: 3`, rendering `{% include project-card.html project=p %}`; then `a.view-all`.
- Style the grid.
- `test/home_intro_test.rb`, on `/`:
  - Exactly one `h1`, which is `h1.home-title` "Ilya Paskhover".
  - `p.home-tagline` equals `profile.tagline`.
  - 3 `ul.home-facts li`, each with a `.tree-glyph`.
  - `.home-grid` has `aside.home-intro` before `section#writing`.
  - `section#featured-projects` follows `.home-grid`. It has `h2` "Featured projects", 3 `article.project-card` (Shallow Whale, Interactive AI CV, YouTube Videos Summarizer) and `a.view-all[href="/projects/"]`.

### T07 Post page: hero, meta grid, kramdown TREE, reading progress, sectioned post bodies (web-dev, M)
- Add to `_config.yml`: `kramdown: { toc_levels: "2" }` (auto_ids is already on via GitHub Pages defaults; state it as `auto_ids: true` too). This keeps the TOC flat (h2 only) and makes extraction robust.
- Rewrite `_layouts/post.html` (section 10). Create `_includes/post-tree.html`, which moves kramdown's TOC into the aside:
  - Split `content` on `<ul id="markdown-toc">`.
  - If there are two parts, the TOC is the second part up to its first `</ul>` (flat list, so no nesting), and the body is the first part plus the rest after that `</ul>`.
  - Otherwise render the "Overview" fallback and the untouched body.
- Extend `site.js` (progress, active TREE link) and add post styles.
- Restructure the three 2025 post bodies, keeping URLs, titles and dates. Each starts with the kramdown TOC marker on two lines, `* TOC` and `{:toc}`, followed by:
  - Base44: intro "Two small apps I built on Base44."
    - `## Interactive AI CV`: "My CV as an interactive, AI-assisted app." + `[Open the Interactive AI CV](https://ilyas-ai-cv.base44.app)`.
    - `## Epoch converter`: "Converts between Unix timestamps and readable dates." + `[Open the Epoch converter](https://epochconverter.base44.app/)`.
  - AI agents: intro "AI agents I have built."
    - `## YouTube videos summarizer`: "A Gemini gem that summarizes YouTube videos." + `[Open the YouTube videos summarizer](same Gemini link)`.
  - Vibe coding apps: intro "Small browser apps built by vibe coding."
    - `## Math Bubbles`: the existing description + `[Play Math Bubbles](/assets/html_apps/math_bubbles.html)`.
- `test/post_test.rb`, on `/2025/06/24/ai-agents.html`:
  - `a.back-link[href="/"]`.
  - One `h1.post-title` "AI agents", `.post-topic` "AI agents", and a non-empty `p.post-lead`.
  - `dl.post-meta-grid dt` texts are Author, Published, Reading time. The `dd`s contain "Ilya Paskhover", a `time[datetime]` and `/\d+ min/`, and each has a `.tree-glyph`.
  - `nav.post-tree[aria-label="Table of contents"] ul#markdown-toc a` has exactly one link, `#youtube-videos-summarizer`.
  - `#post-body` contains no `#markdown-toc`, and the page has exactly one `#markdown-toc`.
  - `.read-progress[role="progressbar"][aria-valuenow="0"]`, `.progress-value` "00%", and `.scroll-hint` containing "to scroll".
  - `a.post-nav-older` points to the Base44 post, `a.post-nav-newer` to the Vibe coding post, and `aside.cta` has a LinkedIn link.
  - No `.post-archived-note`.
- On the Base44 post, the tree links are `#interactive-ai-cv` and `#epoch-converter`.
- On the Welcome to Jekyll post, `.post-archived-note` exists, and the tree is `ul.post-tree-fallback` with one link "Overview" to `#post-body`.
- `js` contains `aria-valuenow`.

### T08 About page (web-dev, S)
- Create `_layouts/about.html` (section 10) and rewrite `about.md`, keeping `title: About` and `permalink: /about/`.
- The intro text is: "I am a senior software developer with more than 15 years of experience. These days I focus on practical AI: agents that save time, and small apps built quickly to test an idea. You can find more about my professional background on [LinkedIn](https://www.linkedin.com/in/ilyapaskhover/)."
- `focus_areas` front matter:
  - "AI agents and automation": "Agents and assistants that take repetitive work off people's plates, like a Gemini gem that summarizes YouTube videos."
  - "Web apps and prototypes": "Small, complete apps shipped fast, from a crypto trading game to an epoch converter."
  - "Systems and fundamentals": "A background that goes below the framework, down to Linux kernel modules."
- `test/about_test.rb`, on `/about/`:
  - One `h1` "About", with the About link `aria-current="page"`.
  - `.about-intro` contains "more than 15 years of experience", and the page has no "experince".
  - `dl.post-meta-grid dt` texts are Role, Experience, Elsewhere, with LinkedIn and GitHub links.
  - 3 `.focus-row` with the h3 titles above.
  - `section.about-projects` has 3 `article.project-card`.
  - `aside.cta` links to LinkedIn and GitHub.

### T09 Metadata: SEO tag, jekyll-feed, jekyll-sitemap, monogram favicon (web-dev, S)
- `_config.yml` changes:
  - Set `title: Ilya Paskhover`, `tagline: Senior software developer`, keep `description`.
  - Set `url: "https://ilya-paskhover.github.io"`, `author: Ilya Paskhover`, `lang: en`.
  - Set `plugins: [jekyll-seo-tag, jekyll-feed, jekyll-sitemap]`.
  - Set `social: { name: Ilya Paskhover, links: [LinkedIn URL, GitHub URL] }`.
  - Add a `defaults:` entry with `scope: { path: "googlec97749bedfe403e3.html" }` and `values: { sitemap: false }`.
  - Keep `exclude:` and the T05/T07 settings.
- Delete the hand-written `feed.xml`. jekyll-feed only generates `/feed.xml` when no source file has that path.
- `_includes/head.html`: replace the manual title, description, canonical and RSS link with `{% seo %}` and `{% feed_meta %}`. Add `<link rel="icon" href="/favicon.svg" type="image/svg+xml">` and `<meta name="theme-color" content="#141414">`.
- Add `favicon.svg` at the root: a 32×32 `#141414` rounded square with the text "IP" in the accent colour, in a monospace font-family. No artwork.
- `test/meta_test.rb` checks:
  - Titles:
    - The `/` title is "Ilya Paskhover | Senior software developer".
    - The `/about/` and `/projects/` titles start with "About" and "Projects".
  - SEO tags:
    - Every own page has `meta[property="og:title"]` and a `link[rel="canonical"]` starting with `https://ilya-paskhover.github.io`.
    - Every own page has `link[rel="alternate"][type="application/atom+xml"]`.
  - Favicon and theme-color:
    - `link[rel="icon"][href="/favicon.svg"]` is present, and `_site/favicon.svg` exists and contains "IP".
    - `meta[name="theme-color"][content="#141414"]` is present.
  - Feed:
    - The source `feed.xml` is absent from `SRC`.
    - `_site/feed.xml` has a root `<feed>` and contains "Vibe coding apps".
  - Sitemap: `_site/sitemap.xml` contains `https://ilya-paskhover.github.io/projects/` and `/about/`, and does not contain `googlec97749bedfe403e3`.

### T10 Content fixes and README (web-dev, S)
- Fix in the 2016 posts:
  - "wiht" becomes "with".
  - "direcroy" becomes "directory".
  - Pronoun "i" becomes "I".
  - Remove the empty `*` bullet in the Linux kernel post.
  - Keep titles, dates and categories.
- README:
  - Add "Run with Docker": Start/Stop, http://localhost:14000/, running one test file, and the keyboard shortcuts.
  - Keep the native Ruby section.
  - Update Structure (`_data/`, `test/`, `docs/`, `projects.md`).
  - In "Writing a Post", document `topic`, `description`, `featured`, the defaults (layout and author no longer needed per post), and the TOC marker (`* TOC` + `{:toc}`).
  - The main thread checks the README's claims against this spec.
- `test/content_test.rb` checks:
  - The posts' HTML has no "wiht" or "direcroy".
  - The Linux kernel post has no empty `li`.
  - `README.md` in `SRC` contains "docker compose up -d --build --force-recreate --wait", "http://localhost:14000", "topic:" and "{:toc}".

### T11 Accessibility pass and shortcut opt-out (web-dev, M)
- Add `button#shortcuts-toggle` to the footer. Its text is "Keyboard shortcuts: on" or "off", with `aria-pressed`. It stores `localStorage.shortcuts`. (WCAG 2.1.4 requires a way to turn off single-key shortcuts.)
- Fix what the checks find.
- `test/a11y_test.rb`, over `own_pages`, checks:
  - Document structure:
    - `html[lang]`.
    - Exactly one `h1`.
    - No downward heading skips.
    - Unique ids.
    - Exactly one `main`.
  - Images: every `img` has `alt`.
  - Accessible names: every `a` and `button` has a non-empty name (text outside `aria-hidden` elements, or `aria-label`).
  - Links: every `a[target="_blank"]` has `rel` containing `noopener`.
  - Decorative and interactive markup:
    - Every `.kbd-hint`, `.tree-glyph` and `.progress-glyphs` is `aria-hidden="true"`.
    - Every `.topic-tab` has `aria-pressed`.
  - Focus order: the first focusable element is the skip link.
  - Shortcut opt-out: `/` has `button#shortcuts-toggle`, and `js` contains `shortcuts`.

### T12 Responsive layout (web-dev, M)
- Behaviour at 375, 768, 1024 and 1280 px:
  - No horizontal page scroll.
  - Home and projects become one column below 1024 px.
  - Below 768 px, feed rows put the date line (with the reading time) above the title.
  - The tabs scroll inside their own row (`overflow-x: auto`).
  - Below 1024 px the TREE sits above the body and is not sticky.
  - The meta grid becomes one column below 768 px.
  - Tap targets are at least 44 px below 768 px.
  - `overflow-wrap: anywhere` on titles and prose.
- `test/responsive_test.rb` checks:
  - `css_compact` has `min-width:768px` and `min-width:1024px` inside `@media` rules, plus `position:sticky`, `overflow-wrap:anywhere` (or `break-word`), `overflow-x:auto` and `min-height:44px`.
  - Every own page has `meta[name="viewport"][content*="width=device-width"]`.

### T13 Motion and interaction polish (web-dev, M)
- Hover and focus-within states:
  - Feed rows: tint to `--color-surface`, and the title turns the accent colour.
  - Project cards and rows: the border turns the accent colour, and `↗`/`→` nudges 2 px.
  - CTA: a brightness shift.
- Other polish:
  - An underline slides in under the active tab.
  - The TREE weight change is animated.
  - The feed fades in once.
  - No loops.
- Smooth scroll only under `prefers-reduced-motion: no-preference`.
- `scroll-margin-top` on `.post-content h2`.
- `test/motion_test.rb` checks that `css_compact` has:
  - `@keyframes`.
  - `.post-row:hover` (or `:focus-within`).
  - `.project-card:hover` or `.project-row:hover`.
  - `scroll-behavior:smooth` inside a `prefers-reduced-motion:no-preference` block.
  - A `prefers-reduced-motion:reduce` block that sets `animation` and `transition` to none, or their durations to 0.
  - `scroll-margin-top`.

### T14 Home search ([S]) (web-dev, S)
- In `div.feed-toolbar`, right-aligned, add `button.search-toggle[aria-controls="post-search-panel"][aria-expanded="false"]` with `span.kbd-hint` "[S]" and "Search". It is shown only with JS.
- Add `div#post-search-panel[hidden]`, holding a visually hidden `label[for="post-search"]` "Search posts" and `input#post-search[type="search"]`.
- Add `p.search-empty[hidden]` "No posts match."
- Behaviour:
  - `s` or a click opens the panel and focuses the input.
  - Typing filters the featured row and the rows by their Liquid-built `data-search` (case-insensitive), ignoring paging.
  - Escape clears and closes the panel, restores the tab filter and paging, and returns focus to the toggle.
  - `/#search` opens the panel on load.
- `test/search_test.rb`, on `/`, checks:
  - The `button.search-toggle` as above.
  - `#post-search-panel[hidden]`.
  - `input#post-search[type="search"]` with its `label[for="post-search"]`.
  - `p.search-empty[hidden]`.
  - The Linux kernel row's `data-search` contains "kernel".
  - `js` contains `post-search`, `data-search` and `#search`.

## 13. Jekyll-native choices

| Feature | Mechanism | Why custom code (if any) |
|---|---|---|
| Profile, nav, projects | `site.data` (`_data/*.yml`) + Liquid loops + include parameters (`project-card.html`, `project-row.html`, `reading-time.html`) | none |
| Projects as data, not a collection | `_data/projects.yml` | Projects have no pages of their own. A collection (`output: false`) would add one file per project with no gain. |
| Post defaults (layout, author) | `_config.yml` `defaults:` | none |
| Topics and tabs | front matter `topic` + `map`, `compact`, `uniq`, `sort`, `slugify` | Filtering on click needs JS, because a static site cannot re-render. `category` is avoided because it changes URLs. |
| Featured post, other posts, featured projects | `where`, `where_exp`, and the `for` loop's `limit:` parameter | none |
| Dates | `date: "%b %d, %Y"`, `date_to_xmlschema` | `date_to_string` is not used: its output ("22 Nov 2025") does not match the reference format ("Nov 22, 2025"). |
| Reading time | `number_of_words`, `plus`, `divided_by` in an include | none |
| Post lead fallback | `excerpt`, `strip_html`, `truncatewords` | none |
| About focus text | front matter + `markdownify` | none |
| Active nav item | Liquid `page.url == item.url` | none |
| Older / Newer | `page.previous` / `page.next` | none |
| TREE (table of contents) | kramdown `* TOC` + `{:toc}`, with `kramdown.toc_levels: "2"` and `auto_ids` in `_config.yml`. The layout moves the generated `ul#markdown-toc` into the aside with one Liquid `split` on that fixed id. | Chosen over a Liquid split on every `<h2 id="`: kramdown builds the list, ids and escaping itself, and our code only relocates one element with a stable id. Jekyll 3 has no `toc_only` filter. Kramdown places the TOC where the marker is, so a small relocation is still needed for a sticky side column. Posts without the marker get the "Overview" fallback. |
| Load more | Liquid renders all rows; JS reveals 3 at a time | jekyll-paginate is unsuitable. It paginates only `index.html` into `/page2/`-style pages, and cannot exclude the featured post or combine with topic filtering and search, which need every row on one page. With 6 posts, server-side pages would also be near-empty. |
| Search | `data-search` attributes built by Liquid (`downcase`, `escape`) on the rendered rows; JS filters them | A `search.json` built with `jsonify` was considered. All posts are already on the home page, so it would add a fetch and a second rendering path for no benefit. Switch to `search.json` if posts are ever paginated. |
| SEO, Open Graph, canonical, title | jekyll-seo-tag `{% seo %}` | none |
| Feed | jekyll-feed (Atom at the same `/feed.xml`), `{% feed_meta %}` | Replacing the hand-written RSS 2.0 is safe: same URL, and feed readers accept Atom. Entry ids become the https post URLs; since T09 also moves `url` to https, existing subscribers may see old posts once more either way. |
| Sitemap | jekyll-sitemap; `defaults` `sitemap: false` for the Google verification file | none |
| Copyright year | `site.time \| date: '%Y'` | none |
| Theme toggle, keyboard shortcuts, mobile menu, tab filter, load more, search UI, reading progress, active TREE link | `assets/js/site.js` (vanilla, no build) | These are runtime behaviours with no Jekyll equivalent. Keep the file small, aiming for under about 250 lines. |
| Favicon | static `favicon.svg` (text monogram) | none |
