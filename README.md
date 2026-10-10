# SwiftBasket: which growth is worth having?

My submission for the Straive campus case study #1 (Senior Business Analyst / Consultant). SwiftBasket is a fictional quick-commerce company. The COO wants to know which growth is worth paying for.

**Short answer:** SwiftBasket doesn't have a growth problem. It has a leak problem, and the leaks can be fixed.

## What I found

- **Unit economics.** An average order earns about ₹167 in product margin and fees. Discounts (₹45) and refunds (₹21) take ₹66 of it. We keep ₹44, which is 7.9% of GMV, and one order in five loses money.
- **Discount-led customers.** Customers who rely on discounts repeat more (43% vs 23%), but earn ₹15 per order against ₹74 for light-discount customers. Bigger first-order offers and marketing clicks show no link to repeat buying. App habit does.
- **The busiest customers.** The COO suspected they might be the least profitable. She's half right: per order, the busiest fifth earns the least (₹36 vs ₹57 for one-order customers), because they get the deepest discounts (9.3% of basket vs 5.9%). In total they still bring the most margin (₹370 each), so the fix is to stop discounting them, not to lose them.
- **Delivery promise.** The 20/25/30-minute promise is given in the same mix at every distance. A 20-minute promise beyond 4 km is late 72% of the time. In rain at peak hours, 47% of orders are late.
- **Stock accuracy.** Wrong stock records lead to stock-outs, stock-outs to refunds, and refunds to lost margin. Store margin per order correlates 0.77 with inventory accuracy.
- **The Q1 promo (randomized).** It lost ₹12.5 of margin per customer against control. The customers who redeemed most were the ones it hurt most. Only free delivery for lapsed, low-engagement customers paid back: +₹8.3 per customer, 95% CI +₹1 to +₹16, and the result held on a holdout half.

## What I'd do next quarter

| Action | Expected effect | How to test it |
|---|---|---|
| Free delivery only for customers lapsed 90+ days with ≤7 app sessions; cap discounts near 10% of basket | Per 10k customers, −₹1.25 lakh becomes +₹0.27 lakh, with 67% fewer offers sent | Rerun with a 20% holdout, judged on margin, not redemption |
| Distance-aware promise: 20 min within 1 km, 25 up to 3 km, 30 beyond | Late rate 17.3% → ~11.8% | Switchback test by store and hour |
| Fix inventory accuracy in the bottom quarter of stores (≤90%) | ≈ +4% of total contribution margin | 4 pilot stores vs 4 matched controls, 6 weeks |

## What's in the repo

| Path | What it is |
|---|---|
| `notebooks/swiftbasket_analysis.ipynb` | The full analysis, run end to end with outputs |
| `sql/analysis_queries.sql` | Every SQL query from the notebook (DuckDB dialect) |
| `charts/` | The charts used in the slides |
| `dashboard/` | Source and aggregate data behind the business-health dashboard |
| `exports/` | Aggregate tables, in case you want to rebuild the dashboard in Tableau or Power BI |
| `presentation/video_script.md` | The 5-minute video script, with timings and a recording checklist |
| `qa/independent_check.py` | Re-derives every number used in the slides straight from the Excel file, in plain pandas with no SQL |

The raw case workbook is **not** in this repo. The case README says it's for the hiring exercise only.

## Running it

**Locally**

```bash
pip install -r requirements.txt
# put SwiftBasket_2026_Case_Data.xlsx in data/
jupyter notebook notebooks/swiftbasket_analysis.ipynb
```

**On Kaggle**

1. Create a private Kaggle dataset and upload `SwiftBasket_2026_Case_Data.xlsx` to it.
2. New Notebook → File → Import Notebook → paste this repo's notebook URL.
3. Add your dataset as input. The notebook finds the file under `/kaggle/input/` on its own.
4. Run all. DuckDB installs with `!pip install duckdb` if it's missing.

## How I used AI

I used Claude (an AI assistant) to help with the analysis code (Python and SQL), the charts and the slide drafts. I reviewed each step and I'm responsible for every number and recommendation.

To check the output:
- Section 7 of the notebook re-computes the headline figures in plain pandas, separately from the SQL. They match.
- `qa/independent_check.py` reads the Excel file fresh and re-derives every number used in the slides, including the confidence intervals and the holdout check. They match.
- The contribution-margin formula reconciles to the rupee on all 30,000 orders.

## Outside sources used for context

- [Blinkit stops '10 minute' delivery claim; Zepto follows suit](https://www.theweek.in/news/biz-tech/2026/01/13/gig-worker-labour-rights-blinkit-stops-10-minute-delivery-claim-zepto-follows-suit.amp.html), The Week, Jan 2026
- [Quick-commerce giants drop '10-minute delivery' promise after govt intervention](https://www.outlookbusiness.com/corporate/quick-commerce-giants-drop-10-minute-delivery-promise-after-govt-intervention), Outlook Business
- [Blinkit turned profit. Zepto filed to IPO. Instamart cut losses.](https://daily.datumintell.com/daily-content/issues/2026-06-11-quick-commerce-zepto-blinkit-instamart.html), Datum Intelligence, Jun 2026

All company, customer and store data in the case is synthetic.
