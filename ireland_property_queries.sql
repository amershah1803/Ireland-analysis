-- select *
-- from property_sales_staging
-- limit 10 offset 5;

-- select Price , round (sum(Price),2) as Total_Sales
-- from property_sales_staging
-- group by Price;

-- select sale_date,address,price
-- from property_sales_staging
-- limit 10;

-- SELECT
--     sale_date,
--     TO_DATE(sale_date, 'DD/MM/YYYY') AS cleaned_sale_date
-- FROM property_sales_staging
-- LIMIT 10

-- UPDATE property_sales_staging
-- SET address = INITCAP(TRIM(address))
-- WHERE address IS NOT NULL;

-- select *
-- from property_sales_staging
-- order by sale_date
-- limit 30

-- SELECT
--     price,
--     REPLACE(REPLACE(price, '€', ''), ',', '') AS cleaned_price
-- FROM property_sales_staging
-- LIMIT 10;

-- SELECT
--     TO_DATE(sale_date, 'DD/MM/YYYY') AS sale_date,
--     initcap(Trim(ADDRESS)) as cleaned_address,
--     county,
--     eircode,
--     REPLACE(REPLACE(price, '€', ''), ',', '')::NUMERIC(12,2) AS price,
--     not_full_market_price,
--     vat_exclusive,
--     property_description,
--     property_size_description
-- property_sales_staging
-- order by sale_date
-- LIMIT 30;

-- update property_sales_staging
-- set price =  REPLACE(REPLACE(price, '€', ''), ',', '')::NUMERIC(12,2) 

-- TILL HERE CLEANED FOR A PREVIEW NOT ACTUALLY CLEANED


-- select *
-- from property_sales_staging
-- order by sale_date
-- limit 30
---------------------------------------------------------------------
-- CLEANING STARTS HERE BY INSERTING IT INTO NEW TABLE


-- CREATE TABLE property_sales_cleaned (
--     sale_date DATE,
--     address TEXT,
--     county TEXT,
--     eircode TEXT,
--     price NUMERIC(12,2),
--     not_full_market_price TEXT,
--     vat_exclusive TEXT,
--     property_description TEXT,
--     property_size_description TEXT
-- );

-- INSERT INTO property_sales_cleaned (
--     sale_date,
--     address,
--     county,
--     eircode,
--     price,
--     not_full_market_price,
--     vat_exclusive,
--     property_description,
--     property_size_description
-- )
-- SELECT
--     TO_DATE(sale_date, 'DD/MM/YYYY'), 
--     INITCAP(TRIM(address)),           
--     county,
--     eircode,
--     REPLACE(REPLACE(price, '€', ''), ',', '')::NUMERIC(12,2), 
--     not_full_market_price,
--     vat_exclusive,
--     property_description,
--     property_size_description
-- FROM property_sales_staging;

-- select * 
-- from property_sales_cleaned
-- limit 10

-- SELECT
--     COUNT(*) AS total_properties,
--     MIN(sale_date) AS earliest_sale,
--     MAX(sale_date) AS latest_sale,
--     MIN(price) AS minimum_price,
--     MAX(price) AS maximum_price,
-- 	SUM(price) as Total_price,
--     ROUND(AVG(price), 2) AS average_price
-- FROM property_sales_cleaned;


-- SELECT
--     sale_date,
--     address,
--     county,
--     price,
--     property_description
-- FROM property_sales_cleaned
-- ORDER BY price DESC
-- where price 
-- LIMIT 50;

-- SELECT
--     MIN(price) AS min_price,
--     PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) AS p25,
--     PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY price) AS median_price,
--     PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) AS p75,
--     PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY price) AS p90,
--     PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY price) AS p95,
--     PERCENTILE_CONT(0.99) WITHIN GROUP (ORDER BY price) AS p99,
--     MAX(price) AS max_price
-- FROM property_sales_cleaned;

-- select county, count(*) as total_sales
-- from property_sales_cleaned
-- group by county
-- order by total_sales desc;


