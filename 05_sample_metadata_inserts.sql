-- ============================================================
-- 05_sample_metadata_inserts.sql
-- Example: onboard tables for archival with a single INSERT
-- ============================================================

-- 3-year retention, Hot storage (historical data still queryable)
INSERT INTO [dbo].[Archival_Metadata] (TableName, DateColumn, RetentionYears, FileFormat, StorageTier, SchemaName)
VALUES ('FactSalesTransaction', 'TransactionDate', '3', 'Parquet', 'Hot', 'dbo');

-- 5-year retention, Hot storage
INSERT INTO [dbo].[Archival_Metadata] (TableName, DateColumn, RetentionYears, FileFormat, StorageTier, SchemaName)
VALUES ('FactOrderHistory', 'OrderDate', '5', 'Parquet', 'Hot', 'dbo');

-- 7-year retention, Cold storage (compliance only — not queryable)
INSERT INTO [dbo].[Archival_Metadata] (TableName, DateColumn, RetentionYears, FileFormat, StorageTier, SchemaName)
VALUES ('FactAuditLog', 'AuditDate', '7', 'Parquet', 'Cold', 'dbo');

-- Telemetry table — 1-year retention, Cold storage
INSERT INTO [dbo].[Archival_Metadata] (TableName, DateColumn, RetentionYears, FileFormat, StorageTier, SchemaName)
VALUES ('TelemetryEvents', 'EventDate', '1', 'Parquet', 'Cold', 'dbo');

-- View current metadata config
SELECT
    MetadataId,
    SchemaName + '.' + TableName  AS FullTableName,
    DateColumn,
    RetentionYears + ' years'     AS RetentionPeriod,
    StorageTier,
    IsActive,
    CreatedDate
FROM [dbo].[Archival_Metadata]
ORDER BY MetadataId;
