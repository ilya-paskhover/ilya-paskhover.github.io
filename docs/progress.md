Next task: T01

# Progress: jekyll-ui-redesign

Plan written in adopt mode and revised twice:

- Revision 1: the design follows the user's claude.dev screenshots. It is dark-first, with mono terminal-style chrome, bracketed keyboard hints, a two-column home feed, and a post TREE with reading progress.
- Revision 2:
  - No invented artwork. The wordmark is plain text and the favicon is an "IP" text monogram.
  - Everything that can be is done with Jekyll itself: site.data, front matter defaults, Liquid filters, kramdown {:toc}, jekyll-seo-tag, jekyll-feed and jekyll-sitemap.

The plan has 15 tasks, T00 to T14, all `failing`. See `docs/poc-spec.md` (section 13 lists the Jekyll-native choices) and `docs/tasks.json`.

- Start: `docker compose up -d --build --force-recreate --wait` (site at http://localhost:14000/)
- Stop: `docker compose down`
- `shallow-whale/` must stay untouched; T00's verify fails if anything under it changes.


## QA report T00

TASK: T00
VERDICT: PASS
COMMANDS:
- test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER: Viewport 1280x800.
- Step 1, http://localhost:14000/: the page loaded. The post list has a link "Vibe coding apps" (/2025/11/22/vibe-coding-apps.html). OK.
- Step 2, click "Vibe coding apps": the post page loaded with h1 "Vibe coding apps" and a link "math bubble" (/assets/html_apps/math_bubbles.html). OK.
- Step 3, http://localhost:14000/shallow-whale/: the tab title is "Shallow Whale". OK.
- Console errors: one, "Failed to load resource: 404 /favicon.ico". Noted only (favicon comes in T09).
CHANGES: 10 files changed, 164 insertions(+), 1 deletion(-) (Docker scaffold, test harness, .gitignore, Gemfile, _config.yml exclude list, tasks.json status).
