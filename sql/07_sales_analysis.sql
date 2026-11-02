-- purpose: analyze orders, revenue, and customer locations

-- 1: combine orders with customer information
-- INNER JOIN connects records from two tables using a matching customer_id
-- lets us see which state each order came from
-- LIMIT 10 displays only first 10 matching records

SELECT
    o.order_id,
    o.order_status,
    c.customer_city,
    c.customer_state
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
LIMIT 10;



-- Q2: count delivered orders by customer state
-- join orders and customers to identify the location of each delivered order
-- GROUP BY combines orders belonging to the same state

SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY delivered_orders DESC;



-- Q3: calculate total delivered merchandise revenue
-- each order can contain multiple products
-- order_items table stores the selling price of each item
-- SUM(price) adds the prices together
-- exclude freight and non-delivered orders

SELECT
    ROUND(SUM(oi.price), 2) AS merchandise_revenue
FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';



-- Q4: calculate average order value 
-- first calculate revenue for each delivered order
-- then AVG calculates the average across those orders
-- this avoids treating each item as a separate order

SELECT
    ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
    SELECT
        o.order_id,
        SUM(oi.price) AS order_revenue
    FROM orders AS o
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.order_id
) AS order_totals;



-- Q5: monthly merchandise revenue trend
-- strftime('%Y-%m', ...) extracts the year and month
-- group delivered orders by purchase month
-- helps identify sales growth and seasonality

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS merchandise_revenue
FROM orders AS o
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY sales_month
ORDER BY sales_month;
