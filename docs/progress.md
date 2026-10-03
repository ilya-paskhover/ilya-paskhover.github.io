Next task: T00

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
