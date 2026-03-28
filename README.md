# Evaluating Cross-Validated R² in Meta-Regression

This project investigates the reliability of cross-validated $R^2$ estimates in random-effects meta-regression, comparing weighted and unweighted k-fold cross-validation strategies.

## Project Structure

- `inst/extdata/`: Contains simulation and empirical results in CSV format.
- `figures/`: Contains diagnostic plots and main results figures.
- `man/`: Contains the draft manuscript for PLOS ONE.
- `scripts/`: Contains R scripts for data analysis and visualization.
- `R/`: Core analytical engine code (installable package).
- `vignettes/`: Reproducibility guide.

## Key Findings

1. Apparent $R^2$ is significantly biased in small samples ($k < 30$).
2. Weighted cross-validation provides more stable and less biased estimates than unweighted cross-validation.
3. Overfitting risk is high when the $k/p$ ratio is less than 10.

## Usage

To reproduce the analysis, run the scripts in the `scripts/` directory.
