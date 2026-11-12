# What is a paid AI assistant worth? A choice-based conjoint study

A choice-based conjoint study of AI assistant subscriptions (ChatGPT, Gemini, Claude). It measures how much people value more usage, bundled extras and the brand itself, in euros per month, and how many would rather stay on a free plan.

**Status (November 2026):** two candidate survey designs are finished and tested by simulation, each with 12 and with 15 questions. They differ in how the free alternative is offered. One of them will be fielded in late November; the analysis and results will be added afterwards.

## Research questions

- How price-sensitive are people, and how many stay on today's free tiers?
- What is each feature worth in euros per month: more usage, cloud storage, a streaming bundle?
- Is there a brand premium between the three assistants?
- Is a streaming bundle priced in line with what people value? Google charges students EUR 7.50 a month more to add YouTube Premium to its AI plan.
- Do people differ, and do groups such as heavy users or former free-trial users choose differently?

## Two ways to offer "free"

Most people use the free versions, so the survey has to let them stay free. There are two ways to do that, and each is prepared as a complete design in its own folder.

| | Free as a price level (`design_price_level/`) | Free as a fixed option (`design_free_option/`) |
|---|---|---|
| A question shows | 3 plans, some of them free | 3 paid plans + "I would keep using only the free versions" |
| Assistant | ChatGPT / Gemini / Claude | ChatGPT / Gemini / Claude |
| Monthly price | EUR 0 / 7.99 / 20.99 | EUR 5.49 / 12.99 / 21.99 |
| Usage (x the free version) | 1x / 4x / 10x | 2x / 4x / 10x |
| Included extras | Nothing / Cloud storage / Cloud storage + streaming | Nothing / Cloud storage / Cloud storage + streaming |
| Where free appears | In 7 of 12 questions, as a plan of one assistant | In every question |
| Model | Multinomial logit, 8 parameters | Multinomial logit with one extra constant for staying free, 9 parameters |
| "Who would pay at all?" | Answered by simulating a market that contains free tiers | Measured directly in every question |
| Realism | Some plans do not exist today (a free plan with 4x usage) | Every paid plan is plausible; prices are Google's real student and regular prices |
| Is the price effect a straight line? | Cannot be separated from "free is special" (Shampanier et al., 2007) | Testable across three paid prices |

**Restriction in the price-level version.** With free as a price level, an unrestricted design contains "free super plans", such as EUR 0 with 10x usage and the streaming bundle. They cannot exist and would win almost any question. Following Rao (2014, section 2.5.8, on generating acceptable designs), profiles that combine EUR 0 with 10x usage or with streaming are removed from the candidate set before the design is built. The restriction costs almost no precision: the largest standard error at 80 respondents is 0.151, against 0.145 without it.

## Experimental design

Both versions use a Bayesian D-optimal design with 12 questions (`idefix`), the best of 48 candidates, chosen after comparison with orthogonal designs (`support.CEs`). The table shows the largest standard error among the part-worths for 80 respondents (lower is better).

| Design | Questions per person | Survey versions | Price level | Free option |
|---|---|---|---|---|
| Rotation (orthogonal) | 9 | 1 | 0.151 | 0.160 |
| L^MA (27 questions in 3 blocks) | 9 | 3 | 0.163 | 0.174 |
| D-optimal | 9 | 1 | 0.182 | 0.190 |
| **D-optimal (chosen)** | **12** | **1** | **0.151** | **0.151** |
| D-optimal | 15 | 1 | 0.130 | 0.136 |

In the price-level version the orthogonal designs are not usable as they stand: the rotation design contains 5 forbidden free plans and the L^MA design 16.

Properties of both chosen designs:

- Every question shows ChatGPT, Gemini and Claude once each, and each assistant appears 4 times in each position.
- No question has a plan that is the same assistant and worse on everything.
- A few questions (3 in the price-level version, 5 in the free-option version) have a plan that beats another on price, usage and extras but comes from a different assistant. These show how strong brand loyalty is.
- Blocking (several survey versions) was tested and rejected: the L^MA design is less precise and contains dominated and duplicate plans.

