###########################################################################
### LLM subscriptions - choice-based conjoint                            ###
### Settings (attributes, levels, prior guesses) and helper functions   ###
### This file is sourced by the other scripts in this folder.           ###
###########################################################################

# Attributes and levels. The first level of each attribute is the reference.
attrib <- list(assistant = c("ChatGPT", "Gemini", "Claude"),
               price     = c("5.49", "12.99", "21.99"),          # EUR per month
               usage     = c("2x", "4x", "10x"),                  # x the free version
               extras    = c("NoExtras", "CloudStorage", "StorageStreaming"))

# Labels shown to respondents in the questionnaire
labels <- list(
  assistant = c(ChatGPT = "ChatGPT", Gemini = "Gemini", Claude = "Claude"),
  price     = c("5.49" = "EUR 5.49 / month", "12.99" = "EUR 12.99 / month",
                "21.99" = "EUR 21.99 / month"),
  usage     = c("2x" = "2x the free version", "4x" = "4x the free version",
                "10x" = "10x the free version"),
  extras    = c(NoExtras = "Nothing extra", CloudStorage = "Cloud storage",
                StorageStreaming = "Cloud storage + music & video streaming"))
free_option_label <- "I would keep using only the free versions"

n_products <- 3          # paid plans shown in each question
n_alts     <- 4          # 3 paid plans + the free option (always last)

# Prior guesses of the average part-worths (dummy coding, reference = first level).
# Deliberately modest, so the checks are conservative. They are ONLY used to build
# an efficient design and to simulate data; the real values come from the survey.
mu <- c(assistantGemini = -0.2, assistantClaude = -0.4,
        price12.99 = -0.9, price21.99 = -1.8,
        usage4x = 0.3, usage10x = 0.5,
        extrasCloudStorage = 0.2, extrasStorageStreaming = 0.5)
mu_free <- 0.3           # utility of "keep using the free versions" (about 40% choose it)

# ---------------------------------------------------------------------------
# Build, for every question, the model matrix of its 4 alternatives
# (3 paid plans + free option). Columns: attribute dummies + "free" constant.
to_X <- function(des) {
  des <- des[order(des$QES, des$ALT), ]
  for (a in names(attrib)) des[[a]] <- factor(des[[a]], levels = attrib[[a]])
  X <- model.matrix(~ assistant + price + usage + extras, data = des)[, -1]
  X <- cbind(X, free = 0)
  lapply(split.data.frame(X, des$QES), function(x) rbind(x, c(rep(0, ncol(x) - 1), 1)))
}

# Asymptotic standard errors of the MNL estimates for n respondents
# (inverse of the Fisher information at the prior values)
mnl_se <- function(Xlist, beta, n) {
  info <- Reduce(`+`, lapply(Xlist, function(X) {
    p <- as.vector(exp(X %*% beta)); p <- p / sum(p)
    t(X) %*% (diag(p) - p %*% t(p)) %*% X
  }))
  sqrt(diag(solve(n * info)))
}

# Ordinal coding used to detect "no-brainer" questions (1 = best level)
ordinal_matrix <- function(des) cbind(
  price  = match(des$price, attrib$price),            # cheaper is better
  usage  = 4 - match(des$usage, attrib$usage),        # more usage is better
  extras = 4 - match(des$extras, attrib$extras))      # more extras is better

# Near-dominated question: one paid plan is at least as good as another on price,
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

# Generate D-optimal designs with idefix (Optimal_Designs.R), including the free option
doptimal_designs <- function(n_sets, seed, n_start = 8, n_draws = 10) {
  set.seed(seed)
  prof.set <- idefix::Profiles(lvls = c(3, 3, 3, 3), coding = rep("D", 4))
  draws <- MASS::mvrnorm(n = n_draws, mu = c(mu_free, mu),
                         Sigma = diag(0.2, length(mu) + 1))
  par.draws <- list(matrix(draws[, 1], ncol = 1), draws[, -1])  # free constant, attributes
  opt <- idefix::Modfed(cand.set = prof.set, n.sets = n_sets, n.alts = n_alts,
                        par.draws = par.draws, alt.cte = c(0, 0, 0, 1),
                        no.choice = TRUE, parallel = FALSE, n.start = n_start)
  alld <- Filter(function(z) is.list(z) && !is.null(z$design), opt$AllDesigns)
  lapply(alld, function(z) {
    dec <- idefix::Decode(des = z$design, n.alts = n_alts, lvl.names = attrib,
                          coding = rep("D", 4), alt.cte = c(0, 0, 0, 1),
                          no.choice = n_alts)$design
    dec <- dec[!apply(is.na(dec), 1, all), ]        # drop the empty free-option rows
    names(dec) <- names(attrib)
    dec$QES <- rep(1:n_sets, each = n_products); dec$ALT <- rep(1:n_products, n_sets)
    dec[, c("QES", "ALT", names(attrib))]
  })
}

dir.create("output", showWarnings = FALSE)
