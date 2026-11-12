###########################################################################
options(width = 200)
### LLM subscriptions - Step 4: print the questionnaire in readable form ###
### (to copy into Google Forms or to turn into images)                   ###
###                                                                       ###
### Before running: set the working directory to THIS folder             ###
###########################################################################
source("00_settings_and_helpers.R")
des <- read.csv("output/02_chosen_design_12q.csv", colClasses = "character")
des$QES <- as.integer(des$QES); des$ALT <- as.integer(des$ALT)
opt_names <- c("Option A", "Option B", "Option C")
rows <- c("Assistant", "Price", "Usage", "Included extras")

intro <- c(
  "INTRODUCTION SHOWN TO RESPONDENTS (draft)",
  "Imagine that next semester you choose ONE AI assistant plan, mainly for your studies/work.",
  "In each of the following 12 questions you will see three plans. Some are free, some are paid.",
  "Usage is described as providers do: as a multiple of what today's free version allows.",
  "Some plans may not exist in reality. Plans differ only in the characteristics shown.",
  "Please choose the plan you would really pick.",
  "")

out <- intro
wide <- NULL
for (q in sort(unique(des$QES))) {
  d <- des[des$QES == q, ][order(des$ALT[des$QES == q]), ]
  tab <- rbind(labels$assistant[d$assistant], labels$price[d$price],
               labels$usage[d$usage], labels$extras[d$extras])
  dimnames(tab) <- list(rows, opt_names)
  out <- c(out, sprintf("Question %d of %d: Which plan would you choose?", q, max(des$QES)),
           capture.output(print(noquote(tab))), "")
  wide <- rbind(wide, data.frame(question = q, row = rows, tab, check.names = FALSE))
}
writeLines(out, "output/04_questionnaire.txt")
write.csv(wide, "output/04_questionnaire_table.csv", row.names = FALSE)
cat(out, sep = "\n")
