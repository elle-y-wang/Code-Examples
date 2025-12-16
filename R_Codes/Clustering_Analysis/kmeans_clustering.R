## K-means clustering 
## - Read tab-delimited data
## - Select numeric variables
## - Clean (NA + zero-variance columns)
## - Standardize
## - Evaluate k using:
##     1) Elbow (WSS)
##     2) Pseudo-F (Calinski–Harabasz-like)
##     3) Silhouette (requires 'cluster')
##     4) Gap statistic (requires 'cluster')
## - Fit final k-means and export cluster labels

## 0. Libraries
library(tidyverse)     # dplyr, ggplot2, purrr, tibble
library(factoextra)    # fviz_nbclust, fviz_gap_stat, fviz_silhouette
library(cluster)       # silhouette(), used by silhouette & gap statistic
library(data.table)    # fwrite()

## 1. Read data
# Choose a tab-delimited file interactively
data <- read.delim(
  file.choose(),
  header = TRUE,
  sep = "\t",
  check.names = FALSE
)

# Quick check of column names and structure
print(names(data))
str(data)

## 2. Select variables for clustering
# Option A (as in your original code): select columns by index
cols <- c(2:5, 7:9, 11:12)

# Safety check: make sure the indices exist in the dataset
stopifnot(max(cols) <= ncol(data))

data1 <- data[, cols]

# Ensure all selected columns are numeric (avoid character/factor issues)
data1 <- data1 %>%
  mutate(across(everything(), ~ as.numeric(.)))

## 3. Handle missing values
# Remove rows with any missing values in selected clustering variables
# (If you prefer imputation instead, replace this step with an imputation method.)
data1 <- data1 %>% drop_na()

## 4. Remove zero-variance columns
# Columns with SD = 0 cause problems for scaling and distance calculations
sd_vec <- sapply(data1, sd, na.rm = TRUE)
keep_cols <- sd_vec > 0

if (!all(keep_cols)) {
  message("Removed zero-variance columns: ",
          paste(names(data1)[!keep_cols], collapse = ", "))
}

data1 <- data1[, keep_cols, drop = FALSE]

## 5. Standardize the data (z-score)
set.seed(42)

# Scale to mean = 0 and SD = 1
normal <- scale(data1)
normal <- as.matrix(normal)

## 6. Evaluate number of clusters (k)
## 6.1 Elbow method (WSS)
# This plots total within-cluster sum of squares for k = 1..10
p_wss <- fviz_nbclust(
  normal,
  FUNcluster = kmeans,
  method = "wss",
  k.max = 10
) + ggtitle("Elbow Method (WSS)")

print(p_wss)

## 6.2 Pseudo-F statistic (Calinski–Harabasz-like)
# NOTE: This is a common pseudo-F style calculation.
pseudoF <- function(X, k, nstart = 25, seed = 42) {
  set.seed(seed)
  n <- nrow(X)

  # Total sum of squares around the global mean
  TSS <- sum(scale(X, scale = FALSE)^2)

  WSS <- numeric(length(k))
  PF  <- numeric(length(k))

  for (i in seq_along(k)) {
    ki <- k[i]

    # Skip invalid k values
    if (ki <= 1 || ki >= n) {
      WSS[i] <- NA_real_
      PF[i]  <- NA_real_
      next
    }

    km <- kmeans(X, centers = ki, nstart = nstart)
    WSS[i] <- sum(km$withinss)

    # Pseudo-F: ((TSS - WSS)/(k-1)) / (WSS/(n-k))
    PF[i] <- ((TSS - WSS[i]) / (ki - 1)) / (WSS[i] / (n - ki))
  }

  tibble(k = k, withinSS = WSS, pseudoF = PF)
}

pf_tbl <- pseudoF(normal, 1:10)
print(pf_tbl)

p_pf <- ggplot(pf_tbl, aes(x = k, y = pseudoF)) +
  geom_line() +
  geom_point() +
  labs(x = "Number of clusters (k)", y = "Pseudo-F statistic") +
  ggtitle("Pseudo-F across k") +
  theme_minimal()

print(p_pf)

## 6.3 Silhouette analysis across k (recommended range: 2..10)
# Silhouette requires a distance matrix
dist_mat <- dist(normal)

sil_tbl <- map_dfr(2:10, function(k) {
  set.seed(42)
  km <- kmeans(normal, centers = k, nstart = 25)
  sil <- silhouette(km$cluster, dist_mat)

  tibble(
    k = k,
    avg_silhouette = mean(sil[, "sil_width"])
  )
})

print(sil_tbl)

p_sil <- ggplot(sil_tbl, aes(x = k, y = avg_silhouette)) +
  geom_line() +
  geom_point() +
  labs(x = "Number of clusters (k)", y = "Average silhouette width") +
  ggtitle("Average Silhouette Width across k") +
  theme_minimal()

print(p_sil)

## 6.4 Gap statistic
# B controls the number of bootstrap samples (higher = more stable but slower)
set.seed(42)
gap_stat <- clusGap(
  normal,
  FUN = kmeans,
  nstart = 25,
  K.max = 10,
  B = 100
)

p_gap <- fviz_gap_stat(gap_stat) + ggtitle("Gap Statistic")
print(p_gap)

## 7. Choose final k and fit k-means
# IMPORTANT:
# Choose k based on your evaluation (WSS elbow + pseudoF peak + silhouette peak + gap rule)
final_k <- 4  # <-- change this to your chosen k

set.seed(42)
final_km <- kmeans(normal, centers = final_k, nstart = 25)

# Optional: silhouette plot for the final solution
final_sil <- silhouette(final_km$cluster, dist_mat)
p_final_sil <- fviz_silhouette(final_sil) + ggtitle(paste0("Silhouette Plot (k=", final_k, ")"))
print(p_final_sil)

## 8. Export cluster assignments
# Cluster numbers correspond to the row order AFTER filtering and NA removal.
cluster_df <- data.table(
  row_id = as.integer(rownames(data1)),  # row index in the filtered data context (may not match original!)
  cluster = final_km$cluster
)

# Write clusters to a tab-delimited file
fwrite(cluster_df, file = "clusternum.txt", sep = "\t")

message("Saved cluster labels to: clusternum.txt")

## 9. (Optional) Merge cluster labels back to the filtered dataset
# This creates a dataset you can inspect and summarize by cluster
clustered_data <- data1 %>%
  mutate(cluster = final_km$cluster)

# Example: compute cluster-wise mean and SD for each variable (on original scale of data1)
cluster_summary <- clustered_data %>%
  group_by(cluster) %>%
  summarise(across(where(is.numeric),
                   list(mean = mean, sd = sd),
                   .names = "{.col}_{.fn}"),
            .groups = "drop")

print(cluster_summary)

# Save cluster summary
write.table(cluster_summary, file = "cluster_summary.txt", sep = "\t", row.names = FALSE, quote = FALSE)
message("Saved cluster summary to: cluster_summary.txt")
