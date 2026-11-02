-- customers and orders tables were created earlier
-- now create remaining 7 tables from Olist dataset


-- 1. ORDER ITEMS
-- table stores the individual products included in orders
-- one order can contain multiple items
-- price represents the item selling price, not the order total

CREATE TABLE IF NOT EXISTS order_items (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TEXT,
    price REAL,
    freight_value REAL,
    PRIMARY KEY (order_id, order_item_id)
);



-- 2. ORDER PAYMENTS
-- table stores payment information for each order
-- one order can have multiple payment records
-- use it to analyze payment methods and payment values

CREATE TABLE IF NOT EXISTS order_payments (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value REAL
);



-- 3. PRODUCTS
-- table contains information about products
-- each product_id identifies one product
-- can use it to analyze product categories and dimensions

CREATE TABLE IF NOT EXISTS products (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);



-- 4. SELLERS
-- table contains information about sellers
-- each seller_id identifies one seller
-- can use it to compare seller activity by location

CREATE TABLE IF NOT EXISTS sellers (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);



-- 5. CATEGORY TRANSLATION
-- product categories in original dataset are in Portuguese
-- this table translates category names into English

CREATE TABLE IF NOT EXISTS category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);



-- 6. ORDER REVIEWS
-- table stores customer ratings and review information
-- one order may have more than one review record
-- we will use it to analyze customer satisfaction

CREATE TABLE IF NOT EXISTS order_reviews (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TEXT,
    review_answer_timestamp TEXT
);



-- 7. GEOLOCATION
-- table stores geographic information for Brazilian ZIPs
-- a ZIP code can appear multiple times in this dataset
-- must account for duplicates before joining it to orders

CREATE TABLE IF NOT EXISTS geolocation (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat REAL,
    geolocation_lng REAL,
    geolocation_city TEXT,
    geolocation_state TEXT
);
