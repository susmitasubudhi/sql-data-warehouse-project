/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

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
