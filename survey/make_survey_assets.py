"""
LLM subscriptions - survey assets for Google Forms

Reads the frozen questionnaire (design_price_level/output/04_questionnaire_table.csv)
and produces:
  1. survey/images/Q01.png ... Q12.png   one choice table per question
     plus Q13.png, the holdout question (defined below, not part of the design)
  2. the DESIGN block inside survey/create_google_form.gs (between the
     "BEGIN DESIGN" and "END DESIGN" markers), used as a text fallback and
     as a record of what each image shows.

The design CSV is the only source: never edit the images or the DESIGN block
by hand. Re-run this script if the design ever changes (it must not change
after the first real response).

Requirements: Python 3, playwright (pip install playwright), and either Chrome/Edge installed
or playwright's Chromium (python -m playwright install chromium)
Run from the repository root:  python survey/make_survey_assets.py
"""
import csv
import html
import json
import re
from pathlib import Path

from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent.parent
DESIGN_CSV = ROOT / "design_price_level" / "output" / "04_questionnaire_table.csv"
IMG_DIR = ROOT / "survey" / "images"
GS_FILE = ROOT / "survey" / "create_google_form.gs"
OPTIONS = ["Option A", "Option B", "Option C"]
ROWS = ["Assistant", "Price", "Usage", "Included extras"]

# ---------------------------------------------------------------------------
# 1. Read the design: {question: {row: [A, B, C]}}
design = {}
with open(DESIGN_CSV, newline="", encoding="utf-8") as f:
    for r in csv.DictReader(f):
        q = int(r["question"])
        design.setdefault(q, {})[r["row"]] = [r[o] for o in OPTIONS]
assert len(design) == 12 and all(list(design[q]) == ROWS for q in design), "unexpected design layout"

# Holdout question (Q13): everyone answers it, but it is left out when fitting the
# model; afterwards the model's predicted shares are compared with the real choices.
# A realistic market: today's free tier, a low-cost plan (like ChatGPT Go) and a
# regular plan with the streaming bundle (like Google AI Pro + YouTube Premium).
# Under the prior guesses the shares are about 15% / 44% / 42%, so it is not a
# no-brainer. It respects the restriction on free plans and is not identical to
# any design question.
HOLDOUT_Q = 13
design[HOLDOUT_Q] = {
    "Assistant":       ["Gemini", "Claude", "ChatGPT"],
    "Price":           ["EUR 20.99 / month", "Free (EUR 0)", "EUR 7.99 / month"],
    "Usage":           ["4x the free version", "Same as today's free version", "4x the free version"],
    "Included extras": ["Cloud storage + music & video streaming", "Nothing extra", "Nothing extra"],
}
n_q = len(design)

# ---------------------------------------------------------------------------
# 2. Render one image per question. Every option gets the same neutral style
#    (no logos, no brand colours, no highlighting of free plans), so the only
#    differences respondents see are the attribute levels.
CSS = """
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Inter', 'DejaVu Sans', sans-serif; background: #ffffff; color: #1f2328; }
.card { width: 840px; padding: 24px 24px 26px; }
.title { font-size: 25px; color: #57606a; margin-bottom: 16px; }
table { width: 100%; border-collapse: separate; border-spacing: 0; table-layout: fixed; }
col.lab { width: 128px; }
th { font-size: 31px; font-weight: 700; padding: 14px 10px; background: #eef1f4;
     border-top: 2px solid #c9d1d9; border-bottom: 2px solid #c9d1d9; }
th:first-child { background: transparent; border: none; }
th + th { border-left: 2px solid #c9d1d9; }
th:last-child, td:last-child { border-right: 2px solid #c9d1d9; }
td { font-size: 29px; line-height: 1.22; padding: 16px 10px; text-align: center;
     vertical-align: middle; border-bottom: 1px solid #d0d7de; }
td + td { border-left: 2px solid #c9d1d9; }
td.lab { font-size: 19px; font-weight: 600; color: #57606a; text-align: left;
         padding-left: 0; text-transform: uppercase; letter-spacing: 0.03em; }
tr.assistant td:not(.lab) { font-weight: 700; font-size: 33px; }
"""


def question_html(q):
    d = design[q]
    head = "".join(f"<th>{html.escape(o)}</th>" for o in OPTIONS)
    body = ""
    for row in ROWS:
        label = "Extras" if row == "Included extras" else row
        # keep "EUR 20.99" and "/ month" together on their own lines
        cells = "".join(f"<td>{html.escape(v).replace(' / ', '&nbsp;<wbr>/&nbsp;').replace('EUR ', 'EUR&nbsp;')}</td>"
                        for v in d[row])
        body += f'<tr class="{row.split()[0].lower()}"><td class="lab">{label}</td>{cells}</tr>'
    return (f"<html><head><style>{CSS}</style></head><body><div class='card'>"
            f"<div class='title'>Question {q} of {n_q}</div>"
            f"<table><colgroup><col class='lab'><col><col><col></colgroup>"
            f"<thead><tr><th></th>{head}</tr></thead><tbody>{body}</tbody></table>"
            f"</div></body></html>")


IMG_DIR.mkdir(parents=True, exist_ok=True)
with sync_playwright() as p:
    # Use playwright's own Chromium if installed (python -m playwright install chromium),
    # otherwise an installed Chrome or Edge (works on Windows, macOS and Linux)
    browser = None
    for opts in ({}, {"channel": "chrome"}, {"channel": "msedge"}):
        try:
            browser = p.chromium.launch(**opts)
            break
        except Exception:
            pass
    if browser is None:
        raise SystemExit("No browser found: run  python -m playwright install chromium  and try again.")
    page = browser.new_page(viewport={"width": 840, "height": 800}, device_scale_factor=1)
    for q in sorted(design):
        page.set_content(question_html(q))
        page.locator(".card").screenshot(path=str(IMG_DIR / f"Q{q:02d}.png"))
    browser.close()

# ---------------------------------------------------------------------------
# 3. Write the design into the Apps Script, between the markers
block = "const DESIGN = [\n" + ",\n".join(
    "  " + json.dumps({"q": q, "holdout": q == HOLDOUT_Q, **{row: design[q][row] for row in ROWS}}, ensure_ascii=False)
    for q in sorted(design)) + "\n];"
gs = GS_FILE.read_text(encoding="utf-8")
new_gs, n = re.subn(r"(// BEGIN DESIGN[^\n]*\n).*?(\n// END DESIGN)",
                    lambda m: m.group(1) + block + m.group(2), gs, flags=re.S)
assert n == 1, "DESIGN markers not found in create_google_form.gs"
GS_FILE.write_text(new_gs, encoding="utf-8")
print(f"Wrote {n_q} images to {IMG_DIR.relative_to(ROOT)} and updated {GS_FILE.relative_to(ROOT)}")
