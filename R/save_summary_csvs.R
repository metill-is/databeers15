### ===========================================================================
### Save the headline DB summaries as CSV for the databeers15 deck.
### Mirrors the Nordic House `data/` layout —
###   data/topic_distribution.csv
###   data/verdict_distribution.csv
###   data/headline_counts.csv
###
### Run:
###   cd ~/talks/metill/databeers15
###   Rscript R/save_summary_csvs.R
### ===========================================================================

options(width = 120)

# Rscript launches with LC_CTYPE=C from non-interactive shells on macOS, which
# makes R unable to round-trip UTF-8 in source literals -- write_csv() escapes
# bytes like 0xC3 0xA9 to the literal text "<c3><a9>". Force a UTF-8 locale.
Sys.setlocale("LC_ALL", "is_IS.UTF-8")

suppressPackageStartupMessages({
  library(tidyverse)
  library(dbplyr)
  library(DBI)
  library(RPostgres)
})

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
  dbname = parsed[6], host = parsed[4], port = as.integer(parsed[5]),
  user = parsed[2], password = parsed[3]
)

claims <- tbl(con, "claims")
sightings <- tbl(con, "claim_sightings")
evidence <- tbl(con, "evidence")

### --- Label mappings ------------------------------------------------------

topic_labels_en <- c(
  eea_eu_law  = "EEA / EU law",
  sovereignty = "Sovereignty",
  fisheries   = "Fisheries",
  precedents  = "Precedents",
  trade       = "Trade & tariffs",
  currency    = "Currency",
  agriculture = "Agriculture",
  energy      = "Energy",
  labour      = "Labour market",
  housing     = "Housing"
)

topic_labels_is <- c(
  eea_eu_law  = "EES-réttur",
  sovereignty = "Fullveldi",
  fisheries   = "Sjávarútvegur",
  precedents  = "Fordæmi",
  trade       = "Viðskipti og tollar",
  currency    = "Gjaldmiðill",
  agriculture = "Landbúnaður",
  energy      = "Orka",
  labour      = "Vinnumarkaður",
  housing     = "Húsnæðismál"
)

verdict_labels_en <- c(
  supported           = "Supported",
  partially_supported = "Partially supported",
  unsupported         = "Unsupported",
  misleading          = "Misleading",
  unverifiable        = "Unverifiable"
)

verdict_labels_is <- c(
  supported           = "Studd",
  partially_supported = "Studd að hluta",
  unsupported         = "Óstudd",
  misleading          = "Þarfnast samhengis",
  unverifiable        = "Ósannreynanleg"
)

### --- Headline counts -----------------------------------------------------

n_articles <- sightings |>
  distinct(source_url) |>
  count() |>
  pull(n) |>
  as.integer()

n_claims <- claims |>
  count() |>
  pull(n) |>
  as.integer()

n_claims_published <- claims |>
  filter(published == TRUE) |>
  count() |>
  pull(n) |>
  as.integer()

n_claims_substantive <- claims |>
  filter(published == TRUE, substantive == TRUE) |>
  count() |>
  pull(n) |>
  as.integer()

n_sources <- evidence |>
  count() |>
  pull(n) |>
  as.integer()

n_outlets <- sightings |>
  filter(!is.na(source_domain)) |>
  distinct(source_domain) |>
  count() |>
  pull(n) |>
  as.integer()

### --- Topic distribution --------------------------------------------------
###   topic, label_en, label_is, sightings, evidence, pct, ratio
###   pct   = share of all sightings  (rounded 1dp)
###   ratio = sightings per evidence entry (rounded 1dp)

claims_per_topic <- claims |>
  count(category) |>
  collect() |>
  rename(topic = category, sightings = n) |>
  mutate(sightings = as.integer(sightings))

evidence_per_topic <- evidence |>
  count(topic) |>
  collect() |>
  rename(evidence = n) |>
  mutate(evidence = as.integer(evidence))

topic_dist <- claims_per_topic |>
  inner_join(evidence_per_topic, by = "topic") |>
  filter(topic %in% names(topic_labels_en)) |>
  mutate(
    label_en = unname(topic_labels_en[topic]),
    label_is = unname(topic_labels_is[topic]),
    pct      = round(100 * sightings / sum(sightings), 1),
    ratio    = round(sightings / evidence, 1)
  ) |>
  arrange(desc(sightings)) |>
  select(topic, label_en, label_is, sightings, evidence, pct, ratio)

### --- Verdict distribution ------------------------------------------------
###   verdict, label_en, label_is, count, pct

verdict_dist <- claims |>
  filter(published == TRUE) |>
  count(verdict) |>
  collect() |>
  filter(verdict %in% names(verdict_labels_en)) |>
  mutate(
    count    = as.integer(n),
    label_en = unname(verdict_labels_en[verdict]),
    label_is = unname(verdict_labels_is[verdict]),
    pct      = round(100 * count / sum(count), 1)
  ) |>
  arrange(desc(count)) |>
  select(verdict, label_en, label_is, count, pct)

### --- Headline counts table ----------------------------------------------

as_of <- Sys.Date()
headline <- tibble(
  metric = c(
    "articles", "claims_total", "claims_published",
    "claims_substantive", "evidence_sources", "outlets"
  ),
  value = c(
    n_articles, n_claims, n_claims_published,
    n_claims_substantive, n_sources, n_outlets
  ),
  as_of = as_of
)

### --- Write CSVs ----------------------------------------------------------

data_dir <- "data"
dir.create(data_dir, showWarnings = FALSE)

write_csv(topic_dist, file.path(data_dir, "topic_distribution.csv"))
write_csv(verdict_dist, file.path(data_dir, "verdict_distribution.csv"))
write_csv(headline, file.path(data_dir, "headline_counts.csv"))

dbDisconnect(con)

### --- Report -------------------------------------------------------------

cat(sprintf("\n=== Saved %s ===\n", as_of))
cat(sprintf(
  "  Articles: %s | Claims: %s (%s published) | Sources: %s | Outlets: %s\n",
  format(n_articles, big.mark = ","),
  format(n_claims, big.mark = ","),
  format(n_claims_published, big.mark = ","),
  format(n_sources, big.mark = ","),
  format(n_outlets, big.mark = ",")
))

cat("\nWrote:\n")
cat("  data/topic_distribution.csv\n")
cat("  data/verdict_distribution.csv\n")
cat("  data/headline_counts.csv\n\n")

cat("Topic distribution:\n")
print(topic_dist)
cat("\nVerdict distribution:\n")
print(verdict_dist)
cat("\n")
