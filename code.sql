--1. What columns does the table have?
--SELECT all columns from the first 10 rows.
SELECT *
FROM survey
LIMIT 5;

--2. What is the number of responses for each question?
SELECT question,
    COUNT(DISTINCT user_id) AS num_response
FROM survey
GROUP BY question;

-- 4. Examine the first five rows of each table. What are the column names?

SELECT *
FROM quiz
LIMIT 5;

SELECT *
FROM home_try_on
LIMIT 5;

SELECT *
FROM purchase
LIMIT 5;

--5. Use a LEFT JOIN to combine the three tables, starting with the top of the funnel (browse) and ending with the bottom of the funnel (purchase).
--Select only the first 10 rows from this table.

SELECT DISTINCT q.user_id,
    h.user_id IS NOT NULL AS 'is_home_try_on',
    h.number_of_pairs,
    p.user_id IS NOT NULL AS 'is_purchase'
FROM quiz AS 'q'
LEFT JOIN home_try_on AS 'h'
    ON h.user_id = q.user_id
LEFT JOIN purchase AS 'p'
    ON p.user_id = q.user_id
LIMIT 10;

--6 Data Analysis
--6.1 Calculate overall conversion rates
-- 1.Create temporay table to store funnel information by user_id
WITH funnels AS (
    SELECT DISTINCT q.user_id,
	h.user_id IS NOT NULL AS 'is_home_try_on',
        h.number_of_pairs,
     	p.user_id IS NOT NULL AS 'is_purchase'
    FROM quiz AS 'q'
    LEFT JOIN home_try_on AS 'h'
	   ON h.user_id = q.user_id
    LEFT JOIN purchase AS 'p'
	   ON p.user_id = q.user_id)
-- 2.Create table with overall conversion numbers from funnels
SELECT COUNT(user_id) AS 'num_user_id',
    SUM(is_home_try_on) AS 'num_home_try_on',
    SUM(is_purchase) AS 'num_purchase',
-- 3.Calculate overall conversion rates
    1.0 * SUM(is_purchase) / COUNT(user_id) AS '%_overall_conversion'
FROM funnels;

--6.2 Calculate conversion rate quiz->home_try_on and home_try_on->purchase.
--Repeat two first steps of exercise 6.1
-- 1.Create temporay table to store funnel information by user_id
WITH funnels AS (
    SELECT DISTINCT q.user_id,
	h.user_id IS NOT NULL AS 'is_home_try_on',
        h.number_of_pairs,
     	p.user_id IS NOT NULL AS 'is_purchase'
    FROM quiz AS 'q'
    LEFT JOIN home_try_on AS 'h'
	   ON h.user_id = q.user_id
    LEFT JOIN purchase AS 'p'
	   ON p.user_id = q.user_id)
-- 2.Create table with overall conversion numbers from funnels
SELECT COUNT(user_id) AS 'num_user_id',
    SUM(is_home_try_on) AS 'num_home_try_on',
    SUM(is_purchase) AS 'num_purchase',
--3.Calculate conversion rate quiz->home_try_on and home_try_on->purchase.
    1.0 * SUM(is_home_try_on) / COUNT(user_id) AS '%_home_try_on',
    1.0 * SUM(is_purchase) / SUM(is_home_try_on) as '%_purchase'
FROM funnels;

--6.3 Calculate the difference in purchase rates between customers who had 3 number_of_pairs with ones who had 5.
--1.Create temporay table to store funnel information by user_id
WITH funnels AS (
    SELECT DISTINCT q.user_id,
	h.user_id IS NOT NULL AS 'is_home_try_on',
        h.number_of_pairs,
     	p.user_id IS NOT NULL AS 'is_purchase'
    FROM quiz AS 'q'
    LEFT JOIN home_try_on AS 'h'
	   ON h.user_id = q.user_id
    LEFT JOIN purchase AS 'p'
	   ON p.user_id = q.user_id)
--2.Create table for 3 pairs conversion numbers from funnels
SELECT COUNT(user_id) AS 'num_user_id_3',
    SUM(is_home_try_on) AS 'num_home_try_on_3',
    SUM(is_purchase) AS 'num_purchase_3',
--3.Calculate conversion rate 3 pairs-> purchase, and ROUND to 2 decimals
    ROUND((1.0 * SUM(is_purchase) / SUM(is_home_try_on)), 2) AS '%_purchase_3'
FROM funnels
WHERE number_of_pairs = '3 pairs';

--4.Repeat the process to create table for 5 pairs conversion number
 WITH funnels AS (
    SELECT DISTINCT q.user_id,
	h.user_id IS NOT NULL AS 'is_home_try_on',
        h.number_of_pairs,
     	p.user_id IS NOT NULL AS 'is_purchase'
    FROM quiz AS 'q'
    LEFT JOIN home_try_on AS 'h'
	   ON h.user_id = q.user_id
    LEFT JOIN purchase AS 'p'
	   ON p.user_id = q.user_id)
--5.Create table for 5 pairs conversion numbers from funnels
SELECT COUNT(user_id) AS 'num_user_id_5',
    SUM(is_home_try_on) AS 'num_home_try_on_5',
    SUM(is_purchase) AS 'num_purchase_5',
--6.Calculate conversion rate 5 pairs-> purchase, and ROUND to 2 decimals
    ROUND((1.0 * SUM(is_purchase) / SUM(is_home_try_on)), 2) AS '%_purchase_5'
FROM funnels
WHERE number_of_pairs = '5 pairs';


--6 Data Analysis - Extra
--6.4 The most common results of the style quiz.
--1 Most chose style
SELECT DISTINCT style AS 'style', 
    COUNT(style) AS 'num_user_style'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;
--2 Most chose fit
SELECT DISTINCT fit AS 'fit',
    COUNT(fit) AS 'num_user_fit'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;
--3 Most chose shape
SELECT DISTINCT shape AS 'shape',
    COUNT(shape) AS 'num_user_shape'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;
--4 Most chose color
SELECT DISTINCT color AS 'color',
    COUNT(color) AS 'num_user_color'
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

--6 Data Analysis - Extra
--6.5 The most common types of purchase made.
--Each combination of style, model_name and color a unique product_id. Find DISTINCT product_id
SELECT DISTINCT product_id
FROM purchase
ORDER BY product_id ASC;

--6 Data Analysis - Extra
--6.5 The most common types of purchase made.
--1 COUNT number of purchase per product_id, then GROUP by product_id, and ORDER from the most bought to the least
SELECT DISTINCT product_id,
    COUNT(product_id) AS 'num_purchase'
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;
--2 Find witch style, model_name and color are related to each product_id
SELECT DISTINCT product_id,
    COUNT(product_id) AS 'num_purchase',
    style,
    model_name,
    color
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;

--6.6 Price - Extra
--1. What are the DISTINC prices?
SELECT DISTINCT price
FROM purchase;
--2. What is Warby Parker price average? ROUND to 2 decimals.
SELECT ROUND(AVG(price),2)  AS 'price_avg'
FROM purchase;
--3. Price of the top 5 selling glasses
SELECT DISTINCT product_id,
    COUNT (product_id) AS 'num_purchase',
    price
FROM purchase
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
--4. Number of purchases per product_id
SELECT DISTINCT product_id,
    COUNT (product_id) AS 'num_purchase'
FROM purchase
GROUP BY 1
ORDER BY 2 DESC;