# Where every number comes from

Use this if an interviewer asks "where did that number come from?". For each number on the slides it shows the value on the slide, the same number re-calculated a second, independent way (plain pandas straight from the case Excel file, no SQL), and the notebook section with the code that produces it.

Result: **135 of 135 numbers match** (small differences are only rounding, e.g. 44.27 is shown as ₹44.3).

Definitions to know:
- "Margin per order" and "% orders losing money" use all 30,000 orders, including the 305 cancelled ones (they're real costs: each is refunded).
- "% late" uses delivered orders only (the case marks late as blank for cancelled orders). The refund-by-missing-items table also uses delivered orders only, so cancellation refunds don't mix in.
- "Margin % of sales" divides by the basket value before discount (7.9%). On sales after discount it would be 8.6%.
- "Offers to everyone lose ₹12,461 per 1,000 customers" is the test's result per customer who got an offer, times 1,000. In the Q1 test only 64.6% got an offer, so the test itself lost about ₹8,050 per 1,000 customers.
- The new delivery promise (7.5% late) is checked order by order: actual delivery time doesn't depend on the promise (about 19 minutes for 20, 25 and 30-minute promises), so each delivered order's actual minutes are compared with the promise it would get.

Things that are *not* from the case data, and are labelled where they appear:
- Outlook Business, 13 Jan 2026: Blinkit, Zepto and others dropped "10-minute delivery" claims (slide 5, notebook Step 6).
- Datum Intelligence, Jun 2026: Blinkit's contribution margin rose from 3.9% to 5.4% of net order value (slide 3 footer, notebook Step 6). On the same basis SwiftBasket is at 8.6%.

Estimates (not measured facts) are the three action effects on slide 8. They're simple arithmetic on the 2025 data, shown in notebook Step 6, and the pilots decide the real number.

## Slide 2 · Three findings

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Orders | 30,000 | 30,000 | Step 1 · row counts | ✓ |
| Customers | 8,000 | 8,000 | Step 1 · row counts | ✓ |
| Stores | 36 | 36 | Step 1 · row counts | ✓ |
| First order | Jan 2025 | Jan 2025 | Step 1 · time period | ✓ |
| Last order | Dec 2025 | Dec 2025 | Step 1 · time period | ✓ |
| Discounts + refunds per order (₹66) | 66 | 66.11 | Step 2 · where the money goes | ✓ |
| % late, all 20-minute promises (40%) | 40 | 40.41 | Step 4 · promise | ✓ |

## Slide 3 · Business health

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Margin per order (₹) | 44.3 | 44.27 | Step 2 · headline numbers | ✓ |
| Margin % of sales | 7.9 | 7.91 | Step 2 · headline numbers | ✓ |
| % orders losing money | 21 | 21 | Step 2 · headline numbers | ✓ |
| % orders late | 17.3 | 17.28 | Step 2 · headline numbers | ✓ |
| % cancelled (about 1%) | 1 | 1.02 | Step 2 · headline numbers | ✓ |
| Orders a month (~2,500) | 2,500 | 2,500 | Step 2 · month by month | ✓ |
| Product margin per order (₹) | 161 | 160.84 | Step 2 · where the money goes | ✓ |
| Delivery fee per order (₹) | 6 | 6.41 | Step 2 · where the money goes | ✓ |
| Money in per order = product margin + fee (₹) | 167 | 167.26 | Step 2 · where the money goes | ✓ |
| Discount per order (₹) | 45 | 44.79 | Step 2 · where the money goes | ✓ |
| Picking cost per order (₹) | 21 | 20.55 | Step 2 · where the money goes | ✓ |
| Delivery cost per order (₹) | 36 | 36.32 | Step 2 · where the money goes | ✓ |
| Refund per order (₹) | 21 | 21.33 | Step 2 · where the money goes | ✓ |
| Cancelled orders, % of orders (~1%) | 1 | 1.02 | Step 2 · cancelled orders | ✓ |
| Margin lost per cancelled order (₹) | -403 | -403.01 | Step 2 · cancelled orders | ✓ |
| Cancelled orders' share of all margin (~9%) | -9.3 | -9.25 | Step 2 · cancelled orders | ✓ |
| Margin per delivered order (~₹49) | 48.9 | 48.87 | Step 2 · cancelled orders | ✓ |
| Part of the ₹21 refund that is cancellations (~₹4) | 4 | 3.71 | Step 2 · cancelled orders | ✓ |
| Customers who ordered in 2025 | 6,759 | 6,759 | Step 2 · customers at a glance | ✓ |
| Repeat within 30 days (31%) | 31 | 30.66 | Step 2 · customers at a glance | ✓ |
| Orders Q4 vs Q1 (+5%) | 5 | 5.22 | Step 2 · orders by quarter | ✓ |
| Margin % of sales after discount (8.6%, Blinkit basis) | 8.6 | 8.6 | Step 2 · headline numbers | ✓ |

## Slide 4 · Customers

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Margin per order, basket <400 (₹) | -10.4 | -10.41 | Step 3 · small baskets | ✓ |
| Margin per order, basket 400-499 (₹) | 17.7 | 17.7 | Step 3 · small baskets | ✓ |
| Margin per order, basket 500-599 (₹) | 41.6 | 41.6 | Step 3 · small baskets | ✓ |
| Margin per order, basket 600-699 (₹) | 66.9 | 66.91 | Step 3 · small baskets | ✓ |
| Margin per order, basket 700+ (₹) | 94.3 | 94.29 | Step 3 · small baskets | ✓ |
| Smallest band discount per basket band (min, ~₹45) | 45 | 44.61 | Step 3 · small baskets | ✓ |
| Largest band discount per basket band (max, ~₹45) | 45 | 44.94 | Step 3 · small baskets | ✓ |
| % of under-₹400 orders losing money | 57 | 57.16 | Step 3 · small baskets | ✓ |
| Discount per order, 1-order customers (₹) | 33 | 32.53 | Step 3 · frequent customers | ✓ |
| Discount per order, 11+ order customers (₹) | 57 | 56.82 | Step 3 · frequent customers | ✓ |
| Margin per order, 1-order customers (₹) | 57 | 56.64 | Step 3 · frequent customers | ✓ |
| Margin per order, 11+ order customers (₹) | 32 | 32.1 | Step 3 · frequent customers | ✓ |
| Orders per customer, discount-heavy (>11% of spend) | 6.1 | 6.09 | Step 8.3 · discount reliance | ✓ |
| Orders per customer, light-discount (≤5%) | 2.7 | 2.65 | Step 8.3 · discount reliance | ✓ |
| Margin per order (all their orders), discount-heavy (₹) | 21 | 20.84 | Step 8.3 · discount reliance | ✓ |
| Margin per order (all their orders), light-discount (₹) | 70 | 69.55 | Step 8.3 · discount reliance | ✓ |
| Margin per customer per year, 11+ order customers (₹) | 427 | 427.45 | Step 3 · frequent customers | ✓ |
| Repeat rate, lowest group by membership/channel/first offer (29%) | 29 | 29.28 | Step 3 · repeat rates | ✓ |
| Repeat rate, highest group by membership/channel/first offer (33%) | 33 | 32.8 | Step 3 · repeat rates | ✓ |
| Repeat rate, 0-3 app sessions (10%) | 10 | 10.43 | Step 3 · app sessions | ✓ |
| Repeat rate, 13+ app sessions (61%) | 61 | 61.03 | Step 3 · app sessions | ✓ |

## Slide 5 · Delivery

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Avg distance, 20-min promise (km) | 2.5 | 2.5 | Step 4 · promise | ✓ |
| Avg distance, 25-min promise (km) | 2.5 | 2.52 | Step 4 · promise | ✓ |
| Avg distance, 30-min promise (km) | 2.5 | 2.52 | Step 4 · promise | ✓ |
| Actual delivery minutes, same for every promise (~19) | 19 | 18.93 | Step 6 · rec 2 | ✓ |
| % late, 20-min promise over 4 km | 72.5 | 72.5 | Step 4 · distance x promise | ✓ |
| % late, rain at peak hours | 47.5 | 47.47 | Step 4 · weather and peak | ✓ |
| % late, 'Normal' weather off-peak | 6.9 | 6.9 | Step 4 · weather and peak | ✓ |
| Rating, late orders | 3.88 | 3.88 | Step 4 · cost of late orders | ✓ |
| Rating, on-time orders | 4.28 | 4.28 | Step 4 · cost of late orders | ✓ |
| % contacting support, late | 18.8 | 18.81 | Step 4 · cost of late orders | ✓ |
| % contacting support, on time | 11.1 | 11.08 | Step 4 · cost of late orders | ✓ |

## Slide 6 · Stores

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Avg refund, nothing missing, delivered orders (₹) | 0 | 0 | Step 4 · missing items | ✓ |
| Delivered orders with a missing item (2 in 3) | 65 | 64.61 | Step 4 · missing items | ✓ |
| Delivered orders with an item not replaced (1 in 3) | 36 | 35.92 | Step 4 · missing items | ✓ |
| Avg refund, 1 item missing (₹) | 28 | 27.66 | Step 4 · missing items | ✓ |
| Avg refund, 3+ items missing (₹) | 27 | 27.42 | Step 4 · missing items | ✓ |
| Rating, nothing missing | 4.95 | 4.95 | Step 4 · missing items | ✓ |
| Rating, 1 item missing | 4.23 | 4.23 | Step 4 · missing items | ✓ |
| Rating, 3+ items missing | 2.94 | 2.94 | Step 4 · missing items | ✓ |
| Stores with stock accuracy below 90% | 9 | 9 | Step 4 · stock accuracy | ✓ |
| Margin per order, stores <90% (₹) | 38.7 | 38.66 | Step 4 · stock accuracy | ✓ |
| Margin per order, stores 90-95% (₹) | 44.3 | 44.27 | Step 4 · stock accuracy | ✓ |
| Margin per order, stores 95%+ (₹) | 49.3 | 49.29 | Step 4 · stock accuracy | ✓ |
| Gap best vs weakest stores (~₹11, said 'about eleven') | 11 | 10.63 | Step 4 · stock accuracy | ✓ |
| % contacting support, late AND items missing | 23.8 | 23.81 | Step 4 · late + missing | ✓ |
| % contacting support, on time AND complete | 1.9 | 1.9 | Step 4 · late + missing | ✓ |
| % late, stores <80% shifts filled | 22 | 21.95 | Step 4 · staffing | ✓ |
| % late, stores 90%+ shifts filled | 14 | 13.86 | Step 4 · staffing | ✓ |
| % late, under 25 riders | 20 | 20.13 | Step 4 · riders | ✓ |
| % late, 40+ riders | 15 | 15.39 | Step 4 · riders | ✓ |

## Slide 7 · Promo test

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Customers with no offer (control) | 2,832 | 2,832 | Step 5 · treatment vs control | ✓ |
| Customers with an offer (treatment) | 5,168 | 5,168 | Step 5 · treatment vs control | ✓ |
| Orders per customer, offer | 1.37 | 1.37 | Step 5 · treatment vs control | ✓ |
| Orders per customer, no offer | 1.21 | 1.21 | Step 5 · treatment vs control | ✓ |
| Margin per customer, offer (₹) | 66.4 | 66.35 | Step 5 · treatment vs control | ✓ |
| Margin per customer, no offer (₹) | 78.8 | 78.82 | Step 5 · treatment vs control | ✓ |
| Promo effect per customer (₹) | -12.5 | -12.46 | Step 6 · rec 1 | ✓ |
| % redeemed among active customers who got an offer (~37%) | 37 | 36.79 | Step 5 · active vs lapsed | ✓ |
| Chart: Dormant (no 2025 orders), Fixed discount vs no offer (₹) | 11.6 | 11.57 | Step 5 · where does the gain come from | ✓ |
| Chart: Dormant (no 2025 orders), Free delivery vs no offer (₹) | 17 | 17.04 | Step 5 · where does the gain come from | ✓ |
| Chart: Dormant (no 2025 orders), Percentage discount vs no offer (₹) | 5.1 | 5.12 | Step 5 · where does the gain come from | ✓ |
| Chart: Lapsed, ordered in 2025, Fixed discount vs no offer (₹) | -13.6 | -13.63 | Step 5 · where does the gain come from | ✓ |
| Chart: Lapsed, ordered in 2025, Free delivery vs no offer (₹) | -0.7 | -0.67 | Step 5 · where does the gain come from | ✓ |
| Chart: Lapsed, ordered in 2025, Percentage discount vs no offer (₹) | -12.5 | -12.46 | Step 5 · where does the gain come from | ✓ |
| Chart: Active, Fixed discount vs no offer (₹) | -34.8 | -34.76 | Step 5 · where does the gain come from | ✓ |
| Chart: Active, Free delivery vs no offer (₹) | -9.4 | -9.36 | Step 5 · where does the gain come from | ✓ |
| Chart: Active, Percentage discount vs no offer (₹) | -22 | -22.04 | Step 5 · where does the gain come from | ✓ |
| Dormant free delivery 95% range, low end (~₹8) | 8 | 7.93 | Step 5 · where does the gain come from | ✓ |
| Dormant free delivery 95% range, high end (~₹26) | 26 | 26.15 | Step 5 · where does the gain come from | ✓ |

## Slide 8 · Three actions

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Promo as run, per 1,000 customers (₹) | -12,461 | -12,461 | Step 6 · rec 1 | ✓ |
| Small-basket rule upper limit, % of total margin (notebook) | 9.1 | 9.11 | Step 6 · rec 1b | ✓ |
| Late % with promise by distance (each order's actual minutes vs new promise) | 7.5 | 7.53 | Step 6 · rec 2 | ✓ |
| % of orders that would see a longer promise (~40%) | 40.5 | 40.53 | Step 6 · rec 2 | ✓ |
| % of customers who are dormant (no orders in the last 12 months) | 15.5 | 15.51 | Step 6 · rec 1 | ✓ |
| Free delivery to dormant customers, per 1,000 customers (~₹2,600) | 2,600 | 2,643 | Step 6 · rec 1 | ✓ |
| Fewer offers than offering everyone (~85%) | 85 | 84.49 | Step 8.14 · offers | ✓ |
| % of orders that would see a shorter promise (18%) | 18 | 18.43 | Step 6 · rec 2 | ✓ |
| Stock fix: ₹ more per order | 5.6 | 5.61 | Step 6 · rec 3 | ✓ |
| Stock fix: % of total margin (~3%) | 3.1 | 3.13 | Step 6 · rec 3 | ✓ |
| Flat 30-minute promise for all: % late (5.6%) | 5.6 | 5.64 | Step 6 · recommendation 2 | ✓ |

## Slide 10 · Appendix

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| Late % in normal hours (~11%) | 11 | 11.54 | Step 4 · hour of day | ✓ |
| Late % in the 5 busy hours (~27%) | 27 | 27.12 | Step 4 · hour of day | ✓ |
| Weekday late %, lowest (16%) | 16 | 16.27 | Step 4 · weekday | ✓ |
| Weekday late %, highest (18%) | 18 | 17.85 | Step 4 · weekday | ✓ |
| Rating, items missing but all replaced | 4.01 | 4.01 | Step 4 · substitutes | ✓ |
| Rating, items missing and 1 not replaced | 3.82 | 3.82 | Step 4 · substitutes | ✓ |
| Members' discount per order, annual (₹36.5) | 36.5 | 36.53 | Step 3 · members | ✓ |
| Members' discount per order, monthly (₹37.7) | 37.7 | 37.66 | Step 3 · members | ✓ |
| Non-members' discount per order (₹51.3) | 51.3 | 51.34 | Step 3 · members | ✓ |
| Fast-growing store S004 margin per order (₹48) | 48.4 | 48.39 | Step 4 · fastest-growing stores | ✓ |
| Fast-growing store S034 margin per order (₹52) | 51.8 | 51.78 | Step 4 · fastest-growing stores | ✓ |
| Orders dated before their store opened | 936 | 936 | Step 1 · data checks | ✓ |
| Orders dated before the customer signed up | 4,744 | 4,744 | Step 1 · data checks | ✓ |
| Customers with no 2025 orders | 1,241 | 1,241 | Step 1 · data checks | ✓ |
| Late % in Q1 (14%) | 14 | 14.28 | Step 2 · orders by quarter | ✓ |
| Late % in Q3 (20%) | 20 | 20.34 | Step 2 · orders by quarter | ✓ |
| Duplicate order ids | 0 | 0 | Step 1 · data checks | ✓ |
| Blank delivery times | 305 | 305 | Step 1 · data checks | ✓ |
| Cancelled orders | 305 | 305 | Step 1 · data checks | ✓ |
| Blank delivery time AND cancelled | 305 | 305 | Step 1 · data checks | ✓ |
| % of orders unrated | 45 | 45.23 | Step 1 · data checks | ✓ |
| Weakest city Tier2 D: margin per order (₹42) | 42 | 42.39 | Step 4 · which cities are weakest | ✓ |
| Weakest city Tier2 D: % late (19%) | 19 | 19.34 | Step 4 · which cities are weakest | ✓ |
| Tier2 D is lowest margin per order | 1 | 1 | Step 4 · which cities are weakest | ✓ |

## Slide Notebook only (not on a slide)

| What the slide says | On slide | Re-checked | Notebook section | |
|---|---|---|---|---|
| % late for all 20-minute promises (40%) | 40.4 | 40.41 | Step 4 · promise | ✓ |

## Other details on the slides

- Weakest 3 stores by margin per order: S012, S011, S027 (notebook Step 4, "The six weakest stores").
- The 9 stores below 90% stock accuracy: S003, S011, S012, S016, S019, S026, S027, S033, S036 (notebook Step 4, stock accuracy).
- Busy hours where lateness jumps: 12, 13, 19, 20 and 21 (notebook Step 4, lateness by hour).
- Fastest-growing stores: S004 and S034 (notebook Step 4, fastest-growing stores).
- "About ₹2,600" per 1,000 customers from free delivery to dormant customers: the notebook prints ₹2,637 (it uses the rounded +₹17.0); exact is ₹2,643.
- Holdout check (notebook Step 8.13): free delivery for dormant customers is the best choice on one random half of customers (+₹13.3) and holds on the other half (+₹20.7).
- The promo targeting rule uses only a field the Data Dictionary marks as known at decision time (orders in the last 12 months).

## How this check was made

I re-calculated each number with plain pandas directly from the case Excel file (a separate script, not the notebook), then compared it with the slide. Inside the notebook, Step 7 re-calculates the key numbers in plain Python, and Step 8 has the extra checks (correlations, 95% ranges, the holdout check).
