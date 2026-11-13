# What is a paid AI assistant worth? A choice-based conjoint study

A choice-based conjoint study of AI assistant plans (ChatGPT, Gemini, Claude). It measures how much people value more usage, bundled extras and the brand itself, in euros per month, and how strongly a free plan pulls people away from paid ones.

**Status (13 November 2026): the design is final.** We field `design_price_level/`: 12 questions, free as one of the three price levels (EUR 0), one questionnaire for everyone, and no "free super plans". The alternatives we considered are kept in `archive/`.

## Research questions

- How price-sensitive are people, and how much more attractive is a free plan than a paid one?
- What is each feature worth in euros per month: more usage, cloud storage, a streaming bundle?
- Is there a brand premium between the three assistants?
- Is a streaming bundle priced in line with what people value? Google charges students EUR 7.50 a month more to add YouTube Premium to its AI plan.
- Do people differ, and do groups such as heavy users, paying users or former free-trial users choose differently?

## The design

Every question shows three plans, one from each assistant, and the respondent picks one. A plan is described by four attributes with three levels each.

| Attribute | Levels | Why these levels |
|---|---|---|
| Assistant | ChatGPT / Gemini / Claude | The three main assistants; the part-worth captures brand value, including perceived quality and familiarity |
| Monthly price | EUR 0 / 7.99 / 20.99 | Free, a low-cost tier (ChatGPT Go costs about EUR 8) and about the regular price of a paid plan |
| Usage | 1x / 4x / 10x the free version | How providers describe limits; "EUR 0, 1x, nothing extra" is today's free tier |
| Included extras | Nothing extra / Cloud storage / Cloud storage + music & video streaming | Bundling, as in Google's offers; each level adds to the previous one |

**Restriction.** A free plan never has 10x usage or the streaming bundle. Such "free super plans" would win almost every question and teach us nothing. They are removed from the candidate plans before the design is built (Rao 2014, section 2.5.8). The cost in precision is small: the largest standard error at 80 respondents is 0.151, against 0.145 for the earlier unrestricted design.

**The 12 questions** come from a Bayesian D-optimal design (`idefix`), the best of 48 candidates. The chosen design:

- shows ChatGPT, Gemini and Claude once in every question, each 4 times in each position;
- has no plan that is the same assistant and worse on everything than another plan in its question;
- has 3 questions where one plan beats another on price, usage and extras but comes from a different assistant, which shows how strong brand loyalty is;
- has 7 free plans, one in each of 7 questions: 2 are today's free tier, the others add cloud storage, 4x usage, or both;
- does not show price equally often with each assistant (Claude appears at EUR 20.99 twice, ChatGPT five times). Efficient designs do this to keep choices balanced; the effects stay separable and the standard errors account for it.

Example (question 1):

| | Option A | Option B | Option C |
|---|---|---|---|
| Assistant | Gemini | Claude | ChatGPT |
| Price | EUR 20.99 / month | EUR 7.99 / month | Free (EUR 0) |
| Usage | 4x the free version | 10x the free version | Same as today's free version |
| Extras | Cloud storage + streaming | Cloud storage | Nothing extra |

The full questionnaire is in `design_price_level/output/04_questionnaire.txt`.

## Why this design

We compared the options below by simulation before deciding. The numbers come from the output files in this repo.

**Free as a price level, not a separate "stay free" answer.** The lecturer accepted EUR 0 as a price level and plans that do not exist today. Every answer then compares plans: with 80 respondents a medium-sized effect (Claude vs ChatGPT) is detected in 94% of simulations, against 71% when "I would keep using only the free versions" is a fourth answer, because about 37% of those answers say nothing about the paid plans. Part of that gap comes from assuming people differ a lot in how attractive staying free is. The model is the plain multinomial logit from the labs, with 8 parameters.

**12 questions, not 15.** Fifteen questions make standard errors about 9% smaller, which is worth roughly 20% more respondents, but with 40 to 60 respondents they detect medium effects only 2 to 4 points more often, which is within simulation noise. We chose the shorter survey. The 15-question design is in `archive/design_price_level_15q/`. Do not shorten it by deleting questions: each design is optimized as a whole.

