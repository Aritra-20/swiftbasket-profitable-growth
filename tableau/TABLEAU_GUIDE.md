# Tableau: step-by-step guide

The finished workbook is `SwiftBasket_Dashboard.twbx` (Tableau 2026.2, packaged with the data). This guide shows how it was built, so you can rebuild or explain any chart.

You'll build **2 simple dashboards** from the case Excel file:

1. **Business Health**: headline numbers, where the money goes, discounts, the monthly trend
2. **Operations & Promo**: late deliveries, stores, stock-outs, the promo test

Time needed: about 1.5 to 2 hours the first time.

You need **Tableau Desktop** or the free **Tableau Public** app: https://public.tableau.com/app/discover → *Create* → *Download Tableau Public*.

---

## Part A · Connect the data (10 min)

1. Open Tableau. On the left under **Connect**, click **Microsoft Excel** and choose `SwiftBasket_2026_Case_Data.xlsx`.
2. You'll see the sheet names on the left. Drag **orders** onto the big empty canvas.
3. Drag **stores** next to it. Tableau draws a line (a "relationship") between them. Click the line and check it says **Store Id = Store Id**. If not, choose those fields.
4. Drag **customers** onto the canvas and connect it to **orders** on **Customer Id = Customer Id**.
5. Drag **campaign_assignments** onto the canvas and connect it to **customers** on **Customer Id = Customer Id**.
6. Click **Sheet 1** at the bottom-left to start building.

> Tableau tidies the column names, so `contribution_margin_inr` shows up as **Contribution Margin Inr**. The formulas below use the tidied names. If yours still show underscores, type them that way; Tableau suggests names as you type.

---

## Part B · Create the calculated fields (15 min)

For each one: in the left **Data** pane, right-click any empty space → **Create Calculated Field…** → type the name and paste the formula → **OK**.

| Name | Formula |
|---|---|
| **Loss Order** | `IF [Contribution Margin Inr] < 0 THEN 1 ELSE 0 END` |
| **Discount Size** | `IF [Discount Inr] = 0 THEN "1. No discount" ELSEIF [Discount Inr] <= 25 THEN "2. ₹1-25" ELSEIF [Discount Inr] <= 50 THEN "3. ₹26-50" ELSEIF [Discount Inr] <= 75 THEN "4. ₹51-75" ELSE "5. ₹76+" END` |
| **Distance Band** | `IF [Delivery Distance Km] <= 2 THEN "1. 0-2 km" ELSEIF [Delivery Distance Km] <= 4 THEN "2. 2-4 km" ELSE "3. over 4 km" END` |
| **Items Missing** | `IF [Stockout Item Count] = 0 THEN "0 missing" ELSEIF [Stockout Item Count] = 1 THEN "1 missing" ELSEIF [Stockout Item Count] = 2 THEN "2 missing" ELSE "3+ missing" END` |
| **Stock Accuracy Group** | `IF [Inventory Accuracy Pct] < 90 THEN "1. Below 90%" ELSEIF [Inventory Accuracy Pct] < 95 THEN "2. 90-95%" ELSE "3. 95% and above" END` |
| **Customer Group** | `IF [Days Since Last Order] > 90 AND [App Sessions 30D] <= 7 THEN "Lapsed + low app use" ELSE "Everyone else" END` |

One more setting: in the Data pane, right-click **Promised Minutes** → **Convert to Dimension**. That way it's treated as a category (20 / 25 / 30), not a number to add up.

---

## Part C · Dashboard 1: Business Health (35 min)

Make each chart on its own sheet (bottom tabs: **New Worksheet** icon). Rename each tab by double-clicking it.

### Sheet "KPI – Margin per order"
1. Drag **Contribution Margin Inr** to **Text** on the Marks card.
2. Right-click the green pill → **Measure** → **Average**.
3. Right-click it again → **Format…** → Numbers → Currency (custom) → 1 decimal, prefix ₹.
4. Click **Text** on the Marks card → **…** → make the font size 28. Title: "Margin per order".
   - ✅ You should see **₹44.3**.

### Sheets "KPI – % Late" and "KPI – % orders losing money"
Do the same as above, but with **Late Delivery Flag** (Average, formatted as Percentage, 1 decimal) and then **Loss Order** (Average, Percentage).
   - ✅ You should see **17.3%** and **21.0%**.

### Sheet "KPI – Orders"
Drag **orders (Count)** to Text. In newer versions this field is at the bottom of the orders table and is called **orders (Count)**.
   - ✅ **30,000**

