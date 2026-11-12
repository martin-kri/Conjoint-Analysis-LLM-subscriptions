# Conjoint project: survey design (Laboratory of Customer and Business Analytics)

- **LLM subscriptions** (`llm_design/`): choice-based conjoint on AI assistant plans. "Free" is a level of the price attribute (EUR 0), so every question is a choice between three plans.

**Changed on 12 November 2026 after the lecturer's feedback.** The separate 4th option "keep using only the free versions" was removed and EUR 0 became a price level. Prices are now EUR 0 / 7.99 / 20.99 and usage is 1x / 4x / 10x. All scripts were rerun and the files in `output/` replaced.

## Folder contents

| File / folder | What it is |
|---|---|
| `install_packages.R` | Run once to install the R packages |
| `llm_design/` | Scripts and results for the LLM topic |
| `references/` | Screenshot of Google's student offers and the list of sources for prices and market shares |
| `AI_usage_log.md` | What the AI assistant (Claude) did, as raw material for the AI declaration the guidelines require |

The `llm_design/` folder contains these scripts:

| Script | What it does | Runtime |
|---|---|---|
| `00_settings_and_helpers.R` | Attributes, levels, prior guesses and helper functions. Sourced by the others; you don't run it directly | - |
| `01_compare_designs.R` | Builds a rotation design, an L^MA design in 3 blocks, and D-optimal designs with 9, 12 and 15 questions, and compares how precise each one would be | 1-3 min |
| `02_choose_design.R` | Builds 48 D-optimal designs with 12 questions and picks the best one, then balances which brand appears in which position | 2-4 min |
| `03_sample_size_simulation.R` | Simulates respondents, fits MNL and mixed MNL with `mlogit`, and checks precision for 40, 60, 80 and 100 respondents | 2-10 min |
| `04_print_questionnaire.R` | Prints the 12 questions in readable form (`output/04_questionnaire.txt`) | seconds |

## How to run

1. Install R (4.1 or newer) and RStudio, then run `install_packages.R` once.
2. Open a script and set the working directory to its folder: in RStudio, **Session > Set Working Directory > To Source File Location**.
3. Run the scripts in order: 01, 02, 03, 04. Scripts 03 and 04 read `output/02_chosen_design_12q.csv`. That file is already included, so you can also run 03 or 04 on their own.
4. Results are written to `output/`. The `console_*.txt` files show the output we got, so you can check that yours matches.

Random seeds are fixed, so with the same package versions you should get the same results. We used R 4.3.3, support.CEs 0.7.0, idefix 1.1.0 and mlogit 2.0.0.

## LLM subscriptions

Framing for respondents: *"Next semester you choose ONE AI assistant plan, mainly for your studies/work. Some plans are free, some are paid."*

| Attribute | Levels | Why these levels |
|---|---|---|
| Assistant | ChatGPT / Gemini / Claude | Main assistants used by students |
| Monthly price | EUR 0 / 7.99 / 20.99 | Free, a low-cost tier (ChatGPT Go costs about EUR 8) and about the regular price of the paid plans. |
| Usage | 1x / 4x / 10x the free version | 1x is what the free versions give today, so "EUR 0, 1x, nothing extra" is today's free tier. Google AI Pro is described as 4x, ChatGPT Go as about 10x |
| Included extras | Nothing extra / Cloud storage / Cloud storage + music & video streaming | Bundling, as in Google's offers |

Because price is one of the attributes, some plans are unrealistic (for example a free plan with 10x usage and streaming).

**Design (D-optimal, `idefix`, 12 questions, 3 plans per question, one questionnaire for everyone):**
- Every question shows ChatGPT, Gemini and Claude once each.
- Each assistant appears 4 times in each position.
- No question has a plan that is the same assistant and worse on everything.
- In 2 of the 12 questions (5 and 6), one plan is better on price, usage and extras than another plan from a *different* assistant. These show how strong brand loyalty is.
- 9 of the 12 questions contain a free plan.

Largest standard error at n = 80 (lower is better):

| Design | Questions per person | Survey versions | Largest SE |
|---|---|---|---|
| Rotation | 9 | 1 | 0.151 |
| L^MA (27 questions in 3 blocks) | 9 | 3 | 0.163 |
| D-optimal | 9 | 1 | 0.160 |
| D-optimal (chosen) | 12 | 1 | 0.145 |
| D-optimal | 15 | 1 | 0.120 |

The L^MA design also has 6 questions with a plan that is the same assistant and worse on everything, and 3 questions with two identical plans. Splitting respondents into groups does not improve precision here.

**Sample-size simulation** (assumed effects deliberately modest; people differ a lot in price sensitivity):

| Respondents | Largest SE (MNL) | 90% range of the estimated value of streaming (assumed EUR 2.86) |
|---|---|---|
| 40 | 0.191 | EUR 0.21 to 5.42 |
| 60 | 0.157 | EUR 0.85 to 4.94 |
| 80 | 0.136 | EUR 1.20 to 4.43 |
| 100 | 0.122 | EUR 0.65 to 4.14 |

- Price is significant in every simulation, already with 40 respondents.
- Large effects (10x usage, the streaming bundle) are significant in 88-100% of simulations.
- Medium effects (0.4 on the logit scale: Claude vs ChatGPT, 4x usage) are significant in 55-100% of simulations with the MNL, and 80-100% with the mixed MNL.
- Small effects (0.2: Gemini vs ChatGPT, cloud storage alone) are often not significant. That would be a finding ("no clear difference"), not a failure.
- About 43% of the simulated answers pick a free plan.
- The mixed MNL can be estimated with 80 respondents.

**Recommendation: 12 questions, as many respondents as we can get.** 60 or more gives comfortable precision, and 40 is still enough for the large effects.

## Data format after collection

The data is one row per alternative, with columns `resp.id, ques, alt, <attributes>, price.num, choice`. `price` is the categorical price and `price.num` the numeric one.

The function `make_long_data()` in `llm_design/03_sample_size_simulation.R` converts a table with `resp.id` and columns `Q1 ... Q12` (the chosen option, 1-3) into that format. `output/03_example_simulated_data_n80.csv` shows what the result looks like.

## Rules for the survey, so the data stays usable

- Freeze the levels and wording before launch. Everyone gets the same 12 questions. Don't change anything after the first response.
- Record answers as Option A/B/C (positions), never as brand names.
- Make every choice question required.
- Google Forms can shuffle the question order. That's fine, as long as each question keeps its own title (Q1 ... Q12).
- Profile questions at the end: assistants used in the last month (multi-select, including "a local model"), main assistant for study/work and for everyday use, whether they pay and through which offer, past free or discounted student plans, how often they hit free limits, student / working / both, field of study and year (for students), age, gender. We use them only to compare groups; there is no screening.