**One questionnaire, no groups.** Splitting respondents into groups with different questions helps designs that need more questions than one person can answer. With four attributes of three levels the rotation design needs only 9 questions, and the L^MA design needs 27 (three groups of 9). Neither can be used here as it stands: the rotation design contains 5 forbidden free plans and the L^MA design 16. The L^MA design is also less precise than one D-optimal questionnaire and contains dominated and duplicate plans.

**Comparison of designs** (largest standard error among the part-worths with 80 respondents; lower is better):

| Design | Questions per person | Versions | Largest SE | Forbidden free plans |
|---|---|---|---|---|
| Rotation (orthogonal) | 9 | 1 | 0.151 | 5 |
| L^MA (27 questions in 3 blocks) | 9 | 3 | 0.163 | 16 |
| D-optimal | 9 | 1 | 0.182 | 0 |
| **D-optimal, chosen** | **12** | **1** | **0.151** | **0** |
| D-optimal | 15 | 1 | 0.130 | 0 |

**Robustness to wrong priors.** A D-optimal design depends on prior guesses of the part-worths. Re-evaluated under eight sets of "true" values (the prior itself, no effects, half or twice as strong, reversed brand order, a much stronger or weaker price effect, free valued as special), the chosen design has a lower D-error than the 9-question rotation design in all eight. Its largest standard error is higher than the rotation design's when the true effects are much weaker than assumed, where all standard errors are small anyway, and marginally when the brand order is reversed (`design_price_level/output/02_robustness.csv`).

## Sample size

A Monte Carlo simulation draws respondents with different part-worths, simulates their answers to the 12 questions and fits the models with `mlogit`: 200 repetitions per sample size for the multinomial logit, 30 for the mixed logit. "Detected" means significant at the 5% level.

| Respondents | Largest SE | Claude vs ChatGPT detected (medium effect) | Streaming bundle detected | 90% range of the streaming value |
|---|---|---|---|---|
| 40 | 0.205 | 69% | 88% | EUR 0.06 to 5.97 |
| 60 | 0.168 | 82% | 96% | EUR 0.55 to 5.26 |
| 80 | 0.144 | 94% | 100% | EUR 1.17 to 5.29 |
| 100 | 0.129 | 94% | 100% | EUR 1.31 to 4.61 |

- Price and 10x usage are detected in at least 95% of simulations already with 40 respondents.
- Small effects (0.2 on the logit scale, such as Gemini vs ChatGPT or cloud storage) are detected in only 20% to 49% of simulations. In the report that is a finding, "no clear difference", not a failure.
- The assumed value of the streaming bundle is EUR 2.86, so every sample size above can tell whether people value it below Google's EUR 7.50.
- About 28% of answers pick a free plan.
- The mixed logit can be estimated with 40 respondents or more, and it finds the medium effect more often (97% at 80 respondents).
- With 40 to 60 respondents, segments of 15 to 20 people are small, so segmentation results must be described cautiously.
- The likelihood-ratio test of price as a number rejected a straight line in 11% to 17% of simulations, even though the assumed price effect was a straight line. People differ a lot in price sensitivity, which the simple logit ignores; read that test together with the mixed logit.

## Planned analysis

1. Descriptives: who answered, how often each level was chosen, how often a free plan was chosen.
2. Multinomial logit, with a test for position effects and a test of price as a number against price as categories.
3. Willingness to pay per feature. If free turns out to be valued as special (Shampanier et al. 2007), euro values are computed from the step between EUR 7.99 and EUR 20.99 only; script 03 already reports this fallback.
4. Preference shares for market scenarios with bootstrap confidence intervals, for example today's three free tiers next to low-cost and regular plans, and a sensitivity chart.
5. Mixed logit for differences between people; individual part-worths compared across the profile groups.
6. Segmentation of respondents on their part-worths (PAM clustering, silhouette width), described with the profile questions.


## Survey protocol

