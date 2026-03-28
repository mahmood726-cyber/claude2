# analyze_results.R - Main Analysis for Cross-Validated R2 Study

# Load necessary libraries
library(dplyr)
library(ggplot2)
library(tidyr)

# Set working directory to project root
# setwd("C:/Users/user/OneDrive - NHS/Documents/claude2")

# 1. Load Simulation Data
sim_summary <- read.csv("inst/extdata/paper4_simulation_summary.csv")
sim_raw <- read.csv("inst/extdata/paper4_simulation_raw.csv")

# 2. Load Empirical Data
empirical <- read.csv("inst/extdata/paper4_empirical_FINAL.csv")

# 3. Summary of Simulation Results
# Effect of k on Optimism
optimism_by_k <- sim_summary %>%
  group_by(k) %>%
  summarize(mean_optimism = mean(optimism_w_mean, na.rm = TRUE))

print("Optimism by k:")
print(optimism_by_k)

# 4. Comparison of Weighted vs Unweighted CV Bias
bias_comparison <- sim_summary %>%
  summarize(
    mean_bias_w = mean(bias_w_mean, na.rm = TRUE),
    mean_bias_uw = mean(bias_uw_mean, na.rm = TRUE)
  )

print("Bias Comparison (Weighted vs Unweighted):")
print(bias_comparison)

# 5. Empirical Examples Summary
empirical_summary <- empirical %>%
  select(Dataset, k, Apparent_R2, CV_weighted, CV_unweighted) %>%
  mutate(Optimism = Apparent_R2 - CV_weighted)

print("Empirical Dataset Summary:")
print(empirical_summary)

# 6. Save results for manuscript
write.csv(optimism_by_k, "inst/extdata/optimism_by_k_summary.csv", row.names = FALSE)
write.csv(empirical_summary, "inst/extdata/empirical_summary_table.csv", row.names = FALSE)

print("Analysis complete. Summary tables saved to inst/extdata/ folder.")
