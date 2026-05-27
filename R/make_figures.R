### ===========================================================================
### Databeers #15 — Regenerate ESB-vaktin figures from the live DB
### ---------------------------------------------------------------------------
### Adapted from `~/esbvaktin/talks/nordic-house-2026/R/figs.R`.
### Same DB pulls and chart logic, but rebranded for the Metill brand
### (Jökull teal / Midnætursól amber / Fraunces / Source Sans 3) and with
### English labels for the Databeers audience.
###
### Run from the talk's root directory:
###   cd ~/talks/metill/databeers15
###   Rscript R/make_figures.R
###
### Heads-up: showtext + Rscript can mis-render glyphs into PNG/PDF on macOS
### (cf. note in `01_make_figures.R`). SVG output via {svglite} embeds font
### references as text and is robust headlessly — the Quarto theme loads
### Fraunces and Source Sans 3 from Google Fonts, so the slide deck renders
### the SVGs correctly even if the host has neither font installed.
### Run inside Positron if you want the in-IDE preview to look right.
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

png_dpi <- 300
png_scale_topics <- 1.45
png_scale_verdicts <- 1.6

### --- Metill brand tokens (mirror theme.scss) -------------------------------

metill <- list(
  jokull = "#1B6B8A",
  jokull_soft = "#7AA9BD",
  jokull_hover = "#145A73",
  midnaetursol = "#C4841D",
  basalt = "#1C1C28",
  basalt_muted = "#5A5C66",
  pappir = "#FAFAF7",
  surface = "#FFFFFF",
  border = "#E2E4E8",
  rule = "#D5D8DE"
)

verdict_palette <- c(
  supported = metill$jokull,
  partially_supported = metill$jokull_soft,
  unverifiable = metill$basalt_muted,
  misleading = metill$midnaetursol,
  unsupported = "#A63A2B"
)

verdict_labels_en <- c(
  supported = "Supported",
  partially_supported = "Partially supported",
  unsupported = "Unsupported",
  misleading = "Misleading",
  unverifiable = "Unverifiable"
)

topic_labels_en <- c(
  eea_eu_law = "EEA / EU law",
  sovereignty = "Sovereignty",
  fisheries = "Fisheries",
  precedents = "Precedents",
  trade = "Trade & tariffs",
  currency = "Currency",
  agriculture = "Agriculture",
  energy = "Energy",
  labour = "Labour market",
  housing = "Housing"
)

### --- ggplot2 theme ---------------------------------------------------------

theme_metill <- function(base_size = 18, grid = "x") {
  half <- base_size / 2
  grid_line <- element_line(colour = metill$rule, linewidth = 0.3)
  grid_x <- if (grid %in% c("xy", "x")) grid_line else element_blank()
  grid_y <- if (grid %in% c("xy", "y")) grid_line else element_blank()

  theme_classic(base_size = base_size, base_family = "Source Sans 3") %+replace%
    theme(
      text = element_text(
        family = "Source Sans 3",
        colour = metill$basalt,
        size = base_size
      ),
      plot.title = element_text(
        family = "Fraunces",
        face = "plain",
        colour = metill$basalt,
        size = rel(1.35),
        hjust = 0,
        margin = margin(t = half, b = half / 2)
      ),
      plot.subtitle = element_text(
        family = "Source Sans 3",
        colour = metill$basalt_muted,
        size = rel(0.95),
        hjust = 0,
        margin = margin(b = half)
      ),
      plot.caption = element_text(
        family = "Source Sans 3",
        colour = metill$basalt_muted,
        size = rel(0.65),
        hjust = 1,
        margin = margin(t = half)
      ),
      plot.background = element_rect(fill = metill$pappir, colour = NA),
      panel.background = element_rect(fill = metill$pappir, colour = NA),
      panel.grid = element_blank(),
      panel.grid.major.x = grid_x,
      panel.grid.major.y = grid_y,
      axis.title = element_text(
        family = "Source Sans 3",
        colour = metill$basalt_muted,
        size = rel(0.85)
      ),
      axis.text = element_text(colour = metill$basalt, size = rel(0.8)),
      axis.line = element_line(colour = metill$rule, linewidth = 0.3),
      axis.ticks = element_blank(),
      legend.background = element_rect(fill = metill$pappir, colour = NA),
      legend.key = element_rect(fill = metill$pappir, colour = NA),
      legend.text = element_text(
        family = "Source Sans 3",
        colour = metill$basalt,
        size = rel(0.85)
      ),
      plot.margin = margin(half, half, half, half)
    )
}

