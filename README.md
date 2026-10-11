# SwiftBasket: which growth is worth having?

My submission for the Straive campus case study #1 (Senior Business Analyst / Consultant). SwiftBasket is a fictional quick-commerce company. The COO wants to know which growth is worth paying for.

I kept the method simple: load the Excel sheets into SQL, answer each question with plain SQL queries, and check the key numbers a second way in Python. I also built two Tableau dashboards.

## What I found

1. **Discounts and refunds eat the margin.** An average order earns about ₹167 in product margin and delivery fees. Discounts (₹45) and refunds (₹21) take ₹66, and we keep ₹44, which is 7.9% of sales. 1 in 5 orders loses money. Cancellations are only 1% of orders, but each loses about ₹403 (mostly refunds), so together they cost about 9% of the year's margin.
2. **Some growth isn't worth having.** The discount doesn't grow with the basket: it averages about ₹45 at every basket size, so baskets under ₹400 lose ₹10.4 each (57% of them lose money). Customers who lean on discounts (over 11% of spend) order the most (6.1 vs 2.7 orders) but earn ₹21 per order vs ₹70. Our most frequent customers get the biggest discounts, so they earn the least per order (₹32 vs ₹57), though they're still worth the most in total (₹427 a year).
3. **The delivery promise ignores distance.** 20-minute promises are late 72.5% of the time beyond 4 km. In rain at peak hours, 47.5% of orders are late.
4. **Missing items turn into refunds.** 2 in 3 delivered orders have a missing item. On delivered orders the refund is ₹0 when nothing is missing and averages about ₹28 when something is. The 9 stores with stock records below 90% accurate earn ₹38.7 per order, against ₹49.3 for the best stores.
5. **The Q1 2026 promo lost money.** Customers who got an offer gave ₹12.5 less margin each than the no-offer group: the extra orders didn't cover the cost of the offers. The one clear gain was free delivery for dormant customers (no orders in 2025): +₹17 each (95% range about +₹8 to +₹26), and it held up on a random half of customers it wasn't chosen on. For customers who did order in 2025, the discounts lost money and free delivery didn't help.

Data caveats I found: 936 orders are dated before their store opened, 4,744 before the customer signed up, and 1,241 customers have no 2025 orders but a last-order date inside 2025. Those 1,241 are the dormant customers the promo works for, so I'd re-test that offer before a full rollout. I don't use store age or signup date.

## What I'd do next quarter

| Action | Expected effect | Main trade-off | How to test it |
|---|---|---|---|
| 1. Spend discounts only where they pay: free delivery only for dormant customers (no orders in the last 12 months, 15.5% of customers), and no discount on baskets under ₹400 | Offers to everyone lose ₹12,461 per 1,000 customers; free delivery to dormant customers gains about ₹2,600, with 85% fewer offers. The ₹400 floor is worth up to about +9% of total margin if customers keep ordering | Fewer offers used; some small-basket orders may be lost | Re-run with a random no-offer group, judged on margin; try the ₹400 minimum in a few cities vs similar cities |
| 2. Promise 25 minutes within 2 km and 30 minutes beyond | Late orders from 17.3% to about 7.5% | About 40% of orders see a longer promise (18% a shorter one) | Randomly chosen stores vs the rest |
| 3. Regular stock counts in the 9 stores below 90% accuracy | About ₹5.6 more per order, about +3% of total margin | Staff time; these stores are also short-staffed, so the pilot must separate the two | 3–4 stores vs similar stores for 6 weeks |

## What's in the repo

| Path | What it is |
|---|---|
| `notebooks/swiftbasket_analysis.ipynb` | The whole analysis, step by step: question → SQL → result → what I see |
| `sql/queries.sql` | All 67 SQL queries in one file (SQLite) |
| `charts/` | The charts made in the notebook (used in the slides) |
| `tableau/TABLEAU_GUIDE.md` | Click-by-click guide to the two Tableau dashboards (Business Health; Operations and Promo), with numbers to check against. The finished workbook is a packaged .twbx that contains the case data, so it's shared separately, not in this repo |
| `presentation/video_script.md` | The video script, recording checklist and AI-use note |
| `presentation/numbers_backup.md` | Every number on the slides, where it comes from in the notebook, and an independent re-check (135 of 135 match) |

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
- Datum Intelligence, Jun 2026: [Blinkit turned profit. Zepto filed to IPO. Instamart cut losses.](https://daily.datumintell.com/daily-content/issues/2026-06-11-quick-commerce-zepto-blinkit-instamart.html). Used on slide 3 and in the notebook.

## How I used AI

I used Claude (an AI assistant) to help write the code and draft the text. I reviewed each step and I'm responsible for every number. To check the work, the last section of the notebook re-calculates the key numbers in plain Python, without SQL, and they match.