**Robustness to wrong priors.** A D-optimal design depends on prior guesses of the part-worths. Each chosen design was re-evaluated under eight alternative sets of "true" values (no effects, effects twice as strong, reversed brand order, a much stronger price effect, and others). Both have a lower D-error than the 9-question rotation design in all eight; part of that is simply the three extra questions. The price-level design has a higher largest standard error than the rotation design when the true effects are much weaker than assumed (and marginally when the brand order is reversed), where all standard errors are small anyway (`output/02_robustness.csv` in each folder).

One known property: price is not shown equally often with each assistant. Efficient designs do this to keep choices balanced; the effects remain separable and the standard errors account for it.

## Sample size

A Monte Carlo simulation draws respondents with different part-worths, simulates their answers to the 12 questions, and fits the models with `mlogit`: 200 repetitions per sample size for the multinomial logit, 30 for the mixed logit. "Detected" means significant at the 5% level.

| Respondents | Price level: largest SE | Claude vs ChatGPT detected | Streaming bundle detected | Free option: largest SE | Claude vs ChatGPT detected | Streaming bundle detected |
|---|---|---|---|---|---|---|
| 40 | 0.205 | 69% | 88% | 0.202 | 42% | 80% |
| 60 | 0.168 | 82% | 96% | 0.165 | 57% | 88% |
| 80 | 0.144 | 94% | 100% | 0.142 | 71% | 97% |
| 100 | 0.129 | 94% | 100% | 0.127 | 76% | 99% |

- The price effect is detected in at least 99% of simulations in both versions, already with 40 respondents.
- The standard errors are the same, but the free-option version detects medium-sized effects less often. In the simulation 37% of its answers go to the free option and say nothing about the paid plans, and people are assumed to differ a lot in how attractive staying free is, which shrinks the pooled estimates. The mixed logit closes part of the gap (Claude vs ChatGPT at 80 respondents: 97% against 87%).
- Value of the streaming bundle with 80 respondents, 90% range of the estimates: EUR 1.17 to 5.29 in the price-level version (true value 2.86), EUR 0.49 to 4.89 in the free-option version (true value 2.75).
- Small effects (0.2 on the logit scale) are detected in only 12% to 52% of simulations in both versions.
- The assumed part-worths differ slightly between the versions because the levels differ, so the comparison is approximate.

With 40 to 60 respondents, which is what a convenience sample of this kind realistically reaches, the large effects are reliable and medium-sized effects are found most of the time in the price-level version.

## 12 or 15 questions

More questions per person partly replace more respondents. A 15-question design was built for each version with the same selection rules (`design_price_level_15q/`, `design_free_option_15q/`) and put through the same simulation.

| Respondents | | Price level, 12 q | Price level, 15 q | Free option, 12 q | Free option, 15 q |
|---|---|---|---|---|---|
| 40 | Largest SE | 0.205 | 0.188 | 0.202 | 0.184 |
| 40 | Claude vs ChatGPT detected | 69% | 72% | 42% | 50% |
| 40 | Streaming bundle detected | 88% | 92% | 80% | 88% |
| 60 | Largest SE | 0.168 | 0.153 | 0.165 | 0.149 |
| 60 | Claude vs ChatGPT detected | 82% | 84% | 57% | 64% |
| 60 | Streaming bundle detected | 96% | 99% | 88% | 96% |

- Standard errors are about 9% smaller with 15 questions, which is worth roughly 20% more respondents: 15 questions with 50 people are about as precise as 12 questions with 60.
- The gain in detected effects is small in the price-level version (2 to 4 points) and larger in the free-option version (about 8 points). With 200 repetitions, differences of 3 to 4 points are within simulation noise.
- The cost is a longer survey, with more risk of fatigue and drop-outs.

## Planned analysis

1. Multinomial logit, with a test for position effects and a test of price as a number against price as categories.
2. Willingness to pay per feature, and preference shares for market scenarios with bootstrap confidence intervals.
3. Mixed logit for differences between people; individual part-worths compared across respondent groups.
4. Segmentation of respondents on their part-worths (PAM clustering, silhouette width).

