-- purpose: validate data and analyze revenue using SQL window functions


-- Q1: check for orders without a matching customer
-- LEFT JOIN keeps all orders, even without a customer match
-- if c.customer_id is NULL, the relationship is missing

SELECT
    COUNT(*) AS orders_without_customers
FROM orders AS o
LEFT JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;



-- Q2: check for missing delivery dates
-- only delivered orders should normally have delivery dates

SELECT
    COUNT(*) AS delivered_orders_missing_delivery_date
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;



-- Q3: rank product categories by merchandise revenue
-- RANK() assigns a ranking based on total revenue
-- CTE first calculates revenue for each category

WITH category_revenue AS (
    SELECT
        COALESCE(t.product_category_name_english,
                 p.product_category_name,
                 'Unknown') AS category,
        SUM(oi.price) AS revenue
    FROM order_items AS oi
    INNER JOIN orders AS o
        ON oi.order_id = o.order_id
    INNER JOIN products AS p
        ON oi.product_id = p.product_id
    LEFT JOIN category_translation AS t
        ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY category
)

SELECT
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank,
    category,
    ROUND(revenue, 2) AS revenue
FROM category_revenue
ORDER BY revenue_rank
LIMIT 10;



-- Q4: calculate monthly revenue and running total
-- SUM() OVER() calculates a cumulative total and helps show how revenue accumulated over time

WITH monthly_revenue AS (
    SELECT
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        SUM(oi.price) AS revenue
    FROM orders AS o
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)

SELECT
    month,
    ROUND(revenue, 2) AS monthly_revenue,
    ROUND(
        SUM(revenue) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ), 2
    ) AS cumulative_revenue
FROM monthly_revenue
ORDER BY month;



-- Q5: calculate each state's percentage of total revenue
-- SUM() OVER() calculates the overall revenue total without removing the individual state rows

WITH state_revenue AS (
    SELECT
        c.customer_state,
        SUM(oi.price) AS revenue
    FROM orders AS o
    INNER JOIN customers AS c
        ON o.customer_id = c.customer_id
    INNER JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)

SELECT
    customer_state,
    ROUND(revenue, 2) AS revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER (), 2
    ) AS revenue_percentage
FROM state_revenue
ORDER BY revenue DESC;
