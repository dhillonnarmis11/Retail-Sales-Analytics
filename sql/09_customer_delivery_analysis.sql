
-- purpose: analyze customer retention and delivery performance


-- Q1: count customers who made more than one order
-- customer_unique_id identifies the same shopper across orders
-- first count orders per shopper, then identify repeat buyers

WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS order_count
    FROM customers AS c
    INNER JOIN orders AS o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)

SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        AS repeat_customers,
    ROUND(
        100.0 * SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END)
        / COUNT(*), 2
    ) AS repeat_customer_percentage
FROM customer_orders;



-- Q2: average delivery time in days
-- julianday() converts dates into numeric values
-- subtracting purchase date from the delivery date gives approx delivery time in days

SELECT
    ROUND(
        AVG(
            julianday(order_delivered_customer_date)
            - julianday(order_purchase_timestamp)
        ), 2
    ) AS average_delivery_days
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;



-- Q3: percentage of deliveries arriving late
-- compare actual delivery date against the estimated date
-- DATE() removes the time component for date-level comparison

SELECT
    COUNT(*) AS delivered_orders_with_dates,
    SUM(
        CASE
            WHEN DATE(order_delivered_customer_date)
                 > DATE(order_estimated_delivery_date)
            THEN 1 ELSE 0
        END
    ) AS late_deliveries,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN DATE(order_delivered_customer_date)
                     > DATE(order_estimated_delivery_date)
                THEN 1 ELSE 0
            END
        ) / COUNT(*), 2
    ) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL
AND order_estimated_delivery_date IS NOT NULL;



-- Q4: customer satisfaction by delivery performance
-- compare avg review scores for late and on time orders
-- first, aggregate reviews per order to prevent duplicate joins

WITH review_scores AS (
    SELECT
        order_id,
        AVG(review_score) AS average_review_score
    FROM order_reviews
    GROUP BY order_id
)

SELECT
    CASE
        WHEN DATE(o.order_delivered_customer_date)
             > DATE(o.order_estimated_delivery_date)
        THEN 'Late'
        ELSE 'On time or early'
    END AS delivery_performance,
    COUNT(*) AS reviewed_orders,
    ROUND(AVG(r.average_review_score), 2) AS average_review_score
FROM orders AS o
INNER JOIN review_scores AS r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_performance
ORDER BY average_review_score DESC;
