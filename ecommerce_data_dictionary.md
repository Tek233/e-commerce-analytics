# Ecommerce Database Data Dictionary

## Overview
This document describes the structure, relationships, constraints, and indexes used in the `ecommerce` database schema.

Schema Name: `ecommerce`

---

# Tables

## 1. customers

Stores customer account and membership information.

| Column Name | Data Type | Description | Constraints |
|-------------|------------|-------------|-------------|
| customer_id | INT | Unique customer identifier | Primary Key, Auto-generated |
| full_name | TEXT | Customer full name | NOT NULL |
| email | TEXT | Customer email address | NOT NULL, UNIQUE |
| country | TEXT | Customer country | NOT NULL |
| signup_date | DATE | Customer registration date | NOT NULL, Must be after 2005-01-01 |
| tier | TEXT | Membership tier | NOT NULL, Values: bronze, silver, gold |

### Constraints
- `customers_email_key`
- `customers_signup_date_chk`
- `customers_tier_chk`

### Relationships
- One customer can place many orders.

---

## 2. orders

Stores order header information.

| Column Name | Data Type | Description | Constraints |
|-------------|------------|-------------|-------------|
| order_id | INT | Unique order identifier | Primary Key, Auto-generated |
| customer_id | INT | Customer who placed the order | Foreign Key → customers.customer_id |
| order_date | TIMESTAMPTZ | Date and time order was placed | NOT NULL, Must be after 2005-01-01 |
| status | TEXT | Current order status | NOT NULL, Values: pending, shipped, delivered, cancelled |
| shipping_country | TEXT | Shipping destination country | NOT NULL |
| discount_code | TEXT | Applied promotion code | Nullable |

### Constraints
- `orders_order_date_chk`
- `orders_status_chk`

### Relationships
- Many orders belong to one customer.
- One order can contain many order items.

---

## 3. products

Stores product catalog information.

| Column Name | Data Type | Description | Constraints |
|-------------|------------|-------------|-------------|
| product_id | INT | Unique product identifier | Primary Key, Auto-generated |
| name | TEXT | Product name | NOT NULL |
| category | TEXT | Product category | NOT NULL |
| cost_price | NUMERIC(10,2) | Internal product cost | NOT NULL, Must be ≥ 0 |
| list_price | NUMERIC(10,2) | Product selling price | NOT NULL, Must be ≥ cost_price |
| is_active | BOOLEAN | Indicates whether product is active | NOT NULL, Default = true |

### Relationships
- One product can appear in many order items.

---

## 4. order_items

Stores line items for each order.

| Column Name | Data Type | Description | Constraints |
|-------------|------------|-------------|-------------|
| item_id | INT | Unique order item identifier | Primary Key, Auto-generated |
| order_id | INT | Related order | Foreign Key → orders.order_id |
| product_id | INT | Related product | Foreign Key → products.product_id |
| quantity | INT | Quantity ordered | NOT NULL, Must be > 0 |
| unit_price | NUMERIC(10,2) | Product price at purchase time | NOT NULL, Must be ≥ 0 |

### Relationships
- Many order items belong to one order.
- Many order items reference one product.
- One order item can have associated returns.

---

## 5. returns

Stores product return information.

| Column Name | Data Type | Description | Constraints |
|-------------|------------|-------------|-------------|
| return_id | INT | Unique return identifier | Primary Key, Auto-generated |
| item_id | INT | Returned order item | Foreign Key → order_items.item_id |
| return_date | DATE | Return processing date | NOT NULL |
| reason | TEXT | Reason for return | NOT NULL, Values: defective, wrong_item, changed_mind |
| refund_amount | NUMERIC(10,2) | Refund amount issued | NOT NULL, Must be ≥ 0 |

### Constraints
- `returns_reason_chk`

### Relationships
- Many returns can reference one order item.

---

# Indexes

| Index Name | Table | Column(s) | Purpose |
|------------|-------|------------|---------|
| idx_orders_customer_id | orders | customer_id | Improves customer order lookups |
| idx_order_items_order_id | order_items | order_id | Improves order item retrieval |
| idx_order_items_product_id | order_items | product_id | Improves product order searches |
| idx_returns_item_id | returns | item_id | Improves return lookups |

---

# Entity Relationship Summary

- customers → orders (1-to-many)
- orders → order_items (1-to-many)
- products → order_items (1-to-many)
- order_items → returns (1-to-many)
