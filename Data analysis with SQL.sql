select * from df_orders;

-- find top 10 highest revenue generationg products.
select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc;

-- find top 5 to 10 highest revenue generationg products.
select product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
offset 5 rows
fetch next 5 rows only;


-- find top 5 highest selling products in each region
with cte as(
select region, product_id, sum(sale_price) as sales
from df_orders
group by region, product_id
)
,cte2 as(
select *,
rank() over(partition by region order by sales desc) as rnk
from cte
)
select * 
from cte2
where rnk<=5;

--find month over month growth comparison for 2022 and 2023.
with cte as(
select month(order_date) as month_, year(order_date) as year_, sum(sale_price) as 'Sales'
from df_orders
group by year(order_date), month(order_date)
)
select month_
, sum(case when year_ = 2022 then sales else 0 end) as sales_2022
, sum(case when year_ = 2023 then sales else 0 end) as sales_2023
from cte
group by month_
order by month_;


-- for each category which month had highest sales
with cte as(
select category, format(order_date, 'yyyyMM') as month_, sum(sale_price) as sales
from df_orders
group by category, format(order_date, 'yyyyMM')
)
, cte1 as(
select *
,rank() over (partition by category order by sales desc) as rnk
from cte
)
select category, month_, sales
from cte1
where rnk=1;

-- which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category, year(order_date) as year_, sum(profit) as profit
from df_orders
group by sub_category, year(order_date)
)
, cte1 as(
select sub_category
,sum(case when year_=2022 then profit else 0 end) as p_22
,sum(case when year_=2023 then profit else 0 end) as p_23
from cte
group by sub_category
)
select top 1 *
, (p_22-p_23)*100/p_22 as growth
from cte1
order by (p_22-p_23)*100/p_22 desc;