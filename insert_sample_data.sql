-- =====================================================
-- INSERT DATA
-- =====================================================

-- CUSTOMERS
INSERT INTO customers
(email, full_name, country, signup_date, tier)
VALUES
('alice@example.com', 'Alice Morgan', 'US', '2022-03-10', 'gold'),
('bob@example.com', 'Bob Chen', 'CA', '2022-07-22', 'silver'),
('caro@example.com', 'Carolina Díaz', 'MX', '2023-01-05', 'bronze'),
('david@example.com', 'David Park', 'US', '2023-04-18', 'silver'),
('eva@example.com', 'Eva Schmidt', 'DE', '2023-09-30', 'bronze'),
('fran@example.com', 'Fran Torres', 'ES', '2024-02-14', 'bronze');

-- PRODUCTS
INSERT INTO products
(name, category, cost_price, list_price, is_active)
VALUES
('Wireless Mouse', 'Electronics', 18.00, 49.99, TRUE),
('Mechanical Keyboard', 'Electronics', 60.00, 129.00, TRUE),
('Notebook Set', 'Stationery', 5.00, 19.99, TRUE),
('Desk Lamp', 'Home', 22.00, 89.00, FALSE);

-- ORDERS
INSERT INTO orders
(customer_id, order_date, status, shipping_country, discount_code)
VALUES
(1, '2024-01-15 09:12:00+00', 'delivered', 'US', 'SAVE10'),
(1, '2024-02-03 14:55:00+00', 'delivered', 'US', NULL),
(2, '2024-02-20 08:30:00+00', 'shipped', 'CA', 'WELCOME'),
(3, '2024-03-01 17:00:00+00', 'cancelled', 'MX', NULL),
(4, '2024-03-10 11:45:00+00', 'delivered', 'US', NULL),
(5, '2024-03-22 20:10:00+00', 'pending', 'DE', 'SAVE10');

-- ORDER ITEMS
INSERT INTO order_items
(order_id, product_id, quantity, unit_price)
VALUES
(1, 1, 2, 49.99),
(1, 2, 1, 129.00),
(2, 1, 1, 49.99),
(3, 3, 3, 19.99),
(5, 2, 2, 129.00),
(6, 4, 1, 89.00);

-- RETURNS
INSERT INTO returns
(item_id, return_date, reason, refund_amount)
VALUES
(1, '2024-01-28', 'defective', 99.98),
(4, '2024-03-05', 'changed_mind', 59.97),
(5, '2024-03-20', 'wrong_item', 129.00);
