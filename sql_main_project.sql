show databases;

use gdb041;
show tables;

describe dim_customer;
SELECT * FROM dim_customer LIMIT 10;
SELECT * FROM dim_product LIMIT 10;
SELECT * FROM dim_market LIMIT 10;
SELECT * FROM fact_sales_monthly LIMIT 10;
SELECT * FROM fact_forecast_monthly LIMIT 10;

USE gdb056;

SELECT * FROM gross_price LIMIT 10;
SELECT * FROM manufacturing_cost LIMIT 10;
SELECT * FROM freight_cost LIMIT 10;
SELECT * FROM pre_invoice_deductions LIMIT 10;
SELECT * FROM post_invoice_deductions LIMIT 10;

-- Task 1:
-- Check for NULL Values in customer table

SELECT 
COUNT(*) AS total_rows,COUNT(customer_code),COUNT(customer),COUNT(market),COUNT(platform),COUNT(channel)
FROM dim_customer;

SELECT *
FROM dim_customer
WHERE customer_code IS NULL
   OR customer IS NULL;

-- remove null values if exsists 

DELETE FROM dim_customer
WHERE customer_code IS NULL;

-- Task 2:
-- Find Duplicate Customers in customer table?

SELECT customer_code, COUNT(*) as cnt
FROM dim_customer
GROUP BY customer_code
HAVING COUNT(*) > 1;

select customer, market, platform, channel, customer_code , count(*)
from dim_customer
group by customer, market, platform,channel,customer_code
having count(*)>1;

-- identify duplicates with now number() in customer table?

select *
from(
select *,
 row_number () over (partition by customer, market, platform, channel,customer_code) as rn
 from dim_customer) as t
 where rn>1;
 
 -- delete duplicates if exists
 
 delete from dim_customer
 where customer_code in(
select customer_code
from(
select *,
 row_number () over (partition by customer, market, platform, channel,customer_code) as rn
 from dim_customer) as t
 where rn>1
 );

-- Task 3:
-- Check Inconsistent Values

SELECT DISTINCT market FROM dim_customer;

 -- Fix Inconsistent Text
 update dim_customer
 set market= lower(trim(market));
 
 -- Task 4: 
 -- check  extra Spaces Issue
   select customer
   from dim_customer
   where customer != trim(customer);
   
   -- Remove Extra Spaces if exists 
    update dim_customer
    set customer= trim(customer);
    
-- do same thing for  market and product tables and fact table also 

-- -------------------------------------------      BUSINESS ANALYSIS      ---------------------------------------------------------
-- Q1. Total Quantity Sold?
 select sum(sold_quantity) as total_quantity_sold
 from fact_sales_monthly;

-- Q2. Sales by Market?
 select market, sum(sold_quantity) as total_sales
  from fact_sales_monthly
  group by market;

-- Q3. Sales by Product
select p.product, sum(sold_quantity) as total_sales
from fact_sales_monthly fsm
join dim_product p
on fsm.product_code = p.product_code 
group by p.product;

-- Q4. Revenue Calculation (Cross-Schema JOIN) ****
select round(sum(s.sold_quantity* gp.gross_price),2) as revenue
from gdb041.fact_sales_monthly as s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year;

-- Q5. Calculate Revenue by Market?
select  market, round(sum(s.sold_quantity* gp.gross_price),2) revenue
from gdb041.fact_sales_monthly as s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year
group by s.market ;

-- Q6. Profit Calculation
select round( sum( (s.sold_quantity* gp.gross_price) - (s.sold_quantity* mc.manufacturing_cost)), 2) profit
from gdb041.fact_sales_monthly s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year
join gdb056.manufacturing_cost mc
on mc.product_code = s.product_code
and mc.cost_year = year(s.date);

-- Q7. Net sales after discounts in the year of 2021
SELECT 
    ROUND(SUM((s.sold_quantity * gp.gross_price) 
    * (1 - COALESCE(pre_d.pre_invoice_discount_pct, 0)) 
    * (1 - (COALESCE(post_d.discounts_pct,0) + coalesce (post_d.other_deductions_pct,0)
                    ))),
            2) AS net_sales
FROM
    gdb041.fact_sales_monthly s
        JOIN
    gdb056.gross_price gp ON gp.product_code = s.product_code
        AND YEAR(s.date) = gp.fiscal_year
        LEFT JOIN
    gdb056.pre_invoice_deductions AS pre_d ON pre_d.customer_code = s.customer_code
        AND YEAR(s.date) = pre_d.fiscal_year
        LEFT JOIN
    gdb056.post_invoice_deductions AS post_d ON post_d.customer_code = s.customer_code
        AND post_d.product_code = s.product_code
        AND s.date = post_d.date
        WHERE YEAR(s.date) = 2021;


  -- Q8. Net sales by customer in 2021
  SELECT  dm.customer,
    ROUND(SUM((s.sold_quantity * gp.gross_price) 
    * (1 - COALESCE(pre_d.pre_invoice_discount_pct, 0)) 
    * (1 - (COALESCE(post_d.discounts_pct,0) + coalesce (post_d.other_deductions_pct,0)
                    ))),
            2) AS net_sales
