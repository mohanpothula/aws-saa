# Lab 09 — Well-Architected Review & Cost Controls

Review a small architecture against the Well-Architected pillars: find the exposure, prove the single point of failure, fix it by scaling out, and write up the findings.

**Lab environment:** Docker Desktop (free local simulation) — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** All four SAA-C03 domains

---

## Overview

| Local component | AWS equivalent |
|---|---|
| `lab9-proxy` (NGINX, port 8089) | Application Load Balancer |
| `app` service (scalable, no fixed name) | EC2 / ECS behind an Auto Scaling group |

---

## Step 1 — Get the lab source and start the lab

```bash
git clone https://github.com/mohanpothula/aws-saa.git
cd aws-saa/labs/lab-09-well-architected-review
docker compose up -d
docker compose ps
```

---

## Step 2 — Security review

**Task:** Find the published ports.

```bash
docker compose ps
```

**Expected result:** You identify every externally exposed port, including the one on `app` itself.

---

## Step 3 — Reliability review

**Task:** Stop the app and observe the impact.

```bash
docker compose stop app
curl -f http://localhost:8089 || echo 'SERVICE DOWN'
```

**Expected result:** `SERVICE DOWN` — a single instance is a single point of failure.

---

## Step 4 — Improve reliability

**Task:** Scale the app to two replicas behind the proxy.

```bash
docker compose start app
docker compose up -d --scale app=2
```

**Expected result:** Two `app` containers are running.

---

## Step 5 — Performance review

**Task:** Run 50 requests.

```bash
for i in $(seq 1 50); do curl -s http://localhost:8089 >/dev/null; done
echo done
```

**Expected result:** All requests complete.

---

## Step 6 — Well-Architected findings

**Task:** Document one Security, Reliability, Performance and Cost improvement.

```bash
echo 'Security: ... Reliability: ... Performance: ... Cost: ...'
```

**Expected result:** Four justified findings.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — Security review | You identify every externally exposed port, including the one on `app` itself |
| Step 3 — Reliability review | `SERVICE DOWN` — a single instance is a single point of failure |
| Step 4 — Improve reliability | Two `app` containers are running |
| Step 5 — Performance review | All requests complete |
| Step 6 — Well-Architected findings | Four justified findings |

## Completion check

- [ ] Every validation result demonstrated to the trainer
- [ ] You can say which AWS service each local component represents
- [ ] Your four findings each name a pillar and a concrete change

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-09-well-architected-review
- Original student guide: [`courseware/AWS_SAA_Lab9_Student_Guide.docx`](../../courseware/AWS_SAA_Lab9_Student_Guide.docx)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
- [Well-Architected Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Amazon ECS Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [Docker Compose](https://docs.docker.com/compose/)
- [NGINX proxy module (proxy_pass, proxy_cache)](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)
