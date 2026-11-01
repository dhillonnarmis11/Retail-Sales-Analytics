import sqlite3

# connect to a database called retail.db
# if the database does not exist, SQLite creates it
connection = sqlite3.connect("retail.db")

# print a message when the connection is successful
print("Database created successfully!")

# close the database connection
connection.close()