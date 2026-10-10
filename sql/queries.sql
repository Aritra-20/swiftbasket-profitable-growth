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

-- Blanks, duplicates and odd values in orders
SELECT COUNT(*) - COUNT(DISTINCT order_id)                          AS duplicate_order_ids,
       SUM(CASE WHEN actual_delivery_minutes IS NULL THEN 1 ELSE 0 END) AS blank_delivery_time,
       SUM(cancelled_flag)                                           AS cancelled_orders,
       SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END)               AS orders_not_rated,
       SUM(CASE WHEN basket_value_inr <= 0 THEN 1 ELSE 0 END)        AS zero_or_negative_baskets
FROM orders;

-- Blanks in the stores table
SELECT SUM(CASE WHEN competitor_intensity IS NULL THEN 1 ELSE 0 END) AS stores_without_competition_score
FROM stores;

-- Do dates make sense? Orders before the store opened or before the customer signed up
SELECT SUM(CASE WHEN o.order_timestamp < s.launch_date THEN 1 ELSE 0 END)  AS orders_before_store_opened,
       SUM(CASE WHEN o.order_timestamp < c.signup_date THEN 1 ELSE 0 END)  AS orders_before_customer_signed_up
FROM orders o
JOIN stores s    ON o.store_id = s.store_id
JOIN customers c ON o.customer_id = c.customer_id;

-- Which stores have orders dated before they opened?
SELECT s.store_id, s.launch_date, COUNT(*) AS orders_before_opening
FROM orders o JOIN stores s ON o.store_id = s.store_id
WHERE o.order_timestamp < s.launch_date
GROUP BY s.store_id
ORDER BY orders_before_opening DESC;

-- Customers with no 2025 orders: what does their 'days since last order' say?
SELECT COUNT(*)                      AS customers_with_no_2025_orders,
       MIN(days_since_last_order)    AS min_days_since_last_order,
       MAX(days_since_last_order)    AS max_days_since_last_order
FROM customers
WHERE historical_orders_12m = 0;

-- Are the customer 'last 12 months' columns just the 2025 orders added up?
SELECT SUM(CASE WHEN c.historical_orders_12m = COALESCE(o.n, 0) THEN 1 ELSE 0 END) AS customers_matching,
       COUNT(*) AS customers
FROM customers c
LEFT JOIN (SELECT customer_id, COUNT(*) AS n FROM orders GROUP BY customer_id) o
       ON c.customer_id = o.customer_id;

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

-- What do cancelled orders cost?
SELECT CASE WHEN cancelled_flag = 1 THEN 'Cancelled' ELSE 'Delivered' END AS status,
       COUNT(*)                                 AS orders,
       ROUND(AVG(refund_inr), 1)                AS avg_refund,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order,
       ROUND(SUM(contribution_margin_inr), 0)   AS total_margin,
       ROUND(100.0 * SUM(contribution_margin_inr) / (SELECT SUM(contribution_margin_inr) FROM orders), 1) AS pct_of_all_margin
FROM orders
GROUP BY status;

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

-- Small baskets: is the discount the same whatever the basket size?
SELECT CASE WHEN basket_value_inr < 400 THEN '1. under ₹400'
            WHEN basket_value_inr < 500 THEN '2. ₹400-499'
            WHEN basket_value_inr < 600 THEN '3. ₹500-599'
            WHEN basket_value_inr < 700 THEN '4. ₹600-699'
            ELSE '5. ₹700+' END                                      AS basket_size,
       COUNT(*)                                                       AS orders,
       ROUND(AVG(discount_inr), 1)                                    AS avg_discount,
       ROUND(AVG(contribution_margin_inr), 1)                         AS margin_per_order,
       ROUND(100.0 * AVG(CASE WHEN contribution_margin_inr < 0 THEN 1 ELSE 0 END), 1) AS pct_losing_money
FROM orders
GROUP BY basket_size
ORDER BY basket_size;

-- Members vs non-members: discount, delivery fee and margin per order
SELECT c.membership_status,
       COUNT(*)                                AS orders,
       ROUND(AVG(o.discount_inr), 1)           AS avg_discount,
       ROUND(AVG(o.delivery_fee_inr), 1)       AS avg_delivery_fee,
       ROUND(AVG(o.contribution_margin_inr), 1) AS margin_per_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.membership_status;

-- Does charging a delivery fee change margin?
SELECT delivery_fee_inr, COUNT(*) AS orders, ROUND(AVG(contribution_margin_inr), 1) AS margin_per_order
FROM orders
GROUP BY delivery_fee_inr;

