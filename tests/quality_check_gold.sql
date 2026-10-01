/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT  
ci.cst_gndr,
ca.GEN,
CASE WHEN ci.cst_gndr!='n/a' 
THEN ci.cst_gndr
ELSE COALESCE(ca.gen,'n/a')
END as new_gen
FROM 
Silver.crm_cust_info ci
LEFT JOIN 
Silver.erp_cust_az12 ca
ON ci.cst_key=ca.CID
LEFT JOIN Silver.erp_loc_a101 la
ON ci.cst_key=la.CID
Order by 1,2


select prd_key ,COUNT(*) as total_count 
from Silver.crm_prd_info
group by prd_key
having count(*)>1

select COUNT (DISTINCT prd_key) from Silver.crm_prd_info


select * from
Gold.fact_sales f
LEFT JOIN Gold.dim_product p
ON p.product_key=f.product_key
where p.product_key IS NULL
