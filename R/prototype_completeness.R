### ===========================================================================
### Prototype — visualising article completeness
### ---------------------------------------------------------------------------
### Two charts:
###  (A) completeness_scatter.png — per-article breadth × depth
###  (B) evidence_pareto.png      — cumulative citation share across evidence
###
### Run:
###   cd ~/talks/metill/databeers15
###   Rscript R/prototype_completeness.R
### ===========================================================================

options(width = 120)

library(tidyverse)
library(dbplyr)
library(DBI)
library(RPostgres)
library(scales)
library(showtext)
library(ragg)

font_add_google("Fraunces", "Fraunces")
font_add_google("Source Sans 3", "Source Sans 3")
showtext_auto()

### --- Brand + theme (trimmed copy from make_figures.R) ----------------------

metill <- list(
  jokull       = "#1B6B8A",
  jokull_soft  = "#7AA9BD",
  midnaetursol = "#C4841D",
  basalt       = "#1C1C28",
  basalt_muted = "#5A5C66",
  pappir       = "#FAFAF7",
  rule         = "#D5D8DE"
)

theme_metill <- function(base_size = 18, grid = "xy") {
  half <- base_size / 2
  grid_line <- element_line(colour = metill$rule, linewidth = 0.3)
  grid_x <- if (grid %in% c("xy", "x")) grid_line else element_blank()
  grid_y <- if (grid %in% c("xy", "y")) grid_line else element_blank()

  theme_classic(base_size = base_size, base_family = "Source Sans 3") %+replace%
    theme(
      text = element_text(family = "Source Sans 3", colour = metill$basalt),
      plot.title = element_text(
        family = "Fraunces", colour = metill$basalt,
        size = rel(1.35), hjust = 0,
        margin = margin(t = half, b = half / 2)
      ),
      plot.subtitle = element_text(
        family = "Source Sans 3", colour = metill$basalt_muted,
        size = rel(0.9), hjust = 0, margin = margin(b = half)
      ),
      plot.caption = element_text(
        family = "Source Sans 3", colour = metill$basalt_muted,
        size = rel(0.65), hjust = 1, margin = margin(t = half)
      ),
      plot.background = element_rect(fill = metill$pappir, colour = NA),
      panel.background = element_rect(fill = metill$pappir, colour = NA),
      panel.grid = element_blank(),
      panel.grid.major.x = grid_x,
      panel.grid.major.y = grid_y,
      axis.title = element_text(
        family = "Source Sans 3", colour = metill$basalt_muted, size = rel(0.85)
      ),
      axis.text = element_text(colour = metill$basalt, size = rel(0.8)),
      axis.line = element_line(colour = metill$rule, linewidth = 0.3),
      axis.ticks = element_blank(),
      plot.margin = margin(half, half, half, half)
    )
}

### --- DB connection --------------------------------------------------------

db_url <- readLines("~/esbvaktin/.env") |>
  grep("^DATABASE_URL", x = _, value = TRUE) |>
  sub("DATABASE_URL=", "", x = _)
parsed <- regmatches(
  db_url, regexec("://(.+?):(.+?)@(.+?):(\\d+)/(.+)", db_url)
)[[1]]

con <- dbConnect(
  Postgres(),
  dbname = parsed[6], host = parsed[4], port = as.integer(parsed[5]),
  user = parsed[2], password = parsed[3]
)

### --- Pulls ----------------------------------------------------------------
### RPostgres returns TEXT[] columns as unparsed Postgres array literals
### (single strings like "{FISH-DATA-001,SOV-LEGAL-007}"), not parsed character
### vectors. We let Postgres expand the arrays server-side via LATERAL unnest
### so the long table arrives ready to use.

claims_long <- dbGetQuery(
  con,
  paste(
    "SELECT c.id AS claim_id, c.category, e_id AS evidence_id",
    "FROM claims c,",
    "LATERAL unnest(c.supporting_evidence || c.contradicting_evidence) AS e_id",
    "WHERE c.published = TRUE",
    "  AND e_id IS NOT NULL",
    "  AND e_id <> ''",
    sep = "\n"
  )
) |>
  as_tibble()

n_claims_total <- tbl(con, "claims") |>
  filter(published == TRUE) |>
  count() |>
  pull(n) |>
  as.integer()

sightings_raw <- tbl(con, "claim_sightings") |>
  select(claim_id, source_url, source_domain, source_date) |>
  filter(!is.na(source_url)) |>
  collect()

evidence_raw <- tbl(con, "evidence") |>
  select(evidence_id, topic) |>
  collect()

dbDisconnect(con)

