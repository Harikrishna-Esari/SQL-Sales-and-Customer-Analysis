# 📊 Sales & Customer Analytics using SQL

## 📌 Project Overview
This project focuses on analyzing sales data using SQL to derive meaningful business insights. The dataset consists of multiple schemas containing customer, product, sales, pricing, and cost-related information.

The objective of this project is to perform end-to-end data analysis, including data cleaning, transformation, KPI calculation, and advanced analytics to support business decision-making.

---

## 🗂️ Dataset Description

### Schema: gdb041
- **dim_customer** – Customer details (customer, market, platform, channel)
- **dim_product** – Product hierarchy (division, segment, category, product)
- **fact_sales_monthly** – Monthly sales transactions
- **fact_forecast_monthly** – Forecasted sales data

### Schema: gdb056
- **gross_price** – Product pricing by fiscal year
- **manufacturing_cost** – Cost of manufacturing per product
- **pre_invoice_deductions** – Pre-invoice discounts
- **post_invoice_deductions** – Post-invoice discounts
- **freight_cost** – Additional cost percentages

---

## 🎯 Objectives

- Perform data cleaning and validation
- Build relationships across multiple tables
- Calculate key business metrics (Revenue, Profit, Net Sales)
- Analyze customer and product performance
- Perform segmentation and ranking analysis
- Apply advanced SQL concepts for real-world scenarios

---

## 🧹 Data Cleaning

- Handled NULL values using `COALESCE`
- Identified and removed duplicate records
- Standardized data formats (date conversions)
- Validated relationships between tables

---

## 📊 Key Metrics Calculated

- **Revenue** = Sold Quantity × Gross Price  
- **Profit** = Revenue − Manufacturing Cost  
- **Net Sales** = Revenue after applying pre-invoice and post-invoice discounts  

---

## 🔍 Key Analysis Performed

### 1. Customer Analysis
- Top customers based on Net Sales
- Customer segmentation (High, Medium, Low performers)
- Average monthly sales per customer

### 2. Market Analysis
- Top customers per market
- Sales distribution across markets

### 3. Product Analysis
- Product demand segmentation based on total sales quantity

---

## ⚙️ SQL Concepts Used

- **Joins**: INNER JOIN, LEFT JOIN  
- **Aggregations**: SUM, AVG  
- **Filtering**: WHERE, HAVING  
- **Subqueries & CTEs**  
- **Window Functions**: RANK(), DENSE_RANK()  
- **CASE Statements**  
- **Date Functions**: YEAR(), MONTH()  

---
## 📂 SQL Analysis & Queries
### Q1. Check for NULL Values in customer table?
```sql
SELECT *
FROM dim_customer
WHERE customer_code IS NULL
   OR customer IS NULL;
```
### Q2. Remove null values if exsists ?
```sql
DELETE FROM dim_customer
WHERE customer_code IS NULL;
```
###  Q3. Find Duplicate Customers in customer table?
-- Approach 1:
```sql
SELECT customer_code, COUNT(*) as cnt
FROM dim_customer
GROUP BY customer_code
HAVING COUNT(*) > 1;
```
-- Approach 2:
```sql
select customer, market, platform, channel, customer_code , count(*)
from dim_customer
group by customer, market, platform,channel,customer_code
having count(*)>1;
```
 
### Q4. Identify duplicates with row_number() in customer table?
```sql
select *
from(
select *,
 row_number () over (partition by customer, market, platform, channel,customer_code) as rn
 from dim_customer) as t
 where rn>1;
```
### Q5. Delete duplicates  Customers if exists?
```sql
delete from dim_customer
 where customer_code in(
select customer_code
from(
select *,
 row_number () over (partition by customer, market, platform, channel,customer_code) as rn
 from dim_customer) as t
 where rn>1
 );
```
### Q6. Check  extra Spaces Issue for Customer?
```sql
select customer
   from dim_customer
   where customer != trim(customer);
```
### Q7. Remove Extra Spaces if exists for customers?
```sql
update dim_customer
    set customer= trim(customer);
```
### Q8. Total Quantity Sold?
```sql
select sum(sold_quantity) as total_quantity_sold
 from fact_sales_monthly;
```
### Q9.Sales by Market?
```sql
select market, sum(sold_quantity) as total_sales
  from fact_sales_monthly
  group by market;
```
### Q10.Sales by Product?
```Sql
select p.product, sum(sold_quantity) as total_sales
from fact_sales_monthly fsm
join dim_product p
on fsm.product_code = p.product_code 
group by p.product;
```
### Q11. Revenue Calculation (Cross-Schema JOIN)?
```sql
select round(sum(s.sold_quantity* gp.gross_price),2) as revenue
from gdb041.fact_sales_monthly as s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year;
```
### Q12.Calculate Revenue by Market?
```sql
select  market, round(sum(s.sold_quantity* gp.gross_price),2) revenue
from gdb041.fact_sales_monthly as s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year
group by s.market ;
```
### Q13.Profit Calculation?
```sql
select round( sum( (s.sold_quantity* gp.gross_price) - (s.sold_quantity* mc.manufacturing_cost)), 2) profit
from gdb041.fact_sales_monthly s
join gdb056.gross_price gp
on gp.product_code = s.product_code
and year(s.date) = gp.fiscal_year
join gdb056.manufacturing_cost mc
on mc.product_code = s.product_code
and mc.cost_year = year(s.date);
```
### Q14.Net sales after discounts in the year of 2021?
```sql
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
```
### Q15. Net sales by customer in 2021?
```sql
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
```
### Q16. Rank all customers based on Net Sales in 2020 ?
```sql
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
```
### Q17. Top 3 customers per market in 2021?
```sql
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
```
### Q18. Segment products into High, Medium, and Low demand categories based on total sold quantity?
```sql
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
```
### Q19. Segment customers into High, Medium, and Low performers based on their average monthly sales?
```sql
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
```
### Q20.calculate the average monthly sales for each customer and segment them into High, Medium, and Low performers. Then, identify the top 2 customers within each segment based on their average monthly sales?
```sql
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
```
---
## 🧠 Advanced Techniques

- Multi-level CTEs for complex transformations  
- Window functions for ranking and Top-N analysis  
- Partitioning for group-wise insights  
- Handling missing data in financial calculations  

---

## 📈 Sample Business Insights

- Identified top-performing customers contributing the highest revenue  
- Segmented customers to enable targeted business strategies  
- Analyzed market-wise performance for better regional decisions  
- Evaluated product demand patterns  

---

## 🚀 Tools Used

- MySQL  
- MySQL Workbench  

---

## 📌 Conclusion

This project demonstrates the use of SQL in solving real-world business problems by transforming raw data into actionable insights. It showcases strong skills in data analysis, query optimization, and business understanding.

---

## 👨‍💻 Author
**Harikrishna Esari**
