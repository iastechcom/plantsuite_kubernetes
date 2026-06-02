# ADR: Percona Operators for Databases

## Status: Accepted

## Context
Need production-grade MongoDB and PostgreSQL with HA, backups, and monitoring.

## Decision
Use Percona operators:
- Percona Server for MongoDB (PSMDB) operator
- Percona PostgreSQL operator (PPGC)

## Consequences
- Managed HA, automated failover, backup support
- Custom resources: PSMDB, PGC instead of raw StatefulSets
- Operator lifecycle tied to Percona release cycle
- Instances: `plantsuite-psmdb` (MongoDB), `plantsuite-ppgc` (PostgreSQL)