-- Margin per order by acquisition channel
SELECT c.acquisition_channel,
       COUNT(*) AS orders,
       ROUND(AVG(o.discount_inr), 1)            AS avg_discount,
       ROUND(AVG(o.contribution_margin_inr), 1) AS margin_per_order
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.acquisition_channel;

-- Do marketing impressions or clicks go with repeat buying?
SELECT 'Impressions (30 days)' AS signal,
       CASE WHEN campaign_impressions_30d <= 4 THEN '1. 0-4'
            WHEN campaign_impressions_30d <= 9 THEN '2. 5-9' ELSE '3. 10+' END AS bucket,
       COUNT(*) AS customers, ROUND(100.0 * AVG(repeat_order_30d), 1) AS pct_repeat
FROM customers GROUP BY signal, bucket
UNION ALL
SELECT 'Clicks (30 days)', CAST(campaign_clicks_30d AS TEXT), COUNT(*), ROUND(100.0 * AVG(repeat_order_30d), 1)
FROM customers GROUP BY campaign_clicks_30d;

-- Do newer customers behave differently? (by signup half-year)
SELECT strftime('%Y', signup_date) || CASE WHEN strftime('%m', signup_date) <= '06' THEN ' H1' ELSE ' H2' END AS signed_up,
       COUNT(*) AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1) AS pct_repeat,
       ROUND(AVG(historical_orders_12m), 2)    AS orders_in_2025
FROM customers
GROUP BY signed_up
ORDER BY signed_up;

-- Customers who signed up but never ordered, and customers who lost us money
SELECT SUM(CASE WHEN historical_orders_12m = 0 THEN 1 ELSE 0 END) AS never_ordered,
       SUM(CASE WHEN historical_orders_12m > 0 AND historical_margin_12m < 0 THEN 1 ELSE 0 END) AS lost_us_money_in_2025,
       SUM(CASE WHEN historical_orders_12m > 0 THEN 1 ELSE 0 END) AS ordered_at_least_once
FROM customers;

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

-- Missing items (stock-outs): refunds and ratings (delivered orders only)
-- Cancelled orders get large refunds (₹365 on average), so I leave them out to see the effect of missing items alone
SELECT CASE WHEN stockout_item_count = 0 THEN '0 missing'
            WHEN stockout_item_count = 1 THEN '1 missing'
            WHEN stockout_item_count = 2 THEN '2 missing'
            ELSE '3+ missing' END              AS items_missing,
       COUNT(*)                                 AS orders,
       ROUND(AVG(refund_inr), 1)                AS avg_refund,
       ROUND(AVG(rating), 2)                    AS avg_rating,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order
FROM orders
WHERE cancelled_flag = 0
GROUP BY items_missing
ORDER BY items_missing;

-- Orders with missing items: how many get a refund, and how big?
SELECT ROUND(100.0 * AVG(CASE WHEN stockout_item_count > 0 THEN 1 ELSE 0 END), 1)                 AS pct_delivered_orders_with_missing_item,
       ROUND(100.0 * AVG(CASE WHEN stockout_item_count > 0 AND refund_inr > 0 THEN 1.0
                              WHEN stockout_item_count > 0 THEN 0 END), 1)                          AS pct_of_those_refunded,
       ROUND(AVG(CASE WHEN stockout_item_count > 0 AND refund_inr > 0 THEN refund_inr END), 0)      AS avg_refund_when_given
FROM orders
WHERE cancelled_flag = 0;

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

-- Lateness by hour of the day
SELECT CAST(strftime('%H', order_timestamp) AS INTEGER) AS hour,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late
FROM orders
GROUP BY hour
ORDER BY hour;

-- Lateness by day of the week (0 = Sunday)
SELECT strftime('%w', order_timestamp) AS weekday,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1) AS pct_late,
       ROUND(AVG(contribution_margin_inr), 1)    AS margin_per_order
FROM orders
GROUP BY weekday
ORDER BY weekday;

-- Bigger orders (more items) have more missing items
SELECT CASE WHEN item_count <= 3 THEN '1. 1-3 items' WHEN item_count <= 6 THEN '2. 4-6 items'
            WHEN item_count <= 9 THEN '3. 7-9 items' ELSE '4. 10+ items' END AS order_size,
       COUNT(*) AS orders,
       ROUND(AVG(stockout_item_count), 2)       AS missing_items_per_order,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order
