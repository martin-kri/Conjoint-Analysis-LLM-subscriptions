# AI usage log

**Tool:** Claude (Anthropic)

## 8 November 2026
- **Background reading.** Read the project brief, reference R scripts and Rao (2014) to summarise the requirements and the methods available.
- **Market research.** Web searches for current Italian prices, plan features and market shares, used to set realistic levels.
- **R code.** Wrote the design scripts, building on reference code for support.CEs, idefix and mlogit:
  - comparing experimental designs
  - choosing a 12-question D-optimal design
  - simulating the sample size
  - printing the questionnaire

## 12 November 2026
- **Design revision.** After feedback on the first design, compared the options (EUR 0 as a price level instead of a separate free option, three or four price levels, splitting respondents into groups) and recommended one 12-question D-optimal questionnaire.
- **R code.** Updated the design scripts to the new levels (EUR 0 / 7.99 / 20.99, usage 1x / 4x / 10x, no separate free option), added the L^MA design to the comparison, and reran all scripts.
- **Documentation.** Updated `README.md`, `references/sources.md` and the project explainer to match.
- **Review.** Reviewed the design choices, scripts and documentation. Added a robustness check of the chosen design against wrong prior guesses, raised the simulation from 40 to 200 repetitions (10 to 30 for the mixed logit), added willingness to pay from the paid price range, and rewrote the README with literature references.
- **Two candidate designs.** Prepared two self-contained versions: `design_price_level/` (EUR 0 as a price level, with implausible free plans removed from the candidate set) and `design_free_option/` (three paid plans plus a fixed "stay free" option). Reran the design comparison, robustness check and sample-size simulation for both and updated the README.
