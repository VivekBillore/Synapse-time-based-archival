-- ============================================================
-- 04_create_union_view.sql
-- UNION ALL View merging active Synapse table + archived External Table
-- Downstream reports use this view — zero changes needed post-archival
-- ============================================================

-- Replace {TableName} with actual table name
CREATE OR ALTER VIEW [dbo].[vw_{TableName}]
AS
    -- Active data (recent rows still in Synapse physical table)
    SELECT * FROM [dbo].[{TableName}]

    UNION ALL

    -- Archived data (older rows in ADLS Hot tier via External Table)
    SELECT * FROM [dbo].[ext_{TableName}_archived]
;

-- ============================================================
-- Verify the view returns correct total row count:
-- SELECT COUNT(*) FROM [dbo].[vw_{TableName}]
-- Should equal: physical table rows + external table rows
-- ============================================================
