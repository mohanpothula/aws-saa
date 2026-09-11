# Lab 02 — Secure VPC & Data Protection

Practise public, private and isolated network separation, troubleshoot App → DB connectivity, and verify KMS-encrypted S3 storage.

**Lab environment:** Docker Desktop + LocalStack — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** Design Secure Architectures

---

## Overview

| Local component | AWS equivalent |
|---|---|
| Published port `8080` | Internet gateway / public subnet |
| `lab2-alb` (NGINX reverse proxy) | Application Load Balancer |
| `private-net` (internal Docker network) | Private subnet with security-group isolation |
| `lab2-app` | Private application tier |
| `isolated-net` (internal Docker network) | Isolated database subnet / NACL separation |
| `lab2-db` (MariaDB) | Database tier (Amazon RDS) |
| LocalStack KMS + S3 | AWS KMS key + SSE-KMS encrypted Amazon S3 bucket |

> Docker networks are a teaching approximation. They do not reproduce VPC route tables, security groups, NACLs, NAT gateways, ACM or VPC endpoints exactly.

---

## Step 1 — Get the lab source and start the lab

```bash
git clone https://github.com/mohanpothula/aws-saa.git
cd aws-saa/labs/lab-02-secure-vpc-data-protection
docker compose up -d
until docker compose logs localstack 2>&1 | grep -q "created successfully"; do sleep 2; done; echo READY
docker compose ps
```

> The app and database are **deliberately** on separate internal networks — finding and fixing that is Step 6.

---

## Step 2 — Test the public entry point

**Task:** Reach the application through the simulated ALB.

```bash
curl http://localhost:8080
```

**Expected result:** Response contains `LAB 2 - Private Application Tier`.

---

## Step 3 — Validate the private app

**Task:** Prove the app has no direct host port.

```bash
docker port lab2-app
docker inspect lab2-app --format '{{json .NetworkSettings.Networks}}'
```

**Expected result:** `docker port` prints nothing — `lab2-app` has no host-published port.

---

## Step 4 — Validate the isolated database

**Task:** Prove MariaDB is not directly exposed.

```bash
docker port lab2-db
docker inspect lab2-db --format '{{json .NetworkSettings.Networks}}'
```

**Expected result:** `docker port` prints nothing — `lab2-db` has no host-published port.

---

## Step 5 — Network security challenge

**Task:** Compare the ALB, App and DB networks and identify why App cannot initially reach DB.

```bash
docker inspect lab2-alb --format '{{json .NetworkSettings.Networks}}'
docker inspect lab2-app --format '{{json .NetworkSettings.Networks}}'
docker inspect lab2-db --format '{{json .NetworkSettings.Networks}}'
```

**Expected result:** App is on `private-net` only; DB is on `isolated-net` only. They share no network, so there is no path between them.

---

## Step 6 — Fix App → DB connectivity

**Task:** Edit `docker-compose.yml` so `app` also joins `isolated-net`. Do **not** publish DB port 3306.

```bash
# in docker-compose.yml, under the app service:
#   networks:
#     - private-net
#     - isolated-net
docker compose up -d --force-recreate app alb
docker exec lab2-app nc -zv db 3306
```

**Expected result:** `db (…:3306) open` — the database is reachable from the app, yet `docker port lab2-db` still prints nothing.

> Why not `apk add` first? `isolated-net` is an **internal** network with no route to the internet, so package installs fail inside it — which is exactly the isolation you are testing. `nc` is already built into the image's BusyBox. Recreate only `app` and `alb`: recreating every service would also restart LocalStack, which keeps its data in memory, so its bucket would vanish until the init script re-ran and Step 7 could fail with `NoSuchBucket`. `alb` is recreated alongside `app` because NGINX looks up the app's address only when it starts.

---

## Step 7 — Verify KMS / S3 encryption

**Task:** Confirm the bucket is encrypted with a KMS key.

```bash
docker exec -it aws-saa-lab2 bash
awslocal kms list-aliases
awslocal s3api get-bucket-encryption --bucket lab2-secure-data
awslocal s3 ls s3://lab2-secure-data
```

**Expected result:** Encryption reports `aws:kms` and `secure.txt` exists.

> The first command opens a shell **inside** the LocalStack container; the three `awslocal` commands run there. Type `exit` to return to your own terminal.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — Test the public entry point | Response contains `LAB 2 - Private Application Tier` |
| Step 3 — Validate the private app | `docker port` prints nothing — `lab2-app` has no host-published port |
| Step 4 — Validate the isolated database | `docker port` prints nothing — `lab2-db` has no host-published port |
| Step 5 — Network security challenge | App is on `private-net` only; DB is on `isolated-net` only. They share no network, so there is no path between them |
| Step 6 — Fix App → DB connectivity | `db (…:3306) open` — the database is reachable from the app, yet `docker port lab2-db` still prints nothing |
| Step 7 — Verify KMS / S3 encryption | Encryption reports `aws:kms` and `secure.txt` exists |

## Completion check

- [ ] Public endpoint works through the ALB
- [ ] App and DB are not directly exposed
- [ ] You repaired the App → DB network path
- [ ] S3 encryption reports `aws:kms`

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-02-secure-vpc-data-protection
- Original student guide: [`courseware/AWS_SAA_Lab2_Student_Guide.docx`](../../courseware/AWS_SAA_Lab2_Student_Guide.docx)
- [What is Amazon VPC?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [VPC security groups](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-groups.html)
- [VPC network ACLs](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-network-acls.html)
- [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [AWS KMS concepts](https://docs.aws.amazon.com/kms/latest/developerguide/overview.html)
- [S3 server-side encryption with AWS KMS (SSE-KMS)](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html)
- [LocalStack documentation](https://docs.localstack.cloud/)
- [Compose file reference — networks](https://docs.docker.com/reference/compose-file/networks/)
- [NGINX proxy module (proxy_pass, proxy_cache)](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