metill_highlight <- function(
  highlight,
  levels,
  accent = metill$jokull,
  grey = metill$rule
) {
  cols <- setNames(rep(grey, length(levels)), levels)
  cols[highlight] <- accent
  cols
}

### --- DB connection (reads ~/esbvaktin/.env) -------------------------------

db_url <- readLines("~/esbvaktin/.env") |>
  grep("^DATABASE_URL", x = _, value = TRUE) |>
  sub("DATABASE_URL=", "", x = _)

parsed <- regmatches(
  db_url,
  regexec("://(.+?):(.+?)@(.+?):(\\d+)/(.+)", db_url)
)[[1]]

con <- dbConnect(
  Postgres(),
  dbname = parsed[6],
  host = parsed[4],
  port = as.integer(parsed[5]),
  user = parsed[2],
  password = parsed[3]
)

claims <- tbl(con, "claims")
sightings <- tbl(con, "claim_sightings")
evidence <- tbl(con, "evidence")

fig_dir <- "Figures"
dir.create(fig_dir, showWarnings = FALSE)

### --- Headline counts (used in slide 8 caption) ---------------------------

n_articles <- sightings |>
  distinct(source_url) |>
  count() |>
  pull(n) |>
  as.integer()

n_claims <- claims |>
  count() |>
  pull(n) |>
  as.integer()

n_sources <- evidence |>
  count() |>
  pull(n) |>
  as.integer()

cat("\n=== Current esbvaktin.is counts ===\n")
cat(sprintf("  Articles: %s\n", comma(n_articles)))
cat(sprintf("  Claims:   %s\n", comma(n_claims)))
cat(sprintf("  Sources:  %s\n", comma(n_sources)))
cat("===================================\n\n")

### ===========================================================================
### Figure 1 — Topic distribution (lollipop)
### "A handful of topics dominate the debate"
### ===========================================================================

topic_dat <- claims |>
  count(category) |>
  collect() |>
  rename(claims = n) |>
  inner_join(
    evidence |>
      count(topic) |>
      collect() |>
      rename(category = topic, evidence = n),
    by = "category"
  ) |>
  pivot_longer(c(claims, evidence), names_to = "type", values_to = "n") |>
  mutate(p = n / sum(n), .by = type) |>
  select(-n) |>
  pivot_wider(names_from = type, values_from = p) |>
  filter(category %in% names(topic_labels_en)) |>
  mutate(
    category = unname(topic_labels_en[category]),
    category = fct_reorder(category, claims)
  ) |>
  arrange(category)

topic_levels <- levels(topic_dat$category)
topic_hl <- c(head(topic_levels, 3), tail(topic_levels, 3))

p_topics <- topic_dat |>
  ggplot(aes(x = claims, y = category)) +
  geom_segment(
    aes(xend = 0, colour = category),
    linewidth = 0.6
  ) +
  geom_point(aes(colour = category), size = 3.2) +
  geom_text(
    data = ~ filter(.x, category %in% topic_hl),
    aes(label = percent(claims, accuracy = 1), colour = category),
    hjust = 0,
    vjust = 0.5,
    nudge_x = 0.005,
    size = 8,
    family = "Source Sans 3",
    fontface = "bold"
  ) +
  scale_x_continuous(
    expand = expansion(mult = c(0, 0.14)),
    labels = label_percent(),
    guide = guide_axis(cap = "both")
  ) +
  scale_y_discrete(guide = guide_axis(cap = "both")) +
  scale_colour_manual(
    values = metill_highlight(topic_hl, topic_levels),
    guide = "none"
  ) +
  theme_metill(base_size = 30, grid = "none") +
  theme(
    axis.line = element_blank(),
    axis.text.y = element_text(
      family = "Fraunces",
      colour = metill$basalt,
      size = rel(0.9)
    )
  ) +
  labs(
    title = "A handful of topics dominate the debate",
    subtitle = "Share of claims by topic",
    x = "Share of all claims",
    y = NULL,
    caption = sprintf(
      "Data: esbvaktin.is · %s claims across %s articles",
      comma(n_claims),
      comma(n_articles)
    )
  )

