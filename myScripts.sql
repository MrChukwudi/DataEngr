-- Selcting All records from categories table:
SELECT * FROM categories

-- Getting the count/number of items ofr a table:
SELECT COUNT(*) FROM categories




SELECT count(* ) FROM orders;



SELECT count(* ) FROM order_items;



SELECT * FROM order_items as oi
LEFT OUTER JOIN orders as o
ON oi.order_item_order_id = o.order_id

SELECT * FROM orders as o
FULL OUTER JOIN order_items as oi
ON oi.order_item_order_id = o.order_id


SELECT COUNT(*) 
FROM orders 
	WHERE order_status = 'CLOSED' 
	OR 
	order_status = 'COMPLETE'



SELECT DISTINCT order_status
FROM orders;



SELECT DISTINCT order_status
FROM orders
ORDER BY 1;



SELECT o.order_id, o.order_date, o.order_status, oi.order_item_subtotal
FROM orders AS o
JOIN order_items AS oi
ON oi.order_item_order_id = o.order_id
	WHERE o.order_status IN ('CLOSED', 'COMPLETE')




SELECT o.order_date::Date, o.order_status, ROUND(SUM(oi.order_item_subtotal)::numeric, 2) AS total_subtotal_for_closed_complete_orders
FROM orders AS o
JOIN order_items AS oi
  ON oi.order_item_order_id = o.order_id
WHERE o.order_status IN ('CLOSED', 'COMPLETE')
GROUP BY o.order_date,
		o.order_status;



SELECT
    o.order_id,
    o.order_date,
    o.order_status,
    SUM(oi.order_item_subtotal) AS order_total_subtotal
FROM orders AS o
JOIN order_items AS oi
  ON oi.order_item_order_id = o.order_id
WHERE o.order_status IN ('CLOSED', 'COMPLETE')
GROUP BY
    o.order_id,
    o.order_date,
    o.order_status
ORDER BY
    o.order_id; -- Optional: order your results;



SELECT
    o.order_date::date AS order_day, -- Cast to date to remove time component for daily grouping
    ROUND(SUM(oi.order_item_subtotal)::NUMERIC, 2) AS daily_total_subtotal
FROM orders AS o
JOIN order_items AS oi
  ON oi.order_item_order_id = o.order_id
WHERE o.order_status IN ('CLOSED', 'COMPLETE')
GROUP BY
    o.order_date::date -- Group by the date part only
ORDER BY
    o.order_date::date; -- Optional: order your results chronologically


SELECT order_date::Date, COUNT(*) AS order_count
FROM orders
WHERE order_status IN ('COMPLETE', 'CLOSED')
GROUP BY 1
ORDER BY 2 DESC;


 SELECT order_item_order_id, round(sum(order_item_subtotal)::numeric, 2)
 FROM order_items
 GROUP BY 1
 	HAVING round(sum(order_item_subtotal)::numeric, 2) >= 2000
 ORDER BY 1 DESC;


--
--			VIEWS 
--			AND
--			CTEs
--

-- Creating a view:
 CREATE VIEW daily_rev_view
 AS
 SELECT o.order_date::Date, o.order_status, SUM(oi.order_item_subtotal) AS total_subtotal_for_closed_complete_orders
FROM orders AS o
JOIN order_items AS oi
  ON oi.order_item_order_id = o.order_id
WHERE o.order_status IN ('CLOSED', 'COMPLETE')
GROUP BY o.order_date,
		o.order_status;


-- Querrying my View:
SELECT min(total_subtotal_for_closed_complete_orders)
FROM daily_rev_view;


-- qUERYING OUR vIEW:
select * 
from daily_rev_view
WHERE round(total_subtotal_for_closed_complete_orders::numeric,2) < 40000;


-- Creating a CTE:
WITH daily_revs_cte
AS
(SELECT o.*,
		oi.order_item_product_id,
		oi.order_item_subtotal,
		oi.order_item_id		
FROM orders AS o
		JOIN order_items as oi
		ON o.order_id = oi.order_item_order_id)
-- Calling your CTE: mUST BE DONE TOGETHER AS ONE QUERRY 
SELECT * FROM daily_revs_cte;





-- His View: ODV
CREATE OR REPLACE VIEW order_details_v
AS
SELECT o.*,
		oi.order_item_product_id,
		oi.order_item_subtotal,
		oi.order_item_id
FROM orders AS o
	JOIN order_items AS oi
		ON oi.order_item_order_id = o.order_id


-- Accessing the View:
SELECT * FROM order_details_v
ORDER BY order_date ASC

-- qUERY the Products table:
SELECT * FROM products;



-- NOW, WE want to Querry the View above with a Join on the Products table:
SELECT *
FROM products AS p
	LEFT OUTER JOIN order_details_v AS odv
		ON p.product_id = odv.order_item_product_id
WHERE odv.order_item_product_id IS NULL


-- To get All the Product Sold in January, 2014:
SELECT p.*, to_char(odv.order_date::timestamp, 'yyyy-MM')
FROM products AS p
	LEFT OUTER JOIN order_details_v as odv
	ON odv.order_item_product_id = p.product_id
