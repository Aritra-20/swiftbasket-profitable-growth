-- SwiftBasket case: analysis queries (DuckDB SQL)
-- Tables: orders, customers, stores, campaign_assignments (one per Excel sheet)

-- Row counts, date window and join integrity
SELECT
  (SELECT COUNT(*) FROM orders)                                   AS orders,
  (SELECT COUNT(DISTINCT customer_id) FROM orders)                AS ordering_customers,
  (SELECT COUNT(*) FROM customers)                                AS customers,
  (SELECT COUNT(*) FROM stores)                                   AS stores,
  (SELECT MIN(order_timestamp) FROM orders)                       AS first_order,
  (SELECT MAX(order_timestamp) FROM orders)                       AS last_order,
  (SELECT COUNT(*) FROM orders o LEFT JOIN customers c USING (customer_id) WHERE c.customer_id IS NULL) AS orphan_customer_rows,
  (SELECT COUNT(*) FROM orders o LEFT JOIN stores s USING (store_id) WHERE s.store_id IS NULL)          AS orphan_store_rows,
  (SELECT SUM(ABS(gross_margin_inr + delivery_fee_inr - discount_inr - picking_cost_inr
                  - delivery_cost_inr - refund_inr - contribution_margin_inr)) FROM orders)              AS cm_identity_error_inr;

-- Are the customer 'history' fields just the 2025 order table re-aggregated?
WITH agg AS (SELECT customer_id, COUNT(*) n, SUM(contribution_margin_inr) cm FROM orders GROUP BY 1)
SELECT
  AVG(CASE WHEN c.historical_orders_12m = COALESCE(a.n,0) THEN 1 ELSE 0 END)            AS share_orders_match,
  CORR(c.historical_margin_12m, COALESCE(a.cm,0))                                        AS corr_margin
FROM customers c LEFT JOIN agg a USING (customer_id);

-- Headline KPI scorecard (2025)
SELECT
  COUNT(*)                                                     AS orders,
  SUM(basket_value_inr)                                        AS gmv_inr,
  AVG(basket_value_inr)                                        AS aov_inr,
  SUM(contribution_margin_inr)                                 AS contribution_margin_inr,
  SUM(contribution_margin_inr) / SUM(basket_value_inr)         AS cm_pct_gmv,
  AVG(contribution_margin_inr)                                 AS cm_per_order,
  AVG(CASE WHEN contribution_margin_inr < 0 THEN 1 ELSE 0 END) AS loss_making_order_share,
  SUM(discount_inr) / SUM(basket_value_inr)                    AS discount_pct_gmv,
  SUM(refund_inr)   / SUM(basket_value_inr)                    AS refund_pct_gmv,
  AVG(late_delivery_flag)                                      AS late_rate,
  AVG(CASE WHEN stockout_item_count > 0 THEN 1 ELSE 0 END)     AS orders_with_stockout,
  AVG(cancelled_flag)                                          AS cancel_rate,
  AVG(service_contact_flag)                                    AS support_contact_rate,
  AVG(rating)                                                  AS avg_rating
FROM orders;

-- Unit economics: where does an average order's ₹ go?
SELECT AVG(gross_margin_inr) AS gross_margin, AVG(delivery_fee_inr) AS delivery_fee,
       -AVG(discount_inr) AS discount, -AVG(picking_cost_inr) AS picking,
       -AVG(delivery_cost_inr) AS last_mile, -AVG(refund_inr) AS refunds,
       AVG(contribution_margin_inr) AS contribution_margin
FROM orders;

-- Monthly trend: is the business getting healthier?
SELECT date_trunc('month', order_timestamp)::DATE AS month, COUNT(*) AS orders,
       AVG(contribution_margin_inr) AS cm_per_order, AVG(late_delivery_flag) AS late_rate,
       SUM(discount_inr)/SUM(basket_value_inr) AS discount_pct
FROM orders GROUP BY 1 ORDER BY 1;

-- Customer-level features from the order table
WITH o AS (
  SELECT customer_id, COUNT(*) n_orders, SUM(contribution_margin_inr) cm, SUM(basket_value_inr) gmv,
         SUM(discount_inr) disc, SUM(refund_inr) refund, AVG(unique_category_count) avg_categories
  FROM orders GROUP BY 1)
SELECT c.*, o.n_orders, o.cm, o.cm / o.n_orders AS cm_per_order, o.disc / o.gmv AS discount_share,
       o.avg_categories
