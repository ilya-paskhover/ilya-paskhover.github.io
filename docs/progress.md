Next task: T12

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

## QA report T06

TASK: T06
VERDICT: PASS
COMMANDS:
- (test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb) -> exit 0
- (docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/home_intro_test.rb) -> exit 0
- (docker compose down) -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (1280x800): The left column shows the heading "Ilya Paskhover" in monospace and the tagline "Notes, apps and AI agents from a senior software developer with more than 15 years of experience." It also shows three lines, each starting with "└". The topic tabs and post rows are in the right column. By eye the right column is about 768px wide and the left about 360px, so roughly twice as wide. This matches the step.
- Step 2: Below the post rows, a "Featured projects" section shows 3 cards in a row: Shallow Whale, Interactive AI CV and YouTube Videos Summarizer. A "View all projects" link follows. This matches the step.
- Step 3: Clicking "View all projects" loaded /projects/. After going back, clicking the Shallow Whale card loaded /shallow-whale/. This matches the step.
- Step 4 (375x800, reloaded): The heading and tagline sit above the tabs and rows in a single column, and the project cards are stacked. The full-page screenshot is exactly 375px wide, so there is no horizontal scrollbar. This matches the step.
- Console: the only error was a 404 for /favicon.ico, which is a browser resource and not from the app's own code, so it is noted only. There were no other errors.
CHANGES:
 _sass/_writing.scss     | 67 +++++++++++++++++++++++++++++++++++++++++++++++++
 docs/tasks.json         |  2 +-
 index.html              | 21 +++++++++++++++-
 test/home_intro_test.rb | 50 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 138 insertions(+), 2 deletions(-)

## QA report T07

TASK: T07
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T07) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/post_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (base44-projects at 1280x800): OK. 'All writing', chip 'Apps', large title 'Base44 projects', lead paragraph, and mono columns AUTHOR / PUBLISHED / READING TIME with '└ Ilya Paskhover', '└ May 23, 2025', '└ 1 min'.
- Step 2: OK. A thin full-width line sits below the header. The left side shows 'TREE' with 'Interactive AI CV' and 'Epoch converter', each with an L-shaped connector. Below that are a block-glyph bar with a percentage and 'PRESS ↑ / ↓ TO SCROLL'. The body is a narrow column and does not repeat the contents list.
- Step 3: OK. Clicking 'Epoch converter' scrolled to that section and put '#epoch-converter' in the URL. The TREE entry became bold and the percentage read 100%, which is above 00%. The aside stayed in view at the top of the viewport after the scroll. In the long Jekyll post the aside also stayed at the top of the viewport after PageDown, so it is sticky.
- Step 4 (ai-agents, scrolled to the bottom): OK. 'Older' links to 'Base44 projects' and 'Newer' links to 'Vibe coding apps'. Below them is a box 'Let's work together' with a 'Get in touch' link. Clicking 'Newer' loaded /2025/11/22/vibe-coding-apps.html (title 'Vibe coding apps').
- Step 5 (welcome-to-jekyll): OK. 'This is an archived note from 2016.' appears in the header area, and the TREE shows a single entry 'Overview'.
- Observation, not a step failure: on all three pages tested, the progress bar read 100% at scroll position 0. Each page's body ends within or near the first viewport. The long Jekyll post still showed 100% after PageDown, and I did not see a value below 100% at any point. I could not check a mid-scroll percentage or a change in the active TREE entry on a post long enough to scroll with several sections. The bar's percentage is therefore not demonstrated to vary with scroll.
- Console: one error, 404 on /favicon.ico (browser resource, noted only). No errors from the app's own code or API calls.
CHANGES:
 _config.yml                                 |   3 +
 _includes/post-tree.html                    |  15 ++
 _layouts/post.html                          |  68 ++++++++-
 _posts/2025-05-23-base44-projects.markdown  |  18 ++-
 _posts/2025-06-24-ai-agents.markdown        |  11 +-
 _posts/2025-11-22-vibe-coding-apps.markdown |  11 +-
 _sass/_post.scss                            | 222 ++++++++++++++++++++++++++++
 assets/js/site.js                           |  48 ++++++
 css/main.scss                               |   1 +
 docs/tasks.json                             |   2 +-
 test/post_test.rb                           |  62 ++++++++
 11 files changed, 449 insertions(+), 12 deletions(-)