-- #1 THIS SHOWS THAT EVRY COUNTY HAS OUTLIERS LIKE AVG PRICE AND MEDIAN PRRICE HAS DIFF SO BECUZ OF OUTLIERS THERES A DIFF 

-- select county, count(*) as total_sales,
-- round (avg(price),2) as average_price,
-- round(
-- 	percentile_cont(0.50)
-- 	within group (order by price)::Numeric,2
-- ) as median_price
-- from property_sales_cleaned
-- group by county
-- order by median_price desc;

-- select county, count(*) as

-- WITH county_stats as (
-- select county, count(*) as total_sales,
-- round (avg(price),2) as average_price,
-- round(
-- 	percentile_cont(0.50)
-- 	within group (order by price)::Numeric,2
-- ) as median_price
-- from property_sales_cleaned
-- group by county
-- )

-- 	select county,
-- 	total_sales,
-- 	average_price,
-- 	median_price,
-- 	round(abs(average_price - median_price)/median_price* 100,2) as percentage_diff
-- 	from county_stats
-- 	order by percentage_diff desc;

-- with county_stats as(
-- 	select county,
-- 	count(*) as total_sales,
-- 	round(avg(price),2) as average_price,
-- 	round(percentile_cont(0.50) within group (order by price)::Numeric,2) as median_price
-- 	from property_sales_cleaned
-- 	group by county
-- )

-- select county,
-- 	total_sales,
-- 	average_price,
-- 	median_price,
-- 	round(abs(average_price-median_price)/median_price*100,2) as percentage_diff
-- 	from county_stats
-- 	order by percentage_diff desc;

-- #2 DUBLIN HAS THE MOST SKEWED DATE BECUZ OF HIGH PERCENTAGE DIFF BETWEEN AVG PRICE NAD MEDIAN PRICE
------------------------------------------------------------------------------------------------------------

--------------------------TOUGH QUERIES HERE--------------------------------------------------


-- SELECT
--     EXTRACT(YEAR FROM sale_date)::INT AS sale_year,
--     COUNT(*) AS total_sales,
--     ROUND(SUM(price), 2) AS total_sales_value,
--     ROUND(AVG(price), 2) AS average_price,
--     ROUND(
--         PERCENTILE_CONT(0.50)
--         WITHIN GROUP (ORDER BY price)::NUMERIC,
--         2
--     ) AS median_price,
	
-- 	ROUND(
--      (ABS(AVG(price) - PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price))
--     / NULLIF(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 0) * 100)::numeric,
--     2) AS percentage_diff
	
-- FROM property_sales_cleaned
-- GROUP BY sale_year
-- ORDER BY sale_year;

--2011 and 2020 experienced low number of transactions

--2012 saw a drop in average price
--2013 and 2014 43-49 percentage diff in avg price and median price
---------------------------------------------------------------------------------

-- SELECT
--     DATE_TRUNC('month', sale_date)::DATE AS sale_month,
--     COUNT(*) AS no_of_transactions,
--     ROUND(SUM(price), 2) AS total_sales_value,
--     ROUND(AVG(price), 2) AS average_price,
--     ROUND(
--         PERCENTILE_CONT(0.50)
--         WITHIN GROUP (ORDER BY price)::NUMERIC,
--         2
--     ) AS median_price,

-- 	ROUND(
--      (ABS(AVG(price) - PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price))
--     / NULLIF(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 0) * 100)::numeric,
--     2) AS percentage_diff
-- FROM property_sales_cleaned
-- GROUP BY sale_month
-- ORDER BY sale_month;
------------------------------------------------------------------------------
-- SELECT
--     EXTRACT(MONTH FROM sale_date)::int AS month_number,
--     TO_CHAR(sale_date, 'Month') AS month_name,
--     COUNT(*) AS no_of_transactions,
--     ROUND(AVG(price), 2) AS average_price,
--     ROUND(
--         PERCENTILE_CONT(0.50)
--         WITHIN GROUP (ORDER BY price)::NUMERIC,
--         2
--     ) AS median_price
-- FROM property_sales_cleaned
-- GROUP BY
--     month_number,
--     month_name
-- ORDER BY month_number;
---------------------------------------------------------------------------

