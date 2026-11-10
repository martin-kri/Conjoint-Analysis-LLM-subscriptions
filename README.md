# Conjoint project: survey design (Laboratory of Customer and Business Analytics)

- **LLM subscriptions** (`llm_design/`): includes a 4th option in every question, "keep using only the free versions".


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
| `01_compare_designs.R` | Builds a rotation design and D-optimal designs with 9, 12 and 15 questions (all with the free option) and compares how precise each one would be | 1-3 min |
| `02_choose_design.R` | Builds 48 D-optimal designs with 12 questions and picks the best one, then balances which brand appears in which position | 2-4 min |
| `03_sample_size_simulation.R` | Simulates respondents, fits MNL and mixed MNL with `mlogit`, and checks precision for 60, 80 and 100 respondents | 1-10 min |
| `04_print_questionnaire.R` | Prints the 12 questions in readable form (`output/04_questionnaire.txt`) | seconds |

## How to run

1. Install R (4.1 or newer) and RStudio, then run `install_packages.R` once.
2. Open a script and set the working directory to its folder: in RStudio, **Session > Set Working Directory > To Source File Location**.
3. Run the scripts in order: 01, 02, 03, 04. Scripts 03 and 04 read `output/02_chosen_design_12q.csv`. That file is already included, so you can also run 03 or 04 on their own.
4. Results are written to `output/`. The `console_*.txt` files show the output we got, so you can check that yours matches.

Random seeds are fixed, so with the same package versions you should get the same results. We used R 4.3.3, support.CEs 0.7.0, idefix 1.1.0 and mlogit 2.0.0.

## LLM subscriptions

Framing for respondents: *"Next semester you decide whether to pay for ONE AI assistant, mainly for your studies/work."*

| Attribute | Levels | Why these levels |
|---|---|---|
| Assistant | ChatGPT / Gemini / Claude | Main assistants used by students |
| Monthly price | EUR 5.49 / 12.99 / 21.99 | Google's real student prices (AI Pro EUR 5.49, AI Pro + YouTube Premium EUR 12.99) and the regular price (EUR 21.99, about the same as ChatGPT Plus and Claude Pro) |
| Usage | 2x / 4x / 10x the free version | How providers describe it: Google AI Plus 2x, AI Pro 4x, ChatGPT Go about 10x |
| Included extras | Nothing extra / Cloud storage / Cloud storage + music & video streaming | Bundling, as in Google's offers |
| Option D | "I would keep using only the free versions" | Costs EUR 0, usage 1x |

**Design (D-optimal, `idefix`, 12 questions, 3 paid plans + free option):**
- Every question shows ChatGPT, Gemini and Claude once each.
- Each assistant appears 4 times in each position.
- No question has a plan that is the same assistant and worse on everything.
- In 5 of the 12 questions, one plan is better on price, usage and extras than another plan from a *different* assistant. This can help to measure brand loyalty.

Largest standard error at n = 80 (lower is better):

| Design | Questions | Largest SE |
|---|---|---|
| Rotation + free option | 9 | 0.160 |
| D-optimal | 9 | 0.190 |
| D-optimal (chosen) | 12 | 0.151 |
| D-optimal | 15 | 0.136 |

**Sample-size simulation** (assumed effects deliberately modest; about 37% of answers go to the free option):
- Price is detected in every simulation, and the streaming bundle in 92-100% of them (n = 60 to 100).
- Medium effects (0.4 on the logit scale, e.g. Claude vs ChatGPT) are significant in about 50-70% of simulations with the MNL, and 70-90% with the mixed MNL.
- Small effects (0.2) are often not significant. That would be a finding ("no clear difference"), not a failure.
- **Willingness to pay for adding streaming**: at n = 80, 90% of the estimates fall between EUR 1.2 and 4.5 around the assumed EUR 2.75. That is precise enough to compare with the EUR 7.50 Google charges students for it (EUR 12.99 vs EUR 5.49).
- The mixed MNL can be estimated with 80 respondents.

**Recommendation: 12 questions, at least 80 respondents.**

## Data format after collection

The data is one row per alternative, with columns `resp.id, ques, alt, <attributes>, choice`. There are also two extra columns: `free` (1 for the free option) and `price.num` (0 for the free option).

The function `make_long_data()` in `llm_design/03_sample_size_simulation.R` converts a table with `resp.id` and columns `Q1 ... Q12` (the chosen option, 1-4) into that format. `output/03_example_simulated_data_n80.csv` shows what the result looks like.

## Rules for the survey, so the data stays usable

- Freeze the levels and wording before launch. Everyone gets the same 12 questions. Don't change anything after the first response.
- Record answers as Option A/B/C/D (positions), never as brand names.
- Make every choice question required.
- Google Forms can shuffle the question order. That's fine, as long as each question keeps its own title (Q1 ... Q12).
- Profile questions at the end: assistants used in the last month (multi-select, including "a local model"), main assistant for study/work and for everyday use, whether they pay and through which offer, past free or discounted student plans, how often they hit free limits, student / working / both, field of study and year (for students), age, gender.