## QA report T08

TASK: T08
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T08) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/about_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (1280x800, key 'a' from /): navigated to /about/. The page shows the chip ABOUT, the h1 About and a lead paragraph. Three mono columns ROLE, EXPERIENCE and ELSEWHERE hold "Senior software developer", "15+ years", and the links LinkedIn and GitHub. OK.
- Step 2: the intro paragraph contains "more than 15 years of experience". The section "What I work on" has 3 rows divided by thin lines: AI agents and automation, Web apps and prototypes, Systems and fundamentals. OK.
- Step 3: the section "Selected projects" shows 3 cards: Shallow Whale, Interactive AI CV, YouTube Videos Summarizer. Clicking the Shallow Whale card loaded /shallow-whale/. Back returned to /about/. OK.
- Step 4: a box at the bottom has the links "Get in touch" and "GitHub". At 375x800 the meta columns, rows and cards stack in one column. The full-page screenshot is 375 px wide, so there is no horizontal overflow. OK.
- Console: 1 error, a 404 for /favicon.ico. It comes from the browser, so it is noted only. There are no app errors.
CHANGES:
 _layouts/about.html | 60 +++++++++++++++++++++++++++++++++++++++++++
 _sass/_about.scss   | 74 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 about.md            | 13 +++++++---
 css/main.scss       |  1 +
 docs/tasks.json     |  2 +-
 test/about_test.rb  | 50 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 196 insertions(+), 4 deletions(-)

## QA report T09

TASK: T09
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T09) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/meta_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER:
1. / tab title: 'Ilya Paskhover | Senior software developer'. Matches.
2. /about/ title 'About | Ilya Paskhover'; /projects/ title 'Projects | Ilya Paskhover'; /2025/06/24/ai-agents.html title 'AI agents | Ilya Paskhover'. All start with the expected text.
3. /feed.xml renders the Atom feed and includes the entries 'Vibe coding apps' and 'Base44 projects', with https://ilya-paskhover.github.io links. /sitemap.xml lists https://ilya-paskhover.github.io/about/ and https://ilya-paskhover.github.io/projects/.
4. /favicon.svg renders the letters 'IP' in orange on a near-black rounded square, with no other artwork. The browser_navigate call to the .svg timed out after 30s (a tool quirk), but the page loaded and the screenshot confirmed the rendering.
Console errors, all sessions: 1. 404 for http://localhost:14000/favicon.ico. This is the browser's automatic request when the bare favicon.svg document was opened, so it comes from the browser and is noted only. No errors from app code or its own API calls. The earlier favicon 404 on regular pages is gone.
CHANGES:
 _config.yml         | 22 ++++++++++++++++++++--
 _includes/head.html |  8 ++++----
 docs/tasks.json     |  2 +-
 favicon.svg         |  1 +
 feed.xml            | 30 ------------------------------
 test/meta_test.rb   | 43 +++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 69 insertions(+), 37 deletions(-)

## QA report T10

TASK: T10
VERDICT: PASS
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T10) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/content_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (linux-kernel-course post): the list has 4 bullets and none is empty. The text reads "...include /sbin directory as well", so "direcroy" is gone.
- Step 2 (about-this-blog post): the note reads "for running Jekyll server (with jekyll serve –watch) I had to enter 'code/jekyll' directory." "with" is spelled correctly and "wiht" is gone. One small difference from the step as written: the browser shows "–watch" with a typographic en dash, not "--watch". I judged this as the site's smart-quote rendering, not a typo, and did not count it as a failure. The caller may want to confirm that.
- Console: 1 error, a 404 on http://localhost:14000/favicon.ico. This is a browser request for a missing favicon, so it is noted only. There are no errors from the app's own code.
CHANGES:
 README.md                                          | 72 ++++++++++++++++++++--
 _posts/2016-03-17-about-this-blog.markdown         |  2 +-
 ...-small-summary-for-linux-kernel-course.markdown |  9 ++-
 docs/tasks.json                                    |  2 +-
 test/content_test.rb                               | 33 ++++++++++
 5 files changed, 106 insertions(+), 12 deletions(-)

## QA report T11 (attempt 1)

