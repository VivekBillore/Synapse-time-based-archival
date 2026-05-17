-- ============================================================
-- 03_create_external_table.sql
-- Template for creating External Table pointing to Hot tier Parquet
-- Replace placeholders before running
-- ============================================================

-- Prerequisites: External Data Source + File Format must exist

-- Step 1: Create External File Format (run once per workspace)
IF NOT EXISTS (SELECT 1 FROM sys.external_file_formats WHERE name = 'ParquetFormat')
BEGIN
    CREATE EXTERNAL FILE FORMAT ParquetFormat
    WITH (FORMAT_TYPE = PARQUET);
END

-- Step 2: Create External Data Source pointing to ADLS Hot tier (run once)
IF NOT EXISTS (SELECT 1 FROM sys.external_data_sources WHERE name = 'ADLS_Hot_Archival')
BEGIN
    CREATE EXTERNAL DATA SOURCE ADLS_Hot_Archival
    WITH (
        TYPE = HADOOP,
        LOCATION = 'abfss://archival@<your_storage_account>.dfs.core.windows.net/hot'
        -- Add CREDENTIAL if not using managed identity
    );
END

-- Step 3: Create External Table for archived data
-- Replace {TableName} and column definitions with actual table schema
IF NOT EXISTS (
    SELECT 1 FROM sys.external_tables
    WHERE name = 'ext_{TableName}_archived'
)
BEGIN
    CREATE EXTERNAL TABLE [dbo].[ext_{TableName}_archived] (
        -- Add your table columns here, e.g.:
        TransactionId     BIGINT,
        TransactionDate   DATE,
        Amount            DECIMAL(18,2),
        CustomerId        INT,
        ProductId         INT
        -- ... add remaining columns
    )
    WITH (
        LOCATION = '/{TableName}/',
        DATA_SOURCE = ADLS_Hot_Archival,
        FILE_FORMAT = ParquetFormat
    );
    PRINT 'External table ext_{TableName}_archived created.';
END
