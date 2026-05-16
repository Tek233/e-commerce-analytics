-- =====================================================
-- Calculate the total revenue (quantity × unit_price) each customer has generated. 
-- Show customer name, email, and total revenue. Order by revenue descending. Include only delivered orders.
-- =====================================================
SET search_path TO ecommerce;

SELECT full_name, email, SUM(quantity* unit_price) AS sum_money_spent FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_items i ON o.order_id = i.order_id
	WHERE status= 'delivered'
	GROUP BY c.customer_id,full_name,email
	ORDER BY sum_money_spent DESC;

-- =====================================================
-- Find all customers who have never placed any order. Return their full_name, email, and signup_date.
-- Expected output:
-- Customers with no matching row in orders.
-- =====================================================
SELECT full_name,email,signup_date FROM customers 
	LEFT JOIN orders USING(customer_id)
	WHERE order_id is NULL
	ORDER BY signup_date;

-- =====================================================
-- Show total revenue (from delivered order_items) grouped by calendar month for the year 2024. 
-- Order chronologically.
-- Expected output:
-- Columns: month, total_revenue.
-- =====================================================
SELECT  EXTRACT(month from order_date) AS month, SUM(quantity * unit_price) AS total_revenue FROM orders
	JOIN order_items USING(order_id)
	WHERE (EXTRACT(year from order_date) ='2024' AND status='delivered')
	GROUP BY 1
	ORDER BY 1;

-- =====================================================
-- For each shipping country, count how many orders are in each status (delivered, shipped, pending, cancelled). Pivot the result so each status is its own column.
-- Expected output:
-- Columns: shipping_country, delivered, shipped, pending, cancelled.
-- =====================================================
SELECT country AS shipping_country,
	COUNT(CASE WHEN o.status= 'delivered' THEN 1 END) AS delivered, 
	COUNT(CASE WHEN o.status= 'shipped' THEN 1 END) AS shipped,
	COUNT(CASE WHEN o.status= 'pending' THEN 1 END) AS pending,
	COUNT(CASE WHEN o.status= 'cancelled' THEN 1 END) AS cancelled 

	FROM customers
	JOIN orders o USING(customer_id)
	GROUP BY country
	ORDER BY country;

-- =====================================================
-- Find all products where the total refund_amount exceeds $100. 
-- Return product name, category, total units sold, total refunded amount, and return rate (refunded units ÷ sold units, as a percentage).
-- Expected output:
-- Only products with total refunds > $100.
-- =====================================================
SELECT product_id, name, category,
	SUM(quantity) AS total_units_sold, 
	SUM(refund_amount) AS total_refunded_amount, 
	 ROUND(
        100.0 * COUNT(return_id) / NULLIF(SUM(quantity), 0),
        2
    ) AS return_rate
	FROM products
	JOIN order_items USING(product_id)
	JOIN returns USING(item_id) 
	GROUP BY product_id,name, category
	HAVING SUM(refund_amount) >100;

-- =====================================================
-- For each product category, find the single best-selling product by total revenue (quantity × unit_price).
-- If there is a tie, return both.
-- Expected output:
-- Columns: category, product_name, total_revenue, rank_in_category.
-- =====================================================
WITH summed_vals AS (
    SELECT
        category,
        name AS product_name,
        SUM(quantity * unit_price) AS total_revenue
    FROM products p
    JOIN order_items USING(product_id)
    GROUP BY name, category
),
ranked_prods AS (
    SELECT
        category,
        product_name,
        total_revenue,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_revenue DESC
        ) AS rank_in_category
    FROM summed_vals
)

SELECT *
FROM ranked_prods
WHERE rank_in_category = 1;

-- =====================================================
-- Days between a customer's consecutive orders
-- For each customer, list all their orders with the number of days since their previous order. 
-- First orders should show NULL for the gap. Order by customer, then order date.
-- Expected output:
-- Columns: full_name, order_id, order_date, days_since_prev_order.
-- =====================================================
SELECT
    full_name,
    order_id,
    order_date,
    order_date
      - LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date
        ) AS days_since_prev_order
FROM customers
LEFT JOIN orders USING(customer_id)
ORDER BY customer_id, order_date;