FROM orders
GROUP BY order_size
ORDER BY order_size;

-- Orders with missing items: does replacing them with a substitute help?
SELECT stockout_item_count - substitution_count AS items_not_replaced,
       COUNT(*)                   AS orders,
       ROUND(AVG(refund_inr), 1)  AS avg_refund,
       ROUND(AVG(rating), 2)      AS avg_rating
FROM orders
WHERE stockout_item_count > 0
GROUP BY items_not_replaced
ORDER BY items_not_replaced;

-- Late AND missing items: how often do customers contact support?
SELECT CASE WHEN late_delivery_flag = 1 THEN 'Late' ELSE 'On time' END            AS delivery,
       CASE WHEN stockout_item_count > 0 THEN 'Items missing' ELSE 'Complete' END AS basket,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(service_contact_flag), 1) AS pct_contacted_support,
       ROUND(AVG(rating), 2) AS avg_rating
FROM orders
WHERE cancelled_flag = 0
GROUP BY delivery, basket
ORDER BY pct_contacted_support;

-- Store format, catchment area and local competition
SELECT 'Store format' AS split, s.store_format AS grp, COUNT(DISTINCT s.store_id) AS stores,
       ROUND(AVG(o.contribution_margin_inr), 1) AS margin_per_order, ROUND(100.0 * AVG(o.late_delivery_flag), 1) AS pct_late
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY s.store_format
UNION ALL
SELECT 'Catchment density', s.catchment_density, COUNT(DISTINCT s.store_id),
       ROUND(AVG(o.contribution_margin_inr), 1), ROUND(100.0 * AVG(o.late_delivery_flag), 1)
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY s.catchment_density
UNION ALL
SELECT 'Competition', COALESCE(s.competitor_intensity, 'Not assessed'), COUNT(DISTINCT s.store_id),
       ROUND(AVG(o.contribution_margin_inr), 1), ROUND(100.0 * AVG(o.late_delivery_flag), 1)
FROM orders o JOIN stores s ON o.store_id = s.store_id GROUP BY COALESCE(s.competitor_intensity, 'Not assessed');

-- Do stores with fewer riders deliver late more often?
SELECT CASE WHEN s.average_active_riders < 25 THEN '1. under 25 riders'
            WHEN s.average_active_riders < 40 THEN '2. 25-39 riders' ELSE '3. 40+ riders' END AS riders_per_shift,
       COUNT(DISTINCT s.store_id) AS stores,
       ROUND(100.0 * AVG(o.late_delivery_flag), 1) AS pct_late
FROM orders o
JOIN stores s ON o.store_id = s.store_id
GROUP BY riders_per_shift
ORDER BY riders_per_shift;

-- Are the fastest-growing stores leaking money? (orders in Jul-Dec vs Jan-Jun)
SELECT store_id,
       SUM(CASE WHEN strftime('%m', order_timestamp) <= '06' THEN 1 ELSE 0 END) AS orders_jan_jun,
       SUM(CASE WHEN strftime('%m', order_timestamp) >  '06' THEN 1 ELSE 0 END) AS orders_jul_dec,
       ROUND(AVG(contribution_margin_inr), 1) AS margin_per_order
FROM orders
GROUP BY store_id
ORDER BY 1.0 * orders_jul_dec / orders_jan_jun DESC
LIMIT 6;

-- When do orders get cancelled?
SELECT weather_flag,
       CASE WHEN peak_period_flag = 1 THEN 'Peak hours' ELSE 'Other hours' END AS time_of_day,
       ROUND(100.0 * AVG(cancelled_flag), 2) AS pct_cancelled
FROM orders
GROUP BY weather_flag, time_of_day
ORDER BY pct_cancelled DESC;

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
       AVG(a.post_campaign_margin_inr)              AS margin_per_customer
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
       AVG(a.post_campaign_margin_inr)              AS margin_per_customer
FROM campaign_assignments a
JOIN customers c ON a.customer_id = c.customer_id
GROUP BY customer_group, a.offer_type
ORDER BY customer_group, a.offer_type;

-- Does the campaign result change by membership, city tier or acquisition channel?
SELECT 'Membership' AS split, c.membership_status AS grp,
       ROUND(AVG(CASE WHEN a.assignment_group = 'Treatment' THEN a.post_campaign_margin_inr END)
           - AVG(CASE WHEN a.assignment_group = 'Control'   THEN a.post_campaign_margin_inr END), 1) AS offer_minus_no_offer
