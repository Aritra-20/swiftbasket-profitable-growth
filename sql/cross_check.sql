-- Simple SQL that reproduces each number from my first analysis

-- Margin per order (₹) (first analysis: 44.27)
SELECT AVG(contribution_margin_inr) FROM orders;

-- Margin as % of sales (first analysis: 7.91)
SELECT 100.0*SUM(contribution_margin_inr)/SUM(basket_value_inr) FROM orders;

-- Discounts as % of sales (first analysis: 8.0)
SELECT 100.0*SUM(discount_inr)/SUM(basket_value_inr) FROM orders;

-- Refunds as % of sales (first analysis: 3.81)
SELECT 100.0*SUM(refund_inr)/SUM(basket_value_inr) FROM orders;

-- % orders losing money (first analysis: 21.0)
SELECT 100.0*AVG(CASE WHEN contribution_margin_inr<0 THEN 1 ELSE 0 END) FROM orders;

-- % orders late (first analysis: 17.28)
SELECT 100.0*AVG(late_delivery_flag) FROM orders;

-- % orders with a stock-out (first analysis: 63.95)
SELECT 100.0*AVG(CASE WHEN stockout_item_count>0 THEN 1 ELSE 0 END) FROM orders;

-- % loss-making orders with a refund (first analysis: 72.27)
SELECT 100.0*AVG(CASE WHEN refund_inr>0 THEN 1 ELSE 0 END) FROM orders WHERE contribution_margin_inr<0;

-- % of refund ₹ on orders with a stock-out (first analysis: 82.62)
SELECT 100.0*SUM(CASE WHEN stockout_item_count>0 THEN refund_inr ELSE 0 END)/SUM(refund_inr) FROM orders;

-- Product margin + delivery fee per order (₹) (first analysis: 167.26)
SELECT AVG(gross_margin_inr)+AVG(delivery_fee_inr) FROM orders;

-- Discount + refund per order (₹) (first analysis: 66.11)
SELECT AVG(discount_inr)+AVG(refund_inr) FROM orders;

-- % orders in rain, Jun-Sep (first analysis: 40.0)
SELECT 100.0*AVG(CASE WHEN weather_flag='Rain' THEN 1 ELSE 0 END) FROM orders WHERE strftime('%m',order_timestamp) BETWEEN '06' AND '09';

-- % orders in rain, other months (first analysis: 11.7)
SELECT 100.0*AVG(CASE WHEN weather_flag='Rain' THEN 1 ELSE 0 END) FROM orders WHERE strftime('%m',order_timestamp) NOT BETWEEN '06' AND '09';

-- Margin/order, top 20% discount-share orders (₹) (first analysis: -4.71)
SELECT AVG(contribution_margin_inr) FROM orders WHERE 1.0*discount_inr/basket_value_inr > 0.124;

-- Repeat %, customers with >11% discount share (first analysis: 43.34)
SELECT 100.0*AVG(c.repeat_order_30d) FROM customers c JOIN (SELECT customer_id, SUM(discount_inr)/SUM(basket_value_inr) AS ds FROM orders GROUP BY customer_id) d ON c.customer_id=d.customer_id WHERE d.ds>0.11;

-- Repeat %, customers with ≤5% discount share (first analysis: 23.12)
SELECT 100.0*AVG(c.repeat_order_30d) FROM customers c JOIN (SELECT customer_id, SUM(discount_inr)/SUM(basket_value_inr) AS ds FROM orders GROUP BY customer_id) d ON c.customer_id=d.customer_id WHERE d.ds<=0.05;

-- Avg margin/order, customers with >11% discount share (₹) (first analysis: 14.74)
SELECT AVG(mpo) FROM (SELECT customer_id, SUM(discount_inr)/SUM(basket_value_inr) AS ds, AVG(contribution_margin_inr) AS mpo FROM orders GROUP BY customer_id) WHERE ds>0.11;

-- Avg margin/order, customers with ≤5% discount share (₹) (first analysis: 74.08)
SELECT AVG(mpo) FROM (SELECT customer_id, SUM(discount_inr)/SUM(basket_value_inr) AS ds, AVG(contribution_margin_inr) AS mpo FROM orders GROUP BY customer_id) WHERE ds<=0.05;

-- Repeat %, 13+ app sessions (first analysis: 61.03)
SELECT 100.0*AVG(repeat_order_30d) FROM customers WHERE app_sessions_30d>=13;

-- Repeat %, 0-3 app sessions (first analysis: 10.43)
SELECT 100.0*AVG(repeat_order_30d) FROM customers WHERE app_sessions_30d<=3;

-- Late %, 20-min promise, over 4 km (first analysis: 72.5)
SELECT 100.0*AVG(late_delivery_flag) FROM orders WHERE promised_minutes=20 AND delivery_distance_km>4;

-- Late %, 20-min promise overall (first analysis: 40.4)
SELECT 100.0*AVG(late_delivery_flag) FROM orders WHERE promised_minutes=20;

-- Late %, rain at peak hours (first analysis: 47.5)
SELECT 100.0*AVG(late_delivery_flag) FROM orders WHERE weather_flag='Rain' AND peak_period_flag=1;

-- Late %, normal weather off-peak (first analysis: 6.9)
SELECT 100.0*AVG(late_delivery_flag) FROM orders WHERE weather_flag='Normal' AND peak_period_flag=0;

-- Avg refund, no item missing, all orders incl. cancelled (₹) (first analysis: 10.28)
SELECT AVG(refund_inr) FROM orders WHERE stockout_item_count=0;

-- Avg refund, 1 item missing (₹) (first analysis: 27.66)
SELECT AVG(refund_inr) FROM orders WHERE stockout_item_count=1;

