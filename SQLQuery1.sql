--Total Sales Amount
SELECT SUM(total_price) AS total_sales_amount
FROM fact_sales;

--Total Number of Orders
SELECT COUNT(*) AS total_orders
FROM dim_orders;

--Number of Distinct Customers
SELECT COUNT(DISTINCT customer_id) AS distinct_customers
FROM dim_customers;

--Average Order Value
SELECT AVG(total_price) AS average_order_value
FROM fact_sales;

--Total Sales Amount by Product Category
SELECT p.product_type, SUM(s.total_price) AS total_sales_amount
FROM fact_sales s
JOIN dim_products p ON s.product_id = p.product_id
GROUP BY p.product_type
order by total_sales_amount desc ;

--Top 10 Customers by Total Sales Amount
SELECT top(10)  c.customer_name, SUM(s.total_price) AS total_sales_amount
FROM fact_sales s
JOIN dim_customers c ON s.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_sales_amount DESC
-- Sales  by Product name

SELECT p.product_name,SUM(s.total_price) AS total_sales_amount
FROM
    fact_sales s
JOIN
    dim_products p ON s.product_id = p.product_id
GROUP BY
    p.product_name
ORDER BY
    total_sales_amount DESC;

--Sales Trend Over Time (Monthly)
SELECT  d.month,
SUM(s.total_price) AS total_sales_amount
FROM fact_sales s
JOIN dim_date d ON s.order_date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

--Average Order Processing Time

SELECT
    AVG(DATEDIFF(day, d1.date, d2.date)) AS average_order_processing_time_days
FROM
    fact_sales s
JOIN
    dim_date d1 ON s.order_date_key = d1.date_key
JOIN
    dim_date d2 ON s.delivery_date_key = d2.date_key;

--Sales Rank by Customer

WITH CustomerSalesRank AS (
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(s.total_price) AS total_sales_amount,
        RANK() OVER (ORDER BY SUM(s.total_price) DESC) AS sales_rank
    FROM
        fact_sales s
    JOIN
        dim_customers c ON s.customer_id = c.customer_id
    GROUP BY
        c.customer_id, c.customer_name
)
SELECT
    customer_name,
    total_sales_amount,
    sales_rank
FROM
    CustomerSalesRank
ORDER BY
    sales_rank;
-- Create Stored Procedure to Calculate Total Sales Amount for a Given Month
CREATE PROCEDURE CalculateTotalSalesByMonth
    @month_param INT
AS
BEGIN
    SELECT SUM(s.total_price) AS total_sales_amount
    FROM fact_sales s
    JOIN dim_date d ON s.order_date_key = d.date_key
    WHERE MONTH(d.date) = @month_param;
END;

EXEC CalculateTotalSalesByMonth @month_param = 5;

--Stored Procedure for Calculating Sales Report
CREATE PROCEDURE CalculateSalesReport
    @start_date DATE,
    @end_date DATE
AS
BEGIN
    SELECT
        SUM(s.total_price) AS total_sales_amount,
        COUNT(*) AS total_orders
    FROM
        fact_sales s
    JOIN
        dim_date d ON s.order_date_key = d.date_key
    WHERE
        d.date BETWEEN @start_date AND @end_date;
END;
GO

EXEC CalculateSalesReport
    @start_date = '2021-01-01',
    @end_date = '2021-01-31';

	-- View to Calculate Average Sales Amount by Month:
	CREATE VIEW vw_average_sales_by_month AS
    SELECT
        MONTH(d.date) AS month,
        AVG(s.total_price) AS average_sales_amount
    FROM
        fact_sales s
    JOIN
        dim_date d ON s.order_date_key = d.date_key
    GROUP BY
        YEAR(d.date), MONTH(d.date);
		
--categorize products based on their prices.
CREATE VIEW vwProductCategories
AS
    SELECT
         product_name,
        price,
        CASE
            WHEN price < 50 THEN 'Low Price'
            WHEN price BETWEEN 50 AND 100 THEN 'Medium Price'
            ELSE 'High Price'
        END AS price_category
    FROM
        Dim_Products;
GO
 select * from vwProductCategories

 --Orders with Highest Sales Amount

 create view OrderswithHighestSaleAmount
 as
 SELECT top(10)
    o.order_id,
    d.date AS order_date,
    c.customer_name,
    p.product_name,
    s.total_price
FROM
    fact_sales s
JOIN
    dim_orders o ON s.order_id = o.order_id
JOIN
    dim_date d ON s.order_date_key = d.date_key
JOIN
    dim_customers c ON o.customer_id = c.customer_id
JOIN
    dim_products p ON s.product_id = p.product_id
ORDER BY
    s.total_price DESC

