/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/


IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);
GO

IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
prd_id INT,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);
GO

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id INT,
sls_order_dt NVARCHAR(50),
sls_ship_dt NVARCHAR(50),
sls_due_dt NVARCHAR(50),
sls_sales INT,
sls_quantity INT,
sls_price INT
);
GO


IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
CID NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(20)
);
GO

IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101(
CID NVARCHAR(50),
CNTRY NVARCHAR(50)
);
GO

IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50)
);
GO
SELECT COUNT(*) FROM bronze.crm_prd_info;


exec bronze.load_bronze

CREATE OR ALTER PROCEDURE bronze.load_bronze as
BEGIN 
    DECLARE @start_time DATETIME , @end_time DATETIME,
    @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
         SET @batch_start_time=GETDATE();
    PRINT 'Loading the Bronze Layer';

    print '------------------------';
    print 'Loading CRM Tables';
    print '------------------------';

set @start_time=GETDATE();
print '>> Truncating Table:bronze.crm_cust_info';
TRUNCATE TABLE bronze.crm_cust_info;

print '>> Inserting Data into :bronze.crm_cust_info';
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


set @start_time=GETDATE();
print '>> Truncating Table:bronze.crm_prd_info';
TRUNCATE TABLE bronze.crm_prd_info

print '>> Inserting Data into :bronze.crm_prd_info';
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


set @start_time=GETDATE();
print '>> Truncating Table:bronze.crm_sales_details';
TRUNCATE TABLE bronze.crm_sales_details

print '>> Inserting Data into :bronze.crm_sales_details';
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


    print '------------------------'
    print 'Loading ERP Tables';
    print '------------------------'


set @start_time=GETDATE();
print '>> Truncating Table:bronze.erp_cust_az12';
TRUNCATE TABLE bronze.erp_cust_az12
print '>> Inserting Data into :bronze.erp_cust_az12';
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


set @start_time=GETDATE();
print '>> Truncating Table:bronze.erp_loc_a101';
TRUNCATE TABLE bronze.erp_loc_a101

print '>> Inserting Data into :bronze.erp_loc_a101';
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
);
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';



set @start_time=GETDATE();
print '>> Truncating Table:bronze.erp_px_cat_g1v2';
TRUNCATE TABLE bronze.erp_px_cat_g1v2

print '>> Inserting Data into :bronze.erp_px_cat_g1v2';
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\ASUS\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
WITH (
FIRSTROW=2,
FIELDTERMINATOR=',',
TABLOCK
); 
set @end_time=GETDATE();
print '>> Load Duration: '+ cast(DATEDIFF(second,@start_time,@end_time) as nVARCHAR) + 'seconds';
print '----------';


SET @batch_end_time=GETDATE();
print'------------------------'
print'Loading Bronze Layer is Completed';
print'  -Total Load Duration :'+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR)+'seconds';
print'-------------------------'

  END TRY
  BEGIN CATCH
  PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
  PRINT 'Error Message'+ERROR_MESSAGE();
  PRINT 'Error Message'+CAST(ERROR_NUMBER() AS NVARCHAR);
              PRINT 'Error Message'+CAST(ERROR_STATE() AS NVARCHAR);
  END CATCH
END
