# SwiftBasket: which growth is worth having?

My submission for the Straive campus case study #1 (Senior Business Analyst / Consultant). SwiftBasket is a fictional quick-commerce company. The COO wants to know which growth is worth paying for.

I kept the method simple: load the Excel sheets into SQL, answer each question with plain SQL queries, and build two dashboards in Tableau.

## What I found

1. **Discounts and refunds eat the margin.** An average order brings in about ₹167. Discounts (₹45) and refunds (₹21) take ₹66, and we keep ₹44, which is 7.9% of sales. 1 in 5 orders loses money. Cancellations are only 1% of orders, but each is refunded and loses about ₹403, so together they cost about 9% of the year's margin.
2. **Bigger discounts don't make bigger baskets.** The basket is about ₹560 whatever the discount. No discount leaves ₹87 of margin; ₹76+ off leaves ₹5. The discount is about ₹45 whatever the basket size, so baskets under ₹400 lose ₹10.4 each (57% of them lose money). Our most frequent customers get the biggest discounts, so they earn us the least per order (₹32 vs ₹57).
3. **The delivery promise ignores distance.** 20-minute promises are late 72.5% of the time beyond 4 km. In rain at peak hours, 47.5% of orders are late.
4. **Missing items turn into refunds.** On delivered orders the refund is ₹0 when nothing is missing and about ₹28 when even one item is missing. The 9 stores with stock records below 90% accurate earn ₹38.7 per order, against ₹49.3 for the best stores.
5. **The Q1 promo lost money.** Customers who got an offer gave ₹12.5 less margin each than the no-offer group. The only offer that paid was free delivery for customers who had stopped ordering (91+ days) and rarely open the app (7 or fewer sessions): +₹8.3 and +0.28 orders each.

## What I'd do next quarter

| Action | Expected effect | How to test it |
|---|---|---|
| Free delivery only for lapsed customers with low app use (91+ days since last order, 7 or fewer app sessions) | Per 1,000 customers, a ₹12,461 loss becomes a gain of about ₹2,700 | Repeat with a random no-offer group, judged on margin |
| No discount on baskets under ₹400 | Small baskets stop losing ₹10.4 each; upper limit about +9% of total margin if nobody stops ordering | Try the ₹400 minimum in a few cities first |
| Promise 25 minutes within 2 km and 30 minutes beyond | Late orders from 17.3% to about 7.1% | Try it in a few stores first |
| Regular stock counts in the 9 stores below 90% accuracy | About +3% of total margin | Start with 3–4 stores for 6 weeks |

## What's in the repo

| Path | What it is |
|---|---|
| `notebooks/swiftbasket_analysis.ipynb` | The whole analysis, step by step: question → SQL → result → what I see |
| `sql/queries.sql` | All 59 SQL queries in one file (SQLite) |
| `sql/cross_check.sql` | 43 simple queries that reproduce every number from my first, more advanced analysis (all match; notebook Step 8) |
| Notebook Step 9 | Every extra check from my first analysis (store correlations, quartiles, 95% confidence ranges, holdout check, five-band promise rule and more) redone in simple code; 19 of 19 numbers match |
| `charts/` | The 8 charts made in the notebook (used in the slides) |
| `tableau/TABLEAU_GUIDE.md` | Click-by-click guide to the two Tableau dashboards (Business Health; Operations and Promo), with numbers to check against. The finished workbook is a packaged .twbx that contains the case data, so it's shared separately, not in this repo |
| `presentation/video_script.md` | The video script, recording checklist and AI-use note |
| `presentation/numbers_backup.md` | Every number on the slides, where it comes from in the notebook, and an independent re-check (108 of 108 match) |

The case Excel file is **not** in this repo. The case README says it's for the hiring exercise only.

## How to run it on Kaggle

1. Create a private Kaggle dataset and upload `SwiftBasket_2026_Case_Data.xlsx`.
2. Create a new notebook → File → Import Notebook → paste the link to `notebooks/swiftbasket_analysis.ipynb` from this repo.
3. On the right, click **Add Input** and add your dataset.
4. Click **Run All**. The notebook finds the Excel file by itself.

To run it on your own laptop instead: put the Excel file in a `data/` folder next to `notebooks/`, run `pip install -r requirements.txt`, and open the notebook.

## Where the data comes from

Every number comes from the case workbook. There are two outside facts, and each one names its source where it appears:
- Outlook Business, 13 Jan 2026: [Quick-commerce giants drop '10-minute delivery' promise after govt intervention](https://www.outlookbusiness.com/corporate/quick-commerce-giants-drop-10-minute-delivery-promise-after-govt-intervention). Used on slide 5 and in the notebook.
- Datum Intelligence, Jun 2026: [Blinkit turned profit. Zepto filed to IPO. Instamart cut losses.](https://daily.datumintell.com/daily-content/issues/2026-06-11-quick-commerce-zepto-blinkit-instamart.html). Used in the notebook only.

## How I used AI

I used Claude (an AI assistant) to help write the code and draft the text. I reviewed each step and I'm responsible for every number. To check the work, the last section of the notebook re-calculates the key numbers in plain Python, without SQL, and they match.
