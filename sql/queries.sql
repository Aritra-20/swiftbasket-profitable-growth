-- SwiftBasket case: all SQL queries used in the notebook (SQLite)
-- Tables: orders, customers, stores, campaign_assignments (one per Excel sheet)

-- How many rows does each table have?
SELECT 'orders' AS table_name, COUNT(*) AS row_count FROM orders
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'stores', COUNT(*) FROM stores
UNION ALL SELECT 'campaign_assignments', COUNT(*) FROM campaign_assignments;

-- A first look at the orders table
SELECT * FROM orders LIMIT 5;

-- What time period do the orders cover?
SELECT MIN(order_timestamp) AS first_order, MAX(order_timestamp) AS last_order FROM orders;

-- Does contribution margin match its formula?
SELECT ROUND(SUM(gross_margin_inr + delivery_fee_inr - discount_inr - picking_cost_inr
                 - delivery_cost_inr - refund_inr - contribution_margin_inr), 2) AS difference
FROM orders;

-- Headline numbers for 2025
SELECT COUNT(*)                                                         AS orders,
       ROUND(AVG(basket_value_inr), 0)                                  AS avg_basket_inr,
       ROUND(AVG(contribution_margin_inr), 1)                           AS margin_per_order_inr,
       ROUND(100.0 * SUM(contribution_margin_inr) / SUM(basket_value_inr), 1) AS margin_pct_of_sales,
       ROUND(100.0 * AVG(CASE WHEN contribution_margin_inr < 0 THEN 1 ELSE 0 END), 1) AS pct_orders_losing_money,
       ROUND(100.0 * AVG(late_delivery_flag), 1)                        AS pct_late,
       ROUND(100.0 * AVG(cancelled_flag), 1)                            AS pct_cancelled,
       ROUND(AVG(rating), 2)                                            AS avg_rating
FROM orders;

-- Where does the money from an average order go?
SELECT ROUND(AVG(gross_margin_inr), 0)   AS product_margin,
       ROUND(AVG(delivery_fee_inr), 0)   AS delivery_fee_paid_by_customer,
       ROUND(AVG(discount_inr), 0)       AS discount,
       ROUND(AVG(picking_cost_inr), 0)   AS picking_cost,
       ROUND(AVG(delivery_cost_inr), 0)  AS delivery_cost,
       ROUND(AVG(refund_inr), 0)         AS refund,
       ROUND(AVG(contribution_margin_inr), 0) AS margin_left
FROM orders;

-- Month by month
SELECT strftime('%m', order_timestamp)          AS month,
       COUNT(*)                                 AS orders,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late,
       ROUND(100.0 * AVG(CASE WHEN weather_flag = 'Rain' THEN 1 ELSE 0 END), 0) AS pct_orders_in_rain
FROM orders
GROUP BY month
ORDER BY month;

-- Bigger discounts, smaller margin (per order)
SELECT CASE WHEN discount_inr = 0   THEN '1. No discount'
            WHEN discount_inr <= 25 THEN '2. ₹1-25'
            WHEN discount_inr <= 50 THEN '3. ₹26-50'
            WHEN discount_inr <= 75 THEN '4. ₹51-75'
            ELSE '5. ₹76+' END                AS discount_size,
       COUNT(*)                               AS orders,
       ROUND(AVG(basket_value_inr), 0)        AS avg_basket,
       ROUND(AVG(contribution_margin_inr), 1) AS margin_per_order
FROM orders
GROUP BY discount_size
ORDER BY discount_size;

-- Do our most frequent customers make us more money per order?
SELECT CASE WHEN c.historical_orders_12m = 1  THEN '1. 1 order'
            WHEN c.historical_orders_12m <= 3 THEN '2. 2-3 orders'
            WHEN c.historical_orders_12m <= 6 THEN '3. 4-6 orders'
            WHEN c.historical_orders_12m <= 10 THEN '4. 7-10 orders'
            ELSE '5. 11+ orders' END             AS orders_in_2025,
       COUNT(DISTINCT c.customer_id)              AS customers,
       ROUND(AVG(o.discount_inr), 0)              AS avg_discount,
       ROUND(AVG(o.contribution_margin_inr), 1)   AS margin_per_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY orders_in_2025