cat(sprintf(
  "\nPublished claims: %d  |  Sightings: %d  |  Evidence: %d\n",
  n_claims_total, nrow(sightings_raw), nrow(evidence_raw)
))
cat(sprintf("Claim-evidence links (after unnest): %d\n", nrow(claims_long)))

### ===========================================================================
### Option B — Evidence-utilisation Pareto
### ===========================================================================

evidence_citations <- claims_long |>
  inner_join(sightings_raw, by = "claim_id", relationship = "many-to-many") |>
  count(evidence_id, name = "sighting_citations")

evidence_full <- evidence_raw |>
  left_join(evidence_citations, by = "evidence_id") |>
  mutate(sighting_citations = replace_na(sighting_citations, 0))

n_evidence <- nrow(evidence_full)
n_uncited <- sum(evidence_full$sighting_citations == 0)
n_cited <- n_evidence - n_uncited
total_citations <- sum(evidence_full$sighting_citations)
top_20pct_share <- evidence_full |>
  arrange(desc(sighting_citations)) |>
  slice_head(prop = 0.2) |>
  summarise(s = sum(sighting_citations) / total_citations) |>
  pull(s)

cat("\n--- Evidence utilisation ---\n")
cat(sprintf("  Evidence entries:        %d\n", n_evidence))
cat(sprintf(
  "  Never cited:             %d (%s)\n",
  n_uncited, percent(n_uncited / n_evidence, accuracy = 1)
))
cat(sprintf("  Total sighting-citations: %d\n", total_citations))
cat(sprintf(
  "  Top 20%% of evidence carry %s of citations\n",
  percent(top_20pct_share, accuracy = 1)
))

evidence_pareto <- evidence_full |>
  arrange(desc(sighting_citations)) |>
  mutate(
    rank          = row_number(),
    rank_pct      = rank / n_evidence,
    cumul_pct     = cumsum(sighting_citations) / total_citations
  )

uncited_x <- (n_evidence - n_uncited) / n_evidence

# Reference point at 20% of evidence
x_top20 <- 0.20
y_top20 <- evidence_pareto$cumul_pct[
  which.min(abs(evidence_pareto$rank_pct - 0.20))
]

p_pareto <- evidence_pareto |>
  ggplot(aes(x = rank_pct, y = cumul_pct)) +
  geom_area(fill = metill$jokull_soft, alpha = 0.4) +
  geom_line(colour = metill$jokull, linewidth = 1.2) +
  # Top-20% reference cross-hair
  geom_segment(
    x = x_top20, xend = x_top20, y = 0, yend = y_top20,
    colour = metill$basalt_muted, linewidth = 0.4, linetype = "dotted"
  ) +
  geom_segment(
    x = 0, xend = x_top20, y = y_top20, yend = y_top20,
    colour = metill$basalt_muted, linewidth = 0.4, linetype = "dotted"
  ) +
  annotate(
    "point",
    x = x_top20, y = y_top20,
    colour = metill$jokull, size = 3
  ) +
  annotate(
    "text",
    x = x_top20 + 0.015, y = y_top20 - 0.04,
    label = sprintf(
      "Top 20%% of evidence\ncarries %s of citations",
      percent(y_top20, accuracy = 1)
    ),
    hjust = 0, vjust = 1,
    family = "Source Sans 3", colour = metill$basalt,
    size = 6
  ) +
  # Never-cited marker on the right
  geom_vline(
    xintercept = uncited_x,
    colour = metill$midnaetursol,
    linewidth = 0.7, linetype = "dashed"
  ) +
  annotate(
    "text",
    x = uncited_x - 0.015, y = 0.5,
    label = sprintf(
      "%d of %d entries never cited (%s)",
      n_uncited, n_evidence,
      percent(n_uncited / n_evidence, accuracy = 1)
    ),
    hjust = 1, vjust = 0.5, angle = 90,
    family = "Source Sans 3", colour = metill$midnaetursol,
    fontface = "bold", size = 5.5
  ) +
  scale_x_continuous(
    labels = label_percent(accuracy = 1),
    expand = expansion(mult = c(0, 0))
  ) +
  scale_y_continuous(
    labels = label_percent(accuracy = 1),
    limits = c(0, 1),
    expand = expansion(mult = c(0, 0.02))
  ) +
  theme_metill(base_size = 22, grid = "y") +
  labs(
    title = "A small share of evidence carries most of the discussion",
    subtitle = sprintf(
      "Cumulative citation share by evidence rank · n = %d evidence entries",
      n_evidence
    ),
    x = "Share of evidence (ranked most-cited → least-cited)",
    y = "Cumulative share of all citations",
    caption = sprintf(
      "Citations counted per article-sighting · Total = %s",
      comma(total_citations)
    )
  )

