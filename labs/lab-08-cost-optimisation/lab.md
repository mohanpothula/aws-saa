# Lab 08 — Cost Optimisation — Storage & Compute

Measure what is actually consumed, spot idle capacity, move data to an archive tier, and right-size a service.

**Lab environment:** Docker Desktop (free local simulation) — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** Design Cost-Optimized Architectures

---

## Overview

| Local component | AWS equivalent |
|---|---|
| `docker stats` | Amazon CloudWatch metrics / AWS Compute Optimizer |
| `lab8-app` memory limit (256 MB → 128 MB) | Right-sizing an instance or task |
| `lab8-store` hot → archive folders (MinIO) | S3 lifecycle transition to an archive storage class |

> No ports are published for this lab — every exercise uses `docker exec` or `docker stats`.

---

## Step 1 — Get the lab source and start the lab

The repo lives in `~/Downloads/aws-saa`. The paths are absolute, so these commands work from any folder. `git clone` is needed only once: if the repo is already there it prints `already exists`, and the next line still takes you into this lab.

```bash
cd ~/Downloads
git clone https://github.com/mohanpothula/aws-saa.git
cd ~/Downloads/aws-saa/labs/lab-08-cost-optimisation
docker compose up -d
docker compose ps
```

---

## Step 2 — Find resource usage

**Task:** Inspect running container consumption.

```bash
docker stats --no-stream
```

**Expected result:** CPU and memory usage are shown for each container.

---

## Step 3 — Identify waste

**Task:** Find containers with low utilisation.

```bash
docker stats --no-stream
```

**Expected result:** You identify the low-use service and its unused headroom.

---

## Step 4 — Storage lifecycle

**Task:** Create hot and archive folders and move an old object.

```bash
docker exec lab8-store sh -c 'mkdir -p /data/hot /data/archive && echo old >/data/hot/old.txt && mv /data/hot/old.txt /data/archive/'
```

**Expected result:** The object has moved to `/data/archive/`.

---

## Step 5 — Right-size the service

**Task:** Edit the memory limit in `docker-compose.yml` from `256M` to `128M`, then recreate.

```bash
docker compose up -d --force-recreate
docker inspect lab8-app --format '{{.HostConfig.Memory}}'
```

**Expected result:** `134217728` — the new 128 MB limit.

---

## Step 6 — Cost decision

**Task:** Choose always-on or on-demand for an infrequent job.

```bash
echo 'Write choice and reason'
```

**Expected result:** An on-demand / event-driven model for the infrequent workload, with the reason.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — Find resource usage | CPU and memory usage are shown for each container |
| Step 3 — Identify waste | You identify the low-use service and its unused headroom |
| Step 4 — Storage lifecycle | The object has moved to `/data/archive/` |
| Step 5 — Right-size the service | `134217728` — the new 128 MB limit |
| Step 6 — Cost decision | An on-demand / event-driven model for the infrequent workload, with the reason |

## Completion check

- [ ] Every validation result demonstrated to the trainer
- [ ] You can say which AWS service each local component represents
- [ ] You can justify the right-sizing change with the numbers from Step 2

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-08-cost-optimisation
- Original student guide: [`courseware/AWS_SAA_Lab8_Student_Guide.docx`](../../courseware/AWS_SAA_Lab8_Student_Guide.docx)
- [Well-Architected Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [AWS Compute Optimizer](https://docs.aws.amazon.com/compute-optimizer/latest/ug/what-is-compute-optimizer.html)
- [S3 lifecycle management](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html)
- [Amazon S3 storage classes](https://aws.amazon.com/s3/storage-classes/)
- [Compose file reference — deploy / resource limits](https://docs.docker.com/reference/compose-file/deploy/)
- [MinIO container documentation](https://min.io/docs/minio/container/index.html)