ggsave(
  filename = file.path(fig_dir, "topics.png"),
  plot = p_topics,
  device = ragg::agg_png,
  width = 8,
  height = 0.55 * 8,
  scale = 1,
  dpi = png_dpi,
  bg = metill$pappir
)

### ===========================================================================
### Figure 2 — Verdict quality by topic (stacked bar)
### "Most claims hold up: few are misleading or unsupported"
### ===========================================================================

verdict_dat <- claims |>
  filter(published == TRUE) |>
  count(category, verdict) |>
  collect() |>
  mutate(p = n / sum(n), .by = category)

verdict_dat <- verdict_dat |>
  bind_rows(
    verdict_dat |>
      summarise(n = sum(n), .by = verdict) |>
      mutate(category = "total", p = n / sum(n))
  ) |>
  filter(category %in% c(names(topic_labels_en), "total")) |>
  mutate(
    category = unname(c(topic_labels_en, total = "All topics")[category]),
    category = fct_reorder(category, (verdict == "supported") * p),
    category = fct_relevel(category, "All topics", after = Inf),
    verdict = fct_relevel(
      verdict,
      "misleading",
      "unsupported",
      "unverifiable",
      "partially_supported",
      "supported"
    )
  )

vp <- verdict_palette
vp[c("unverifiable")] <- adjustcolor(
  metill$rule,
  alpha.f = 0.55
)

label_dat <- verdict_dat |>
  filter(verdict %in% c("supported", "partially_supported")) |>
  arrange(category, desc(verdict)) |>
  mutate(
    x_pos = cumsum(p) - p,
    x_pos = x_pos + p / 2,
    label = percent(p, accuracy = 1),
    .by = category
  )

p_verdicts <- verdict_dat |>
  ggplot(aes(x = p, y = category, fill = verdict)) +
  geom_col(colour = metill$pappir, linewidth = 0.3) +
  geom_text(
    data = label_dat,
    aes(x = x_pos, y = category, label = label),
    inherit.aes = FALSE,
    colour = "white",
    fontface = "bold",
    family = "Source Sans 3",
    size = 9
  ) +
  scale_x_continuous(expand = expansion(), labels = NULL, breaks = NULL) +
  scale_fill_manual(
    values = vp,
    labels = verdict_labels_en,
    guide = guide_legend(reverse = TRUE, nrow = 1, byrow = TRUE)
  ) +
  theme_metill(base_size = 30, grid = "none") +
  theme(
    legend.position = "top",
    legend.text = element_text(family = "Source Sans 3", size = rel(1)),
    legend.key.size = unit(1.3, "lines"),
    legend.margin = margin(0, 0, 0, 0),
    legend.key.spacing = unit(0.2, "cm"),
    legend.box.spacing = unit(0.15, "cm"),
    legend.spacing = unit(0, "cm"),
    axis.line = element_blank(),
    axis.text.y = element_text(
      family = "Fraunces",
      colour = metill$basalt,
      size = rel(0.9),
      face = ifelse(
        levels(verdict_dat$category) == "All topics",
        "bold",
        "plain"
      )
    )
  ) +
  labs(
    title = "Most claims hold up: few are misleading or unsupported",
    subtitle = "Verdict distribution by topic",
    x = NULL,
    y = NULL,
    fill = NULL,
    caption = sprintf(
      "Data: esbvaktin.is · %s published claims · %s evidence sources",
      comma(n_claims),
      comma(n_sources)
    )
  )

ggsave(
  filename = file.path(fig_dir, "verdicts.png"),
  plot = p_verdicts,
  device = ragg::agg_png,
  width = 8,
  height = 0.55 * 8,
  scale = 1,
  dpi = png_dpi,
  bg = metill$pappir
)

dbDisconnect(con)

cat("\nWrote figures:\n")
cat(sprintf("  %s/topics.svg   |  %s/topics.png\n", fig_dir, fig_dir))
cat(sprintf("  %s/verdicts.svg |  %s/verdicts.png\n", fig_dir, fig_dir))
cat("\nSlide 8 caption (paste into index.qmd):\n")
cat(sprintf(
  "  **%s** articles · **%s** claims · **%s** sources\n\n",
  comma(n_articles),
  comma(n_claims),
  comma(n_sources)
))