FROM
    gdb041.fact_sales_monthly s
        JOIN
    gdb056.gross_price gp ON gp.product_code = s.product_code
        AND YEAR(s.date) = gp.fiscal_year
        LEFT JOIN
    gdb056.pre_invoice_deductions AS pre_d ON pre_d.customer_code = s.customer_code
        AND YEAR(s.date) = pre_d.fiscal_year
        LEFT JOIN
    gdb056.post_invoice_deductions AS post_d ON post_d.customer_code = s.customer_code
        AND post_d.product_code = s.product_code
        AND s.date = post_d.date
        join dim_customer dm
        on dm.customer_code= s.customer_code
          WHERE YEAR(s.date) = 2021
	   group by dm.customer_code, dm.customer
       order by net_sales desc 
       limit 10;
        
  -- Q9. Rank all customers based on Net Sales in 2020  
  
with sales as (
SELECT  dm.customer,
    ROUND(SUM((s.sold_quantity * gp.gross_price) 
    * (1 - COALESCE(pre_d.pre_invoice_discount_pct, 0)) 
    * (1 - (COALESCE(post_d.discounts_pct,0) + coalesce (post_d.other_deductions_pct,0)
                    ))),
            2) AS net_sales
FROM
    gdb041.fact_sales_monthly s
        JOIN
    gdb056.gross_price gp ON gp.product_code = s.product_code
        AND YEAR(s.date) = gp.fiscal_year
        LEFT JOIN
    gdb056.pre_invoice_deductions AS pre_d ON pre_d.customer_code = s.customer_code
        AND YEAR(s.date) = pre_d.fiscal_year
        LEFT JOIN
    gdb056.post_invoice_deductions AS post_d ON post_d.customer_code = s.customer_code
        AND post_d.product_code = s.product_code
        AND s.date = post_d.date
        join dim_customer dm
        on dm.customer_code= s.customer_code
        WHERE YEAR(s.date) = 2020
	   group by dm.customer_code, dm.customer
)    
select customer, net_Sales, drnk
from(
select *,
dense_rank () over (order by net_sales ) as  drnk
from sales) t
where drnk <= 5;

-- Q10. Top 3 customers per market in 2021

with sales as (
SELECT  dm.customer, s.market,
    ROUND(SUM((s.sold_quantity * gp.gross_price) 
    * (1 - COALESCE(pre_d.pre_invoice_discount_pct, 0)) 
    * (1 - (COALESCE(post_d.discounts_pct,0) + coalesce (post_d.other_deductions_pct,0)
                    ))),
            2) AS net_sales
FROM
    gdb041.fact_sales_monthly s
        JOIN
    gdb056.gross_price gp ON gp.product_code = s.product_code
        AND YEAR(s.date) = gp.fiscal_year
        LEFT JOIN
    gdb056.pre_invoice_deductions AS pre_d ON pre_d.customer_code = s.customer_code
        AND YEAR(s.date) = pre_d.fiscal_year
        LEFT JOIN
    gdb056.post_invoice_deductions AS post_d ON post_d.customer_code = s.customer_code
        AND post_d.product_code = s.product_code
        AND s.date = post_d.date
        join dim_customer dm
        on dm.customer_code= s.customer_code
        WHERE YEAR(s.date) = 2021
        group by dm.customer_code, dm.customer,s.market
)    
select customer,net_Sales, market , drnk
from(
select *,
dense_rank () over ( partition by market order by net_sales desc ) as  drnk
from sales) t
where drnk <= 3;

-- Q11. Segment products into High, Medium, and Low demand categories 
--      based on total sold quantity

 select dp.product, sum( sold_quantity) total_quantity, 
 case when sum( sold_quantity) > 1000000  then 'high'
   when sum( sold_quantity) between 500000 and 1000000 then 'medium'
   when sum( sold_quantity) < 500000 then 'low'
   else 0
   end as demand
 from fact_sales_monthly s 
 join dim_product dp
 on dp.product_code = s.product_code
 group by dp.product;
 
 -- Q12. Segment customers into High, Medium, and Low performers 
 --      based on their average monthly sales.
 
 with month_Sales as (
 select customer_code, year(date) yr, month(date) mo, sum(sold_quantity) as monthly_qnty
 from fact_sales_monthly 
 group by customer_code,yr,mo),
  avg_sales as (
  select customer_code, avg(monthly_qnty) as avg_monthly_sales
  from month_sales
  group by customer_code)
  select 
   dm.customer, round(avs.avg_monthly_sales,0) avg_monthlysales,
   case when avg_monthly_sales> 30000 then 'high performer'
    when avg_monthly_sales between 10000 and 30000 then 'medium performer'
   else 'low performer'
   end as performance
   from avg_sales avs
   join dim_customer dm
   on 
   dm.customer_code = avs.customer_code;

-- Q13. calculate the average monthly sales for each customer and segment them into High,
--  Medium, and Low performers. Then, identify the top 2 customers within each segment 
--  based on their average monthly sales       

with monthly_sales as (
 select customer_code, year(date) yr, month(date) mo, sum(sold_quantity) as monthly_qnty
 from fact_sales_monthly s
 group by customer_code, yr, mo
),
avg_sales as (
select customer_code, avg(monthly_qnty) as avg_monthly_sales
from monthly_sales
group by customer_code
)
select *
from(
select customer, avg_monthlysales,performance,
dense_rank() over (partition by performance order by avg_monthlysales desc) as drnk
from(
select dm.customer, round(avs.avg_monthly_sales,0) avg_monthlysales,
case when avs.avg_monthly_sales > 20000 then 'high performer'
      when avs.avg_monthly_sales between 8000 and 20000 then 'medium performer'
       else 'low performer'
       end as performance
 from avg_sales avs
 join dim_customer dm
 on dm.customer_code= avs.customer_code) as t) t2
where  drnk <= 2
 

 
  
 
	
       
       
       
     
  