## Limitations

- **Convenience sample**, mostly students; results are not representative of all users.
- **Stated choices.** The outputs are preference shares, not market shares.
- **Main effects only.** Interactions, such as streaming being worth more with one assistant, are not estimated.
- **Brand mixes several things**: perceived quality, familiarity and the name itself.
- **Price-level version:** some plans shown do not exist today, and values for prices between EUR 7.99 and 20.99 rest on a straight-line assumption.
- **Free-option version:** answers that pick the free option carry no information about the paid plans, so more respondents are needed for the same power.

## Repository

| File / folder | What it is |
|---|---|
| `install_packages.R` | Installs the R packages (run once) |
| `design_price_level/` | Design with free as a price level (EUR 0), restricted to plausible free plans |
| `design_free_option/` | Design with three paid plans and a fixed "stay free" option |
| `design_price_level_15q/`, `design_free_option_15q/` | 15-question variants of the two designs: scripts 02 to 04 only, using the settings and step 1 results of the 12-question folder |
| `references/sources.md` | Price sources and literature |
| `AI_usage_log.md` | Record of how AI assistance was used |

The two 12-question folders are self-contained and have the same five scripts:

| Script | What it does | Runtime |
|---|---|---|
| `00_settings_and_helpers.R` | Attributes, levels, prior guesses and helper functions; sourced by the other scripts | - |
| `01_compare_designs.R` | Builds the rotation, L^MA and D-optimal designs and compares their precision | 1-3 min |
| `02_choose_design.R` | Picks the best of 48 D-optimal designs, balances assistant by position, checks robustness | 2-4 min |
| `03_sample_size_simulation.R` | Monte Carlo simulation of precision and power for 40 to 100 respondents | 6-20 min |
| `04_print_questionnaire.R` | Prints the 12 questions in readable form | seconds |

Results are in each folder's `output/`: the designs, the simulation tables, the questionnaire (`04_questionnaire.txt`) and the console output of every script.

To reproduce: run `install_packages.R`, set the working directory to one of the design folders, then run scripts 01 to 04 in order (02 to 04 in a 15-question folder). Seeds are fixed. Results were produced with R 4.3.3, support.CEs 0.7.0, idefix 1.1.0 and mlogit 2.0.0.

## Survey protocol

- Levels and wording are frozen before launch; everyone gets the same 12 questions.
- Answers are recorded as option letters (positions), never as brand names, and every choice question is required.
- Question order may be shuffled as long as each question keeps its own ID (Q1 to Q12).
- Profile questions at the end: assistants used, main assistant, current and past paid or discounted plans, how often free limits are hit, occupation, field of study, age, gender. They are used to compare groups; there is no screening.

**Data format.** One row per option shown: `resp.id, ques, alt, assistant, price, usage, extras, price.num, choice`, plus a `free` column in the free-option version. `make_long_data()` in script 03 builds it from a table of chosen options (`Q1 ... Q12`); `output/03_example_simulated_data_n80.csv` is an example.

## References

- Aizaki, H. (2012). Basic functions for supporting an implementation of choice experiments in R. *Journal of Statistical Software*, 50(Code Snippet 2).
- Chapman, C., & Feit, E. M. (2019). *R for Marketing Research and Analytics* (2nd ed.). Springer.
- Croissant, Y. (2020). Estimation of random utility models in R: The mlogit package. *Journal of Statistical Software*, 95(11).
- Louviere, J. J., Hensher, D. A., & Swait, J. D. (2000). *Stated Choice Methods: Analysis and Applications*. Cambridge University Press.
- Rao, V. R. (2014). *Applied Conjoint Analysis*. Springer.
- Shampanier, K., Mazar, N., & Ariely, D. (2007). Zero as a special price: The true value of free products. *Marketing Science*, 26(6).
- Traets, F., Sanchez, D. G., & Vandebroek, M. (2020). Generating optimal designs for discrete choice experiments in R: The idefix package. *Journal of Statistical Software*, 96(3).
