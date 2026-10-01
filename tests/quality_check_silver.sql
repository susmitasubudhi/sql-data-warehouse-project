/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
select 
cst_id,COUNT(*)
from Silver.crm_cust_info
group by cst_id
having count(*)>1 or cst_id is null

-- Check for Unwanted Spaces
-- Expectation: No Results

select cst_lastname
from Silver.crm_cust_info
where cst_lastname!=TRIM(cst_lastname)

-- Data Standardization & Consistency
SELECT DISTINCT 
    cst_marital_status 
FROM silver.crm_cust_info;

select distinct cst_gndr
from Silver.crm_cust_info

select *
from Silver.crm_cust_info

-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
select 
NULLIF(sls_order_dt,0) sls_order_dt
from bronze.crm_sales_details
where sls_order_dt<=0
or LEN(sls_order_dt)!=8
or sls_order_dt<19000101 
or sls_order_dt>20500101

select 
NULLIF(sls_ship_dt,0) sls_ship_dt
from bronze.crm_sales_details
where sls_ship_dt<=0
or LEN(sls_ship_dt)!=8
or sls_ship_dt<19000101 
or sls_ship_dt>20500101

select 
NULLIF(sls_due_dt,0) sls_due_dt
from bronze.crm_sales_details
where sls_due_dt<=0
or LEN(sls_due_dt)!=8
or sls_due_dt<19000101 
or sls_due_dt>20500101


--invalid Date Orders
 select * from
  Silver.crm_sales_details
  where sls_order_dt>sls_ship_dt or sls_order_dt>sls_due_dt

  -- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results

select DISTINCT
sls_sales,
sls_quantity,
sls_price
from bronze.crm_sales_details
where sls_sales !=sls_quantity*sls_price
or sls_sales is null
or sls_quantity is null
or sls_price is null
or sls_sales <0
or sls_quantity <0
or sls_price <0
Order by sls_sales,sls_quantity,sls_price

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
select BDATE 
from Silver.erp_cust_az12
where BDATE<'1924-01-01' or BDATE> GETDATE()

SELECT DISTINCT GEN
FROM Silver.erp_cust_az12
-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================
-- Data Standardization & Consistency
select * from
Silver.erp_loc_a101

select distinct 
CNTRY as old_cntry,
case when trim(CNTRY)='DE' THEN 'Germany'
     when trim(CNTRY) IN('US','USA') THEN 'United States'
     when trim(CNTRY) =''OR CNTRY IS NULL then 'n/a'
     else trim(CNTRY)
END AS CNTRY
from  bronze.erp_loc_a101

  -- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================
-- Check for Unwanted Spaces
-- Expectation: No Results

select * from 
bronze.erp_px_cat_g1v2
where SUBCAT!=TRIM(SUBCAT)
or CAT!=TRIM(CAT)
or MAINTENANCE!=TRIM(MAINTENANCE)

select distinct 
MAINTENANCE
from 
Silver.erp_px_cat_g1v2
