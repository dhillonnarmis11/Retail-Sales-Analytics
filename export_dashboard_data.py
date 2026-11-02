import sqlite3
import csv
from pathlib import Path


# find the project folder and database
project_folder = Path(__file__).resolve().parent
database_path = project_folder / "retail.db"

# create a folder for exported dashboard data
output_folder = project_folder / "data" / "processed"
output_folder.mkdir(parents=True, exist_ok=True)


# each entry contains a CSV filename and its SQL query
queries = {

    "monthly_sales.csv": """
        SELECT
            strftime('%Y-%m', o.order_purchase_timestamp) AS month,
            COUNT(DISTINCT o.order_id) AS orders,
            ROUND(SUM(oi.price), 2) AS revenue
        FROM orders AS o
        JOIN order_items AS oi ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY month
        ORDER BY month;
    """,

    "category_sales.csv": """
        SELECT
            COALESCE(t.product_category_name_english,
                     p.product_category_name,
                     'Unknown') AS category,
            COUNT(*) AS items_sold,
            ROUND(SUM(oi.price), 2) AS revenue
        FROM order_items AS oi
        JOIN orders AS o ON oi.order_id = o.order_id
        JOIN products AS p ON oi.product_id = p.product_id
        LEFT JOIN category_translation AS t
            ON p.product_category_name = t.product_category_name
        WHERE o.order_status = 'delivered'
        GROUP BY category
        ORDER BY revenue DESC;
    """,

    "state_sales.csv": """
        SELECT
            c.customer_state AS state,
            COUNT(DISTINCT o.order_id) AS orders,
            ROUND(SUM(oi.price), 2) AS revenue
        FROM orders AS o
        JOIN customers AS c ON o.customer_id = c.customer_id
        JOIN order_items AS oi ON o.order_id = oi.order_id
        WHERE o.order_status = 'delivered'
        GROUP BY c.customer_state
        ORDER BY revenue DESC;
    """,

    "delivery_reviews.csv": """
        WITH review_scores AS (
            SELECT
                order_id,
                AVG(review_score) AS review_score
            FROM order_reviews
            GROUP BY order_id
        )
        SELECT
            CASE
                WHEN DATE(o.order_delivered_customer_date)
                   > DATE(o.order_estimated_delivery_date)
                THEN 'Late'
                ELSE 'On time or early'
            END AS delivery_status,
            COUNT(*) AS reviewed_orders,
            ROUND(AVG(r.review_score), 2) AS average_review_score
        FROM orders AS o
        JOIN review_scores AS r ON o.order_id = r.order_id
        WHERE o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL
          AND o.order_estimated_delivery_date IS NOT NULL
        GROUP BY delivery_status;
    """
}


# connect to SQLite and run each query
with sqlite3.connect(database_path) as connection:

    for filename, query in queries.items():

        cursor = connection.execute(query)

        # read the column names from the query result
        column_names = [
            column[0] for column in cursor.description
        ]

        # save the results to a CSV file
        file_path = output_folder / filename

        with open(file_path, "w", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)

            writer.writerow(column_names)
            writer.writerows(cursor.fetchall())

        print(f"Created: {file_path.name}")


print("All dashboard data exports completed successfully!")