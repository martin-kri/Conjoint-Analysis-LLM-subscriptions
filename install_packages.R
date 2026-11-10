###########################################################################
### Run this ONCE to install the R packages used in this project         ###
###########################################################################
pkgs <- c("support.CEs",  # fractional factorial designs (rotation, mix-and-match, L^MA)
          "idefix",       # D-optimal designs
          "MASS",         # mvrnorm() for simulations
          "mlogit",       # MNL and mixed MNL models
          "lme4",         # multilevel linear model (traditional conjoint, if needed)
          "cluster",      # pam() for post-hoc segmentation
          "lattice", "vcd")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing) > 0) install.packages(missing)
invisible(lapply(pkgs, library, character.only = TRUE))
cat("All packages are installed and load correctly.\n")
print(sapply(pkgs, function(p) as.character(packageVersion(p))))
