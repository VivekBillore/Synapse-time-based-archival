# Synapse Time-Based Data Archival

An enterprise-grade **metadata-driven archival pipeline** that migrates aging Synapse fact and transaction tables to ADLS Hot/Cold tiers using Azure Data Factory and Parquet — achieving **25%+ Synapse storage reclamation**, improved query performance, and significant cost savings.

---

## Problem Statement

Large-scale data warehouses accumulate billions of rows in fact and transaction tables over time. Without a retention strategy:
- **Query performance degrades** as tables grow unboundedly
- **Synapse storage costs increase** unnecessarily for rarely-accessed historical data
- **Manual archival is error-prone** — no audit trail, no rollback, no automation
- **Downstream reports break** if tables are simply deleted

This project solves all four problems with a **zero-disruption, metadata-driven archival framework**.

---

## Architecture

```
Synapse DW (Fact/Transaction Tables)
        |
        ▼
Archival_Metadata Table  <— Admin configures retention rules here
(table name, date column, retention years, storage tier)
        |
        ▼
ADF Pipeline (PL_DATA_TIME_BASED_ARCHIVAL)
├── Read metadata config
├── Export aged rows → ADLS Parquet (Hot or Cold tier)
├── Create External Table (Hot tier only)
├── Create UNION ALL View (Physical + External Table)
├── Delete archived rows from Synapse physical table
└── Write audit log entry
        |
        ▼
┌──────────────────────┐
│   ADLS Gen2 Storage  │
├── /archival/hot/{TableName}/    → Queryable via External Table
└── /archival/cold/{TableName}/   → Stored only (compliance)
└── ...
        |
        ▼
Synapse View (vw_{TableName})
= Physical Table (recent data)
UNION ALL
External Table (hot archived data)
        |
        ▼
Power BI / SQL Consumers
(zero changes required — same view, same queries)
```

---

## Hot vs Cold Tier

| Feature | Hot Tier | Cold Tier |
|---|---|---|
| Storage | ADLS Standard | ADLS Archive / Cheap |
| Queryable | ✅ Yes – via External Table | ❌ No – stored only |
| Use Case | Historical data still needed in reports | Compliance/legal retention only |
| View Merge | ✅ UNION ALL with physical table | ❌ Not exposed to SQL engine |

---

## Metadata-Driven Design

Onboard any table with a single SQL INSERT:

```sql
INSERT INTO [dbo].[Archival_Metadata]
VALUES (
    'FactSalesTransaction',   -- Table to archive
    'TransactionDate',        -- Date column for retention filter
    '3',                      -- Retention years (keep last 3 years active)
    'Parquet',                -- File format
    'Hot',                    -- Storage tier
    'dbo'                     -- Schema
);
```

No code changes needed — just add a row and run the pipeline.

---

## Tech Stack

| Component | Technology |
|---|---|
| Source | Azure Synapse Analytics (Dedicated SQL Pool) |
| Orchestration | Azure Data Factory |
| Storage | ADLS Gen2 (Hot + Cold tiers) |
| File Format | Apache Parquet |
| Query Layer | Synapse External Tables + UNION ALL Views |
| Audit | SQL-based Archival_AuditLog table |

---

## Key Technical Highlights

- **Metadata-driven** — any table onboarded via single SQL INSERT, zero code changes
- **Zero-disruption** — UNION ALL Views ensure downstream reports need no changes
- **Hot/Cold separation** — balance between queryability and storage cost
- **Full audit trail** — every archival run logged with row counts, file paths, timestamps
- **Idempotent** — safe to re-run; uses IF NOT EXISTS checks throughout
- **Rollback-safe** — Cold files retained even after Synapse rows deleted

---

## Project Structure

```
synapse-time-based-archival/
├── README.md
├── sql_scripts/
│   ├── 01_create_metadata_table.sql    # Archival config table
│   ├── 02_create_audit_log_table.sql   # Run history tracking
│   ├── 03_create_external_table.sql    # External Table template
│   ├── 04_create_union_view.sql        # UNION ALL View template
│   └── 05_sample_metadata_inserts.sql  # Example onboarding rows
├── notebooks/
│   └── archival_validation.py          # PySpark row count validation
├── adf_pipeline/
│   └── PL_DATA_TIME_BASED_ARCHIVAL.json  # Sanitized ADF pipeline export
├── data_samples/
│   └── sample_archival_metadata.csv    # Demo metadata config
└── docs/
    └── architecture.md                 # Detailed design notes
```

---

## Impact

| Metric | Result |
|---|---|
| Synapse storage reclaimed | **25%+** |
| Query performance | **Improved** — active tables smaller |
| Manual archival effort | **Reduced by 70%** via full automation |
| Downstream report changes | **Zero** — same Views, same queries |
| Infrastructure cost | **Significant savings** — cheap ADLS vs Synapse |
| Presented at | Internal engineering Townhall — developers + executives |

---

## Setup (Demo)

```bash
# 1. Clone the repo
git clone https://github.com/VivekBillore/synapse-time-based-archival

# 2. Run SQL scripts in order (01 → 05) in your Synapse workspace

# 3. Configure ADF pipeline with your ADLS + Synapse linked services

# 4. Insert metadata rows for tables you want to archive

# 5. Trigger PL_DATA_TIME_BASED_ARCHIVAL
```

> ⚠️ **Note:** This is a sanitized demo. All company-specific table names, endpoints, and connection strings have been replaced with generic examples.
