# Databeers #15 — ESB-vaktin og Þingfréttir

Deck slug: `databeers15`
Talk date: 2026-05-27
Repo: not yet created (will be `metill-is/databeers15` when published)
Public URL: `metill.is/databeers15` (post-publish)

## Workflow status

Per [`~/talks/.claude/skills/slide-workshop/SKILL.md`](../../.claude/skills/slide-workshop/SKILL.md):

| Step                                          | Status               |
| --------------------------------------------- | -------------------- |
| 0 — Skeleton + Metill brand applied           | ✓ done 2026-05-26    |
| 1 — Rough sequence                            | ✓ done 2026-05-26    |
| 2 — Conversation / framing                    | ✓ done 2026-05-26    |
| 3 — Audience artefact (4 sentences)           | ✓ done 2026-05-26    |
| 4 — Computation plan                          | ✓ done 2026-05-26    |
| 5 — Slide map                                 | ✓ done 2026-05-26    |
| 6 — Render-and-check (deliberate visual pass) | ✓ done 2026-05-26    |
| 7 — Draft slide-by-slide                      | ✓ done 2026-05-26    |
| 8 — Post-talk annotated pass                  | □ (after 2026-05-27) |

## Audience

Captured 2026-05-26 from step 3 conversation (Facebook event copy +
user's calibrated estimate from two prior Databeers appearances).
Paste these four sentences into every subsequent prompt as deck
context.

1. **Who.** ~60–100 mingling Databeers Reykjavik regulars — a
   grab-bag of Iceland's data / ML / AI / data-infrastructure
   crowd, mixed industry + academia + government — warmed up by
   ~30+ min of free drinks and food before talks start.
2. **How long.** ~7-minute talk (loose 20×20; napkin-math timing
   acceptable at this point in the user's Databeers experience),
   followed by **liberal Q&A** — the talk doesn't need to address
   every edge case, Q&A picks up the rest.
3. **Format.** Lightning talk on a 4-speaker bill at Databeers #15
   (Brynjólfur's 3rd appearance). Event copy primed the audience
   for "LLM-based fact checkers, highly pertinent in this day and
   age" — a narrower framing than the trustworthiness thesis the
   talk actually carries.
4. **Venue / context.** Wednesday 2026-05-27, 17:30, at **Ölgerðin
   Egill Skallagrímsson** — Iceland's most legendary brewery
   (Databeers in a brewery: on-the-nose). Co-speakers: Margrét
   Otterstedt (Landspítali, hospital data democratisation), Arnar
   Arinbjarnarson (taxpayers' association, probable civic-data
   adjacency), Davíð Már Sigurðsson (Ölgerðin host, corporate
   retail data). Two of the four talks (Brynjólfur, Arnar) are
   civic-data-for-public-good; the other two are
   institutional/corporate. 275 Facebook RSVPs (Iceland-Facebook
   overcount, hence the 60–100 realistic estimate).

### Implications for downstream steps

Hard constraints and opportunities this audience creates for
steps 4 (computation plan), 5 (slide map), and 7 (drafting):

- **Delivery language: English.** Decided at step 4. Drives
  translation work for ESB-vaktin reuse from the (Icelandic)
  Nordic House talk: pipeline labels, worked example, headline
  card gloss, and three closing tips all need English versions.
- **Slides-as-billboards is now a hard constraint.** Warm, mingled,
  drinking audience + 20-sec/slide budget ⇒ each slide must work
  as a single visual hook with big text. No dense numbers, no
  paragraphs, no multi-panel charts. One big number / one
  stripped-back chart / one screenshot per slide. This drives the
  computation plan more than originally predicted. Prior Databeers
  decks (Databeers #1, #12) confirm the aesthetic — section
  heading + one image is the dominant pattern; voice carries
  meaning.
- **"LLM fact-checker" priming is a pivot opportunity, not a
  problem.** Audience walked in with one framing; talk delivers a
  broader one. The "An LLM is a tool" reframe (already queued as a
  candidate slide) is now even better positioned as the talk's
  hinge moment — it directly engages the framing the audience was
  given.
- **Liberal Q&A absorbs unfinished threads.** Step 5's slide map
  doesn't have to finish every arc. Provocative or
  under-developed bits — especially the taste / Design Thinking
  secondary thread — can be planted in-talk and elaborated in Q&A.
- **Co-speaker thematic adjacency (Arnar).** Two civic-data talks
  on the bill creates either redundancy or contrast (solo-builder
  vs institutional). Worth finding out the running order before
  step 5 — affects whether to lean into novelty (if Brynjólfur
  goes after Arnar) or set up a foil (if before).
- **Venue gag (optional, risky).** Ölgerðin is named after Egill
  Skallagrímsson — Iceland's most famous saga rhetorician AND a
  self-promoter / unreliable narrator, almost the antithesis of
  "demonstrate trustworthiness." A throwaway aside could land
  brilliantly with this crowd, but requires the cultural
  reference to land in seconds. Only worth using if user wants it.

## Framing

Captured 2026-05-26 from step 2 conversation. User-approved spine
(reads well per user); voice signal preserved.

> "Don't try to increase trust — demonstrate trustworthiness"
> (Spiegelhalter, O'Neill) is the design principle behind
> ESB-vaktin and Þingfréttir, and it's also the principle behind
> this talk. People are often afraid of AI/LLMs being used
> maliciously to misinform; these projects explore what it looks
> like to do the opposite. They're built so their outputs are
> trustworthy the way any tool's outputs should be — methods
> verifiable, failures loud, paper trails followable.

_Secondary thread — taste / design thinking._

Originally drafted as a tail on the framing paragraph; dropped
because it didn't flow from trustworthiness. To develop as its own
thread elsewhere in the talk (not in the headline framing).
References to draw from:

- Garry Tan (and others) on taste being more important in the LLM
  era.
- Hillary Parker and Roger Peng on _Not So Standard Deviations_:
  data analysis as Design Thinking; Hillary has argued Design
  Thinking will be extra important in the age of LLMs.

If this becomes a slide or short section, anchor it in the external
references (same trick the trustworthiness thread uses with
Spiegelhalter / O'Neill / Harford) rather than as a first-person
claim about the user's own taste. Both threads then share the same
structural form — _"here's what these thinkers have argued; here's
how it shows up in the work"_ — which solves the awkwardness of
claiming good taste out loud (Jante etc.) and gives the deck
parallel structure across its two intellectual anchors.

## Rough sequence

Captured verbatim from step 1 conversation (2026-05-26). User's
words, lightly sectioned for navigation only — do NOT paraphrase
or restructure when drafting slides at step 7. The phrasing here
is the voice signal.

_Personal positioning._

As a statistician, I've found myself to be a "hater" of new
technologies and modeling approaches if they get too much hype. I
take my time and pick up new techs slowly. So, it almost was a
surprise to me as I started really using claude code a lot this
year how much I could do. Þingfréttir and ESB Vaktin were partly
created just as a test of what I could do, but I also always have
a sort of sense of duty to try to help inform people.

_Þingfréttir._

Started out as "What if I could connect Claude to the Alþingi XML
and ask questions about the data?" It then grew into trying to
create an English pundit based on Claude that helps people stay
up to date on the workings of Alþingi but in a fun way. I didn't
expect the Icelandic to work this well, but some tricks and using
Miðeind tools along with reviewing the text manually (but
quickly — don't want to edit the writing too much) has really
helped. Claude and I then developed the tables, data viz, etc.
that are seen.

_ESB-vaktin._

Grew out of a thought: "People are often afraid of AI/LLMs being
used maliciously to misinform. Why can't we just do the
opposite?" Built over a very short time after the referendum was
announced. Works via several linked steps:

1. Scrape and store articles/writing
2. Process articles for claims and store them
3. Compare claims to evidence database
4. Update evidence database if needed
5. Repeat

This creates a database that can then be used to summarise the
information. At the start, I framed some statistics as calculating
how trustworthy people are etc., but following what Tim Harford
has said, we can't fix misinformation by only fact checking. If we
only fact check and make everyone out to be untrustworthy, we'll
just end up believing no one — and that's what can lead to
conspiracy theories and polarisation. Instead, the site's goal is
to try to increase curiosity ("what actually is known?") and to
give readers confidence in themselves ("this is something I could
actually know").

_Theoretical anchor — trust._

I'm driven a lot by what David Spiegelhalter and Onora O'Neill
have said about trust. You shouldn't try to increase trust. You
should demonstrate trustworthiness. This is done by being
vulnerable — by that I mean: fail loudly and publicly, and make it
easy for the reader to check what's going on under the hood and to
follow paper trails of evidence.

_Closing — three tips._

From Tim Harford, David Spiegelhalter, and Onora O'Neill:

1. Does this make me feel emotional? (If so, take a minute and
   ingest the information later.)
2. Is someone trying to inform me, or to persuade me?
3. Don't try to increase trust — demonstrate trustworthiness.

## Computation plan

Locked 2026-05-26 from step 4 conversation (user signed off).
Delivery in English. Numbers strategy: use Nordic House April
counts (343 articles / 2,154 claims / 499 sources) with a verbal
"as of April, now higher" aside — user may refresh with current
counts before delivery if available. The Nordic House counts came
from frozen CSVs at `~/esbvaktin/talks/nordic-house-2026/R/data/`,
not a live DB query, so a refresh requires re-running the pipeline.

### Existing artefacts to reuse from `~/talks/metill/nordic-house-2026/`

- `figures/verdicts.svg` — verdict-quality chart (slide 12).
  Check whether Icelandic axis labels are baked into the SVG; may
  need re-export with English labels.
- 4-step pipeline diagram laid out as HTML/CSS in
  [index.qmd](talks/metill/nordic-house-2026/index.qmd) lines
  49–87 (slide 10) — needs English translation.
- Worked claim → evidence → verdict example in
  [index.qmd](talks/metill/nordic-house-2026/index.qmd) line 87
  (slide 11) — needs English translation. The example: "Ísland
  hafi innleitt 80% af regluverki ESB" → EEA-LEGAL-001,
  EEA-DATA-017, EEA-LEGAL-006 → "að hluta staðfest".
- viðræður/aðild headline cards in
  [index.qmd](talks/metill/nordic-house-2026/index.qmd) lines
  27–45 (slide 9) — pick ONE for Databeers (audience can't read
  5 in 20 sec); needs English gloss.
- Three closing tips in
  [index.qmd](talks/metill/nordic-house-2026/index.qmd) lines
  116–135 (slide 15) — needs English translation, otherwise
  drop-in. Attribution: Harford / Spiegelhalter / O'Neill.

### Existing artefacts to reuse from other projects

- `~/althingi/althingi-content/weekly/output/2026-05-18/post_en.html`
  — most-recent English-pundit weekly piece. Title: _"L157 #12:
  Three Days, One Question."_ Custom excerpt: _"Session 157 weekly
  digest: 25 votes, 499 speeches, 12 committee meetings."_ Feature
  on slide 5.
- `~/sirkabat/assets/logo.png` and `~/sirkabat/assets/Gimaldid_Logo.svg`
  — Sirkabát + Gimaldid co-brand visuals for slide 2 (landscape).
- A representative chart from
  `~/althingi/althingi-content/weekly/chart_*.py` (slide 6) —
  pick at draft time; vote / speech / trend / legislation are
  candidates.

### Needs generating / picking at step 7

- 4 logos/screenshots for the landscape slide (slide 2): Metill.is,
  ESB-vaktin, Þingfréttir, Sirkabát.
- thingfrettir.is section-divider screenshot (slide 4).
- esbvaktin.is section-divider screenshot (slide 8).
- Photos for the three thinkers — Spiegelhalter, O'Neill, Harford
  (slide 14).
- "An LLM is a tool" text slide content (slide 13) — author's
  step-2 phrasing in ≤10 words, matching the Databeers#1
  "Trustworthiness: Open / Accessible / Intelligible / Useable"
  precedent.

### Numbers reference (Nordic House, 14 April 2026)

- 343 articles scraped
- 2,154 claims extracted
- 499 evidence sources cross-referenced

## Slide map

Locked 2026-05-26 — step 5 complete. Slide-critic reviewed the
draft 16-slide map; user accepted all three proposed cuts (drop
transition slide #3, drop dedicated Miðeind slide #7 — now
layered as a fragment on the chart slide — and drop pipeline
diagram #10, with its counts moved to the worked-example
slide as a caption). Final: **13 slides + optional 14th**
(fail-loudly demo).

| #   | Section (`data-name=`) | Slide                                | Visual                                                                 | Source / status                                                          |
| --- | ---------------------- | ------------------------------------ | ---------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| 1   | Intro                  | Title                                | "ESB-vaktin & Þingfréttir / Databeers #15"                             | needs writing                                                            |
| 2   | Intro                  | 4-project landscape                  | 4-logo / thumbnail grid (Metill.is, ESB-vaktin, Þingfréttir, Sirkabát) | logos exist; layout new                                                  |
| 3   | Þingfréttir            | Section divider — thingfrettir.is    | Screenshot of live site landing                                        | needs screenshot                                                         |
| 4   | Þingfréttir            | Recent English-pundit output         | Screenshot/excerpt of 2026-05-18 _"Three Days, One Question"_          | exists, needs cropping                                                   |
| 5   | Þingfréttir            | One Þingfréttir chart + Miðeind logo | Stripped-back chart from `chart_*.py`; Miðeind logo as fragment        | exists or quick re-cut; logo needs sourcing                              |
| 6   | ESB-vaktin             | Section divider — esbvaktin.is       | Screenshot of live site                                                | needs screenshot                                                         |
| 7   | ESB-vaktin             | viðræður/aðild hook — ONE headline   | Single headline card with English gloss                                | REUSE Nordic House lines 27–45, pick one                                 |
| 8   | ESB-vaktin             | Worked claim → evidence → verdict    | "Iceland adopted 80% of EU regulation" example + 343/2154/499 caption  | REUSE Nordic House line 87 + counts caption inheriting from cut pipeline |
| 9   | ESB-vaktin             | Verdict-quality chart                | `verdicts.svg`                                                         | REUSE; check labels for translation                                      |
| 10  | ESB-vaktin             | "An LLM is a tool" reframe           | ≤10-word big-text slide                                                | needs writing — author's step-2 phrasing                                 |
| 11  | Closing                | Three thinkers — photos + names      | Spiegelhalter / O'Neill / Harford photos                               | needs sourcing photos                                                    |
| 12  | Closing                | Three tips                           | Three lines, big text, fragmented entrance                             | REUSE Nordic House lines 116–135, translate to EN                        |
| 13  | Closing                | Thank-you + links                    | metill.is, esbvaktin.is, thingfrettir.is, Sirkabát URL                 | needs writing                                                            |
| 14  | (optional)             | Fail-loudly / paper-trail demo       | Live esbvaktin.is screenshot showing uncertainty                       | optional headroom                                                        |

## Iteration log

| date       | change                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           | why                                                                                                                                                                               |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-05-26 | Skeleton created in `talks/metill/databeers15/`, Metill brand applied                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | Initial scaffolding                                                                                                                                                               |
| 2026-05-26 | Per-deck CLAUDE.md initialised; slide-workshop workflow wired up at ~/talks/                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | Ready to enter step 1                                                                                                                                                             |
| 2026-05-26 | Step 1 captured — rough sequence dumped verbatim                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Voice preserved for step 7 reuse                                                                                                                                                  |
| 2026-05-26 | Step 2 captured — trustworthiness as headline thesis, taste split to its own secondary thread, "LLM is a tool" reframe queued as candidate slide                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 | Framing tight; taste anchored in external references avoids first-person taste claim                                                                                              |
| 2026-05-26 | Step 3 captured — Databeers #15 audience artefact + downstream implications (slides-as-billboards constraint, LLM-fact-checker pivot opportunity, Q&A absorbs unfinished threads, civic-talk adjacency with Arnar)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Audience state (mingled, drinking, primed) now hardens the visual + structural constraints for steps 4–7                                                                          |
| 2026-05-26 | Steps 4–5 locked — computation plan + 16-slide map; delivery in English; landscape slide adds Metill.is + Sirkabát alongside ESB-vaktin + Þingfréttir; Nordic House April numbers (343/2154/499) with verbal aside; minimal-content Databeers aesthetic per prior decks #1 and #12                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Plan ready for slide-critic review; awaiting critique before step 6 (render-check)                                                                                                |
| 2026-05-26 | Step 5 complete — slide-critic reviewed; user accepted all 3 proposed cuts (transition slide #3, dedicated Miðeind slide #7 → fragment on chart slide, pipeline diagram #10 → counts caption on worked-example). Final: 13 slides + optional 14th                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | Density risk in ESB-vaktin core resolved; "voice carries transitions" principle applied; ready for step 6 render-check                                                            |
| 2026-05-26 | Step 6 complete — `quarto render` succeeded; title + content slide screenshots verified via Claude_in_Chrome MCP. Metill brand applied (Pappír background, Fraunces headings, footer link, simplemenu bar on content slides). Two minor flags: (a) Chrome MCP rejects `file://` so `python3 -m http.server` in `docs/` is the workflow; (b) body text appears serif in screenshots — confirm Source Sans 3 is loading before slide drafting                                                                                                                                                                                                                                                                                                                                                                                                      | Ready for step 7 (slide-by-slide drafting)                                                                                                                                        |
| 2026-05-26 | Step 7 complete — all 13 slides drafted across batches A/B/C/D. Reused Nordic House assets (verdicts.svg, viðræður/aðild hook, worked example, three tips). New artefacts: thingfrettir-landing.png, thingfrettir-article.png, thingfrettir-charts.png (cropped from tall article screenshot), esbvaktin-landing.png. Slide-critic pass after Batch D produced 4 proposed edits; 3 accepted (slide 10 "Verify the methods / Fail loudly" punchier hinge, slide 8 cut Article block to reduce density, slide 11 re-cut tags to align with slide 12 quotes), 1 declined (O'Neill em-dash polish — kept verbatim from rough sequence to preserve voice). Numbers refreshed from live esbvaktin.is (503 / 2,673 / 516 vs. Nordic House's 343 / 2,154 / 499). Body-font serif issue and optional slide 14 deferred to polish pass                     | Deck draft complete; ready for user visual review                                                                                                                                 |
| 2026-05-26 | Step 7 polish pass — comprehensive theme.scss rewrite (~400 lines). Body-font fix: explicit `.reveal p / li / blockquote { font-family: $font-family-sans-serif }` (Quarto revealjs doesn't read Sass vars directly). Custom classes per slide: `.landscape-grid` + `.landscape-project` (slide 2), `.site-frame` (slides 3/4/6 screenshots), `.chart-callout` (slide 5), `.headline-quote` (slide 7), `.worked-example` + `.we-step` + `.we-verdict` (slide 8), `.reframe` + `.reframe-slide` (slide 10), `.thinkers` + `.thinker` (slide 11), `.three-tips` + `.tip` + `.attribution` (slide 12), `.thank-you` (slide 13). Brand-color usage: Jökull teal for all accents, Miðnætursól amber as one flourish on the verdict step + last reframe line. Hidden headings on Þingfréttir/ESB-vaktin section dividers (were overlapping simplemenu) | Visual polish committed; user should walk through the deck directly (Chrome MCP / revealjs navigation was flaky during testing — file is correct per `grep` on `docs/index.html`) |
| 2026-05-27 | Placement fix — every content slide was overlapping the simplemenu bar. Added a `$menubar-safe: 100px` + `$footer-safe: 55px` safe-zone padding rule on `.reveal .slides > section:not(#title-slide)`. Added flex-column centering on `.no-heading` sections that do NOT contain a `.r-stretch` child (Reveal's auto-stretch JS calculates 0×0 inside a flex container, so stretched-image slides keep default block layout). Added a `:not(.r-stretch)` height cap (`max-height: 520px`) on `.site-frame` images so slides where the screenshot is inside a `::: column` (e.g. slide 5) don't run off the top. Removed the bespoke `.reframe-slide` flex block — the general `.no-heading` rule now covers it. Also fixed the simplemenu header markup in the boilerplate: `<div class='menubar mb-10'>...<div>` → `</div>` (Quarto was warning about an unclosed div on every render). Walked through all 13 slides post-render in Chrome — clean. | Slide content was visibly clipped by the top nav and stuck at the top of every no-heading slide because the simplemenu floats at `top:0 position:absolute` and Reveal's auto-center is defeated when the leading `## ` heading is `display:none` |
| 2026-05-27 | Slide 8 (worked example) re-styled to match the Nordic House `.pipeline-example` — replaced the stacked `.we-step` cards + vertical arrows with a single horizontal flex row: labelled cells (Claim, Evidence) separated by `→` arrows, with the verdict as an amber pill chip at the end. Adopted from `talks/metill/nordic-house-2026/index.qmd:87` and the matching theme.scss block (lines 233–316), adapted to Metill tokens (Jökull teal left border + 5%-tint background, Miðnætursól amber for `.ex-verdict--partial`, Fraunces for content, Geist Mono for the `.ev-id` codes). `flex-wrap: nowrap` + `white-space: nowrap` on `.ex-content` keeps the row to one line; verified at 1492px viewport in Chrome | Slide 8 was visually heavier than the rest of the Metill family — Nordic House's single-row pipeline reads at a glance, which matches the slides-as-billboards audience constraint |
| 2026-05-27 | Slide 8 expanded — lifted the full Nordic House slide 2 (Aðferð) on top of the existing `.pipeline-example`. Now leads with the 4-step `.pipeline` diagram (Discussion → Claims → Sources → Verdict) — each step is a numbered card with a label, description, and the running count, fragmented in one at a time. The `.pipeline-example` row below shows the full worked walk-through (Article → Claim → Evidence → Verdict). Translated Icelandic → English; refreshed counts (343→503 articles, 2,154→2,673 claims, 499→516 sources). Standalone counts caption dropped — those numbers now live in the pipeline-step cards. Font sizes scaled ~35% down from Nordic House because that deck uses a 1920×1080 canvas; databeers15 inherits Reveal's 960×700 default. The pipeline-example wraps to two rows on the smaller canvas (matches Nordic House's own `flex-wrap: wrap` choice for the same reason at larger zoom) | User asked for the Nordic House method slide "lifted almost verbatim" — the 4-step + worked-example combo is the cleanest visualisation of the ESB-vaktin pipeline and was the methodology slide we'd previously cut from the slide map |
