# AI usage log

**Tool:** Claude (Anthropic)

## 8 November 2026
- **Reading course material.** Read the project guidelines, lab R scripts and the Rao textbook to summarise the project requirements and the methods available.
- **Market research.** Web searches for current Italian prices, plan features and market shares, used to set realistic levels.
- **R code.** Wrote the scripts in `llm_design/`, adapting the lab scripts (support.CEs, idefix, mlogit):
  - comparing experimental designs
  - choosing a 12-question D-optimal design
  - simulating the sample size
  - printing the questionnaire

## 12 November 2026
- **Advice after the lecturer's feedback.** Compared the options (EUR 0 as a price level instead of a separate free option, three or four price levels, splitting respondents into groups) using the lab designs, and recommended one 12-question D-optimal questionnaire.
- **R code.** Updated the scripts in `llm_design/` to the new levels (EUR 0 / 7.99 / 20.99, usage 1x / 4x / 10x, no separate free option), added the L^MA design to the comparison, and reran all scripts.
- **Documentation.** Updated `README.md`, `references/sources.md` and the project explainer to match.