-- SELECT
--     property_description,
--     COUNT(*) AS no_of_transactions,
--     ROUND(AVG(price), 2) AS average_price,
--     ROUND(
--         PERCENTILE_CONT(0.50)
--         WITHIN GROUP (ORDER BY price)::NUMERIC,
--         2
--     ) AS median_price,

--     COUNT(*) FILTER (
--         WHERE vat_exclusive = 'Yes'
--     ) AS vat_exclusive_sales,

--     ROUND(
--         100.0 * COUNT(*) FILTER (WHERE vat_exclusive = 'Yes')
--         / COUNT(*),
--         2
--     ) AS vat_exclusive_percentage

-- FROM property_sales_cleaned
-- GROUP BY property_description
-- ORDER BY no_of_transactions DESC;
-------------------------------------------------------------------------

-- SELECT
--     county,
--     COUNT(*) AS total_sales,

--     COUNT(*) FILTER (
--         WHERE vat_exclusive = 'Yes'
--     ) AS vat_exclusive_sales,

--     COUNT(*) FILTER (
--         WHERE vat_exclusive = 'No'
--     ) AS non_vat_exclusive_sales,

--     ROUND(
--         100.0 * COUNT(*) FILTER (WHERE vat_exclusive = 'Yes')
--         / COUNT(*),
--         2
--     ) AS vat_exclusive_percentage

-- FROM property_sales_cleaned

-- GROUP BY county

-- ORDER BY vat_exclusive_percentage DESC;


--kildare, Meath, wicklow, louth,laois,Cork,Dudlin these states have highest growing VAT exclusive percenatge
--Tiperia, Mayo, Longford, kerry, Rosco, has lowest VAT exclusive percentage.
------------------------------------------------------------------------------------------
-- SELECT
--     not_full_market_price,
--     COUNT(*) AS no_of_transactions,

--     ROUND(
--         100.0 * COUNT(*) / SUM(COUNT(*)) OVER (),
--         2
--     ) AS percentage_of_sales,

--     ROUND(AVG(price), 2) AS average_price,

--     ROUND(
--         PERCENTILE_CONT(0.50)
--         WITHIN GROUP (ORDER BY price)::NUMERIC,
--         2
--     ) AS median_price

-- FROM property_sales_cleaned

-- GROUP BY not_full_market_price

-- ORDER BY no_of_transactions DESC;

--only 5 % of the properties had discount
------------------------------------------------------------

-- SELECT
--     county,
--     COUNT(*) AS total_sales,

--     COUNT(*) FILTER (
--         WHERE property_description = 'New Dwelling house /Apartment'
--     ) AS new_sales,

--     ROUND(
--         100.0 * COUNT(*) FILTER (
--             WHERE property_description = 'New Dwelling house /Apartment'
--         ) / COUNT(*),
--         2
--     ) AS new_build_percentage,

--     ROUND(
--         100.0 * COUNT(*) FILTER (
--             WHERE vat_exclusive = 'Yes'
--         ) / COUNT(*),
--         2
--     ) AS vat_exclusive_percentage

	
-- FROM property_sales_cleaned

-- GROUP BY county
-- ORDER BY new_build_percentage DESC;

-----------------------------------------------------------------
-- SELECT
--     EXTRACT(YEAR FROM sale_date)::INT AS sale_year,

--     COUNT(*) AS total_sales,

--     COUNT(*) FILTER (
--         WHERE vat_exclusive = 'Yes'
--     ) AS vat_exclusive_sales,

--     ROUND(
--         100.0 * COUNT(*) FILTER (
--             WHERE vat_exclusive = 'Yes'
--         ) / COUNT(*),
--         2
--     ) AS vat_exclusive_percentage

-- FROM property_sales_cleaned

-- GROUP BY sale_year
-- ORDER BY sale_year;

--2012 and 2021 has low "VAT exclusive percentage" compare to other years
------------------------------------------------------------

-- SELECT
--     EXTRACT(YEAR FROM sale_date)::INT AS sale_year,
--     county,

--     COUNT(*) AS total_sales,

