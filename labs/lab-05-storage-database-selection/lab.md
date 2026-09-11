# Lab 05 — High-Performance Storage & Database Selection

Work with a relational database, an in-memory cache and object storage side by side, then choose the right store for each workload.

**Lab environment:** Docker Desktop (free local simulation) — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** Design High-Performing Architectures

---

## Overview

| Local component | AWS equivalent |
|---|---|
| `lab5-db` (MariaDB) | Amazon RDS / Aurora |
| `lab5-redis` (Redis) | Amazon ElastiCache |
| `lab5-minio` (MinIO) | Amazon S3 |

> No ports are published for this lab — every exercise uses `docker exec`.

---

## Step 1 — Get the lab source and start the lab

The repo lives in `~/Downloads/aws-saa`. The paths are absolute, so these commands work from any folder. `git clone` is needed only once: if the repo is already there it prints `already exists`, and the next line still takes you into this lab.

```bash
cd ~/Downloads
git clone https://github.com/mohanpothula/aws-saa.git
cd ~/Downloads/aws-saa/labs/lab-05-storage-database-selection
docker compose up -d
docker compose ps
```

> MariaDB needs 10–20 seconds to initialise on first start. If Step 2 fails with a connection error, wait a moment and run it again.

---

## Step 2 — SQL workload

**Task:** Create and query product data.

```bash
docker exec lab5-db mariadb -uroot -pPass123! labdb -e "CREATE TABLE products(id INT,name VARCHAR(30)); INSERT INTO products VALUES(1,'Laptop'); SELECT * FROM products;"
```

**Expected result:** `Laptop` is returned.

---

## Step 3 — Cache workload

**Task:** Set and get a cached value.

```bash
docker exec lab5-redis redis-cli SET product:1 Laptop
docker exec lab5-redis redis-cli GET product:1
```

**Expected result:** `Laptop` is returned.

---

## Step 4 — Object storage

**Task:** Create a bucket folder and upload a file.

```bash
docker exec lab5-minio sh -c 'mkdir -p /data/lab5 && echo report >/data/lab5/report.txt && ls -l /data/lab5'
```

**Expected result:** `report.txt` is listed.

---

## Step 5 — Selection challenge

**Task:** Choose storage for a transaction, a session cache and an image archive.

```bash
echo 'Transaction=?  Session=?  Archive=?'
```

**Expected result:** Transaction → MariaDB (RDS) · Session → Redis (ElastiCache) · Archive → MinIO (S3).

---

## Step 6 — Validate services

**Task:** Check all three services.

```bash
docker compose ps
```

**Expected result:** All three are running.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — SQL workload | `Laptop` is returned |
| Step 3 — Cache workload | `Laptop` is returned |
| Step 4 — Object storage | `report.txt` is listed |
| Step 5 — Selection challenge | Transaction → MariaDB (RDS) · Session → Redis (ElastiCache) · Archive → MinIO (S3) |
| Step 6 — Validate services | All three are running |

## Completion check

- [ ] Every validation result demonstrated to the trainer
- [ ] You can say which AWS service each local component represents
- [ ] You can justify each store in the selection challenge

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-05-storage-database-selection
- Original student guide: [`courseware/AWS_SAA_Lab5_Student_Guide.docx`](../../courseware/AWS_SAA_Lab5_Student_Guide.docx)
- [Amazon RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- [Amazon ElastiCache](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.html)
- [Amazon S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- [Amazon S3 storage classes](https://aws.amazon.com/s3/storage-classes/)
- [MariaDB official Docker image](https://hub.docker.com/_/mariadb)
- [MinIO container documentation](https://min.io/docs/minio/container/index.html)
