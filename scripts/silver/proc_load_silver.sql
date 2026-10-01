/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN
 DECLARE @start_time DATETIME , @end_time DATETIME,
    @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
          SET @batch_start_time=GETDATE();
          PRINT '-----------------------';
          PRINT 'Loading the Silver Layer';
          print '------------------------';
          print '------------------------';
          print 'Loading CRM Tables';
          print '------------------------';


---1. Clean the the data and load it into Silver layer
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.crm_cust_info';
TRUNCATE TABLE Silver.crm_cust_info;
PRINT'>> Inserting Into : Silver.crm_cust_info'
INSERT INTO Silver.crm_cust_info
(
cst_id,
cst_key,
cst_firstname,
cst_lastname, 
cst_marital_status,
cst_gndr,
cst_create_date )

select 
cst_id,
cst_key,
trim(cst_firstname) as cst_firstname,
trim(cst_lastname) as cst_lastname,
case when upper(trim(cst_marital_status))='M' THEN 'Married'
     when upper(trim(cst_marital_status))='S' THEN 'Single'
     else 'n/a'
END
cst_marital_status,
case when upper(trim(cst_gndr))='F' THEN 'Female'
     when upper(trim(cst_gndr))='M' THEN 'Male'
     else 'n/a'
END cst_gndr,
cst_create_date
from (
select *,
row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_cust_info
where cst_id IS NOT NULL) T where flag_last=1
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';





---2.
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.crm_prd_info';
TRUNCATE TABLE Silver.crm_prd_info;
PRINT'>> Inserting Into : Silver.crm_prd_info'
INSERT INTO Silver.crm_prd_info
(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
select 
prd_id,
REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
prd_nm,
ISNULL(prd_cost,0) AS prd_cost ,
case  upper(trim(prd_line))
      when'M' THEN 'Mountain'
     when 'R' THEN 'Road'
     when 'S' THEN 'Other Sales'
     when 'T' THEN 'Touring'
     ELSE 'n/a'
end as prd_line,
prd_start_dt,
DATEADD(DAY,-1,LEAD(prd_start_dt) over(partition by prd_key order by prd_start_dt)) as prd_end_dt
from bronze.crm_prd_info
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';





---3.
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.crm_sales_details';
TRUNCATE TABLE Silver.crm_sales_details;
PRINT'>> Inserting Into : Silver.crm_sales_details'
INSERT INTO Silver.crm_sales_details(
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)

SELECT sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt=0 or LEN(sls_order_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR)AS DATE)
     END as sls_order_dt,
CASE WHEN sls_ship_dt=0 or LEN(sls_ship_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR)AS DATE)
     END as sls_ship_dt,

CASE WHEN sls_due_dt=0 or LEN(sls_due_dt)!=8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR)AS DATE)
     END as sls_due_dt,

CASE WHEN sls_sales IS NULL OR sls_sales<0 
OR sls_sales!= sls_quantity*ABS(sls_price)
THEN sls_quantity*ABS(sls_price)
else sls_sales
END as sls_sales,

CASE WHEN sls_price is NULL or sls_price<0
THEN sls_sales/NULLIF (sls_quantity,0)
ELSE sls_price
END AS sls_price,
sls_quantity
FROM bronze.crm_sales_details

set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


    print '------------------------'
    print 'Loading ERP Tables';
    print '------------------------'

---4.
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.erp_cust_az12';
TRUNCATE TABLE Silver.erp_cust_az12;
PRINT'>> Inserting Into : Silver.erp_cust_az12'
INSERT INTO Silver.erp_cust_az12(
CID,
BDATE,
GEN
)
select 
CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
ELSE CID
END CID,
CASE WHEN BDATE> GETDATE() THEN NULL
ELSE BDATE
END BDATE,
CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
     WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
     ELSE 'n/a'
     END GEN
from bronze.erp_cust_az12

set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


---5.
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.erp_loc_a101';
TRUNCATE TABLE Silver.erp_loc_a101;
PRINT'>> Inserting Into : Silver.erp_loc_a101'
INSERT INTO Silver.erp_loc_a101(
CID,
CNTRY
)
select 
REPLACE(CID,'-','') CID,
case when trim(CNTRY)='DE' THEN 'Germany'
     when trim(CNTRY) IN('US','USA') THEN 'United States'
     when trim(CNTRY) =''OR CNTRY IS NULL then 'n/a'
     else trim(CNTRY)
END AS CNTRY
FROM bronze.erp_loc_a101

set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


---6.
set @start_time=GETDATE();
PRINT'>> Truncating Table:Silver.erp_px_cat_g1v2';
TRUNCATE TABLE Silver.erp_px_cat_g1v2;
PRINT'>> Inserting Into : Silver.erp_px_cat_g1v2'
INSERT INTO Silver.erp_px_cat_g1v2(
ID, CAT,SUBCAT,MAINTENANCE)
SELECT 
ID,
CAT,
SUBCAT,
MAINTENANCE
FROM bronze.erp_px_cat_g1v2

set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';

SET @batch_end_time=GETDATE();
print'------------------------'
print'Loading Silver Layer is Completed';
print'  -Total Load Duration :'+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)+'seconds';
print'-------------------------'

  END TRY
  BEGIN CATCH
  PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
  PRINT 'Error Message'+ERROR_MESSAGE();
  PRINT 'Error Message'+CAST(ERROR_NUMBER() AS NVARCHAR);
              PRINT 'Error Message'+CAST(ERROR_STATE() AS NVARCHAR);
  END CATCH
END

EXEC Silver.load_silver
