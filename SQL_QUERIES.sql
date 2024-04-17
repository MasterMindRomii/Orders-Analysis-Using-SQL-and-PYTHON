
--find top 10 highest reveue generating products 
SELECT top 10 product_id,SUM(sale_price) AS 'Revenue' FROM df_orders
GROUP BY product_id
ORDER BY Revenue DESC

--find top 5 highest selling products in each region
WITH CTE AS (SELECT product_id,region,sale_price,
RANK() OVER(PARTITION BY region ORDER BY sale_price DESC) AS 'Ranking'
FROM df_orders)

SELECT product_id,region,sale_price FROM CTE
WHERE Ranking <=5

--find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
WITH CTE AS (
    SELECT YEAR(order_date) AS Order_Year, 
           MONTH(order_date) AS Order_Month,
           SUM(sale_price) AS Sales 
    FROM df_orders 
    GROUP BY YEAR(order_date), MONTH(order_date) 
)

SELECT Order_Month,
       SUM(CASE WHEN Order_Year=2022 THEN Sales ELSE 0 END) AS Month_2022,
       SUM(CASE WHEN Order_Year=2023 THEN Sales ELSE 0 END) AS Month_2023
FROM CTE 
GROUP BY Order_Month 
ORDER BY Order_Month;


--for each category which month had highest sales
WITH CTE AS (
SELECT category,
FORMAT(order_date, 'yyyyMM') AS order_year_month,
SUM(sale_price) AS sales 
FROM df_orders
GROUP BY category,FORMAT(order_date, 'yyyyMM'))
SELECT * FROM (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
FROM CTE) b
WHERE rn = 1;

--which sub category had highest growth by profit in 2023 compare to 2022.
WITH cte AS (
SELECT sub_category,
YEAR(order_date) AS order_year,
SUM(sale_price) AS sales FROM df_orders
GROUP BY sub_category,YEAR(order_date))
,cte2 AS (
SELECT sub_category,
SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte 
GROUP BY sub_category)
SELECT TOP 1 *,
(sales_2023 - sales_2022) AS sales_difference
FROM cte2
ORDER BY (sales_2023 - sales_2022) DESC;
