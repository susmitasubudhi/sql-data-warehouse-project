/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================


CREATE OR ALTER VIEW Gold.dim_customer AS
SELECT 
ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,
ci.cst_id AS customer_id,
ci.cst_key AS customer_number,
ci.cst_firstname AS first_name,
ci.cst_lastname last_name,
la.CNTRY as country,
ci.cst_marital_status AS marital_status,

CASE WHEN ci.cst_gndr!='n/a' THEN ci.cst_gndr
      ELSE COALESCE(ca.gen,'n/a')
END as gender,
ca.BDATE AS birthdate,
ci.cst_create_date AS create_date
FROM 
Silver.crm_cust_info ci
LEFT JOIN 
Silver.erp_cust_az12 ca
ON ci.cst_key=ca.CID
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key=la.CID

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================

CREATE VIEW Gold.dim_product AS
SELECT 
ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt,pn.prd_key) AS product_key,
pn.prd_id AS product_id ,
pn.prd_key AS product_number,
pn.prd_nm AS product_name,
pn.cat_id AS category_id,
pc.CAT AS category,
pc.SUBCAT AS subcategory,
pc.MAINTENANCE AS maintenance,
pn.prd_cost AS cost,
pn.prd_line AS product_line,
pn.prd_start_dt AS start_date
from Silver.crm_prd_info pn
LEFT JOIN 
Silver.erp_px_cat_g1v2 pc
ON pn.cat_id=pc.ID
WHERE prd_end_dt IS NULL

  -- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
CREATE OR ALTER VIEW Gold.fact_sales AS
select 
sd.sls_ord_num AS order_number ,
pr.product_key ,
cu.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS shipping_date,
sd.sls_due_dt AS due_date,
sd.sls_sales AS sales_amount,
sd.sls_quantity AS quantity,
sd.sls_price AS price
from 
Silver.crm_sales_details sd
LEFT JOIN Gold.dim_product pr
ON sd.sls_prd_key=pr.product_number
LEFT JOIN Gold.dim_customer cu
ON sd.sls_cust_id=cu.customer_id







