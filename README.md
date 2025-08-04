# Neo4j Dev KG (Docker)

Single-developer Neo4j 5 setup for Windows + Docker Desktop with APOC and GDS enabled.

## Quick Start
1) Install Docker Desktop.
2) Copy `.env.example` → `.env`, set a strong password.
3) Start:
   ```powershell
   docker compose up -d
   ```
4) Browser: http://localhost:8474  |  Bolt: bolt://localhost:8687

## Seeding
```powershell
./scripts/seed.ps1
```

## Dump (backup)
```powershell
./scripts/dump.ps1
```
Outputs to `./backups` (container stopped during dump).

## Load (restore)
```powershell
./scripts/load.ps1 -DumpFile "<filename.dump>"
```

## Notes
- Image tag is pinned via `.env` (default `5.26.0`).
- Plugins: APOC + GDS are enabled via `NEO4J_PLUGINS`.
- Host ports are remapped to avoid conflicts: 8474 (HTTP), 8687 (Bolt).
- Volumes use explicit names (`neo4j_dev_kg_data`, `neo4j_dev_kg_plugins`) so scripts can reference them reliably.
- For heavy GDS jobs, increase memory in `.env`.