FROM customers c LEFT JOIN o USING (customer_id);

-- Discount reliance vs. value: heavy discount users repeat as much but earn ~5x less
SELECT CASE WHEN discount_share <= 0.05 THEN '1. ≤5%' WHEN discount_share <= 0.08 THEN '2. 5–8%'
            WHEN discount_share <= 0.11 THEN '3. 8–11%' ELSE '4. >11%' END AS discount_share_of_basket,
       COUNT(*) customers, AVG(repeat_order_30d) repeat_30d, AVG(n_orders) orders_per_cust,
       AVG(cm_per_order) cm_per_order, AVG(cm) cm_per_customer
FROM cust WHERE n_orders > 0 GROUP BY 1 ORDER BY 1;

-- Order-level discount depth vs. contribution margin
SELECT NTILE(5) OVER (ORDER BY discount_inr / basket_value_inr) AS discount_quintile,
       discount_inr / basket_value_inr AS d, contribution_margin_inr, basket_value_inr FROM orders;

-- Engagement that matters vs. engagement that doesn't
SELECT 'App sessions (30d)' AS signal,
       CASE WHEN app_sessions_30d <= 3 THEN '1. 0–3' WHEN app_sessions_30d <= 7 THEN '2. 4–7'
            WHEN app_sessions_30d <= 12 THEN '3. 8–12' ELSE '4. 13+' END AS bucket,
       COUNT(*) customers, AVG(repeat_order_30d) repeat_30d, AVG(historical_margin_12m) margin_12m
FROM customers GROUP BY 1,2
UNION ALL
SELECT 'Marketing clicks (30d)', CAST(campaign_clicks_30d AS VARCHAR), COUNT(*), AVG(repeat_order_30d), AVG(historical_margin_12m)
FROM customers GROUP BY 1,2
UNION ALL
SELECT 'First-order offer (₹)',
       CASE WHEN first_order_offer_inr = 0 THEN '1. none' WHEN first_order_offer_inr <= 75 THEN '2. ≤75'
            WHEN first_order_offer_inr <= 112 THEN '3. 76–112' ELSE '4. 113+' END,
       COUNT(*), AVG(repeat_order_30d), AVG(historical_margin_12m)
FROM customers GROUP BY 1,2
ORDER BY 1,2;

-- Basket breadth, membership and acquisition channel
SELECT 'Avg categories / order' AS dim,
       CASE WHEN avg_categories <= 3 THEN '1. ≤3' WHEN avg_categories <= 5 THEN '2. 3–5' ELSE '3. >5' END AS bucket,
       COUNT(*) customers, AVG(repeat_order_30d) repeat_30d, AVG(cm_per_order) cm_per_order, AVG(discount_share) discount_share
FROM cust WHERE n_orders > 0 GROUP BY 1,2
UNION ALL
SELECT 'Membership', membership_status, COUNT(*), AVG(repeat_order_30d), AVG(cm_per_order), AVG(discount_share)
FROM cust WHERE n_orders > 0 GROUP BY 1,2
UNION ALL
SELECT 'Channel', acquisition_channel, COUNT(*), AVG(repeat_order_30d), AVG(cm_per_order), AVG(discount_share)
FROM cust WHERE n_orders > 0 GROUP BY 1,2
ORDER BY 1,2;

