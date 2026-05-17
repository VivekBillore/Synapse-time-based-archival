# Architecture Notes

## Core Design Principles

1. **Metadata-driven** — no code changes to onboard new tables; just INSERT a config row
2. **Zero-disruption** — UNION ALL Views preserve downstream query compatibility
3. **Hot/Cold separation** — queryable vs compliance-only storage tiers
4. **Full auditability** — every run logged with row counts, paths, timestamps
5. **Idempotent** — IF NOT EXISTS checks make re-runs safe

---

## ADF Pipeline Structure

```
PL_DATA_TIME_BASED_ARCHIVAL  (Master Pipeline)
    |
    ├── ACT_LKP_GetMetadata        → Read active rows from Archival_Metadata
    |
    └── ACT_FOREACH_Table          → Loop over each table config
            |
            ├── ACT_COPY_ExportParquet  → CETAS: export aged rows to ADLS as Parquet
            ├── ACT_SP_CreateExtTable   → Create External Table (Hot tier only)
            ├── ACT_SP_CreateView       → Create/update UNION ALL View
            ├── ACT_SP_DeleteArchived   → Delete archived rows from physical table
            └── ACT_SP_WriteAuditLog    → Log run details to Archival_AuditLog
```

---

## SQL Objects Created Per Table

| Object | Name Pattern | Purpose |
|---|---|---|
| External Table | `ext_{TableName}_archived` | Points to Hot tier Parquet |
| UNION ALL View | `vw_{TableName}` | Merges physical + archived — zero report changes |
| Audit Log row | `Archival_AuditLog` | Row counts, file paths, run status per execution |

---

## ADLS Folder Structure

```
archival/
├── hot/
│   ├── FactSalesTransaction/
│   │   └── archival_2023.parquet
│   └── FactOrderHistory/
│       └── archival_2021_2022.parquet
└── cold/
    ├── FactAuditLog/
    │   └── archival_2015_2018.parquet
    └── TelemetryEvents/
        └── archival_2024.parquet
```

---

## Retention Logic

```sql
-- Rows older than RetentionYears cutoff get archived
-- Example: RetentionYears = 3, today = 2026-05-16
-- Cutoff = 2023-05-16
-- Rows with DateColumn < '2023-05-16' → exported to ADLS → deleted from Synapse
DATEADD(YEAR, -CAST(RetentionYears AS INT), GETDATE())
```

---

## Hot vs Cold Tier Decision

| Feature | Hot Tier | Cold Tier |
|---|---|---|
| Storage | ADLS Standard | ADLS Archive (cheap) |
| Queryable | Yes — via External Table | No — stored only |
| View Merge | UNION ALL with physical table | Not exposed to SQL engine |
| Use Case | Historical data still in reports | Compliance / legal retention |
