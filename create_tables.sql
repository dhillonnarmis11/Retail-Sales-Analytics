
-- create a table to store retail sales data

CREATE TABLE IF NOT EXISTS sales (
    sale_id INTEGER PRIMARY KEY,
    product_name TEXT,
    quantity INTEGER,
    price REAL 
);

-- check which tables exist in our database

SELECT name 
FROM sqlite_master
WHERE type = 'table';
