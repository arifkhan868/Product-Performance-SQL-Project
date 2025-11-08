


/*
=====================================================================================
Product Report
=====================================================================================
Purpose:
        -This report consolidates key product metrics and behaviors.
        
Highlights:
		1. Gathers essential fields such as product name, category, subcategory, and cost.
		2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
        3. Aggregates product-level metrics:
            --total orders
			--total sales
			--total quantity sold
			--total customers (unique)
			--lifespan (in months)
        4. Calculates valuable KPIs:
            --recency (months since last sale)
			--average order revenue (AOR)
			--average monthly revenue

====================================================================================
*/

/*----------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products
------------------------------------------------------------------------*/
with
  Base_Query as (
    select
      p.product_key,
      p.category,
      p.subcategory,
      p.product_name,
      p."cost",
      s.order_number,
      s.sales_amount,
      s.quantity,
      s.customer_key,
      s.order_date
    from
      gold.sales s
      left join gold.products p on s.product_key = p.product_key
  ),
  product_agreegation as (
    select
      product_key,
      category,
      subcategory,
      product_name,
      avg("cost") as avg_cost,
      count(distinct order_number) as total_order,
      sum(sales_amount) as total_revenue,
      sum(quantity) as total_qty_sold,
      count(distinct customer_key) as total_customer,
      max(order_date) as last_order_date,
      (
        extract(
          year
          from
            age (max(order_date), min(order_date))
        ) * 12 + extract(
          month
          from
            age (max(order_date), min(order_date))
        )
      ) as lifespan
    from
      Base_Query
    group by
      1,
      2,
      3,
      4
  )
select
  product_key,
  category,
  subcategory,
  product_name,
  case
    when total_revenue < 50000 then 'Low-Performers'
    when total_revenue BETWEEN 50000 and 100000  then 'Mid-Range'
    else 'High-Performers'
  end as product_segment,
  (
    date_part('year', age (current_date, last_order_date)) * 12 + date_part('month', age (current_date, last_order_date))
  ) as Recency,
  case
    when total_order = 0 then 0
    else total_revenue / total_order
  end as avg_order_revenue,
  case
    when lifespan = 0 then total_revenue
    else total_revenue / lifespan
  end as avg_monthly_spend,
  total_cost,
  total_order,
  total_revenue,
  total_qty_sold,
  total_customer,
  last_order_date,
  lifespan
from
  product_agreegation;



CREATE OR REPLACE VIEW gold.product_report AS
WITH Base_Query AS 
(
    SELECT 
        p.product_key,
        p.category,
        p.subcategory,
        p.product_name,
        p."cost",
        s.order_number,
        s.sales_amount,
        s.quantity,
        s.customer_key,
        s.order_date
    FROM gold.sales s 
    LEFT JOIN gold.products p 
    ON s.product_key = p.product_key
),
product_aggregation AS 
(
    SELECT 
        product_key,
        category,
        subcategory,
        product_name,
        avg("cost") AS avg_cost,
        COUNT(DISTINCT order_number) AS total_order,
        SUM(sales_amount) AS total_revenue,
        SUM(quantity) AS total_qty_sold,
        COUNT(DISTINCT customer_key) AS total_customer,
        MAX(order_date) AS last_order_date,
        (EXTRACT(YEAR FROM age(MAX(order_date), MIN(order_date))) * 12
        + EXTRACT(MONTH FROM age(MAX(order_date), MIN(order_date)))) AS lifespan
    FROM Base_Query
    GROUP BY 1,2,3,4
)
SELECT 
    product_key,
    category,
    subcategory,
    product_name,
    CASE 
        WHEN total_revenue < 50000 THEN 'Low-Performers'
        WHEN total_revenue BETWEEN 50000 AND 100000 THEN 'Mid-Range'
        ELSE 'High-Performers'
    END AS product_segment,
    (DATE_PART('year', age(CURRENT_DATE, last_order_date)) * 12 
    + DATE_PART('month', age(CURRENT_DATE, last_order_date))) AS recency,
    CASE 
        WHEN total_order = 0 THEN 0 
        ELSE total_revenue / total_order 
    END AS avg_order_revenue,
    CASE 
        WHEN lifespan = 0 THEN total_revenue 
        ELSE total_revenue / lifespan 
    END AS avg_monthly_spend,
    total_cost,
    total_order,
    total_revenue,
    total_qty_sold,
    total_customer,
    last_order_date,
    lifespan
FROM product_aggregation;