ORDER BY orders_in_2025;

-- Do repeat rates differ by membership, acquisition channel or city tier?
SELECT 'Membership' AS split, membership_status AS grp, COUNT(*) AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1) AS pct_repeat
FROM customers GROUP BY membership_status
UNION ALL
SELECT 'Channel', acquisition_channel, COUNT(*), ROUND(100.0 * AVG(repeat_order_30d), 1)
FROM customers GROUP BY acquisition_channel
UNION ALL
SELECT 'City tier', city_tier, COUNT(*), ROUND(100.0 * AVG(repeat_order_30d), 1)
FROM customers GROUP BY city_tier;

-- Does a bigger first-order offer bring customers back?
SELECT first_order_offer_inr, COUNT(*) AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1) AS pct_repeat
FROM customers
GROUP BY first_order_offer_inr;

-- Does using the app more go with coming back?
SELECT CASE WHEN app_sessions_30d <= 3  THEN '1. 0-3 sessions'
            WHEN app_sessions_30d <= 7  THEN '2. 4-7 sessions'
            WHEN app_sessions_30d <= 12 THEN '3. 8-12 sessions'
            ELSE '4. 13+ sessions' END AS app_use,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1) AS pct_repeat
FROM customers
GROUP BY app_use
ORDER BY app_use;

-- How often is each delivery promise missed?
SELECT promised_minutes, COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late,
       ROUND(AVG(delivery_distance_km), 1)        AS avg_distance_km
FROM orders
GROUP BY promised_minutes;

-- Late deliveries by distance and promise
SELECT CASE WHEN delivery_distance_km <= 2 THEN '1. 0-2 km'
            WHEN delivery_distance_km <= 4 THEN '2. 2-4 km'
            ELSE '3. over 4 km' END AS distance,
       promised_minutes,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late
FROM orders
GROUP BY distance, promised_minutes
ORDER BY distance, promised_minutes;

-- Late deliveries by weather and peak hours
SELECT weather_flag,
       CASE WHEN peak_period_flag = 1 THEN 'Peak hours' ELSE 'Other hours' END AS time_of_day,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late
FROM orders
GROUP BY weather_flag, time_of_day
ORDER BY pct_late DESC;

-- Do late orders cost us anything?
SELECT CASE WHEN late_delivery_flag = 1 THEN 'Late' ELSE 'On time' END AS delivery,
       COUNT(*) AS orders,
       ROUND(AVG(rating), 2) AS avg_rating,
       ROUND(100.0 * AVG(service_contact_flag), 1) AS pct_contacted_support
FROM orders
WHERE cancelled_flag = 0
GROUP BY delivery;

-- Missing items (stock-outs): refunds and ratings
SELECT CASE WHEN stockout_item_count = 0 THEN '0 missing'
            WHEN stockout_item_count = 1 THEN '1 missing'
            WHEN stockout_item_count = 2 THEN '2 missing'
            ELSE '3+ missing' END              AS items_missing,
       COUNT(*)                                 AS orders,
       ROUND(AVG(refund_inr), 1)                AS avg_refund,
       ROUND(AVG(rating), 2)                    AS avg_rating,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order
FROM orders
GROUP BY items_missing
ORDER BY items_missing;

-- Stores grouped by how accurate their stock records are
SELECT CASE WHEN s.inventory_accuracy_pct < 90 THEN '1. Below 90%'
            WHEN s.inventory_accuracy_pct < 95 THEN '2. 90-95%'
            ELSE '3. 95% and above' END             AS stock_accuracy,
       COUNT(DISTINCT s.store_id)                   AS stores,
       COUNT(*)                                     AS orders,
       ROUND(AVG(o.stockout_item_count), 2)         AS missing_items_per_order,
       ROUND(AVG(o.refund_inr), 1)                  AS refund_per_order,
       ROUND(AVG(o.contribution_margin_inr), 1)     AS margin_per_order,
       ROUND(AVG(o.rating), 2)                      AS avg_rating
FROM orders o
JOIN stores s ON o.store_id = s.store_id
GROUP BY stock_accuracy
ORDER BY stock_accuracy;