WHERE to_char(odv.order_date::timestamp, 'yyyy-MM') = '2014-01'


-- To Get Products Not sold in January 2014
SELECT * FROM products AS p
WHERE NOT EXISTS( -- Our View as a Sub-Query
	SELECT 1 FROM order_details_v AS odv
	WHERE p.product_id = odv.order_item_product_id
		AND TO_CHAR(odv.order_date::TIMESTAMP, 'yyyy-mm') = '2014-01'
)

-- Alternative: To Getting All products that were not sold in 2014-01
SELECT * 
FROM products AS p
	LEFT OUTER JOIN order_details_v AS odv
		ON p.product_id = odv.order_item_product_id
		AND 	to_char(odv.order_date::timestamp, 'yyyy-mm') = '2014-01'
		WHERE odv.order_id IS NULL;



--
-- 					CTAS: Create Table As Select
--					CUMMULATIVE AGGREGATIONS
--					adn
--					RANKS
--


-- Grouping By Order Date
SELECT o.order_date, round(sum(oi.order_item_subtotal)::NUMERIC, 2) AS order_revenue
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
	WHERE o.order_status IN ('COMPLETE', 'CLOSE')
	GROUP BY 1
	ORDER BY 1;



-- Grouping By Order Item Product ID and by Order Date
SELECT o.order_date, oi.order_item_product_id, round(sum(oi.order_item_subtotal)::NUMERIC, 2) AS order_revenue
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
	WHERE o.order_status IN ('COMPLETE', 'CLOSE')
	GROUP BY 1,
			2
	ORDER BY 1;



-- CREATING TABLE AS SELECT STATEMENT: COPYING ALL Data OVER:
CREATE TABLE order_count_by_stat
AS
SELECT order_status, count(*) AS order_count
FROM orderS
GROUP BY 1
ORDER BY 1;


-- CREATING TABLE AS SELECT STATEMENT: WITHOUT COPYING ALL Data OVER:
CREATE TABLE order_count_stg
AS
SELECT *
FROM orders where false; -- You can also use WHERE 1 = 2 OR ANY OTHER FALSEY EXPRESSION;

SELECT * FROM order_count_by_stat


SELECT * FROM order_count_stg


--CREATING a CTAS table from our Select Statement below ==> Daily Revenue:
CREATE TABLE daily_revenue
AS
-- Grouping By Order Item Product ID and by Order Date
SELECT o.order_date, round(sum(oi.order_item_subtotal)::NUMERIC, 2) AS order_revenue
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
	WHERE o.order_status IN ('COMPLETE', 'CLOSE')
	GROUP BY 1;



--CREATING a CTAS table from our Select Statement below ==> Daily Product Revenue:
CREATE TABLE daily_product_revenue
AS
-- Grouping By Order Item Product ID and by Order Date
SELECT o.order_date, oi.order_item_product_id, round(sum(oi.order_item_subtotal)::NUMERIC, 2) AS order_revenue
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
	WHERE o.order_status IN ('COMPLETE', 'CLOSE')
	GROUP BY 1, 2;

SELECT * FROM daily_product_revenue
ORDER BY 1, 3 DESC;



SELECT * FROM daily_revenue


-- Here, we are able to Sum all the Monthly order_revenue and group them by Month:
SELECT to_char(dr.order_date::timestamp, 'yyyy-MM') AS order_month, 
	   sum(dr.order_revenue) AS month_order_rev
FROM daily_revenue AS dr
GROUP BY 1
ORDER BY 1;


-- If We want to have the Monthly Oder rev information and still retain the table structur: We will remove GROUP BY
SELECT to_char(dr.order_date::timestamp, 'yyyy-MM') AS order_month,
		dr.order_date,
		dr.order_revenue,
	   sum(dr.order_revenue) OVER (PARTITION BY to_char(dr.order_date::timestamp, 'yyyy-MM') )AS month_order_rev
FROM daily_revenue AS dr
ORDER BY 1;


-- Partitioning with Aggregate Functions while Retaining the Raw Data table structure:
SELECT dr.*, 
		sum(dr.order_revenue) OVER (PARTITION BY 1) AS monthly_order_revIE
FROM daily_revenue AS dr
ORDER BY 1;



-- Ranking:
SELECT * FROM daily_product_revenue

SELECT * FROM daily_product_revenue
ORDER BY 1, 3 DESC;



-- First Ranked Table: rank() and dense_rank() ==> Global Ranking without Using [WHERE] filter
SELECT order_date, 
	   order_item_product_id, 
	   order_Revenue,
	   rank() OVER (ORDER BY order_revenue DESC) AS ranked_rev,
	   dense_rank() OVER(ORDER BY order_revenue DESC) AS dense_rank_rev
FROM daily_product_revenue
ORDER BY order_revenue DESC;


