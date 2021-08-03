SELECT * FROM sales.customers limit 5; -- cust-code, cust_name, cust_type

SELECT distinct(customer_type) FROM sales.customers; -- 2 types of customers

Select count(distinct(customer_code)) from sales.customers;

Select * from sales.markets; -- market_code, markets_name we even have New york and Paris, zone

Select count(distinct(product_code)), count(distinct(product_type)) from sales.products;

select product_type, count(distinct(product_code)) from sales.products group by product_type;

select * from sales.transactions;

select distinct(currency) from sales.transactions; -- duplicate currencies for inr and usd, covert duplicates to actual ones, also convet dollars to inr

select count(*) from sales.transactions where (sales_amount<1);-- 1611 rows remove these 

select count(*) from sales.transactions where (sales_qty<1);  -- 0

select * from sales.date; -- contains different formats of date

-- find out transactions in year 2020

select year(order_date), count(*) from sales.transactions group by year(order_date); -- # of sales started declining after 2018

select year(order_date), sum(sales_amount) from sales.transactions group by year(order_date); -- sales_amt went down too

-- Show transactions in 2020
select date.* , transactions.* from sales.date inner join sales.transactions on sales.date.date = sales.transactions.order_date where year(sales.transactions.order_date)=2020;

-- Total revenue in year 2020
Select sum(transactions.sales_amount) 
from sales.transactions
where year(transactions.order_date)=2020;

SELECT SUM(transactions.sales_amount) 
FROM sales.transactions INNER JOIN sales.date ON transactions.order_date=date.date;
-- where date.year=2020 and transactions.currency="INR\r" or transactions.currency="USD\r";

-- total revenue in January,2020
SELECT SUM(transactions.sales_amount) 
FROM sales.transactions INNER JOIN sales.date ON transactions.order_date=date.date
where date.year=2020 and date.month_name="January" ;

-- revenue in chennai
SELECT SUM(transactions.sales_amount) 
FROM sales.transactions INNER JOIN sales.date ON transactions.order_date=date.date 
where date.year=2020 and transactions.market_code="Mark001";







