/*select top 1 * from Customer
select top 1 * from Transactions
select top 1 * from prod_cat_info

select count(*) as tot_reords from Customer
select count(*) as tot_reords from Transactions
select count(*) as tot_reords from prod_cat_info

select * from Customer
select * from Transactions
select * from prod_cat_info*/

-- prepration and understanding 
-- Q1
select * from (
select 'customer' as table_name, count(*) as total_No_rows from  Customer  union all
select 'transactions' as table_name, count(*) as total_No_rows from Transactions union all 
select 'product info' as table_name, count(*)  as total_No_rows  from prod_cat_info) as tbl

--Q2
select count(qty) as tot_tran_return from Transactions where qty<0
--  OR
select count(rate) as tot_tran_return from Transactions where rate<0

--Q3

select convert(date,tran_date,105) from Transactions

--Q4

select min(tran_date) as initial_record ,
max(tran_date) as final_tran ,
datediff (month,min(tran_date),max(tran_date)) as tot_month_tran,
datediff (year, min(tran_date),max(tran_date)) as tot_year_tran,
datediff (day,min(tran_date),max(tran_date)) as tot_day_tran
from Transactions

--Q5
select prod_cat,prod_subcat from prod_cat_info where prod_subcat='diy'

--data analysis
--Q1
select top 1 store_type as most_freq_channel,count(store_type) as tot_tran from Transactions group by Store_type order by count(store_type) desc
--Q2
select gender, count(gender) as no_male_female from Customer group by gender order by count(gender) desc
--Q3
select top 1 city_code as max_cust_city_code ,count(customer_id) as no_customer from Customer group by city_code order by count(customer_id) desc 
--Q4
select prod_cat,count(prod_subcat) as no_sub_cat from prod_cat_info where prod_cat='books' group by prod_cat
--Q5   
select top 1 prod_cat_code,count(qty) as max_qty_order from Transactions group by prod_cat_code order by count(qty) desc
--Q6
select sum(cast(total_amt as float)) as tot_revenue from Transactions where prod_cat_code in (
select distinct prod_cat_code from prod_cat_info where prod_cat in ('electronics','books'))
--Q7 
select count( *) as no_customers from (
select cust_id,count(transaction_id) as No_tran from Transactions where qty>0 group by cust_id having count(transaction_id)>10
) as tbl
--Q8
select sum(cast(total_amt as float)) as tot_revenue_2cat_1store from Transactions
 where prod_cat_code in (
select distinct prod_cat_code from prod_cat_info
 where prod_cat in ('electronics','clothing')) and Store_type='flagship store' 
--Q9
select prod_subcat,sum(cast(total_amt as float)) as tot_revenue from
(select concat(prod_cat_code,' ',prod_subcat_code) as cat_subcat,total_amt from Transactions as t
 inner join (select * from Customer where Gender='m') as c on t.cust_id=c.customer_Id ) as a
inner join (select concat(prod_cat_code,' ',prod_sub_cat_code) as cat_subcat,prod_subcat from
 prod_cat_info where prod_cat='electronics') as p on 
a.cat_subcat=p.cat_subcat  group by prod_subcat
--Q10
select top 5 prod_subcat,sum(a.tot_revenue) as total_revenue,
(sum(a.tot_revenue) / (select sum(cast(total_amt as float)) from transactions) * 100) as percentage_tot_revenue,
abs(sum(b.return_total) / (select sum(cast(total_amt as float)) from transactions) * 100) as percentage_return_tot
from(select p.cat_subcat,p.prod_subcat,t.tot_revenue from (
select concat(prod_cat_code, ' ', prod_sub_cat_code) as cat_subcat,prod_subcat  from prod_cat_info ) as p
inner join(select concat(prod_cat_code, ' ', prod_subcat_code) as cat_subcat,
sum(cast(total_amt as float)) as tot_revenue from transactions group by concat(prod_cat_code, ' ', prod_subcat_code))
 as t on p.cat_subcat = t.cat_subcat) as a
inner join (select concat(prod_cat_code,' ',prod_subcat_code) as cat_subcat,sum(cast(total_amt as float)) as return_total
 from transactions where cast(total_amt as float)<0 
 group by concat(prod_cat_code,' ',prod_subcat_code) ) as b on a.cat_subcat = b.cat_subcat
group by prod_subcat order by total_revenue desc;

--11
select a.customer_Id,sum(cast(b.total_amt as float)) as total_rev_last30days  from(
(select customer_Id,convert(date,dob,105) as birth_date,
datediff(year,convert(date,dob,105),getdate()) as age from Customer
where datediff(year,convert(date,dob,105),getdate()) between 25 and 35) as a
inner join 
(select
tran_date,total_amt,cust_id
from Transactions where tran_date between (select dateadd(day,-30,max(tran_date)) from Transactions)
and (select max(tran_date) from Transactions)) as b 
on a.customer_Id=b.cust_id
) group by a.customer_Id

--12
select top 1 a.prod_cat,sum(cast(b.total_amt as float)) as total_return from 
(
select concat(prod_cat_code, ' ', prod_sub_cat_code) as cat_subcat,prod_cat  from prod_cat_info 
) as a inner join 
(
select
tran_date,total_amt,concat(prod_cat_code,' ',prod_subcat_code) as cat_subcat 
from Transactions where tran_date between (select dateadd(month,-3,max(tran_date)) from Transactions)
and (select max(tran_date) from Transactions) and cast(total_amt as float)<0
) as b on a.cat_subcat=b.cat_subcat group by a.prod_cat order by total_return

--13
select top 1  store_type,sum(cast(total_amt as float)) as tot_revenue,sum(cast(qty as int)) as tot_qty
 from Transactions
 group by Store_type order by tot_revenue desc
 
 --14
 select distinct b.prod_cat,a.average_revenue from ((select prod_cat_code,avg(cast( total_amt as float)) as average_revenue
  from Transactions 
  group by prod_cat_code
  having avg(cast( total_amt as float))>(select avg(cast(total_amt as float)) from Transactions) ) as a
  inner join 
  prod_cat_info as b on a.prod_cat_code=b.prod_cat_code)

  --15
   select top 5 b.prod_cat,b.prod_subcat,
   a.tot_revenue,a.average_revenue,a.quantity_sold from (
   (select 
   prod_cat_code,concat(prod_cat_code,' ',prod_subcat_code) as cat_subcat,
   prod_subcat_code,
  sum(cast(total_amt as float)) as tot_revenue ,
  avg(cast(total_amt as float)) as average_revenue,
  sum(cast(qty as int)) as quantity_sold
  from 
  Transactions
  group by
  prod_cat_code,prod_subcat_code) as a inner join 
  ( select concat(prod_cat_code, ' ', prod_sub_cat_code) as cat_subcat,prod_cat,prod_subcat from prod_cat_info) as b on
  a.cat_subcat=b.cat_subcat ) order by a.quantity_sold desc


  ------------------------------------------------------------------------------------------------------------------------