-- =====================================================
-- Calculate each product category's total revenue and its percentage of total store revenue across all delivered orders. 
-- Sort by revenue descending.
-- Expected output:
-- Columns: category, category_revenue, pct_of_total.
-- =====================================================
SELECT 
    category,
    SUM(quantity * unit_price) AS category_revenue,
    ROUND(
        (
            SUM(quantity * unit_price) * 100.0 /
            (
                SELECT SUM(quantity * unit_price)
                FROM order_items
                JOIN orders USING(order_id)
                WHERE status = 'delivered'
            )
        ),
        2
    ) AS pct_of_total
FROM products
JOIN order_items USING(product_id)
JOIN orders USING(order_id)
WHERE status = 'delivered'
GROUP BY category
ORDER BY category_revenue DESC;

-- =====================================================
-- Complete monthly revenue calendar (no gaps)
-- Generate a complete list of every month in 2024 (Jan–Dec). 
-- For each month, show total delivered revenue — including $0 for months with no sales.
-- Expected output:
-- 12 rows exactly. Columns: month, total_revenue (0 for empty months).
-- =====================================================
WITH months AS (
    SELECT generate_series(1, 12) AS month
)

SELECT m.month ,COALESCE(SUM(quantity*unit_price),0)  AS total_revenue 
	FROM months m
	LEFT JOIN orders o ON EXTRACT(month from o.order_date) = m.month
	AND EXTRACT(year from o.order_date)='2024'
	AND o.status='delivered'
	LEFT JOIN order_items oi USING(order_id)
	GROUP BY m.month
	ORDER BY m.month;

-- =====================================================
-- Group customers by their signup month (cohort). 
-- For each cohort, count: how many customers signed up, and how many placed at least one order within 30 days of signup. 
-- Show the conversion rate.
-- Expected output:
-- Columns: cohort_month, cohort_size, converted, conversion_rate_pct.
-- =====================================================
WITH customer_conversion AS (
	SELECT 
		c.customer_id,
		EXTRACT(month FROM c.signup_date) AS cohort_month,
		EXISTS(
			SELECT 1
			FROM orders o
			WHERE o.customer_id= c.customer_id
				AND o.order_date <= c.signup_date + INTERVAL '30 days'
                AND o.order_date >= c.signup_date
		) AS converted
 FROM customers c)


SELECT 
	cohort_month,
	COUNT(*) AS cohort_size,
	COUNT(*) FILTER (WHERE converted) AS converted,
	ROUND(100.0 * COUNT(*) FILTER (WHERE converted)/ COUNT(*),2) AS conversion_rate_pct
	FROM customer_conversion
	GROUP BY cohort_month
	ORDER BY cohort_month;

-- =====================================================
-- For each product, calculate: gross margin per unit (list_price − cost_price), total gross profit earned (sold units × margin), total refunds paid out, and net profit after refunds. 
-- Rank products by net profit.
-- Expected output:
-- Columns: name, category, margin_per_unit, gross_profit, total_refunds, net_profit, profit_rank.
-- =====================================================
WITH
	REFUND_PER_ITEM AS (
		SELECT
			ITEM_ID,
			SUM(REFUND_AMOUNT) AS TOTAL_REFUND
		FROM
			RETURNS
		GROUP BY
			ITEM_ID
	),
	PRODUCTS_INFO AS (
		SELECT
			OI.PRODUCT_ID,
			SUM(OI.QUANTITY) AS SOLD_UNITS,
			COALESCE(SUM(RPI.TOTAL_REFUND), 0) AS TOTAL_REFUNDS
		FROM
			ORDER_ITEMS OI
			LEFT JOIN REFUND_PER_ITEM RPI ON OI.ITEM_ID = RPI.ITEM_ID
		GROUP BY
			OI.PRODUCT_ID
	),
	NET_TABLE AS (
		SELECT
			NAME,
			CATEGORY,
			(LIST_PRICE - COST_PRICE) AS MARGIN_PER_UNIT,
			(LIST_PRICE - COST_PRICE) * SOLD_UNITS AS GROSS_PROFIT,
			TOTAL_REFUNDS,
			((LIST_PRICE - COST_PRICE) * SOLD_UNITS) - TOTAL_REFUNDS AS NET_PROFIT
		FROM
			PRODUCTS
			JOIN PRODUCTS_INFO PI USING (PRODUCT_ID)
	)
SELECT
	*,
	DENSE_RANK() OVER (
		ORDER BY
			NET_PROFIT DESC
	) AS PROFIT_RANK
FROM
	NET_TABLE;