-- Stores grouped by how well their shifts are staffed
SELECT CASE WHEN s.staffing_fill_rate_pct < 80 THEN '1. Below 80%'
            WHEN s.staffing_fill_rate_pct < 90 THEN '2. 80-90%'
            ELSE '3. 90% and above' END   AS shifts_filled,
       COUNT(DISTINCT s.store_id)         AS stores,
       ROUND(100.0 * AVG(o.late_delivery_flag), 1) AS pct_late
FROM orders o
JOIN stores s ON o.store_id = s.store_id
GROUP BY shifts_filled
ORDER BY shifts_filled;

-- The six weakest stores
SELECT s.store_id, s.city, s.inventory_accuracy_pct, s.staffing_fill_rate_pct,
       COUNT(*) AS orders,
       ROUND(AVG(o.contribution_margin_inr), 1) AS margin_per_order,
       ROUND(100.0 * AVG(o.late_delivery_flag), 1) AS pct_late
FROM orders o
JOIN stores s ON o.store_id = s.store_id
GROUP BY s.store_id
ORDER BY margin_per_order
LIMIT 6;

-- Do city, delivery model or store age matter?
SELECT 'City' AS split, s.city AS grp, ROUND(AVG(o.contribution_margin_inr), 1) AS margin_per_order
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY s.city
UNION ALL
SELECT 'Delivery model', s.delivery_partner_model, ROUND(AVG(o.contribution_margin_inr), 1)
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY s.delivery_partner_model
UNION ALL
SELECT 'Store opened in', strftime('%Y', s.launch_date), ROUND(AVG(o.contribution_margin_inr), 1)
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY strftime('%Y', s.launch_date);

-- Check: are the groups alike before the campaign?
SELECT a.offer_type,
       COUNT(*) AS customers,
       ROUND(AVG(c.days_since_last_order), 0) AS avg_days_since_last_order,
       ROUND(AVG(c.app_sessions_30d), 1)      AS avg_app_sessions,
       ROUND(AVG(c.historical_orders_12m), 1) AS avg_orders_2025
FROM campaign_assignments a
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY a.offer_type;

-- Overall result: treatment vs control
SELECT assignment_group,
       COUNT(*) AS customers,
       ROUND(AVG(post_campaign_orders), 2)     AS orders_per_customer,
       ROUND(AVG(post_campaign_margin_inr), 1) AS margin_per_customer
FROM campaign_assignments
GROUP BY assignment_group;

-- Result by offer type
SELECT offer_type,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(offer_redeemed_flag), 1) AS pct_redeemed,
       ROUND(AVG(post_campaign_orders), 2)        AS orders_per_customer,
       ROUND(AVG(post_campaign_margin_inr), 1)    AS margin_per_customer
FROM campaign_assignments
GROUP BY offer_type
ORDER BY margin_per_customer DESC;

-- Split by whether the customer was active or lapsed before the campaign
SELECT CASE WHEN c.days_since_last_order <= 90 THEN '1. Active (ordered in last 90 days)'
            ELSE '2. Lapsed (no order for 91+ days)' END AS customer_type,
       a.offer_type,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(a.offer_redeemed_flag), 1) AS pct_redeemed,
       ROUND(AVG(a.post_campaign_orders), 2)        AS orders_per_customer,
       ROUND(AVG(a.post_campaign_margin_inr), 1)    AS margin_per_customer
FROM campaign_assignments a
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY customer_type, a.offer_type
ORDER BY customer_type, a.offer_type;

-- Narrow it down: lapsed AND low app use, vs everyone else
SELECT CASE WHEN c.days_since_last_order > 90 AND c.app_sessions_30d <= 7
            THEN '2. Lapsed + low app use' ELSE '1. Everyone else' END AS customer_group,
       a.offer_type,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(a.offer_redeemed_flag), 1) AS pct_redeemed,
       ROUND(AVG(a.post_campaign_orders), 2)        AS orders_per_customer,
       ROUND(AVG(a.post_campaign_margin_inr), 1)    AS margin_per_customer
FROM campaign_assignments a
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY customer_group, a.offer_type
ORDER BY customer_group, a.offer_type;

