###########################################################################
### LLM subscriptions - Step 1: compare candidate experimental designs   ###
### (course scripts: Fractional_Factorial_Designs.R, Optimal_Designs.R)  ###
###                                                                       ###
### Before running: set the working directory to THIS folder, e.g.       ###
### RStudio > Session > Set Working Directory > To Source File Location  ###
### Runtime: about 2-4 minutes                                           ###
###########################################################################
suppressMessages({library(support.CEs); library(idefix); library(MASS)})
source("00_settings_and_helpers.R")

# Turn a support.CEs design into a list of blocks (one data frame per block)
from_support_CEs <- function(d) {
  x <- do.call(rbind, d$alternatives)
  names(x)[1:3] <- c("BLOCK", "QES", "ALT")
  for (v in c("BLOCK", "QES", "ALT")) x[[v]] <- as.numeric(as.character(x[[v]]))
  for (a in names(attrib)) x[[a]] <- as.character(x[[a]])
  lapply(split(x, x$BLOCK), function(b) b[order(b$QES, b$ALT), c("QES", "ALT", names(attrib))])
}

designs <- list()   # each element is a list of blocks

# 1) Rotation design (support.CEs): 9 questions, one questionnaire for everyone
designs$rotation_9q <- from_support_CEs(
  rotation.design(attribute.names = attrib, nalternatives = n_alts,
                  nblocks = 1, randomize = FALSE, seed = 999))

# 2) L^MA design (support.CEs): 27 questions, split into 3 blocks of 9.
#    Each respondent would answer only one block (3 versions of the survey).
designs$LMA_27q_3blocks <- from_support_CEs(
  Lma.design(attribute.names = attrib, nalternatives = n_alts, nblocks = 3, seed = 999))

# 3) D-optimal designs (idefix) with 9, 12 and 15 questions, one questionnaire.
#    For each size we keep the most efficient of 8 random starts.
for (nq in c(9, 12, 15)) {
  cands <- doptimal_designs(n_sets = nq, seed = 2026 + nq)
  se80 <- sapply(cands, function(d) max(mnl_se(d, mu, 80)))
  designs[[paste0("Doptimal_", nq, "q")]] <- list(cands[[which.min(se80)]])
}

# ---- Compare: standard errors of the part-worths for different sample sizes
all_questions <- function(blocks) do.call(rbind, lapply(seq_along(blocks), function(i) {
  x <- blocks[[i]]; x$QES <- x$QES + 1000 * i; x }))
res <- NULL
for (d in names(designs)) for (n in c(40, 60, 80, 100)) {
  se <- mnl_se(designs[[d]], mu, n)
  res <- rbind(res, data.frame(design = d,
                               questions_per_person = length(unique(designs[[d]][[1]]$QES)),
                               versions = length(designs[[d]]), n = n,
                               largest_SE = round(max(se), 3), average_SE = round(mean(se), 3)))
}
checks <- t(sapply(designs, function(b) { a <- all_questions(b)
  c(questions = length(unique(a$QES)), dominance_counts(a),
    same_assistant_twice = dup_assistant(a), identical_plans = identical_plans(a)) }))

cat("\n=== Questions with a 'no-brainer' plan (lower is better) ===\n"); print(checks)
cat("\n=== Asymptotic standard errors of the MNL estimates (lower is better) ===\n")
print(res, row.names = FALSE)

write.csv(res, "output/01_design_comparison.csv", row.names = FALSE)
for (d in names(designs)) {
  a <- do.call(rbind, lapply(seq_along(designs[[d]]), function(i) cbind(BLOCK = i, designs[[d]][[i]])))
  write.csv(a, paste0("output/01_design_", d, ".csv"), row.names = FALSE)
}
