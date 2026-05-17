-- ============================================================
-- 01_create_metadata_table.sql
-- Archival configuration table — one row per table to archive
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = 'Archival_Metadata' AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE [dbo].[Archival_Metadata] (
        MetadataId       INT IDENTITY(1,1) PRIMARY KEY,
        TableName        NVARCHAR(200)  NOT NULL,  -- e.g. 'FactSalesTransaction'
        DateColumn       NVARCHAR(200)  NOT NULL,  -- e.g. 'TransactionDate'
        RetentionYears   NVARCHAR(10)   NOT NULL,  -- e.g. '3' (keep last 3 years active)
        FileFormat       NVARCHAR(50)   NOT NULL,  -- 'Parquet'
        StorageTier      NVARCHAR(20)   NOT NULL,  -- 'Hot' or 'Cold'
        SchemaName       NVARCHAR(100)  NOT NULL,  -- e.g. 'dbo'
        IsActive         BIT            NOT NULL DEFAULT 1,
        CreatedDate      DATETIME       NOT NULL DEFAULT GETDATE(),
        ModifiedDate     DATETIME       NOT NULL DEFAULT GETDATE()
    );
    PRINT 'Archival_Metadata table created successfully.';
END
ELSE
    PRINT 'Archival_Metadata table already exists.';
