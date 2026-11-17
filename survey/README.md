# The Google Form

This folder builds the Google Form for the survey from the final design. Nothing in it is typed by hand: questions 1 to 12 come from `../design_price_level/output/04_questionnaire_table.csv`, and question 13, the holdout, is defined in `make_survey_assets.py`.

| File | What it is |
|---|---|
| `make_survey_assets.py` | Renders the 13 choice tables as images (`images/Q01.png` ... `Q13.png`), defines the holdout question and copies all 13 into the Apps Script |
| `images/` | The choice tables shown in the form, one per question |
| `create_google_form.gs` | Google Apps Script that creates the form and its response spreadsheet |

## Create the form (about 2 minutes)

1. The images must be on GitHub (`main` branch, `survey/images/`), because the script downloads them from there.
2. Open <https://script.google.com> with the Google account that should own the form, click **New project**, delete the sample code and paste the whole of `create_google_form.gs`. Save.
3. Select `createForm` in the toolbar and click **Run**. Google asks for permission to create forms and spreadsheets in your account; allow it (for a personal script you may need *Advanced → Go to project (unsafe)*).
4. The **Execution log** prints three links: the link to send, the edit link (team only) and the response spreadsheet.

Each run creates a **new** form and spreadsheet; nothing is overwritten.

## Pilot, then launch

- `PILOT = true` (default): the title starts with "[PILOT]" and a last page asks for feedback: time taken, device, whether the tables were readable, whether the introduction and "4x / 10x the free version" were clear, how people decided, and which questions felt strange. Send it to 3 to 5 people who are **not** in the team.
- After the pilot, fix the wording if needed (in `../design_price_level/04_print_questionnaire.R` and `00_settings_and_helpers.R` for the plan labels, then rerun script 04 and `make_survey_assets.py`, or in the `.gs` file for the introduction and profile questions). The design itself (which plans appear in which question) does not change.
- Set `PILOT = false`, run again, and send the new link. This gives a new form and link; the old form and its answers are not touched.
- Once the survey is live, nothing respondents see before or during the choices may change.

**What we did (17 November 2026).** The pilot did not change anything respondents see before or during the choices (introduction, the 13 tables, answer options, order). So we did not rerun the script: the pilot form was edited by hand in Google Forms and is used for the survey, with the same link, and the pilot answers are analysed with the others. The script was not changed, so it still builds the pilot version. Differences between the script and the form actually used:

- "[PILOT]" removed from the title, the pilot sentence removed from the description, and the "Pilot feedback" page removed.
- Degree question: options reduced to Bachelor's / Master's / PhD / Other / I do not study.
- Current plan question: now a checkbox question, "Which of these describes your AI assistant plans right now? Select all that apply.", with the options: I only use free versions; I pay full price for a plan; I pay a student discount; I have a plan for free through a student offer, trial or promotion; I have a plan paid by my university or employer. In the pilot, a single answer could not record a free student plan (the old question asked about a "paid or discounted" plan) or two plans of different kinds.
- The next question is now titled "If you have a plan, which one(s)?" (was "If yes, which plan(s)?").

To rebuild the form actually used, run the script with `PILOT = false` and apply the last three changes by hand.

**Answers given before these changes** are recoded in the analysis by rules applied to everyone, never by editing single answers:

- old degree answers are merged into the new categories (every "Bachelor's, ..." becomes Bachelor's, every "Master's, ..." becomes Master's);
- each old plan answer becomes the matching ticked option ("No, I only use free versions" becomes "I only use free versions", and so on);
- "has a free student plan now" is built for everyone from both the current plan question and the past student plan question ("Yes, and it is still active");
- anyone who ticks "I only use free versions" together with a plan counts as having a plan.

## What the form contains

1. **Introduction**: the frozen text from script 04, plus one sentence on the course, duration and anonymity. It does not mention Google's student offers.
2. **13 choice questions**, one page each: the image, then "Qk. Which plan would you choose?" with the answers *Option A / Option B / Option C*, required. All options look the same (no logos or brand colours), and the order is the same for everyone. Q13 is the holdout (below); respondents cannot tell it apart from the others.
3. **Profile questions** (README, "Survey protocol"): assistants used in the last month, main assistant for study or work and for everyday use, current plans (select all) and which ones, past free or discounted student plan and what happened after, how often free limits are hit, studying / working / both / neither, field of study and degree, age, gender.
4. **Pilot feedback** (pilot version only; removed from the form on 17 November).

This list describes the form as used for the survey; the script still builds the pilot wording of the degree and plan questions (see "What we did" above).

No names or email addresses are collected. The response spreadsheet has one column per question, titled `Q1. Which plan would you choose?` and so on, holding `Option A`, `Option B` or `Option C`. Mapping A/B/C to 1/2/3 gives the `Q1 ... Q12` table that `make_long_data()` (script 03) expects; the row number is the respondent ID. `Q13` is kept apart for the holdout check.

## The holdout question (Q13)

Everyone answers it, but it is **not** used to fit the model. After fitting the multinomial logit on Q1 to Q12, we predict the shares of its three plans and compare them with the share of respondents who really chose each one. If they match, the model predicts choices it never saw.

| | Option A | Option B | Option C |
|---|---|---|---|
| Assistant | Gemini | Claude | ChatGPT |
| Price | EUR 20.99 / month | Free (EUR 0) | EUR 7.99 / month |
| Usage | 4x the free version | Same as today's free version | 4x the free version |
| Extras | Cloud storage + music & video streaming | Nothing extra | Nothing extra |

It is a realistic market: today's free tier, a low-cost plan (like ChatGPT Go) and a regular plan with streaming (like Google AI Pro + YouTube Premium). Under our prior guesses the shares are about 15% / 44% / 42%, so it is not a question everyone answers the same way. It respects the restriction on free plans and is not identical to any of Q1 to Q12. It comes last so that it cannot affect the answers to the design questions. To change it, edit `design[HOLDOUT_Q]` in `make_survey_assets.py` and rerun the script, before the pilot.

## Regenerating the images

Only needed if the design or the holdout changes; the images in `images/` are final. Fonts differ between computers, so regenerated images may look slightly different.

```
pip install playwright
python -m playwright install chromium   # not needed if Chrome or Edge is installed
python survey/make_survey_assets.py      # from the repository root
```
