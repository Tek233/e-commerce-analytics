-- =====================================================
-- CREATE SCHEMA
-- =====================================================

CREATE SCHEMA IF NOT EXISTS ecommerce;
SET search_path TO ecommerce;

-- =====================================================
-- DROP TABLES IF EXIST
-- =====================================================

DROP TABLE IF EXISTS returns;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- =====================================================
-- CREATE TABLES
-- =====================================================

CREATE TABLE customers (
    customer_id INT GENERATED ALWAYS AS IDENTITY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL,
    country TEXT NOT NULL,
    signup_date DATE NOT NULL,
    tier TEXT NOT NULL,

    CONSTRAINT customers_signup_date_chk
        CHECK (signup_date > DATE '2005-01-01'),

    CONSTRAINT customers_email_key
        UNIQUE (email),

    CONSTRAINT customers_pkey
        PRIMARY KEY (customer_id),

    CONSTRAINT customers_tier_chk
        CHECK (tier IN ('bronze', 'silver', 'gold'))
);

-- =====================================================

CREATE TABLE orders (
    order_id INT GENERATED ALWAYS AS IDENTITY,
    customer_id INT NOT NULL,
    order_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL,
    shipping_country TEXT NOT NULL,
    discount_code TEXT,

    CONSTRAINT orders_order_date_chk
        CHECK (order_date > TIMESTAMPTZ '2005-01-01'),

    CONSTRAINT orders_pkey
        PRIMARY KEY (order_id),

    CONSTRAINT orders_customer_id_fkey
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE RESTRICT,

    CONSTRAINT orders_status_chk
        CHECK (
            status IN (
                'pending',
                'shipped',
                'delivered',
                'cancelled'
            )
        )
);

-- =====================================================

CREATE TABLE products (
    product_id INT GENERATED ALWAYS AS IDENTITY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,

    cost_price NUMERIC(10,2) NOT NULL
        CHECK (cost_price >= 0),

    list_price NUMERIC(10,2) NOT NULL
        CHECK (list_price >= cost_price),

    is_active BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT products_pkey
        PRIMARY KEY (product_id)
);

-- =====================================================

CREATE TABLE order_items (
    item_id INT GENERATED ALWAYS AS IDENTITY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,

    quantity INT NOT NULL
        CHECK (quantity > 0),

    unit_price NUMERIC(10,2) NOT NULL
        CHECK (unit_price >= 0),

    CONSTRAINT order_items_pkey
        PRIMARY KEY (item_id),

    CONSTRAINT order_items_order_id_fkey
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE,

    CONSTRAINT order_items_product_id_fkey
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT
);

-- =====================================================

CREATE TABLE returns (
    return_id INT GENERATED ALWAYS AS IDENTITY,
    item_id INT NOT NULL,
    return_date DATE NOT NULL,
    reason TEXT NOT NULL,

    refund_amount NUMERIC(10,2) NOT NULL
        CHECK (refund_amount >= 0),

    CONSTRAINT returns_pkey
        PRIMARY KEY (return_id),

    CONSTRAINT returns_item_id_fkey
        FOREIGN KEY (item_id)
        REFERENCES order_items(item_id),

    CONSTRAINT returns_reason_chk
        CHECK (
            reason IN (
                'defective',
                'wrong_item',
                'changed_mind'
            )
        )
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_orders_customer_id
    ON orders(customer_id);

CREATE INDEX idx_order_items_order_id
    ON order_items(order_id);

CREATE INDEX idx_order_items_product_id
    ON order_items(product_id);

CREATE INDEX idx_returns_item_id
    ON returns(item_id);
