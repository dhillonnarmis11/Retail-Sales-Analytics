-- purpose: analyze category and seller sales performance
-- revenue includes item prices only, excluding freight
-- only delivered orders are included


-- Q1: top 10 product categories by merchandise revenue
-- join order items to products to find each item's category
-- join the translation table to display English category names
-- LEFT JOIN keeps products without a matching translation

SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name,
             'Unknown') AS category,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items AS oi
INNER JOIN orders AS o
    ON oi.order_id = o.order_id
INNER JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation AS t
    ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;



-- Q2: top 10 sellers by merchandise revenue
-- each seller may sell many products across different orders
-- COUNT(DISTINCT order_id) avoids counting multiple items from the same order as separate orders

SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM order_items AS oi
INNER JOIN orders AS o
    ON oi.order_id = o.order_id
INNER JOIN sellers AS s
    ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY oi.seller_id, s.seller_state
ORDER BY revenue DESC
LIMIT 10;



-- Q3: revenue by customer state
-- join orders to customers to find where buyers are located
-- Join order items to calculate merchandise revenue

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders AS o
INNER JOIN customers AS c
    ON o.customer_id = c.customer_id
INNER JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;