- Levels and wording are frozen before launch; everyone gets the same 12 questions.
- Answers are recorded as option letters (positions), never as brand names, and every choice question is required.
- Question order may be shuffled as long as each question keeps its own ID (Q1 to Q12).
- Pilot with 3 to 5 people first; team members do not answer.
- There is no screening. Profile questions at the end are used to compare groups: assistants used in the last month, main assistant for study or work and for everyday use, current and past paid or discounted plans, how often free limits are hit, student / working / both, field of study, age, gender.

**Data format.** One row per option shown: `resp.id, ques, alt, assistant, price, usage, extras, price.num, choice`. `make_long_data()` in script 03 builds it from a table of chosen options (`Q1 ... Q12`).

## Limitations

- **Convenience sample**, mostly students; results are not representative of all users.
- **Stated choices.** The outputs are preference shares, not market shares.
- **Some plans do not exist today**, such as a free plan with 4x usage; the introduction tells respondents so.
- **Only three prices, one of them zero.** A special value of "free" cannot be separated from a curved price effect, and values between EUR 7.99 and 20.99 rest on a straight-line assumption.
- **Main effects only.** Interactions, such as streaming being worth more with one assistant, are not estimated.
- **Brand mixes several things**: perceived quality, familiarity and the name itself.
- **Usage is a label.** "4x the free version" means different things to different people; we measure the value of the label firms actually use.

## Repository

| File / folder | What it is |
|---|---|
| `design_price_level/` | **The final design**: scripts and results |
| `archive/` | Designs we considered and did not field (see `archive/README.md`) |
| `install_packages.R` | Installs the R packages (run once) |
| `references/sources.md` | Price sources and literature |
| `AI_usage_log.md` | Record of how AI assistance was used |

Scripts in `design_price_level/`:

| Script | What it does | Runtime |
|---|---|---|
| `00_settings_and_helpers.R` | Attributes, levels, restriction, prior guesses and helper functions; sourced by the other scripts | - |
| `01_compare_designs.R` | Builds the rotation, L^MA and D-optimal designs and compares their precision | 1-3 min |
| `02_choose_design.R` | Picks the best of 48 D-optimal designs, balances assistant by position, checks robustness | 2-4 min |
| `03_sample_size_simulation.R` | Monte Carlo simulation of precision and power for 40 to 100 respondents | 10-20 min |
| `04_print_questionnaire.R` | Prints the 12 questions in readable form | seconds |

To reproduce: run `install_packages.R`, set the working directory to `design_price_level/`, then run scripts 01 to 04 in order. Seeds are fixed; every output was reproduced exactly from a clean copy on 13 November 2026 with R 4.3.3, support.CEs 0.7.0, idefix 1.1.0 and mlogit 2.0.0.

## References

- Aizaki, H. (2012). Basic functions for supporting an implementation of choice experiments in R. *Journal of Statistical Software*, 50(Code Snippet 2).
- Bansak, K., Hainmueller, J., Hopkins, D. J., & Yamamoto, T. (2018). The number of choice tasks and survey satisficing in conjoint experiments. *Political Analysis*, 26(1).
- Chapman, C., & Feit, E. M. (2019). *R for Marketing Research and Analytics* (2nd ed.). Springer.
- Croissant, Y. (2020). Estimation of random utility models in R: The mlogit package. *Journal of Statistical Software*, 95(11).
- Johnson, R. M., & Orme, B. K. (1996). How many questions should you ask in choice-based conjoint studies? Sawtooth Software Research Paper Series.
- Louviere, J. J., Hensher, D. A., & Swait, J. D. (2000). *Stated Choice Methods: Analysis and Applications*. Cambridge University Press.
- Rao, V. R. (2014). *Applied Conjoint Analysis*. Springer.
- Shampanier, K., Mazar, N., & Ariely, D. (2007). Zero as a special price: The true value of free products. *Marketing Science*, 26(6).
- Traets, F., Sanchez, D. G., & Vandebroek, M. (2020). Generating optimal designs for discrete choice experiments in R: The idefix package. *Journal of Statistical Software*, 96(3).