FROM campaign_assignments a JOIN customers c ON a.customer_id = c.customer_id GROUP BY c.membership_status
UNION ALL
SELECT 'City tier', c.city_tier,
       ROUND(AVG(CASE WHEN a.assignment_group = 'Treatment' THEN a.post_campaign_margin_inr END)
           - AVG(CASE WHEN a.assignment_group = 'Control'   THEN a.post_campaign_margin_inr END), 1)
FROM campaign_assignments a JOIN customers c ON a.customer_id = c.customer_id GROUP BY c.city_tier
UNION ALL
SELECT 'Channel', c.acquisition_channel,
       ROUND(AVG(CASE WHEN a.assignment_group = 'Treatment' THEN a.post_campaign_margin_inr END)
           - AVG(CASE WHEN a.assignment_group = 'Control'   THEN a.post_campaign_margin_inr END), 1)
FROM campaign_assignments a JOIN customers c ON a.customer_id = c.customer_id GROUP BY c.acquisition_channel;

-- Orders that point to a customer or store that doesn't exist
SELECT (SELECT COUNT(*) FROM orders WHERE customer_id NOT IN (SELECT customer_id FROM customers)) AS orders_with_unknown_customer,
       (SELECT COUNT(*) FROM orders WHERE store_id NOT IN (SELECT store_id FROM stores))          AS orders_with_unknown_store,
       (SELECT COUNT(DISTINCT customer_id) FROM orders)                                         AS customers_who_ordered;

-- Discounts, refunds and support contacts
SELECT ROUND(100.0 * SUM(discount_inr) / SUM(basket_value_inr), 1)                     AS discounts_pct_of_sales,
       ROUND(100.0 * SUM(refund_inr) / SUM(basket_value_inr), 1)                       AS refunds_pct_of_sales,
       ROUND(100.0 * AVG(CASE WHEN refund_inr > 0 THEN 1 ELSE 0 END), 1)              AS pct_orders_with_a_refund,
       ROUND(100.0 * AVG(CASE WHEN stockout_item_count > 0 THEN 1 ELSE 0 END), 1)     AS pct_orders_with_a_stockout,
       ROUND(100.0 * AVG(service_contact_flag), 1)                                     AS pct_orders_contacting_support,
       ROUND(SUM(discount_inr), 0)                                                      AS total_discounts,
       ROUND(SUM(contribution_margin_inr), 0)                                           AS total_margin
FROM orders;

-- Loss-making orders: how many had a refund?
SELECT ROUND(100.0 * AVG(CASE WHEN refund_inr > 0 THEN 1 ELSE 0 END), 1) AS pct_loss_orders_with_refund
FROM orders
WHERE contribution_margin_inr < 0;

-- Month by month: lateness and discount share
SELECT strftime('%m', order_timestamp)                              AS month,
       ROUND(100.0 * AVG(late_delivery_flag), 1)                     AS pct_late,
       ROUND(100.0 * SUM(discount_inr) / SUM(basket_value_inr), 1)   AS discount_pct_of_sales
FROM orders
GROUP BY month
ORDER BY month;

-- Customers grouped by how much of their spend was discounted
SELECT CASE WHEN discount_share <= 0.05 THEN '1. up to 5%'
            WHEN discount_share <= 0.08 THEN '2. 5-8%'
            WHEN discount_share <= 0.11 THEN '3. 8-11%'
            ELSE '4. over 11%' END                      AS discount_share_of_spend,
       COUNT(*)                                          AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1)          AS pct_repeat,
       ROUND(AVG(orders), 1)                             AS orders_per_customer,
       ROUND(AVG(margin_per_order), 1)                   AS margin_per_order
FROM (SELECT c.customer_id, c.repeat_order_30d,
             COUNT(*)                                       AS orders,
             SUM(o.discount_inr) / SUM(o.basket_value_inr)  AS discount_share,
             AVG(o.contribution_margin_inr)                 AS margin_per_order
      FROM orders o JOIN customers c ON o.customer_id = c.customer_id
      GROUP BY c.customer_id)
GROUP BY discount_share_of_spend
ORDER BY discount_share_of_spend;

-- Customers grouped by how many categories they buy per order
SELECT CASE WHEN avg_categories <= 3 THEN '1. up to 3'
            WHEN avg_categories <= 5 THEN '2. 3-5'
            ELSE '3. more than 5' END             AS categories_per_order,
       COUNT(*)                                    AS customers,
       ROUND(100.0 * AVG(repeat_order_30d), 1)    AS pct_repeat
