
-- count orders by their current status

SELECT 
    order_status,
    COUNT(*) AS order_count
FROM orders 
GROUP BY order_status
ORDER BY order_count DESC; 