--     ROUND(
--         100.0 * COUNT(*) FILTER (
--             WHERE vat_exclusive = 'Yes'
--         ) / COUNT(*),
--         2
--     ) AS vat_exclusive_percentage

-- FROM property_sales_cleaned

-- WHERE county IN (
--     'Kildare',
--     'Meath',
--     'Wicklow',
--     'Louth',
--     'Laois',
--     'Cork',
--     'Dublin'
-- )

-- GROUP BY sale_year, county
-- ORDER BY sale_year, county;

-- 'Kildare' --2011 and 2012 low but 2020 & 2021 high
   -- 'Meath' -- 14 &15 low and 19 was the highest
     -- 'Wicklow' -- 11 & 12 were low
    -- 'Louth' --11, 12 & 13 were low
    -- 'Laois' -- over all low except for the last years 3 years
    -- 'Cork' -- 12, 13 & 14 were low
    --'Dublin' -- 11, 12 were low but 21, 22 were high

---------------------------------------------------------------

-- WITH monthly_sales AS (
--     SELECT
--         EXTRACT(YEAR FROM sale_date)::INT AS sale_year,
--         EXTRACT(MONTH FROM sale_date)::INT AS sale_month,
-- 		TO_CHAR(sale_date, 'Month') AS month_name,
--         COUNT(*) AS transactions
--     FROM property_sales_cleaned
--     GROUP BY sale_year, sale_month,month_name
-- ),

-- ranked AS (
--     SELECT *,
--         RANK() OVER (
--             PARTITION BY sale_year
--             ORDER BY transactions asc) AS month_rank
--     FROM monthly_sales
-- )

-- SELECT
--     sale_year,
--     sale_month,
-- 	month_name,
--     transactions
	
-- FROM ranked
-- WHERE month_rank = 1
-- ORDER BY sale_year;

-- January is the lowest  and DEC gives the highes no. of transactions
------------------------------------------------------------------------
-- WITH monthly AS (
--     SELECT
--         DATE_TRUNC('month', sale_date)::DATE AS sale_month,
--         COUNT(*) AS transactions
--     FROM property_sales_cleaned
--     GROUP BY sale_month
-- ),

-- comparison AS (
--     SELECT
--         sale_month,
--         transactions,
--         LAG(transactions) OVER (
--             ORDER BY sale_month
--         ) AS previous_month
--     FROM monthly
-- )

-- SELECT
--     sale_month,
--     transactions,
--     previous_month,

--     ROUND(
--         100.0 * (transactions - previous_month)
--         / NULLIF(previous_month, 0),
--         2
--     ) AS monthly_change_pct

-- FROM comparison
-- ORDER BY sale_month;
-----------------------------------------------------------------

-- with yearly as(
-- 	select
-- 		extract(year from sale_date) as years,
-- 		county,
-- 		round(avg(price),2) as avg_price
-- 		from property_sales_cleaned
-- 		group by county,years
-- 		order by years asc
-- ),
-- ranked as (
-- 	select years,
-- 	county,
-- 	avg_price,
-- 	Rank() over (
-- 	partition by years
-- 	order by avg_price desc) as rnk 
-- 	from yearly
-- )

-- select years,
-- 	county,
-- 	avg_price,
-- 	rnk
-- from ranked
-- where rnk<=3
-- order by years,rnk;
--exactly 3 counties per year, use

--------------------------------------------

-- with sales as(
-- 	select
-- 	extract ( year from sale_date) as yearly_sales,
-- 	county,
-- 	count(*) as total_sales
-- 	from property_sales_cleaned
-- 	group by yearly_sales
-- ),

-- ranked as (
-- 	select yearly_sales,
-- 	county,
-- 	total_sales,
-- 	rank() (
-- 		over partition by yearly_sales ORDER by total_sales desc
-- 	) as rnk
-- 	from sales)

-- select yearly_sales,
-- 	county,
-- 	total_sales,
-- 	rnk 
-- 	from ranked
-- 	where rnk<=3
-- 	group by yearly_sales
	

-- ----------------------------------------------