### Sheet "Where the money goes"
1. Drag **Measure Names** to **Columns** and **Measure Values** to **Rows**.
2. On the **Measure Values** card (left, under Marks), keep only: Gross Margin Inr, Delivery Fee Inr, Discount Inr, Picking Cost Inr, Delivery Cost Inr, Refund Inr, Contribution Margin Inr. Drag the others off.
3. Right-click the Measure Values pill → **Measure** → **Average** (do this for each one if needed).
4. Click **Label** on the Marks card → tick **Show mark labels**.
   - ✅ About 161, 6, 45, 21, 36, 21 and 44.

### Sheet "Discount vs margin"
1. **Discount Size** to Columns, **Contribution Margin Inr** to Rows → change to **Average**.
2. Show mark labels.
   - ✅ From about ₹87 (no discount) down to about ₹5 (₹76+).

### Sheet "Monthly trend"
1. Drag **Order Timestamp** to Columns, then right-click it and choose the **Month** that says "May 2015" style (continuous month).
2. **Contribution Margin Inr** to Rows → **Average**. Change the mark type to **Line**.
   - ✅ A flat line around ₹41–47.

### Build the dashboard
1. Click the **New Dashboard** icon (bottom). On the left, set **Size** → **Automatic**.
2. Drag the four KPI sheets into a row across the top (hold **Shift** while dragging to make them float, or drop them side by side).
3. Below them, drag "Where the money goes" and "Discount vs margin" side by side, then "Monthly trend" at the bottom.
4. Add a title: tick **Show dashboard title** at the bottom-left and write *"SwiftBasket: business health, 2025"*.
5. Rename the tab **Business Health**.

---

## Part D · Dashboard 2: Operations & Promo (40 min)

### Sheet "Late % by distance and promise"
1. **Distance Band** to Columns, **Promised Minutes** to Columns (next to it).
2. **Late Delivery Flag** to Rows → **Average** → format as Percentage.
3. Drag **Promised Minutes** to **Color** too. Show mark labels.
   - ✅ 20 minutes over 4 km should show about **72.5%**.

### Sheet "Late % by weather and peak hours"
1. **Weather Flag** to Columns, **Peak Period Flag** to Columns (convert it to Dimension first, same as Promised Minutes).
2. **Late Delivery Flag** to Rows → Average → Percentage. Show labels.
   - ✅ Rain + peak (1) ≈ **47.5%**.

### Sheet "Stores"
1. **Store Id** to Rows, **Contribution Margin Inr** to Columns → **Average**.
2. Click the sort button in the toolbar (ascending) so the weakest stores are on top.
3. Drag **Stock Accuracy Group** to **Color**.
   - ✅ The weakest stores (S012, S011, S027) should be coloured "Below 90%".

### Sheet "Missing items → refunds"
1. **Items Missing** to Columns, **Refund Inr** to Rows → Average. Show labels.
   - ✅ About ₹10 for 0 missing, ₹27–28 for 1 or more.

### Sheet "Promo test"
1. **Offer Type** (from campaign_assignments) to Columns.
2. **Customer Group** to Columns as well (next to Offer Type), or to Color.
3. **Post Campaign Margin Inr** to Rows → **Average**. Show labels.
4. Read it like this: compare each offer with the **No offer** bar for the same customer group.
   - ✅ Lapsed + low app use: No offer ≈ ₹38.3, Free delivery ≈ ₹46.6 (the only offer above its No-offer bar). Everyone else: No offer ≈ ₹98.7, every offer lower.

### Build the dashboard
New Dashboard → Size: Automatic → put "Late % by distance and promise" and "Late % by weather" on top, "Stores" and "Missing items" in the middle, and "Promo test" at the bottom. Title: *"SwiftBasket: operations and the promo test"*. Rename the tab **Operations & Promo**.

---

## Part E · Publish (5 min)

1. **File → Save to Tableau Public…** and sign in (free account).
2. Give it a name like *SwiftBasket Case Study*.
3. **Important:** everything on Tableau Public is public. The case data is synthetic, but its README says it's for the hiring exercise only. On your Tableau Public profile, open the workbook's settings and switch it to **hidden from profile**, then share only the link.
4. Copy the link for your video description and README.

---

## Check your numbers

If a number in Tableau doesn't match these, the usual cause is **Sum** instead of **Average**. Right-click the pill → Measure → Average.

| Number | Value |
|---|---|
| Orders | 30,000 |
| Margin per order | ₹44.3 |
| % late | 17.3% |
| % orders losing money | 21.0% |
| Margin per order, ₹76+ discount | ₹4.9 |
| Late %, 20-min promise over 4 km | 72.5% |
| Late %, rain at peak hours | 47.5% |
| Margin per order, stores below 90% stock accuracy | ₹38.7 |
| Promo: lapsed + low app use, free delivery vs no offer | ₹46.6 vs ₹38.3 |
