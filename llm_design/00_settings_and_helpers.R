###########################################################################
### LLM subscriptions - choice-based conjoint                            ###
### Settings (attributes, levels, prior guesses) and helper functions   ###
### This file is sourced by the other scripts in this folder.           ###
###########################################################################

# Attributes and levels. The first level of each attribute is the reference.
# After the lecturer's feedback (12 Nov): "free" is a level of price (EUR 0),
# so there is no separate "keep using the free versions" option any more.
attrib <- list(assistant = c("ChatGPT", "Gemini", "Claude"),
               price     = c("0", "7.99", "20.99"),               # EUR per month
               usage     = c("1x", "4x", "10x"),                  # x the free version
               extras    = c("NoExtras", "CloudStorage", "StorageStreaming"))

# Labels shown to respondents in the questionnaire
labels <- list(
  assistant = c(ChatGPT = "ChatGPT", Gemini = "Gemini", Claude = "Claude"),
  price     = c("0" = "Free (EUR 0)", "7.99" = "EUR 7.99 / month",
                "20.99" = "EUR 20.99 / month"),
  usage     = c("1x" = "Same as today's free version", "4x" = "4x the free version",
                "10x" = "10x the free version"),
  extras    = c(NoExtras = "Nothing extra", CloudStorage = "Cloud storage",
                StorageStreaming = "Cloud storage + music & video streaming"))

n_alts <- 3              # plans shown in each question

# Prior guesses of the average part-worths (dummy coding, reference = first level).
# Deliberately modest, so the checks are conservative. They are ONLY used to build
# an efficient design and to simulate data; the real values come from the survey.
# Price: about -0.105 per euro (EUR 7.99 -> -0.84, EUR 20.99 -> -2.20).
mu <- c(assistantGemini = -0.2, assistantClaude = -0.4,
        price7.99 = -0.84, price20.99 = -2.2,
        usage4x = 0.4, usage10x = 0.6,
        extrasCloudStorage = 0.2, extrasStorageStreaming = 0.5)

# ---------------------------------------------------------------------------
# Build, for every question, the model matrix of its 3 alternatives
to_X <- function(des) {
  des <- des[order(des$QES, des$ALT), ]
  for (a in names(attrib)) des[[a]] <- factor(des[[a]], levels = attrib[[a]])
  X <- model.matrix(~ assistant + price + usage + extras, data = des)[, -1]
  split.data.frame(X, des$QES)
}

# Fisher information of the MNL for ONE respondent answering these questions
mnl_info <- function(Xlist, beta) Reduce(`+`, lapply(Xlist, function(X) {
  p <- as.vector(exp(X %*% beta)); p <- p / sum(p)
  t(X) %*% (diag(p) - p %*% t(p)) %*% X
}))

# Asymptotic standard errors of the MNL estimates for n respondents.
# "blocks" is a list of questionnaires (one data frame per block); the n
# respondents are split equally between the blocks. One block = everyone
# answers the same questions.
mnl_se <- function(blocks, beta, n) {
  if (is.data.frame(blocks)) blocks <- list(blocks)
  info <- Reduce(`+`, lapply(blocks, function(b) (n / length(blocks)) * mnl_info(to_X(b), beta)))
  sqrt(diag(solve(info)))
}

# Ordinal coding used to detect "no-brainer" questions (1 = best level)
ordinal_matrix <- function(des) cbind(
  price  = match(des$price, attrib$price),            # cheaper is better
  usage  = 4 - match(des$usage, attrib$usage),        # more usage is better
  extras = 4 - match(des$extras, attrib$extras))      # more extras is better

# Near-dominated question: one plan is at least as good as another on price,
# usage and extras (ignoring the assistant). Strictly dominated: same assistant too.
dominance_counts <- function(des) {
  des <- des[order(des$QES, des$ALT), ]
  M <- ordinal_matrix(des)
  near <- strict <- 0
  for (q in unique(des$QES)) {
    idx <- which(des$QES == q); hn <- hs <- FALSE
    for (i in idx) for (j in idx) if (i != j && all(M[i, ] <= M[j, ]) && any(M[i, ] < M[j, ])) {
      hn <- TRUE
      if (des$assistant[i] == des$assistant[j]) hs <- TRUE
    }
    near <- near + hn; strict <- strict + hs
  }
  c(near_dominated = near, strictly_dominated = strict)
}

# Number of questions in which the same assistant appears twice
dup_assistant <- function(des)
  sum(sapply(split(des$assistant, des$QES), function(x) any(duplicated(x))))

# Number of questions that contain two identical plans
identical_plans <- function(des)
  sum(sapply(split(des[, names(attrib)], des$QES), function(x) any(duplicated(x))))

# Generate D-optimal designs with idefix (Optimal_Designs.R)
doptimal_designs <- function(n_sets, seed, n_start = 8, n_draws = 10) {
  set.seed(seed)
  prof.set <- idefix::Profiles(lvls = c(3, 3, 3, 3), coding = rep("D", 4))
  draws <- MASS::mvrnorm(n = n_draws, mu = mu, Sigma = diag(0.2, length(mu)))
  opt <- idefix::Modfed(cand.set = prof.set, n.sets = n_sets, n.alts = n_alts,
                        par.draws = draws, parallel = FALSE, n.start = n_start)
  alld <- Filter(function(z) is.list(z) && !is.null(z$design), opt$AllDesigns)
  lapply(alld, function(z) {
    dec <- idefix::Decode(des = z$design, n.alts = n_alts, lvl.names = attrib,
                          coding = rep("D", 4))$design
    names(dec) <- names(attrib)
    dec$QES <- rep(1:n_sets, each = n_alts); dec$ALT <- rep(1:n_alts, n_sets)
    dec[, c("QES", "ALT", names(attrib))]
  })
}

dir.create("output", showWarnings = FALSE)