-- select extract (year from sale_date)::int as sale_year,
-- round(avg(price),2) as avg_price,
-- round(percentile_cont(0.50) within group ( order by price):: numeric , 2) as median_price
-- from property_sales_cleaned                                                                                                                                                                                                                         
-- group by sale_year
-- order by sale_year;
-- --------------------------------------------------------------
-- with ms as(
-- 	select 
-- 	date_trunc('month',sale_date)::date as monthly,
-- 	count(*) as monthly_sales
-- 	from property_sales_cleaned
-- 	group by monthly
-- 	order by monthly asc
-- )

-- select monthly,
-- 	monthly_sales,
-- 	round(avg(monthly_sales) over (order by monthly rows between 2 preceding and current row),2) as total_sales
-- 	from ms

----------------------------------------------------------------
-- with states as  (
-- 	select county,
-- 	count(*) as total_sales
-- from property_sales_cleaned
-- group by county
-- ),

--  tsales as(
-- 	select county,
-- 	total_sales,
-- 	sum(total_sales) over() as all_sales
-- 	from states
	
-- )
-- select county,
-- 	total_sales,
-- 	round(100.0*(total_sales/all_sales),2) as percentage_of_total
-- 	from tsales
-- 	order by percentage_of_total desc;
---------------------------------------------------------------
-- with cap as(
-- 	select county,
-- 	extract(year from sale_date) as yearly,
-- 	round(avg(price),2) as current_avg_price
-- 	from property_sales_cleaned
-- 	group by yearly,county
-- 	),
	
-- comparison as (
-- 	select county,
-- 	yearly,
-- 	current_avg_price,
-- 	lag(current_avg_price) over (partition by county order by yearly ) as previous_avg_price
-- 	from cap
-- )

-- select county,
-- 	yearly,
-- 	current_avg_price,
-- 	previous_avg_price,
-- 	round(100.0* (current_avg_price - previous_avg_price)/ nullif(previous_avg_price,0),2) as percentage
-- 	from comparison
-- 	order by yearly asc
-- 	limit 1

------------------------------------------------

-- with cat as( 
-- 	select 
-- 		extract(year from sale_date) as years,
-- 		count(*) as total_sales,
-- 		count(*) filter (where not_full_market_price = 'No' ) as full_market_sales,
-- 		count(*) filter (where not_full_market_price = 'Yes' ) as not_full_market_sales
-- 		from property_sales_cleaned
-- 		group by years
-- 		order by years asc
-- 	)
-- select
-- 	years,
-- 	total_sales,
-- 	full_market_sales,
-- 	not_full_market_sales,
-- 	round(100.0*not_full_market_sales/nullif(total_sales,0),2) as percentage
-- 	from cat
-- ------------------------------------------------------
	-- select county,
	-- price,
	-- ROW_NUMBER() OVER (
 --    PARTITION BY county
 --    ORDER BY price DESC )
	-- from property_sales_cleaned
	-- limit 5
-----------------------------------------------	
-- 	WITH ranked AS (
--     SELECT
--         county,
--         price,
--         RANK() OVER (
--             PARTITION BY county
--             ORDER BY price DESC
--         ) AS rnk
--     FROM property_sales_cleaned
-- )

-- SELECT
--     county,
--     price,
--     rnk
-- FROM ranked
-- WHERE rnk = 3;
--------------------------------------------------

-- select
-- county,
-- count(*) as no_of_transactions,
-- round(avg(price),2) as avg_price,
-- round(percentile_cont(0.50) within group ( order by price):: numeric , 2) as median_price
-- from property_sales_cleaned                                                                                                                                                                                                                         
-- group by county
-- order by median_price desc;
-- this proves that the seven highest vat percentage counties even has highest price theresfore theres a correlation between vat and price

-----------------------------------------------------------------------

-- select 
-- property_description,
-- count(*) as no_of_transactions,
-- round(avg(price),2) as avg_price,
-- round(percentile_cont(0.50) within group ( order by price):: numeric , 2) as median_price
-- from property_sales_cleaned  
-- group by property_description;

-----------------------------------------------------------------

