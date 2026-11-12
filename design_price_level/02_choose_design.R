###########################################################################
### LLM subscriptions - Step 2: choose the 12-question D-optimal design  ###
### and balance which assistant appears in which position               ###
###                                                                       ###
### Before running: set the working directory to THIS folder             ###
### Runtime: about 3-5 minutes                                           ###
###########################################################################
suppressMessages({library(idefix); library(MASS)})
source("00_settings_and_helpers.R")
n_sets <- 12

# Generate 6 x 8 = 48 candidate designs (different random starts)
cands <- unlist(lapply(1:6, function(s) doptimal_designs(n_sets = n_sets, seed = 100 + s)),
                recursive = FALSE)
summ <- do.call(rbind, lapply(seq_along(cands), function(i) data.frame(
  id = i, largest_SE_n80 = round(max(mnl_se(cands[[i]], mu, 80)), 3),
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

# Balance assistant x position: reorder the 3 plans inside each question.
# Efficiency does not change, because the model without position constants
# ignores the order of the alternatives.
set.seed(7)
imbalance <- function(d) {
  tab <- table(factor(d$ALT, 1:n_alts), factor(d$assistant, attrib$assistant))
  sum((tab - n_sets / 3)^2)
}
best_d <- chosen; best_val <- imbalance(chosen)
for (it in 1:20000) {
  d <- do.call(rbind, lapply(split(chosen, chosen$QES), function(x) {
    x <- x[sample(n_alts), ]; x$ALT <- 1:n_alts; x }))
  v <- imbalance(d)
  if (v < best_val) { best_val <- v; best_d <- d }
  if (best_val == 0) break
}
chosen <- best_d[order(best_d$QES, best_d$ALT), ]; rownames(chosen) <- NULL

cat("\nChosen design: largest SE at n = 80:", round(max(mnl_se(chosen, mu, 80)), 3), "\n")
print(c(dominance_counts(chosen), same_assistant_twice = dup_assistant(chosen),
        forbidden_free_plans = forbidden_plans(chosen)))
cat("\nFree plans in the design (never 10x usage, never streaming):\n")
print(chosen[chosen$price == "0", c("QES", "assistant", "usage", "extras")], row.names = FALSE)
cat("\nAssistant by position:\n")
print(table(position = chosen$ALT, assistant = chosen$assistant))
cat("\nHow often each level appears (36 plans in total):\n")
for (a in names(attrib)) print(table(chosen[[a]])[attrib[[a]]])
cat("\nQuestions that contain a free (EUR 0) plan:",
    sum(sapply(split(chosen$price, chosen$QES), function(x) any(x == "0"))), "of", n_sets, "\n")
cat("\nStandard errors of each estimate for n = 40 / 60 / 80 / 100:\n")
print(round(rbind(n40 = mnl_se(chosen, mu, 40), n60 = mnl_se(chosen, mu, 60),
                  n80 = mnl_se(chosen, mu, 80), n100 = mnl_se(chosen, mu, 100)), 3))

# Price is not shown equally often with every assistant: an efficient design
# tends to give the assistant assumed to be preferred the higher prices. The
# effects stay separable; the standard errors above already account for it.
cat("\nAssistant by price (number of plans):\n")
print(table(assistant = factor(chosen$assistant, attrib$assistant),
            price = factor(chosen$price, attrib$price)))

# Robustness: the design was built on prior guesses. How precise is it if the
# true part-worths are different? Compared with the rotation design from step 1,
# which does not depend on any prior. Largest SE and D-error for n = 60.
rot_file <- "output/01_design_rotation_9q.csv"
rot <- if (file.exists(rot_file)) read.csv(rot_file, colClasses = "character") else NULL
if (!is.null(rot)) { rot$QES <- as.integer(rot$QES); rot$ALT <- as.integer(rot$ALT) }
robust <- t(sapply(scenarios, function(b) c(
  largest_SE_chosen = max(mnl_se(chosen, b, 60)),
  largest_SE_rotation = if (is.null(rot)) NA else max(mnl_se(rot, b, 60)),
  D_error_chosen = d_error(chosen, b),
  D_error_rotation = if (is.null(rot)) NA else d_error(rot, b))))
cat("\nRobustness to wrong prior guesses (n = 60; lower is better):\n")
print(round(robust, 3))
write.csv(data.frame(scenario = rownames(robust), round(robust, 3)),
          "output/02_robustness.csv", row.names = FALSE)

write.csv(chosen, "output/02_chosen_design_12q.csv", row.names = FALSE)
