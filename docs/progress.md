Next task: T06

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

## QA report T01

TASK: T01
VERDICT: PASS
COMMANDS:
- smoke (T00 verify) -> exit 0
- docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/foundation_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER: Steps 1 to 4 PASS (dark background, off-white text; Skip to content visible on Tab and URL ends #main; inline code bordered mono and code block hairline; no horizontal overflow at 375x800, code box did not need to scroll). Console: only 404 /favicon.ico (T09).
CHANGES: 8 files changed, 261 insertions(+), 174 deletions(-) (tokens, base, syntax, layout shell, foundation test, tasks.json).

## QA report T02

TASK: T02
VERDICT: PASS
COMMANDS:
- ( test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb ) -> exit 0
- ( docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/header_test.rb ) -> exit 0
- ( docker compose down ) -> exit 0
- ( git diff --cached --stat ) -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (1280x800, /): header shows mono 'Ilya Paskhover' at left with no logo image. Nav shows '[H] HOME' (bold), '[P] PROJECTS', '[A] ABOUT', '[G] GITHUB'. At the right is a solid light 'Get in touch ›' button. No Menu button is visible.
- Step 2 (keys): 'a' loaded /about/ and '[A] ABOUT' became the bold item. 'p' loaded /projects/, which lists 'Shallow Whale' (and 'Interactive AI CV'). 'h' loaded /.
- Step 3 (theme): clicking 'Switch to light theme' gave a near-white background with dark text. After a reload it stayed light and the toggle read 'Switch to dark theme'. Clicking it returned the page to dark.
- Step 4 (375x800 reload): header shows 'Ilya Paskhover', the theme toggle and a 'MENU' button. The nav items are hidden. Clicking Menu opened a panel with HOME, PROJECTS, ABOUT, GITHUB and 'Get in touch ›'. Escape closed the panel and Menu was collapsed (screenshot shows the panel gone and focus back on the Menu button). The snapshot showed no expanded state on the button. I did not read aria-expanded directly, and the tools I'm allowed don't expose it.
- Step 5 (375x800): Menu then ABOUT loaded /about/ with the panel closed.
- Cosmetic note: when the mobile panel is open, its top edge overlaps the bottom of the header bar slightly. This does not contradict any acceptance step.
- Console errors: only 'Failed to load resource: 404 /favicon.ico', which is a browser resource and is noted only. No app errors.
CHANGES:
 _data/navigation.yml  |  13 +++++++
 _data/profile.yml     |  10 +++++
 _data/projects.yml    |  35 +++++++++++++++++
 _includes/head.html   |   1 +
 _includes/header.html |  29 +++++----------
 _sass/_header.scss    | 101 ++++++++++++++++++++++++++++++++++++++++++++++++++
 _sass/_layout.scss    |  90 --------------------------------------------
 assets/js/site.js     |  61 ++++++++++++++++++++++++++++++
 css/main.scss         |   1 +
 docs/tasks.json       |   2 +-
 projects.md           |  10 +++++
 test/header_test.rb   |  52 ++++++++++++++++++++++++++
 12 files changed, 295 insertions(+), 110 deletions(-)

## QA report T03

TASK: T03
VERDICT: PASS
COMMANDS:
- (test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb) -> exit 0
- (docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/footer_test.rb) -> exit 0
- (docker compose down) -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (1280x800, bottom of /): a thin divider sits above the footer. The footer shows "Ilya Paskhover" with the tagline "Senior software developer". The Site column has Home, Projects, About and RSS. The Elsewhere column has GitHub and LinkedIn. All of it is in a monospace face. The last line reads "© 2026 Ilya Paskhover. Built with Jekyll." Matches.
- Step 2: clicking the footer RSS link went to http://localhost:14000/feed.xml. The page shows feed XML containing the title "Vibe coding apps". Matches.
- Step 3 (375x800, bottom of /): the columns are stacked vertically in this order: wordmark, Site, Elsewhere, copyright. All links are fully visible. No horizontal scrollbar was visible in the screenshot. Matches.
- Console errors: only a 404 for /favicon.ico, a browser resource. Noted, not a failure. No app errors.
CHANGES:
 _includes/footer.html | 64 +++++++++++++++-------------------------------
 _sass/_footer.scss    | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++
 _sass/_layout.scss    | 65 +---------------------------------------------
 css/main.scss         |  1 +
 docs/tasks.json       |  2 +-
 test/footer_test.rb   | 45 ++++++++++++++++++++++++++++++++
 6 files changed, 139 insertions(+), 109 deletions(-)

## QA report T04

TASK: T04
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T04) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/projects_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER:
- 1280x800 /projects/: left column has the heading "Projects" and "Apps, games and AI agents I have built." The right column has 5 rows with thin dividers. Row 1 is Shallow Whale with "A simulated crypto trading game. No ads, no purchases, no real money.", mono chips Game and PWA, and the mono label "Web game" at the right. The chips and label render uppercase, which I take to be CSS text-transform, since the snapshot text is "Game", "PWA" and "Web game". "[P] PROJECTS" is bold in the header.
- Link names in the snapshot: "Epoch Converter (opens in a new tab)" ends with the suffix. "Shallow Whale" has no suffix. The other external links also carry the suffix, and Math Bubbles does not.
- Clicking the Math Bubbles title loaded /assets/html_apps/math_bubbles.html in the same tab. Going back returned to /projects/. Clicking the Shallow Whale title loaded /shallow-whale/ with the tab title "Shallow Whale".
- 375x800: the heading is above the rows in one column. All 5 rows are fully visible in the full-page screenshot, and I saw no horizontal scrollbar.
- Console: 0 errors.
CHANGES:
 _includes/project-card.html |   5 ++
 _includes/project-link.html |   6 ++
 _includes/project-row.html  |  12 ++++
 _layouts/projects.html      |  14 +++++
 _sass/_projects.scss        | 145 ++++++++++++++++++++++++++++++++++++++++++++
 css/main.scss               |   1 +
 docs/tasks.json             |   2 +-
 projects.md                 |   8 +--
 test/projects_test.rb       |  50 +++++++++++++++
 9 files changed, 236 insertions(+), 7 deletions(-)

