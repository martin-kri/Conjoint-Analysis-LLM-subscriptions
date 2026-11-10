###########################################################################
### LLM subscriptions - Step 2: choose the 12-question D-optimal design  ###
### and balance which assistant appears in which position               ###
###                                                                       ###
### Before running: set the working directory to THIS folder             ###
### Runtime: about 3-4 minutes                                           ###
###########################################################################
suppressMessages({library(idefix); library(MASS)})
source("00_settings_and_helpers.R")
n_sets <- 12
beta <- c(mu, free = mu_free)

# Generate 6 x 8 = 48 candidate designs (different random starts)
cands <- unlist(lapply(1:6, function(s) doptimal_designs(n_sets = n_sets, seed = 100 + s)),
                recursive = FALSE)
summ <- do.call(rbind, lapply(seq_along(cands), function(i) data.frame(
  id = i, largest_SE_n80 = round(max(mnl_se(to_X(cands[[i]]), beta, 80)), 3),
  t(dominance_counts(cands[[i]])), same_assistant_twice = dup_assistant(cands[[i]]))))

# Rule: no strictly dominated question, efficiency within 10% of the best design,
# then prefer designs where each question shows three different assistants,
# then fewer near-dominated questions, then lower standard errors.
write.csv(summ, "output/02_all_candidates.csv", row.names = FALSE)
best <- min(summ$largest_SE_n80)
ok <- subset(summ, strictly_dominated == 0 & largest_SE_n80 <= 1.10 * best)
ok <- ok[order(ok$same_assistant_twice, ok$near_dominated, ok$largest_SE_n80), ]
cat("Best candidates (within 10% of the most efficient design):\n")
print(head(ok, 8), row.names = FALSE)
chosen <- cands[[ok$id[1]]]

# Balance assistant x position: reorder the 3 paid plans inside each question
# (the free option always stays last). Efficiency does not change, because the
# model without position constants ignores the order of the alternatives.
set.seed(7)
imbalance <- function(d) {
  tab <- table(factor(d$ALT, 1:n_products), factor(d$assistant, attrib$assistant))
  sum((tab - n_sets / 3)^2)
}
best_d <- chosen; best_val <- imbalance(chosen)
for (it in 1:20000) {
  d <- do.call(rbind, lapply(split(chosen, chosen$QES), function(x) {
    x <- x[sample(n_products), ]; x$ALT <- 1:n_products; x }))
  v <- imbalance(d)
  if (v < best_val) { best_val <- v; best_d <- d }
  if (best_val == 0) break
}
chosen <- best_d[order(best_d$QES, best_d$ALT), ]; rownames(chosen) <- NULL

cat("\nChosen design: largest SE at n = 80:", round(max(mnl_se(to_X(chosen), beta, 80)), 3), "\n")
print(dominance_counts(chosen))
cat("\nAssistant by position (paid plans only):\n")
print(table(position = chosen$ALT, assistant = chosen$assistant))
cat("\nHow often each level appears (36 paid-plan profiles):\n")
for (a in names(attrib)) print(table(chosen[[a]])[attrib[[a]]])
cat("\nStandard errors of each estimate for n = 60 / 80 / 100:\n")
print(round(rbind(n60 = mnl_se(to_X(chosen), beta, 60), n80 = mnl_se(to_X(chosen), beta, 80),
                  n100 = mnl_se(to_X(chosen), beta, 100)), 3))

write.csv(chosen, "output/02_chosen_design_12q.csv", row.names = FALSE)