FROM (SELECT c.customer_id, c.repeat_order_30d, AVG(o.unique_category_count) AS avg_categories
      FROM orders o JOIN customers c ON o.customer_id = c.customer_id
      GROUP BY c.customer_id)
GROUP BY categories_per_order
ORDER BY categories_per_order;

-- Members vs non-members: discount as a share of spend
SELECT CASE WHEN c.membership_status = 'Non-member' THEN 'Non-member' ELSE 'Member' END AS membership,
       ROUND(100.0 * SUM(o.discount_inr) / SUM(o.basket_value_inr), 1)                  AS discount_pct_of_spend
FROM orders o JOIN customers c ON o.customer_id = c.customer_id
GROUP BY membership;

-- Late % and margin per order by weather and time of day
SELECT weather_flag,
       CASE WHEN peak_period_flag = 1 THEN 'Peak' ELSE 'Off-peak' END AS time_of_day,
       COUNT(*) AS orders,
       ROUND(100.0 * AVG(late_delivery_flag), 1)  AS pct_late,
       ROUND(AVG(contribution_margin_inr), 1)     AS margin_per_order
FROM orders
GROUP BY weather_flag, time_of_day
ORDER BY weather_flag, time_of_day;

-- Four equal groups of orders, by the store's stock accuracy
SELECT quartile,
       MIN(inventory_accuracy_pct)              AS lowest_accuracy,
       MAX(inventory_accuracy_pct)              AS highest_accuracy,
       COUNT(*)                                 AS orders,
       ROUND(AVG(stockout_item_count), 2)       AS missing_items_per_order,
       ROUND(AVG(refund_inr), 1)                AS refund_per_order,
       ROUND(AVG(contribution_margin_inr), 1)   AS margin_per_order,
       ROUND(AVG(rating), 2)                    AS avg_rating
FROM (SELECT o.*, s.inventory_accuracy_pct,
             NTILE(4) OVER (ORDER BY s.inventory_accuracy_pct) AS quartile   -- NTILE(4) = cut into 4 equal groups
      FROM orders o JOIN stores s ON o.store_id = s.store_id)
GROUP BY quartile
ORDER BY quartile;

-- Late vs on-time, inside each distance band (delivered orders)
SELECT CASE WHEN delivery_distance_km <= 2 THEN '1. up to 2 km'
            WHEN delivery_distance_km <= 4 THEN '2. 2-4 km'
            ELSE '3. over 4 km' END                   AS distance,
       CASE WHEN late_delivery_flag = 1 THEN 'Late' ELSE 'On time' END AS delivery,
       COUNT(*)                                       AS orders,
       ROUND(AVG(contribution_margin_inr), 1)         AS margin_per_order,
       ROUND(AVG(rating), 2)                          AS avg_rating,
       ROUND(100.0 * AVG(service_contact_flag), 1)    AS pct_contacted_support
FROM orders
WHERE cancelled_flag = 0
GROUP BY distance, delivery
ORDER BY distance, delivery;

-- Margin and delivery cost by distance
SELECT CASE WHEN delivery_distance_km <= 1 THEN '1. up to 1 km'
            WHEN delivery_distance_km <= 2 THEN '2. 1-2 km'
            WHEN delivery_distance_km <= 3 THEN '3. 2-3 km'
            WHEN delivery_distance_km <= 4 THEN '4. 3-4 km'
            ELSE '5. over 4 km' END                AS distance,
       COUNT(*)                                    AS orders,
       ROUND(AVG(delivery_cost_inr), 1)            AS delivery_cost,
       ROUND(AVG(contribution_margin_inr), 1)      AS margin_per_order,
       ROUND(100.0 * AVG(late_delivery_flag), 1)   AS pct_late
FROM orders
GROUP BY distance
ORDER BY distance;

-- Late % by five distance bands and promise (delivered orders)
SELECT CASE WHEN delivery_distance_km <= 1 THEN '0-1'
            WHEN delivery_distance_km <= 2 THEN '1-2'
            WHEN delivery_distance_km <= 3 THEN '2-3'
            WHEN delivery_distance_km <= 4 THEN '3-4'
            ELSE '4+' END                       AS band,
       promised_minutes,
       COUNT(*)                                 AS orders,
       AVG(late_delivery_flag)                  AS late_rate
FROM orders
WHERE cancelled_flag = 0
GROUP BY band, promised_minutes;