-- select 
-- case
-- when price < 100000
-- then '<100k'
-- when price between 100000 and 200000 
-- then '100k-200k'
-- when price between 200000 and 300000 
-- then '200k-300k'
-- when price between 300000 and 500000 
-- then '300k-500k'
-- else '500k+' 
-- end as price_range,

-- count(*) as no_of_transaction
-- from property_sales_cleaned
-- group by price_range
-- order by no_of_transaction desc;

----------------------------------------------------------------------

-- select *
-- from property_sales_cleaned
-- where nullif(TRIM(property_size_description) ,'' )is not null;
--------------------------------------------------------------------

-- SELECT
--     property_size_description,
--     COUNT(*) AS transactions,
--     ROUND(
--         100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
--         2
--     ) AS percentage_of_market,
-- 	round(avg(price),2) as avg_price,
-- 	percentile_cont(0.50) within group (order by price) as median_price,
-- 	 	ROUND(
--      (ABS(AVG(price) - PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price))
--      / NULLIF(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 0) * 100)::numeric,
--      2) AS percentage_diff
-- FROM property_sales_cleaned
-- where nullif(TRIM(property_size_description),'') is not null
-- GROUP BY property_size_description
-- ORDER BY transactions DESC;
-- -------------------------------------------------------------

-- SELECT

-- property_size_description,

-- property_description,

-- COUNT(*) AS transactions,

-- ROUND(
-- 100.0 * COUNT(*) /
-- SUM(COUNT(*)) OVER(PARTITION BY property_size_description),
-- 2
-- ) AS percentage

-- FROM property_sales_cleaned

-- where nullif(TRIM(property_size_description),'') is not null


-- GROUP BY
-- property_size_description,
-- property_description

-- ORDER BY property_size_description;
-------------------------------------------------------------------

SELECT

county,

property_size_description,

COUNT(*) AS transactions,
	round(avg(price),2) as avg_price,
	percentile_cont(0.50) within group (order by price) as median_price,
	 	ROUND(
     (ABS(AVG(price) - PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price))
     / NULLIF(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price), 0) * 100)::numeric,
     2) AS percentage_diff
FROM property_sales_cleaned

WHERE property_size_description IN (
    'greater than 125 sq metres',
    'greater than or equal to 125 sq metres'
)


GROUP BY
county,
property_size_description

ORDER BY county, transactions DESC;

-- expensive counties are seen here but not much details are there so we stop here for property size desc
----------------------------------------------------

-- with tops as 
-- (select county,
-- 		price,
-- 		rank() over (partition by county order by price desc) as rnk,
-- 		row_number() over ( partition by county order by price desc) as rn
-- 		from property_sales_cleaned
-- )

-- select county,
-- 	price,
-- 	rnk,
-- 	rn
-- 	from tops
-- 	where rnk <=3 and rn <=3
-- 	order by county

------------------------------------------

-- with comp as (select county,
-- 	price,
-- 	first_VALUE(price) OVER (
--     PARTITION BY county
--     ORDER BY price desc 
-- ) as max_price
-- 	from property_sales_cleaned
-- 	order by county desc
-- )

-- select county,
-- 	price,
-- 	max_price,
-- 	round((max_price - price),2) as diff
-- 	from comp
-- 	limit 10
	
--------------------------------------

-- with comp as (
-- 	select county,
-- 	sale_date,
-- 	first_value(sale_date) over ( partition by county order by sale_date asc ) as first_sale_date,
-- 	last_value(sale_date) over ( partition by county order by sale_date asc rows  between UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_sale_date
-- 	from property_sales_cleaned
-- )
-- select county,
-- 	sale_date,
-- 	first_sale_date,
-- 	last_sale_date,
-- 	last_sale_date - first_sale_date as days_between
-- 	from comp
-- 	order by sale_date desc
-- 	limit 10
--------------------------------------------------

-- select county,
-- 	price,
-- 	dense_rank() over ( partition by county order by price desc) as densed_rank
-- 	from property_sales_cleaned
-- 	group by county, price
-- 	limit 3

----------------------------------------------------


	