/*
Project: E-commerce Analytics using SQL Server
Purpose: Create the database and project schemas.

IMPORTANT:
Run this script only when setting up a new project.
Do not run it against an existing database.
*/

USE master;
GO

IF DB_ID('EcommerceAnalytics') IS NULL
BEGIN
    CREATE DATABASE EcommerceAnalytics;
END;
GO

USE EcommerceAnalytics;
GO

IF SCHEMA_ID('staging') IS NULL
    EXEC('CREATE SCHEMA staging');
GO

IF SCHEMA_ID('analytics') IS NULL
    EXEC('CREATE SCHEMA analytics');
GO

IF SCHEMA_ID('reporting') IS NULL
    EXEC('CREATE SCHEMA reporting');
GO