library(metafor)
library(dplyr)
library(forestploter)
library(grid)

# ============================================================
# 1) Compute effect sizes (SMD) and run meta-analysis (metafor)
# ============================================================
Memory_and_learning_Immediate_free_recall_SMD <- escalc(
  measure = "SMD",
  n1i  = `N of multivitamins`,
  m1i  = `mean of post-dose multivitamins`,
  sd1i = `sd of post-dose multivitamins`,
  n2i  = `N of placebo`,
  m2i  = `mean of post-dose placebo`,
  sd2i = `sd of post-dose placebo`,
  data = Memory_and_learning_Immediate_free_recall
)

# Random-effects model (change to method="FE" if you want fixed-effects)
Memory_and_learning_Immediate_free_recall_res <- rma(
  yi, vi,
  data = Memory_and_learning_Immediate_free_recall_SMD,
  method = "REML"
)

# ============================================================
# 2) Build a forestploter table (display columns + numeric columns)
# ============================================================

raw_df <- Memory_and_learning_Immediate_free_recall

# Per-study SMD and CI (study-level)
yi  <- Memory_and_learning_Immediate_free_recall_SMD$yi
sei <- sqrt(Memory_and_learning_Immediate_free_recall_SMD$vi)
lower <- yi - 1.96 * sei
upper <- yi + 1.96 * sei

# A formatted CI text column (optional but looks nice)
effect_text <- sprintf("%.2f [%.2f, %.2f]", yi, lower, upper)

Book1 <- raw_df %>%
  transmute(
    Study = `Study Label`,

    `Multivitamins N`    = `N of multivitamins`,
    `Multivitamins Mean` = `mean of post-dose multivitamins`,
    `Multivitamins SD`   = `sd of post-dose multivitamins`,

    `Placebo N`    = `N of placebo`,
    `Placebo Mean` = `mean of post-dose placebo`,
    `Placebo SD`   = `sd of post-dose placebo`,

    spacer = strrep(" ", 11),           # stable spacer column for the CI plot
    `SMD [95% CI]` = effect_text,       # text column

    # numeric columns for forest() to use
    SMD = yi,
    lower = lower,
    upper = upper
  )

# ------------------------------------------------------------
# 2.1 Add an overall summary row (from metafor)
# ------------------------------------------------------------
sum_est   <- as.numeric(Memory_and_learning_Immediate_free_recall_res$b)
sum_se    <- as.numeric(Memory_and_learning_Immediate_free_recall_res$se)
sum_lower <- sum_est - 1.96 * sum_se
sum_upper <- sum_est + 1.96 * sum_se

summary_row <- tibble(
  Study = "Overall",

  `Multivitamins N`    = "",
  `Multivitamins Mean` = "",
  `Multivitamins SD`   = "",

  `Placebo N`    = "",
  `Placebo Mean` = "",
  `Placebo SD`   = "",

  spacer = strrep(" ", 11),
  `SMD [95% CI]` = sprintf("%.2f [%.2f, %.2f]", sum_est, sum_lower, sum_upper),

  SMD = sum_est,
  lower = sum_lower,
  upper = sum_upper
)

Book1 <- bind_rows(Book1, summary_row)

# ------------------------------------------------------------
# 2.2 IMPORTANT: keep numeric columns numeric; only replace NA in display cols
# ------------------------------------------------------------
num_cols <- c("SMD", "lower", "upper")
Book1[num_cols] <- lapply(Book1[num_cols], function(x) as.numeric(as.character(x)))

Book1 <- Book1 %>%
  mutate(across(-all_of(num_cols), ~ ifelse(is.na(.), "", .)))

# ============================================================
# 3) Footnote text from metafor model
# ============================================================
Q  <- Memory_and_learning_Immediate_free_recall_res$QE
df <- Memory_and_learning_Immediate_free_recall_res$k - Memory_and_learning_Immediate_free_recall_res$p
pQ <- Memory_and_learning_Immediate_free_recall_res$QEp
I2 <- Memory_and_learning_Immediate_free_recall_res$I2

footnote_txt <- sprintf(
  "Random-Effects Model (Q = %.2f, df = %d, p = %.3f; I^2 = %.1f%%)",
  Q, df, pQ, I2
)

# ============================================================
# 4) Forestploter theme (your style + centered headers)
# ============================================================
tm <- forest_theme(
  base_size = 10,

  ci_pch = 15,
  ci_col = "#0e8abb",
  ci_fill = "red",
  ci_alpha = 1,
  ci_lty = 1,
  ci_lwd = 2,
  ci_Theight = 0.2,

  refline_lwd = gpar(lwd = 1, lty = "dashed", col = "grey20"),
  vertline_lwd = 1,
  vertline_lty = "dashed",
  vertline_col = "grey20",

  summary_fill = "#006400",
  summary_col = "#006400",

  title_just = "left",
  title_gp = gpar(cex = 1, fontface = "bold"),

  footnote_gp = gpar(cex = 0.6, fontface = "italic", col = "blue"),

  core = list(fg_params = list(hjust = 0.5, x = 0.5)),
  colhead = list(fg_params = list(hjust = 0.5, x = 0.5))
)

# ============================================================
# 5) Choose display columns and draw forest plot
# ============================================================
display_df <- Book1 %>%
  select(
    Study,
    `Multivitamins N`, `Multivitamins Mean`, `Multivitamins SD`,
    `Placebo N`, `Placebo Mean`, `Placebo SD`,
    spacer,
    `SMD [95% CI]`
  )

ci_col_idx <- which(names(display_df) == "spacer")

p <- forest(
  data = display_df,
  est = Book1$SMD,
  lower = Book1$lower,
  upper = Book1$upper,

  ci_column = ci_col_idx,
  is_summary = c(rep(FALSE, nrow(Book1) - 1), TRUE),

  xlab = "Standardized Mean Difference",
  title = "The effects of multivitamins on immediate free recall",
  footnote = footnote_txt,

  theme = tm,
  xlim = c(-1, 1),
  ticks_at = c(-1, -0.5, 0, 0.5, 1)
)

# Bold the summary row (last row)
p <- edit_plot(p, row = nrow(Book1), gp = gpar(fontface = "bold"))

# Optional: widen the CI column safely
widths_mm <- convertWidth(p$widths, "mm", valueOnly = TRUE)
if (length(widths_mm) >= ci_col_idx) widths_mm[ci_col_idx] <- 60
p$widths <- unit(widths_mm, "mm")

print(p)

# ============================================================
# 6) Export (publication-friendly)
# ============================================================
png("Immediate_free_recall_forest.png", width = 3500, height = 1000, res = 300, units = "px")
print(p)
dev.off()

tiff("Immediate_free_recall_forest.tiff", width = 3500, height = 1000, res = 300, units = "px", compression = "lzw")
print(p)
dev.off()