-- Avg rating, 3+ items missing (first analysis: 2.94)
SELECT AVG(rating) FROM orders WHERE stockout_item_count>=3;

-- Campaign: treatment minus control margin (₹) (first analysis: -12.46)
SELECT AVG(CASE WHEN assignment_group='Treatment' THEN post_campaign_margin_inr END) - AVG(CASE WHEN assignment_group='Control' THEN post_campaign_margin_inr END) FROM campaign_assignments;

-- Fixed discount vs no offer (₹) (first analysis: -20.64)
SELECT AVG(CASE WHEN offer_type='Fixed discount' THEN post_campaign_margin_inr END) - AVG(CASE WHEN offer_type='No offer' THEN post_campaign_margin_inr END) FROM campaign_assignments;

-- Percentage discount vs no offer (₹) (first analysis: -14.07)
SELECT AVG(CASE WHEN offer_type='Percentage discount' THEN post_campaign_margin_inr END) - AVG(CASE WHEN offer_type='No offer' THEN post_campaign_margin_inr END) FROM campaign_assignments;

-- Free delivery vs no offer, everyone (₹) (first analysis: -2.1)
SELECT AVG(CASE WHEN offer_type='Free delivery' THEN post_campaign_margin_inr END) - AVG(CASE WHEN offer_type='No offer' THEN post_campaign_margin_inr END) FROM campaign_assignments;

-- Free delivery vs no offer, lapsed + low app use (₹) (first analysis: 8.28)
SELECT AVG(CASE WHEN a.offer_type='Free delivery' THEN a.post_campaign_margin_inr END) - AVG(CASE WHEN a.offer_type='No offer' THEN a.post_campaign_margin_inr END) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE c.days_since_last_order>90 AND c.app_sessions_30d<=7;

-- Extra orders, free delivery, lapsed + low app use (first analysis: 0.28)
SELECT AVG(CASE WHEN a.offer_type='Free delivery' THEN a.post_campaign_orders END) - AVG(CASE WHEN a.offer_type='No offer' THEN a.post_campaign_orders END) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE c.days_since_last_order>90 AND c.app_sessions_30d<=7;

-- Free delivery vs no offer, active + high app use (₹) (first analysis: -13.72)
SELECT AVG(CASE WHEN a.offer_type='Free delivery' THEN a.post_campaign_margin_inr END) - AVG(CASE WHEN a.offer_type='No offer' THEN a.post_campaign_margin_inr END) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE c.days_since_last_order<=90 AND c.app_sessions_30d>7;

-- All offers vs no offer, active + high app use (₹) (first analysis: -25.84)
SELECT AVG(CASE WHEN a.assignment_group='Treatment' THEN a.post_campaign_margin_inr END) - AVG(CASE WHEN a.assignment_group='Control' THEN a.post_campaign_margin_inr END) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE c.days_since_last_order<=90 AND c.app_sessions_30d>7;

-- Redemption %, active + high app use (first analysis: 41.6)
SELECT 100.0*AVG(a.offer_redeemed_flag) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE a.assignment_group='Treatment' AND c.days_since_last_order<=90 AND c.app_sessions_30d>7;

-- Redemption %, lapsed + low app use (first analysis: 24.1)
SELECT 100.0*AVG(a.offer_redeemed_flag) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE a.assignment_group='Treatment' AND c.days_since_last_order>90 AND c.app_sessions_30d<=7;

-- % of customers who are lapsed + low app use (first analysis: 32.6)
SELECT 100.0*AVG(CASE WHEN days_since_last_order>90 AND app_sessions_30d<=7 THEN 1 ELSE 0 END) FROM customers;

-- Promo gain per 10,000 customers, targeted (₹) (first analysis: 26985)
SELECT 10000 * (SELECT AVG(CASE WHEN days_since_last_order>90 AND app_sessions_30d<=7 THEN 1.0 ELSE 0 END) FROM customers) * (SELECT AVG(CASE WHEN a.offer_type='Free delivery' THEN a.post_campaign_margin_inr END) - AVG(CASE WHEN a.offer_type='No offer' THEN a.post_campaign_margin_inr END) FROM campaign_assignments a JOIN customers c ON a.customer_id=c.customer_id WHERE c.days_since_last_order>90 AND c.app_sessions_30d<=7);

-- Promo loss per 10,000 customers, as run (₹) (first analysis: -124610)
SELECT 10000*(AVG(CASE WHEN assignment_group='Treatment' THEN post_campaign_margin_inr END) - AVG(CASE WHEN assignment_group='Control' THEN post_campaign_margin_inr END)) FROM campaign_assignments;

-- Margin/order, customers in top 20% by order count (₹) (first analysis: 36.49)
SELECT AVG(o.contribution_margin_inr) FROM orders o JOIN customers c ON o.customer_id=c.customer_id WHERE c.customer_id IN (SELECT customer_id FROM customers WHERE historical_orders_12m>0 ORDER BY historical_orders_12m DESC, customer_id DESC LIMIT 1351);

-- Margin/order, bottom 20% by order count (₹) (first analysis: 56.61)
SELECT AVG(o.contribution_margin_inr) FROM orders o JOIN customers c ON o.customer_id=c.customer_id WHERE c.customer_id IN (SELECT customer_id FROM customers WHERE historical_orders_12m>0 ORDER BY historical_orders_12m ASC, customer_id ASC LIMIT 1352);

-- Stores below 90% stock accuracy: margin/order (₹) (first analysis: 38.66)
SELECT AVG(o.contribution_margin_inr) FROM orders o JOIN stores s ON o.store_id=s.store_id WHERE s.inventory_accuracy_pct<90;