## QA report T05

TASK: T05
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T05) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/writing_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER: 1280x800.
- Step 1: The feed matched the acceptance text. Tabs ALL (bold), AI AGENTS, APPS, NOTES. Featured chip, "Vibe coding apps", "Ilya Paskhover · Apps", and "1 minute" at the right. Exactly 3 rows with thin dividers: AI agents (Jun 24, 2025), Base44 projects (May 23, 2025), "A small summary of 'Linux Kernel' course - day 2!". Each row had "1 minute" at the right. LOAD MORE at the left and "Press R to load more" at the right.
- Step 2: A real click on LOAD MORE added "About this blog!" and "Welcome to Jekyll!" below the rows. The button and its hint were gone. After a reload, pressing "r" added the same two rows.
- Step 3: After a reload, clicking APPS made it the bold, pressed tab. Only the featured "Vibe coding apps" and "Base44 projects" showed, and LOAD MORE was hidden. Clicking NOTES showed the three 2016 posts and hid the featured row. Clicking ALL restored the featured row, the 3 rows and LOAD MORE with its hint.
- Step 4: Clicking "AI agents" loaded /2025/06/24/ai-agents.html. The page heading was "AI agents" (h1).
- Console: no JS errors from the app. The only error was a 404 for /favicon.ico, which comes from the browser and is noted only.
CHANGES:
 _config.yml                                        |   8 ++
 _includes/post-row.html                            |   8 ++
 _includes/reading-time.html                        |   4 +
 _posts/2016-03-17-about-this-blog.markdown         |   2 +
 ...-small-summary-for-linux-kernel-course.markdown |   2 +
 _posts/2016-03-17-welcome-to-jekyll.markdown       |   2 +
 _posts/2025-05-23-base44-projects.markdown         |   2 +
 _posts/2025-06-24-ai-agents.markdown               |   2 +
 _posts/2025-11-22-vibe-coding-apps.markdown        |   3 +
 _sass/_writing.scss                                | 146 +++++++++++++++++++++
 assets/js/site.js                                  |  51 ++++++-
 css/main.scss                                      |   1 +
 docs/tasks.json                                    |   2 +-
 index.html                                         |  51 +++++--
 test/writing_test.rb                               |  62 +++++++++
 15 files changed, 332 insertions(+), 14 deletions(-)