TASK: T11
VERDICT: FAIL
COMMANDS:
- (T00 smoke) test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb -> exit 0
- (T11) docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/a11y_test.rb -> exit 0
- docker compose down -> exit 0
FAILURE OUTPUT: none (both verify commands exit 0: smoke 5 runs, 146 assertions, 0 failures; a11y 7 runs, 765 assertions, 0 failures)
BROWSER:
- Step 1 (Tab order at 1280x800): PASS. Tab order was Skip to content, Ilya Paskhover, Home, Projects, About, GitHub, Get in touch, theme toggle, then the All tab. Screenshots of the skip link and the theme toggle show a visible accent-coloured (orange) outline. The other elements were confirmed focused through the snapshot's active marker.
- Step 2 (accessible names): FAIL on a literal reading. The nav links are named "Home", "Projects", "About", and the [H]/[P]/[A]/[G] hints are not part of the names. But the GitHub link is named "GitHub (opens in a new tab)", not "GitHub", because of an added visually hidden "(opens in a new tab)" span. "Get in touch" and the other external links carry the same suffix. The "All" tab is reported as [pressed], as required.
- Step 3 (shortcut switch): PASS. The footer button "Keyboard shortcuts: on" changed to "Keyboard shortcuts: off". Pressing 'a' kept the page on /. Clicking again gave "Keyboard shortcuts: on", and pressing 'a' loaded /about/.
- Step 4 (one h1 per page): PASS. Each of the four pages has exactly one level-1 heading: / has "Ilya Paskhover", /projects/ has "Projects", /about/ has "About", and the base44 post has "Base44 projects".
- Console: one error, a 404 for /favicon.ico. That is a browser resource, not app code, so it is noted only. No errors from app code.
- The only failure is the step 2 naming difference. The hidden "(opens in a new tab)" text is arguably an intended accessibility improvement, but it differs from the acceptance text, which names the links 'GitHub'. Decide whether to amend the acceptance wording or the markup.
CHANGES:
 _includes/footer.html |  1 +
 _sass/_footer.scss    | 13 +++++++
 assets/js/site.js     | 15 ++++++++
 docs/tasks.json       |  2 +-
 test/a11y_test.rb     | 94 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 124 insertions(+), 1 deletion(-)

## QA report T11

TASK: T11
VERDICT: PASS
COMMANDS:
- ( test -z "$(git status --porcelain -- shallow-whale/)" && docker compose up -d --build --force-recreate --wait && curl -sf -o /dev/null http://localhost:14000/ && docker compose exec -T site bundle exec ruby -Itest test/smoke_test.rb ) -> exit 0
- ( docker compose up -d --build --force-recreate --wait && docker compose exec -T site bundle exec ruby -Itest test/a11y_test.rb ) -> exit 0
- ( docker compose down ) -> exit 0
FAILURE OUTPUT: none
BROWSER:
- Step 1 (1280x800): Tab order was Skip to content, Ilya Paskhover, Home, Projects, About, GitHub, Get in touch, theme toggle, All tab. I checked each stop by the [active] marker in the accessibility tree. I confirmed the visible accent-coloured (orange) outline on a screenshot at Home. I did not screenshot each of the other stops.
- Step 2: The accessible names are exactly "Home", "Projects", "About", "GitHub" and "Get in touch". The "[H]" style hints are not part of the names. The "All" tab is reported as button "All" [pressed]. The snapshot also shows a banner-level text node "Opens in a new tab", which is the aria-describedby target. It is not part of any link name.
- Step 3: Clicking "Keyboard shortcuts: on" changed it to "Keyboard shortcuts: off". Pressing "a" left the page on /, with a single tab. Clicking the button again gave "Keyboard shortcuts: on" [pressed]. Pressing "a" then loaded /about/.
- Step 4: / has one level-1 heading, "Ilya Paskhover". /projects/ has one, "Projects". /about/ has one, "About". /2025/05/23/base44-projects.html has one, "Base44 projects".
- Console: one error, 404 for /favicon.ico. That is a browser resource, not app code, so it is noted only. There are no app errors and no warnings.
- The stack was left stopped with docker compose down.
CHANGES:
 _includes/footer.html |  1 +
 _includes/header.html |  5 +--
 _sass/_footer.scss    | 13 +++++++
 assets/js/site.js     | 15 ++++++++
 docs/progress.md      | 24 +++++++++++++++++++++++
 docs/tasks.json       |  2 +-
 test/a11y_test.rb     | 94 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 7 files changed, 151 insertions(+), 3 deletions(-)
