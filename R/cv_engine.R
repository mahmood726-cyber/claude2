# R/cv_engine.R - Core Cross-Validation Engine for Meta-Regression

#' Simulate a Meta-Analytic Dataset
#' @param k Number of studies
#' @param p Number of moderators
#' @param true_R2 Target true R2
#' @export
simulate_ma_dataset <- function(k, p, true_R2) {
  X <- matrix(rnorm(k * p), nrow = k, ncol = p)
  tau2 <- 0.05
  vi <- runif(k, 0.01, 0.03)
  beta <- rep(sqrt(true_R2 * tau2 / p), p)
  theta <- X %*% beta + rnorm(k, 0, sqrt(tau2))
  yi <- rnorm(k, theta, sqrt(vi))
  return(data.frame(yi = yi, vi = vi, X))
}

#' Perform k-fold Cross-Validation for Meta-Regression
#' @param data Dataset with yi, vi, and moderators
#' @param weighted Logical; whether to use weighted MSE in loss function
#' @param folds Number of folds (default 10)
#' @export
perform_meta_cv <- function(data, weighted = TRUE, folds = 10) {
  k <- nrow(data)
  fold_ids <- sample(rep(1:folds, length.out = k))
  
  sq_errors <- numeric(k)
  weights <- numeric(k)
  
  for (i in 1:folds) {
    train <- data[fold_ids != i, ]
    test <- data[fold_ids == i, ]
    
    # Fit random-effects model using metafor with error handling
    fit <- try(metafor::rma(yi ~ ., vi = vi, data = train, method = "REML"), silent = TRUE)
    
    if (inherits(fit, "try-error")) {
      sq_errors[fold_ids == i] <- NA
      weights[fold_ids == i] <- NA
      next
    }
    
    # Predict for test set
    mod_cols <- setdiff(names(test), c("yi", "vi"))
    preds <- try(metafor::predict.rma(fit, newmods = as.matrix(test[, mod_cols]))$pred, silent = TRUE)
    
    if (inherits(preds, "try-error")) {
      sq_errors[fold_ids == i] <- NA
      weights[fold_ids == i] <- NA
      next
    }
    
    sq_errors[fold_ids == i] <- (test$yi - preds)^2
    weights[fold_ids == i] <- 1/(test$vi + fit$tau2)
  }
  
  # Remove folds that failed to converge
  valid_idx <- !is.na(sq_errors)
  if (sum(valid_idx) == 0) return(NA)
  
  if (weighted) {
    return(sum(sq_errors[valid_idx] * weights[valid_idx]) / sum(weights[valid_idx]))
  } else {
    return(mean(sq_errors[valid_idx]))
  }
}
