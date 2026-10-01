
/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
---CREATE DATABASE DATAWAREHOUSE
USE master
GO 
--DROP and CREATE the 'Datawarehouse' database

IF EXISTS(SELECT 1 FROM sys.databases where name='DataWarehouse')
BEGIN
   ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   DROP DATABASE DataWarehouse
END;
GO


USE DataWarehouse
GO

--CREATE SCHEMAS
CREATE SCHEMA bronze
GO
CREATE SCHEMA Silver
GO
CREATE SCHEMA Gold
GO
