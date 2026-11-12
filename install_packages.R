###########################################################################
### Run this ONCE to install the R packages used in this project         ###
###########################################################################
pkgs <- c("support.CEs",  # orthogonal choice designs (rotation, mix-and-match, L^MA)
          "idefix",       # Bayesian D-optimal designs
          "MASS",         # mvrnorm() for simulations
          "mlogit")       # MNL and mixed MNL models
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing) > 0) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))
cat("All packages are installed and load correctly.\n")
print(sapply(pkgs, function(p) as.character(packageVersion(p))))
