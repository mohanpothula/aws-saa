# Lab 06 — Elastic Compute, Containers & Serverless

Build and run a containerised service with explicit CPU and memory limits, invoke a function-style endpoint, and inspect a batch worker.

**Lab environment:** Docker Desktop (free local simulation) — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** Design High-Performing Architectures

---

## Overview

| Local component | AWS equivalent |
|---|---|
| `lab6-app` (Flask, 0.5 CPU / 128 MB, port 8086) | An EC2 instance size or ECS task size |
| `GET /function` | An AWS Lambda function invocation |
| `lab6-worker` (loop every 10 s) | AWS Batch / an ECS scheduled task |

---

## Step 1 — Get the lab source and start the lab

The repo lives in `~/Downloads/aws-saa`. The paths are absolute, so these commands work from any folder. `git clone` is needed only once: if the repo is already there it prints `already exists`, and the next line still takes you into this lab.

```bash
cd ~/Downloads
git clone https://github.com/mohanpothula/aws-saa.git
cd ~/Downloads/aws-saa/labs/lab-06-compute-containers-serverless
docker compose up -d
docker compose ps
```

---

## Step 2 — Build the image

**Task:** Build the Flask image.

```bash
docker compose build
```

**Expected result:** The build succeeds.

---

## Step 3 — Run the service

**Task:** Start and test the app.

```bash
docker compose up -d
curl http://localhost:8086
```

**Expected result:** `LAB6 Flask App` is returned.

---

## Step 4 — Inspect sizing

**Task:** Check the CPU and memory limits.

```bash
docker inspect lab6-app --format 'Memory={{.HostConfig.Memory}} NanoCPUs={{.HostConfig.NanoCpus}}'
```

**Expected result:** `Memory=134217728 NanoCPUs=500000000` — 128 MB and half a CPU.

---

## Step 5 — Function simulation

**Task:** Invoke the event endpoint.

```bash
curl http://localhost:8086/function
```

**Expected result:** `{"status":"processed"}` is returned.

---

## Step 6 — Batch workload

**Task:** Inspect the worker logs.

```bash
docker compose logs --tail=5 worker
```

**Expected result:** `batch-job-<timestamp>` messages are visible.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — Build the image | The build succeeds |
| Step 3 — Run the service | `LAB6 Flask App` is returned |
| Step 4 — Inspect sizing | `Memory=134217728 NanoCPUs=500000000` — 128 MB and half a CPU |
| Step 5 — Function simulation | `{"status":"processed"}` is returned |
| Step 6 — Batch workload | `batch-job-<timestamp>` messages are visible |

## Completion check

- [ ] Every validation result demonstrated to the trainer
- [ ] You can say which AWS service each local component represents
- [ ] You can explain when you would pick Lambda over a long-running container

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-06-compute-containers-serverless
- Original student guide: [`courseware/AWS_SAA_Lab6_Student_Guide.docx`](../../courseware/AWS_SAA_Lab6_Student_Guide.docx)
- [Amazon ECS Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [AWS Batch User Guide](https://docs.aws.amazon.com/batch/latest/userguide/what-is-batch.html)
- [Docker Compose](https://docs.docker.com/compose/)
- [Compose file reference — deploy / resource limits](https://docs.docker.com/reference/compose-file/deploy/)
