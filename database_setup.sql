-- Switch to the system database
USE master;
GO

-- Drop the database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'netflix_db')
    DROP DATABASE netflix_db;
GO

-- Create a new Netflix database
CREATE DATABASE netflix_db;
GO

-- Use the newly created database
USE netflix_db;
GO

-- Netflix table was imported from a CSV file
-- using SQL Server's "Import Flat File" feature

-- Get total number of records in the dataset
SELECT 
    COUNT(*) AS total_content
FROM netflix;
