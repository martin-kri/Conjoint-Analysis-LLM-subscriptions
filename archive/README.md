# Archive: designs we considered and did not field

These folders are kept so the comparison in the main README can be checked and reproduced. They are not used for the survey. The final design is in `../design_price_level/`.

| Folder | What it is | Why we did not field it |
|---|---|---|
| `design_free_option/` | Three paid plans (EUR 5.49 / 12.99 / 21.99, usage 2x / 4x / 10x) plus a fourth answer, "I would keep using only the free versions", in every question | About 37% of answers go to the free answer and carry no information about the paid plans, so medium effects are detected less often (71% against 94% at 80 respondents) |
| `design_free_option_15q/` | The same with 15 questions | We chose 12 questions |
| `design_price_level_15q/` | The final design's settings with 15 questions | We chose 12 questions; the gain in power was 2 to 4 points at 40 to 60 respondents |

How to run them:

- `design_free_option/` is self-contained: set the working directory to it and run scripts 01 to 04.
- The two `_15q` folders have scripts 02 to 04 only. They use the settings and step 1 results of `design_free_option/` (in this folder) and of `../../design_price_level/` (the final design), so keep the repo's folder layout. Run step 1 in those folders first if their `output/` is missing.
