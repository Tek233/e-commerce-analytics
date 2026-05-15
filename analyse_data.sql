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