-- Are the busiest customers the least profitable? (the COO's hypothesis)
WITH q AS (
  SELECT customer_id, n_orders, cm, NTILE(5) OVER (ORDER BY n_orders, customer_id) AS frequency_quintile
  FROM cust WHERE n_orders > 0)
SELECT q.frequency_quintile,
       COUNT(DISTINCT q.customer_id)                                   AS customers,
       COUNT(*) * 1.0 / COUNT(DISTINCT q.customer_id)                  AS avg_orders,
       SUM(o.contribution_margin_inr) / COUNT(DISTINCT q.customer_id)  AS cm_per_customer,
       AVG(o.contribution_margin_inr)                                  AS cm_per_order,
       SUM(o.discount_inr) / SUM(o.basket_value_inr)                   AS discount_share,
       (SELECT AVG(CASE WHEN q2.cm < 0 THEN 1 ELSE 0 END) FROM q q2 WHERE q2.frequency_quintile = q.frequency_quintile) AS share_loss_making
FROM q JOIN orders o USING (customer_id)
GROUP BY 1 ORDER BY 1;

-- The delivery promise ignores distance
SELECT CASE WHEN delivery_distance_km <= 1 THEN '0–1 km' WHEN delivery_distance_km <= 2 THEN '1–2 km'
            WHEN delivery_distance_km <= 3 THEN '2–3 km' WHEN delivery_distance_km <= 4 THEN '3–4 km' ELSE '4+ km' END AS distance,
       promised_minutes, COUNT(*) orders, AVG(late_delivery_flag) late_rate, AVG(rating) rating
FROM orders WHERE cancelled_flag = 0 GROUP BY 1,2 ORDER BY 1,2;

-- Peak hours × weather
SELECT weather_flag, CASE WHEN peak_period_flag = 1 THEN 'Peak' ELSE 'Off-peak' END AS period,
       COUNT(*) orders, AVG(late_delivery_flag) late_rate, AVG(contribution_margin_inr) cm_per_order
FROM orders GROUP BY 1,2 ORDER BY 1,2;

-- Store league table: inventory accuracy, staffing and outcomes
SELECT s.store_id, s.city, s.store_format, s.delivery_partner_model, s.inventory_accuracy_pct, s.staffing_fill_rate_pct,
       s.average_active_riders, COUNT(*) orders, AVG(o.contribution_margin_inr) cm_per_order,
       AVG(o.stockout_item_count) stockouts_per_order, AVG(o.refund_inr) refund_per_order,
       AVG(o.late_delivery_flag) late_rate, AVG(o.rating) rating
FROM orders o JOIN stores s USING (store_id)
GROUP BY ALL ORDER BY cm_per_order;

-- The mechanism: stock-outs → refunds → margin and rating
SELECT CASE WHEN stockout_item_count = 0 THEN '0' WHEN stockout_item_count = 1 THEN '1'
            WHEN stockout_item_count = 2 THEN '2' ELSE '3+' END AS stockout_items,
       COUNT(*) orders, AVG(refund_inr) refund_per_order, AVG(contribution_margin_inr) cm_per_order, AVG(rating) rating
FROM orders GROUP BY 1 ORDER BY 1;

-- Inventory-accuracy quartiles (store-level, order-weighted)
SELECT q, MIN(inventory_accuracy_pct) lo, MAX(inventory_accuracy_pct) hi, COUNT(*) orders,
       AVG(stockout_item_count) stockouts, AVG(refund_inr) refund, AVG(contribution_margin_inr) cm_per_order, AVG(rating) rating
FROM (SELECT o.*, s.inventory_accuracy_pct, NTILE(4) OVER (ORDER BY s.inventory_accuracy_pct) q FROM orders o JOIN stores s USING (store_id))
GROUP BY q ORDER BY q;

-- Is lateness itself costly? Compare late vs on-time *within the same distance band*
SELECT CASE WHEN delivery_distance_km <= 2 THEN '≤2 km' WHEN delivery_distance_km <= 4 THEN '2–4 km' ELSE '4+ km' END AS band,
       late_delivery_flag, COUNT(*) orders, AVG(contribution_margin_inr) cm, AVG(refund_inr) refund,
       AVG(rating) rating, AVG(service_contact_flag) contact_rate
FROM orders WHERE cancelled_flag = 0 GROUP BY 1,2 ORDER BY 1,2;

-- Randomization balance check
SELECT offer_type, COUNT(*) n, AVG(c.days_since_last_order) recency, AVG(c.app_sessions_30d) sessions,
       AVG(c.historical_orders_12m) orders_12m, AVG(c.historical_margin_12m) margin_12m,
       AVG(CASE WHEN c.membership_status <> 'Non-member' THEN 1 ELSE 0 END) member_share
FROM campaign_assignments a JOIN customers c USING (customer_id) GROUP BY 1 ORDER BY 1;

-- Redemption vs. incrementality by offer
WITH ctrl AS (SELECT AVG(post_campaign_orders) o0, AVG(post_campaign_margin_inr) m0 FROM campaign_assignments WHERE assignment_group='Control')
SELECT offer_type, COUNT(*) customers, AVG(offer_value_inr) offer_value, AVG(offer_redeemed_flag) redemption,
       AVG(post_campaign_orders) - (SELECT o0 FROM ctrl) AS incr_orders_per_cust,
       AVG(post_campaign_margin_inr) - (SELECT m0 FROM ctrl) AS incr_margin_per_cust
FROM campaign_assignments GROUP BY 1 ORDER BY incr_margin_per_cust DESC;

