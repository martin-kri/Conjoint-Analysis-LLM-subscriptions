###########################################################################
### LLM subscriptions - Step 3: how many respondents do we need?         ###
### Same logic as the course script Simulations_for_sample_size.R:       ###
### simulate answers from assumed part-worths, fit the models with       ###
### mlogit, and look at standard errors / precision.                     ###
###                                                                       ###
### Before running: set the working directory to THIS folder             ###
### Runtime: about 5-10 minutes                                           ###
###########################################################################
suppressMessages({library(mlogit); library(MASS)})
source("00_settings_and_helpers.R")
des <- read.csv("output/02_chosen_design_12q.csv", colClasses = "character")
des$QES <- as.integer(des$QES); des$ALT <- as.integer(des$ALT)
n_sets <- max(des$QES)

# ---------------------------------------------------------------------------
# Long-format data, one row per alternative (same layout as the minivan data).
# price is the categorical version, price.num the numeric one (EUR per month).
make_long_data <- function(design, choices) {
  # design: QES, ALT, attributes; choices: data frame with resp.id and one
  # column per question (Q1..Qk) holding the chosen alternative (1, 2 or 3)
  full <- design[order(design$QES, design$ALT), ]
  full$price.num <- as.numeric(as.character(full$price))
  out <- do.call(rbind, lapply(seq_len(nrow(choices)), function(r) {
    d <- full; d$resp.id <- choices$resp.id[r]
    chosen <- unlist(choices[r, paste0("Q", 1:n_sets)])
    d$choice <- as.numeric(d$ALT == chosen[d$QES]); d }))
  for (a in names(attrib)) out[[a]] <- factor(out[[a]], levels = attrib[[a]])
  out$ques <- (match(out$resp.id, unique(out$resp.id)) - 1) * n_sets + out$QES  # unique task id
  out$alt <- out$ALT
  out[, c("resp.id", "ques", "alt", names(attrib), "price.num", "choice")]
}

# ---------------------------------------------------------------------------
# Assumed population (prior guesses + heterogeneity between respondents).
# People differ most in how they react to price: some never pay, some pay easily.
Sigma <- diag(c(0.5, 0.5, 1.0, 2.0, 0.2, 0.2, 0.2, 0.2))
dimnames(Sigma) <- list(names(mu), names(mu))
Sigma["price7.99", "price20.99"] <- Sigma["price20.99", "price7.99"] <- 1.2
X <- to_X(des)

simulate_choices <- function(n) {
  coefs <- mvrnorm(n, mu, Sigma)
  ch <- t(sapply(1:n, function(i) sapply(X, function(x) {
    u <- exp(x %*% coefs[i, ]); sample(1:n_alts, 1, prob = u / sum(u)) })))
  data.frame(resp.id = 1:n, setNames(as.data.frame(ch), paste0("Q", 1:n_sets)))
}

f_cat <- choice ~ assistant + price + usage + extras | -1      # like m2 in the lab
f_num <- choice ~ assistant + price.num + usage + extras | -1  # like m3 in the lab
f_pos <- choice ~ assistant + price + usage + extras           # like m1 (position constants)

set.seed(2026)
reps <- 40
res <- NULL; sig <- NULL
for (n in c(40, 60, 80, 100)) {
  for (r in 1:reps) {
    long <- make_long_data(des, simulate_choices(n))
    dd <- dfidx(long, idx = list(c("ques", "resp.id"), "alt"))
    m2 <- mlogit(f_cat, data = dd)
    m1 <- mlogit(f_pos, data = dd)
    m3 <- mlogit(f_num, data = dd)
    s <- summary(m2)$CoefTable
    b <- coef(m3)
    sig <- rbind(sig, data.frame(n = n, t(s[, "Pr(>|z|)"] < 0.05)))
    res <- rbind(res, data.frame(
      n = n, largest_SE = max(s[, "Std. Error"]),
      share_choosing_free_plan = sum(long$choice[long$price == "0"]) / (n * n_sets),
      false_position_effect = lrtest(m2, m1)$`Pr(>Chisq)`[2] < 0.05,
      price_not_linear = lrtest(m3, m2)$`Pr(>Chisq)`[2] < 0.05,
      wtp_streaming = (b["extrasStorageStreaming"] - b["extrasCloudStorage"]) / -b["price.num"]))
  }
}
true_wtp <- (mu["extrasStorageStreaming"] - mu["extrasCloudStorage"]) /
            (-mu["price20.99"] / 20.99)
cat("Assumed (true) WTP for adding streaming to cloud storage: EUR",
    round(true_wtp, 2), "per month\n\n")
agg <- aggregate(. ~ n, data = res, FUN = mean)
print(round(agg, 3), row.names = FALSE)
cat("\n90% range of the estimated WTP for streaming (EUR/month):\n")
print(round(t(sapply(split(res$wtp_streaming, res$n), quantile, c(0.05, 0.95))), 2))
cat("\nShare of simulations in which each estimate is significant (MNL, 5% level).\n")
cat("Assumed true values:\n"); print(mu)
power_mnl <- aggregate(. ~ n, data = sig, FUN = mean)
print(round(power_mnl, 2), row.names = FALSE)
write.csv(agg, "output/03_simulation_summary.csv", row.names = FALSE)
write.csv(power_mnl, "output/03_power_MNL.csv", row.names = FALSE)

# ---------------------------------------------------------------------------
# The mixed MNL (random coefficients) recovers small effects better, because the
# simple MNL shrinks estimates when people differ a lot (here: in price).
# Fewer repetitions here because each fit takes several seconds.
# Note: mlogit resets the random seed internally when it fits a mixed model,
# so we set a different seed explicitly before simulating each data set.
reps_mixed <- 10
sig_mx <- NULL
for (n in c(40, 60, 80, 100)) {
  for (r in 1:reps_mixed) {
    set.seed(1000 * n + r)
    dd <- dfidx(make_long_data(des, simulate_choices(n)), idx = list(c("ques", "resp.id"), "alt"))
    m2 <- mlogit(f_cat, data = dd)
    rp <- rep("n", length(m2$coef)); names(rp) <- names(m2$coef)
    mx <- mlogit(f_cat, data = dd, panel = TRUE, rpar = rp, correlation = FALSE)
    p <- summary(mx)$CoefTable[names(mu), "Pr(>|z|)"]
    sig_mx <- rbind(sig_mx, data.frame(n = n, t(p < 0.05)))
  }
}
cat("\nShare of simulations in which each average estimate is significant (mixed MNL):\n")
power_mx <- aggregate(. ~ n, data = sig_mx, FUN = mean)
print(round(power_mx, 2), row.names = FALSE)
write.csv(power_mx, "output/03_power_mixedMNL.csv", row.names = FALSE)

# ---------------------------------------------------------------------------
# One mixed MNL with n = 80, exactly as in the lab, to check that it is estimable
set.seed(80)
long <- make_long_data(des, simulate_choices(80))
dd <- dfidx(long, idx = list(c("ques", "resp.id"), "alt"))
m2 <- mlogit(f_cat, data = dd)
rpar <- rep("n", length(m2$coef)); names(rpar) <- names(m2$coef)
mx <- mlogit(f_cat, data = dd, panel = TRUE, rpar = rpar, correlation = FALSE)
cat("\nMixed MNL with n = 80 (uncorrelated random effects):\n")
print(round(summary(mx)$CoefTable, 3))
print(lrtest(m2, mx))
write.csv(long, "output/03_example_simulated_data_n80.csv", row.names = FALSE)
