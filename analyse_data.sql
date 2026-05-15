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
