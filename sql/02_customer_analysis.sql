-- count customer records in each Brazilian state

SELECT
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
ORDER BY customer_count DESC;


-- total customer records
SELECT COUNT(*) AS total_customers
FROM customers;


-- count customer records from Sao Paulo

SELECT COUNT(*) AS sp_customers
FROM customers
WHERE customer_state = 'SP';


-- count customers from Sao Paulo or Rio de Janeiro

SELECT COUNT(*) AS sp_rj_customers
FROM customers
WHERE customer_state IN ('SP', 'RJ');


-- count customers from Sao Paulo City within state SP using AND

SELECT COUNT(*) AS sao_paulo_city_customers
FROM customers
WHERE customer_state = 'SP' AND customer_city = 'sao paulo';


-- find the top 5 cities in SP by customer records

SELECT 
    customer_city,
    COUNT(*) AS customer_count
FROM customers
WHERE customer_state = 'SP'
GROUP BY customer_city
ORDER BY customer_count DESC
LIMIT 5;


-- count unique shoppers in the dataset

SELECT
    COUNT(DISTINCT customer_unique_id) AS unique_customers
FROM customers;


-- find states with more than 2000 customer records

SELECT 
    customer_state,
    COUNT(*) AS customer_count
FROM customers
GROUP BY customer_state
HAVING COUNT(*) > 2000
ORDER BY customer_count DESC;





