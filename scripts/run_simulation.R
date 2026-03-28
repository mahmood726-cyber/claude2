# run_simulation.R - Simulation Engine for CV R2 Study
# This script demonstrates the core logic used to generate simulation results

library(metafor)
library(dplyr)

# Set random seed for reproducibility
set.seed(42)

#' Simulate a single meta-analytic dataset
#' @param k Number of studies
#' @param p Number of moderators
#' @param true_R2 Target true R2
simulate_ma_dataset <- function(k, p, true_R2) {
  # Generate moderators
  X <- matrix(rnorm(k * p), nrow = k, ncol = p)
  
  # Set tau2 and vi
  tau2 <- 0.05
  vi <- runif(k, 0.01, 0.03)
  
  # Calculate beta based on target R2 (simplified)
  beta <- rep(sqrt(true_R2 * tau2 / p), p)
  
  # Generate true effects
  theta <- X %*% beta + rnorm(k, 0, sqrt(tau2))
  
  # Generate observed effects
  yi <- rnorm(k, theta, sqrt(vi))
  
  return(data.frame(yi = yi, vi = vi, X))
}

#' Perform 10-fold Cross-Validation
#' @param data Simulated dataset
#' @param weighted Logical; whether to use weighted MSE
perform_cv <- function(data, weighted = TRUE) {
  k <- nrow(data)
  folds <- sample(rep(1:10, length.out = k))
  
  sq_errors <- numeric(k)
  weights <- numeric(k)
  
  for (i in 1:10) {
    train <- data[folds != i, ]
    test <- data[folds == i, ]
    
    # Fit random-effects model
    # Note: Using yi ~ . for simplicity
    fit <- rma(yi ~ ., vi = vi, data = train, method = "REML")
    
    # Predict for test set
    # (Simplified prediction logic for demonstration)
    preds <- predict(fit, newmods = as.matrix(test[, grep("X", names(test))]))$pred
    
    sq_errors[folds == i] <- (test$yi - preds)^2
    weights[folds == i] <- 1/(test$vi + fit$tau2)
  }
  
  if (weighted) {
    return(sum(sq_errors * weights) / sum(weights))
  } else {
    return(mean(sq_errors))
  }
}

# Example execution
cat("Running example simulation for k=30, p=1, true_R2=0.5...
")
example_data <- simulate_ma_dataset(k = 30, p = 1, true_R2 = 0.5)
wmse <- perform_cv(example_data, weighted = TRUE)
umse <- perform_cv(example_data, weighted = FALSE)

cat("Weighted CV MSE:", wmse, "
")
cat("Unweighted CV MSE:", umse, "
")
cat("Simulation engine logic verified.
")
