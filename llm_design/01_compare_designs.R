###########################################################################
### LLM subscriptions - Step 1: compare candidate experimental designs   ###
### (course scripts: Fractional_Factorial_Designs.R, Optimal_Designs.R)  ###
###                                                                       ###
### Before running: set the working directory to THIS folder, e.g.       ###
### RStudio > Session > Set Working Directory > To Source File Location  ###
### Runtime: about 2-3 minutes                                           ###
###########################################################################
suppressMessages({library(support.CEs); library(idefix); library(MASS)})
source("00_settings_and_helpers.R")

designs <- list()

# 1) Rotation design (support.CEs), 9 questions; the free option is added as a
#    4th alternative to every question
rot <- rotation.design(attribute.names = attrib, nalternatives = n_products,
                       nblocks = 1, randomize = FALSE, seed = 999)
rot <- do.call(rbind, rot$alternatives)
names(rot)[1:3] <- c("BLOCK", "QES", "ALT")
rot$QES <- as.numeric(as.character(rot$QES)); rot$ALT <- as.numeric(as.character(rot$ALT))
designs$rotation_9q <- rot[order(rot$QES, rot$ALT), c("QES", "ALT", names(attrib))]

# 2) D-optimal designs (idefix) with the free option, 9, 12 and 15 questions.
#    For each size we keep the most efficient of 8 random starts.
for (nq in c(9, 12, 15)) {
  cands <- doptimal_designs(n_sets = nq, seed = 2026 + nq)
  se80 <- sapply(cands, function(d) max(mnl_se(to_X(d), c(mu, free = mu_free), 80)))
  designs[[paste0("Doptimal_", nq, "q")]] <- cands[[which.min(se80)]]
}

# ---- Compare: standard errors of the part-worths for different sample sizes
beta <- c(mu, free = mu_free)
res <- NULL
for (d in names(designs)) {
  X <- to_X(designs[[d]])
  for (n in c(60, 80, 100, 120)) {
    se <- mnl_se(X, beta, n)
    res <- rbind(res, data.frame(design = d, questions = length(X), n = n,
                                 largest_SE = round(max(se), 3),
                                 average_SE = round(mean(se), 3)))
  }
}
checks <- t(sapply(designs, function(d) c(dominance_counts(d),
                                          same_assistant_twice = dup_assistant(d))))

cat("\n=== Questions with a 'no-brainer' paid plan (lower is better) ===\n"); print(checks)
cat("\n=== Asymptotic standard errors of the MNL estimates (lower is better) ===\n")
print(res, row.names = FALSE)

write.csv(res, "output/01_design_comparison.csv", row.names = FALSE)
for (d in names(designs))
  write.csv(designs[[d]], paste0("output/01_design_", d, ".csv"), row.names = FALSE)