ggsave(
  filename = "Figures/evidence_pareto.png",
  plot = p_pareto,
  device = ragg::agg_png,
  width = 9, height = 5,
  dpi = 300,
  bg = metill$pappir
)

### ===========================================================================
### Option A — Article completeness scatter
### ===========================================================================

article_long <- claims_long |>
  inner_join(sightings_raw, by = "claim_id", relationship = "many-to-many")

evidence_by_topic <- evidence_raw |>
  count(topic, name = "evidence_in_topic")

article_summary <- article_long |>
  group_by(source_url, source_domain) |>
  summarise(
    topic_breadth = n_distinct(category),
    claim_count = n_distinct(claim_id),
    evidence_cited = n_distinct(evidence_id),
    topics_touched = list(unique(category)),
    .groups = "drop"
  )

# Cross-join topics_touched with evidence_by_topic to get available evidence
article_avail <- article_summary |>
  select(source_url, topics_touched) |>
  unnest_longer(topics_touched) |>
  rename(topic = topics_touched) |>
  inner_join(evidence_by_topic, by = "topic") |>
  group_by(source_url) |>
  summarise(evidence_available = sum(evidence_in_topic), .groups = "drop")

article_complete <- article_summary |>
  select(-topics_touched) |>
  inner_join(article_avail, by = "source_url") |>
  mutate(depth_ratio = evidence_cited / evidence_available) |>
  filter(evidence_available > 0)

n_articles_complete <- nrow(article_complete)

cat("\n--- Article completeness ---\n")
cat(sprintf("  Articles with ≥1 evidence-linked claim: %d\n", n_articles_complete))
cat(sprintf(
  "  Median topic breadth: %.1f  |  Median depth: %s\n",
  median(article_complete$topic_breadth),
  percent(median(article_complete$depth_ratio), accuracy = 0.1)
))
cat("  Distribution of topic_breadth:\n")
print(table(article_complete$topic_breadth))

### Primary scatter: absolute evidence count (no denominator trap)
###   x = topics covered    y = distinct evidence engaged
### Median reference lines partition the chart into four quadrants:
###   upper-right = broad + many-source (the exemplars)

med_breadth <- median(article_complete$topic_breadth)
med_evcount <- median(article_complete$evidence_cited)

p_scatter <- article_complete |>
  ggplot(aes(x = topic_breadth, y = evidence_cited)) +
  geom_hline(
    yintercept = med_evcount,
    colour = metill$rule, linewidth = 0.4, linetype = "dashed"
  ) +
  geom_vline(
    xintercept = med_breadth,
    colour = metill$rule, linewidth = 0.4, linetype = "dashed"
  ) +
  geom_jitter(
    aes(size = claim_count),
    colour = metill$jokull,
    alpha = 0.4,
    width = 0.25, height = 0
  ) +
  annotate(
    "text",
    x = 9.5, y = max(article_complete$evidence_cited),
    label = "broad + many-source",
    family = "Source Sans 3", colour = metill$basalt_muted,
    size = 5, hjust = 1, vjust = 1,
    fontface = "italic"
  ) +
  scale_x_continuous(
    breaks = 1:10,
    expand = expansion(add = c(0.4, 0.4))
  ) +
  scale_y_continuous(
    trans = "sqrt",
    breaks = c(1, 5, 10, 25, 50, 100),
    limits = c(0, NA),
    expand = expansion(mult = c(0, 0.05))
  ) +
  scale_size_continuous(
    range = c(1.5, 7),
    breaks = c(1, 5, 10, 25, 50),
    name = "Claims per article"
  ) +
  guides(size = guide_legend(
    override.aes = list(alpha = 0.7),
    nrow = 1
  )) +
  theme_metill(base_size = 22, grid = "xy") +
  theme(
    legend.position = "top",
    legend.text = element_text(family = "Source Sans 3", size = rel(0.55)),
    legend.title = element_text(family = "Source Sans 3", size = rel(0.6)),
    legend.key.size = unit(1.4, "lines"),
    legend.margin = margin(b = 0)
  ) +
  labs(
    title = "How much evidence does each article engage?",
    subtitle = sprintf(
      "Topics covered × distinct evidence cited · n = %d articles",
      n_articles_complete
    ),
    x = "Distinct topics in the article",
    y = "Distinct evidence entries cited (sqrt scale)",
    caption = sprintf(
      "Dashed lines: median values (%d topics, %d evidence)",
      med_breadth, med_evcount
    )
  )

ggsave(
  filename = "Figures/completeness_scatter.png",
  plot = p_scatter,
  device = ragg::agg_png,
  width = 9, height = 5.5,
  dpi = 300,
  bg = metill$pappir
)

cat("\nWrote:\n")
cat("  Figures/evidence_pareto.png\n")
cat("  Figures/completeness_scatter.png\n\n")
