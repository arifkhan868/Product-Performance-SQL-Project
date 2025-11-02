# Product Performance Analysis SQL Project
---
### Project Overview:
This is a full, recruiter-friendly GitHub repository for a Product Performance & Revenue Segmentation SQL project.
It contains all necessary files for a complete portfolio presentation including SQL, documentation, examples, LinkedIn copy, and a clear README.
Designed to demonstrate both technical and business analytics skills in a way recruiters immediately understand and value.

### Repository Structure :
```
product-performance-analysis-sql/
├─ sql/
│  └─ product_report_view.sql      # Production-ready SQL view
├─ docs/
│  └─ data_dictionary.md          # Field definitions & assumptions
├─ examples/
│  └─ sample_queries.sql          # Example queries & results
├─ README.md                      # Clear, recruiter-friendly description
├─ linkedin_post.md               # Ready-to-post copy for visibility
├─ CONTRIBUTING.md                # Contribution guidelines
├─ LICENSE                        # MIT License or preferred
└─ .gitignore                     # Ignore unnecessary files
README.md
```
# Product Performance Analysis (SQL)

This recruiter-friendly SQL project highlights product-level performance and business intelligence skills.

## Project Summary
- Production-ready SQL view analyzing product performance.
- Calculates key KPIs: revenue, orders, quantity sold, customer reach, recency, lifespan, average order revenue, average monthly revenue, gross margin.
- Segments products into Low, Mid, High Performers based on revenue.
- Ready for BI integration (Power BI / Tableau).

## Skills Demonstrated
- SQL & Data Modeling: CTEs, Joins, Aggregations
- Business Analytics: KPI calculation, product segmentation
- Data Storytelling: Clear documentation & results
- Production Thinking: Reusable view design

## Quick Start
1. Clone repository
2. Run SQL view in PostgreSQL
3. Explore results

## Why Recruiter-Friendly
- Highlights business impact
- Structured & documented code
- Portfolio presentation ready

## SQL: product_report_view.sql
```
CREATE OR REPLACE VIEW gold.product_report AS
WITH Base_Query AS (
    SELECT
        p.product_key,
        p.category,
        p.subcategory,
        p.product_name,
        p.cost,
        s.order_number,
        s.sales_amount,
        s.quantity,
        s.customer_key,
        s.order_date
    FROM gold.sales s
    LEFT JOIN gold.products p
    ON s.product_key = p.product_key
),
product_aggregation AS (
    SELECT
        product_key,
        category,
        subcategory,
        product_name,
        AVG(cost) AS avg_cost,
        SUM(cost * quantity) AS total_cost,
        COUNT(DISTINCT order_number) AS total_order,
        SUM(sales_amount) AS total_revenue,
        SUM(quantity) AS total_qty_sold,
        COUNT(DISTINCT customer_key) AS total_customer,
        MAX(order_date) AS last_order_date,
        (EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
         + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date)))) AS lifespan
    FROM Base_Query
    GROUP BY product_key, category, subcategory, product_name
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
    (DATE_PART('year', AGE(CURRENT_DATE, last_order_date)) * 12
     + DATE_PART('month', AGE(CURRENT_DATE, last_order_date))) AS recency,
    CASE WHEN total_order = 0 THEN 0 ELSE total_revenue::numeric / total_order END AS avg_order_revenue,
    CASE WHEN lifespan = 0 THEN total_revenue ELSE total_revenue::numeric / NULLIF(lifespan,0) END AS avg_monthly_spend,
    avg_cost,
    total_cost,
    total_order,
    total_revenue,
    total_qty_sold,
    total_customer,
    last_order_date,
    lifespan,
    CASE WHEN total_revenue = 0 THEN NULL ELSE (total_revenue - total_cost) END AS gross_margin,
    CASE WHEN total_revenue = 0 THEN NULL ELSE ((total_revenue - total_cost) / NULLIF(total_revenue,0)) END AS margin_pct
FROM product_aggregation;
```
## Data Dictionary: data_dictionary.md
• gold.sales
    - order_number: Unique order ID
    - order_date: Transaction date
    - product_key: Product foreign key
    - sales_amount: Revenue per line item
    - quantity: Units sold
    - customer_key: Unique customer identifier

• gold.products
    - product_key: Unique product ID
    - product_name: Name of product
    - category: Product category
    - subcategory: Product subcategory
    - cost: Unit cost / COGS

• gold.product_report (Generated View)
    - product_segment: Low/Mid/High performance classification
    - recency: Months since last sale
    - avg_order_revenue: Revenue / total orders
    - avg_monthly_spend: Revenue / active months
    - gross_margin: Revenue − Cost
    - margin_pct: Profitability ratio

LinkedIn Post: linkedin_post.md
🚀 Product Performance & Revenue Segmentation (SQL Project)

I built a recruiter-friendly SQL view to analyze product-level performance — segmenting products into High-, Mid-, and Low-performers and calculating business-critical KPIs like recency, avg order revenue, avg monthly revenue, and gross margin.

🔍 Highlights:
• Clean, readable, and scalable SQL
• Product-level profitability & behavioral segmentation
• Ready for Power BI / Tableau dashboards

GitHub Repository Link: (add after upload)