-- Second Ranked Table: rank() and dense_rank() ==> Localized Ranking Using [WHERE] filter
SELECT order_date, 
	   order_item_product_id, 
	   order_Revenue,
	   rank() OVER (ORDER BY order_revenue DESC) AS ranked_rev,
	   dense_rank() OVER(ORDER BY order_revenue DESC) AS dense_rank_rev
FROM daily_product_revenue
WHERE order_date = '2014-01-01 00:00:00'
ORDER BY order_revenue DESC;

SELECT * FROM daily_product_revenue;

-- Let's Compute Daily Rank for Orders in January 2014: Partion is how you partition, order is how you rank:
SELECT dr.*,
		RANK() OVER(PARTITION BY order_date ORDER BY order_revenue DESC) AS rnk,
		DENSE_RANK() OVER (PARTITION BY order_date ORDER BY order_revenue DESC) AS d_rank
FROM daily_product_revenue AS dr
WHERE to_char(order_date::date, 'yyyy-mm') = '2014-01'
ORDER BY order_date, order_revenue DESC;



-- Limitation with Rank() functio is the order of execution:
	-- FROM
	-- WHERE
	-- SELECT 
	-- ORDER BY (THIS IS WHERE RANKING HAPPENS)
-- So, if you try to filter the returned result based on the rankings, you'll get an error:

-- The way around this limitation is
	--1 -- Using Nested Queries: Nest your ranking query inside the query that needs to filter on the ranked Result:
SELECT *
FROM (
		SELECT dr.*,
		RANK() OVER(PARTITION BY order_date ORDER BY order_revenue DESC) AS rnk,
		DENSE_RANK() OVER (PARTITION BY order_date ORDER BY order_revenue DESC) AS d_rank
	FROM daily_product_revenue AS dr
	WHERE to_char(order_date::date, 'yyyy-mm') = '2014-01'
	ORDER BY order_date, order_revenue DESC
) AS q
WHERE d_rank <= 3;


	--2 -- Store your ranking query as a CTE, then Query the CTE:
WITH daily_prod_rev_rank
AS (
	SELECT dr.*,
			RANK() OVER(PARTITION BY order_date ORDER BY order_revenue DESC) AS rnk,
			DENSE_RANK() OVER (PARTITION BY order_date ORDER BY order_revenue DESC) AS d_rank
	FROM daily_product_revenue AS dr
	WHERE to_char(order_date::date, 'yyyy-mm') = '2014-01'
	ORDER BY order_date, order_revenue DESC
	)
SELECT * FROM daily_prod_rev_rank
		 WHERE d_rank <= 2;



-- Creating a Student Table to Practice Ranking:
CREATE TABLE student_scores (
			 student_id INT PRIMARY KEY,
			 student_score INT 
)

-- Inserting Data into the table:

INSERT INTO student_scores (student_id, student_score)
SELECT
    -- Generate student_id from 1 to 1000
    generate_series(1, 1000) AS student_id,
    -- Generate a random score between 50 and 100 (inclusive)
    FLOOR(RANDOM() * (100 - 50 + 1) + 50)::INT AS student_score;


select * from student_scores
ORDER BY student_score DESC;



SELECT student_id, student_score,
RANK() OVER(ORDER BY student_score DESC) AS rank,
DENSE_RANK() OVER(ORDER BY student_score DESC) AS d_rank
FROM student_scores; 





-- Check out all available tables in my Server:
SELECT * 
FROM information_schema.tables
WHERE table_name like '%ord%' AND table_type = 'BASE TABLE';



-- Generating and Interpreting Explain Plans for Query Performance Optimization:
-- Method 1: UsingThe Explain Keyword:
EXPLAIN 
SELECT * FROM orders;

-- Method 2: Using the Explain Button without the Explain Key Word:
SELECT o.*,
		round(sum(oi.order_item_subtotal)::numeric, 2) AS revenue
FROM orders AS o
	JOIN order_items AS oi
	ON o.order_id = oi.order_item_order_id
WHERE o.order_id IN (2, 3, 4, 5, 6)
GROUP BY o.order_id,
		 o.order_Date,
		 o.order_customer_id,
		 o.order_status;



-- Dropping an Index:

DROP INDEX [index_name];


-- Adding a Foreign Key to a Table After the Table had already been created:
ALTER TABLE order_items
ADD 
FOREIGN KEY (order_item_order_id) --Which column to make the foreign key
REFERENCES orders (order_id); -- Which table are we refering to (which column in the reference table);

COMMIT;


SELECT COUNT(*) 
FROM orders AS o
	JOIN order_items AS oi
		ON o.order_id = oi.order_item_order_id
WHERE o.order_customer_id IN (5, 7, 3);



-- Altering orders Table to add a Foreign Key on order_customer_id to reference customers table:
ALTER TABLE orders
	ADD FOREIGN KEY (order_customer_id)
	REFERENCES customers (customer_id);
COMMIT;

-- Adding Indexes to our orders Tables:
CREATE INDEX order_order_cust_id_indx
ON orders (order_customer_id);

-- Adding Indexes to our order_items Tables:
CREATE INDEX order_items_ord_id.indx
ON order_items (order_item_order_id)