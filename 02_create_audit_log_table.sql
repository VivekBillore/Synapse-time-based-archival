-- ============================================================
-- 02_create_audit_log_table.sql
-- Tracks every archival run — row counts, file paths, status
-- ============================================================

IF NOT EXISTS (
    SELECT 1 FROM sys.tables
    WHERE name = 'Archival_AuditLog' AND schema_id = SCHEMA_ID('dbo')
)
BEGIN
    CREATE TABLE [dbo].[Archival_AuditLog] (
        AuditId                INT IDENTITY(1,1) PRIMARY KEY,
        TableName              NVARCHAR(200)   NOT NULL,
        SchemaName             NVARCHAR(100)   NOT NULL,
        StorageTier            NVARCHAR(20)    NOT NULL,
        ArchivalCutoffDate     DATE            NOT NULL,  -- Rows older than this were archived
        RowsArchived           BIGINT          NOT NULL,
        RowsRemainingActive    BIGINT          NOT NULL,
        ParquetFilePath        NVARCHAR(1000)  NOT NULL,
        ExternalTableName      NVARCHAR(200)   NULL,
        ViewName               NVARCHAR(200)   NULL,
        RunStatus              NVARCHAR(50)    NOT NULL,  -- 'Success' / 'Failed'
        ErrorMessage           NVARCHAR(MAX)   NULL,
        ArchivedOn             DATETIME        NOT NULL DEFAULT GETDATE(),
        ArchivedBy             NVARCHAR(200)   NOT NULL DEFAULT SYSTEM_USER
    );
    PRINT 'Archival_AuditLog table created successfully.';
END
ELSE
    PRINT 'Archival_AuditLog table already exists.';
