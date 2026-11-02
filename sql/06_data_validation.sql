-- purpose: verify that all 9 CSV files imported successfully

-- use COUNT(*) to count the number of rows in each table
-- UNION ALL combines results into one output (unlike UNION, UNION ALL does not remove duplicate rows)
-- makes it suitable for combining our table counts

-- check the number of customer records
SELECT 'customers' AS table_name,
       COUNT(*) AS row_count
FROM customers

UNION ALL

-- check the number of orders
SELECT 'orders', COUNT(*)
FROM orders

UNION ALL

-- check the number of individual order items
SELECT 'order_items', COUNT(*)
FROM order_items

UNION ALL

-- check the number of payment records
SELECT 'order_payments', COUNT(*)
FROM order_payments

UNION ALL

-- check the number of products
SELECT 'products', COUNT(*)
FROM products

UNION ALL

-- check the number of sellers
SELECT 'sellers', COUNT(*)
FROM sellers

UNION ALL

-- check the number of product category translations
SELECT 'category_translation', COUNT(*)
FROM category_translation

UNION ALL

-- check the number of customer reviews
SELECT 'order_reviews', COUNT(*)
FROM order_reviews

UNION ALL

-- check the number of geographic records
SELECT 'geolocation', COUNT(*)
FROM geolocation;