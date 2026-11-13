###########################################################################
options(width = 200)
### LLM subscriptions - Step 4: print the questionnaire in readable form ###
### (to copy into Google Forms or to turn into images)                   ###
###                                                                       ###
### 15-question variant. Uses the settings (and the step 1 results) of   ###
### ../design_free_option/, so keep both folders side by side.        ###
### Before running: set the working directory to THIS folder             ###
###########################################################################
source("../design_free_option/00_settings_and_helpers.R")   # same settings as the 12-question version
des <- read.csv("output/02_chosen_design_15q.csv", colClasses = "character")
des$QES <- as.integer(des$QES); des$ALT <- as.integer(des$ALT)
opt_names <- c("Option A", "Option B", "Option C", "Option D")
rows <- c("Assistant", "Price", "Usage", "Included extras")

intro <- c(
  "INTRODUCTION SHOWN TO RESPONDENTS (draft)",
  "Imagine that next semester you decide whether to pay for ONE AI assistant, mainly for your studies/work.",
  "In each of the following 15 questions you will see three paid plans and the option to keep using only the free versions.",
  "Usage is described as providers do: as a multiple of the free version (1x = what you get today for free).",
  "Plans differ only in the characteristics shown. Please choose the option you would really pick.",
  "")

out <- intro
wide <- NULL
for (q in sort(unique(des$QES))) {
  d <- des[des$QES == q, ][order(des$ALT[des$QES == q]), ]
  tab <- rbind(labels$assistant[d$assistant], labels$price[d$price],
               labels$usage[d$usage], labels$extras[d$extras])
  tab <- cbind(tab, c(free_option_label, "", "", ""))
  dimnames(tab) <- list(rows, opt_names)
  out <- c(out, sprintf("Question %d of %d: Which option would you choose?", q, max(des$QES)),
           capture.output(print(noquote(tab))), "")
  wide <- rbind(wide, data.frame(question = q, row = rows, tab, check.names = FALSE))
}
writeLines(out, "output/04_questionnaire.txt")
write.csv(wide, "output/04_questionnaire_table.csv", row.names = FALSE)
cat(out, sep = "\n")
