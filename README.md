# AWS Solutions Architect – Associate: Local Docker Labs

Ten hands-on labs that simulate core AWS architecture patterns on your own laptop with Docker Compose and LocalStack — free to run, no AWS account and no cloud bill.

| Detail | Information |
|---|---|
| Certification | [AWS Certified Solutions Architect – Associate (SAA-C03)](https://aws.amazon.com/certification/certified-solutions-architect-associate/) |
| Labs | 10 guided labs, each with its own Docker Compose stack |
| Guided lab time | About 6.5 hours (35–40 minutes per lab) |
| Lab environment | Docker Desktop on Windows, macOS or Linux |
| Cost | Free — everything runs locally |

## About the labs

Each lab reproduces one Solutions Architect design decision with open-source stand-ins for AWS services: LocalStack for IAM, S3 and KMS; NGINX and HAProxy for load balancing, failover and edge caching; MariaDB, Redis and MinIO for RDS, ElastiCache and S3; RabbitMQ and Redis Streams for queues and streams.

Learners start a stack, perform the exercises, deliberately break something, and validate every result. Each lab maps every local component to the AWS service it stands in for, so the skills transfer directly to the real console.

> These are local simulations for learning architecture patterns. Docker networks, NGINX and LocalStack approximate AWS behaviour; they do not reproduce VPC routing, IAM enforcement, managed-service SLAs or pricing exactly.

## Learning outcomes

By the end of the labs, learners will be able to:

- design least-privilege IAM identities and explain why an explicit DENY always wins;
- separate public, private and isolated tiers and troubleshoot connectivity between them;
- encrypt data at rest with KMS-managed keys;
- decouple services with load balancers, path-based routing and message queues;
- design failover, measure recovery time and back up a database;
- choose between relational, in-memory and object storage for a given workload;
- size compute and recognise when function-style or batch execution fits better;
- use edge caching and event streams, and reason about behaviour when an origin fails;
- find idle capacity, tier cold data and right-size services; and
- review an architecture against the AWS Well-Architected pillars.

## Exam domain coverage

| SAA-C03 domain | Labs |
|---|---|
| Design Secure Architectures | 1, 2 |
| Design Resilient Architectures | 3, 4 |
| Design High-Performing Architectures | 5, 6, 7 |
| Design Cost-Optimized Architectures | 8, 9 |
| All four domains | 9, 10 |

## Labs

| # | Lab | Time | Focus |
|---|---|---|---|
| 1 | [IAM & Account Security Design](labs/lab-01-iam-account-security/lab.md) | 40 min | IAM users, groups, roles, least privilege, explicit DENY |
| 2 | [Secure VPC & Data Protection](labs/lab-02-secure-vpc-data-protection/lab.md) | 40 min | Public/private/isolated networks, App → DB troubleshooting, SSE-KMS |
| 3 | [Scalable Loosely-Coupled Architecture](labs/lab-03-loosely-coupled-architecture/lab.md) | 40 min | Path-based routing, message queues, failure isolation |
| 4 | [Highly Available & Fault-Tolerant Architecture](labs/lab-04-high-availability-fault-tolerance/lab.md) | 40 min | Failover, RTO measurement, database backup |
| 5 | [High-Performance Storage & Database Selection](labs/lab-05-storage-database-selection/lab.md) | 40 min | Relational vs cache vs object storage selection |
| 6 | [Elastic Compute, Containers & Serverless](labs/lab-06-compute-containers-serverless/lab.md) | 40 min | Container sizing, function-style endpoints, batch workers |
| 7 | [Networking, Edge & Data Ingestion](labs/lab-07-networking-edge-ingestion/lab.md) | 40 min | Edge caching, cache hits, event streams, origin failure |
| 8 | [Cost Optimisation — Storage & Compute](labs/lab-08-cost-optimisation/lab.md) | 40 min | Utilisation, archive tiering, right-sizing |
| 9 | [Well-Architected Review & Cost Controls](labs/lab-09-well-architected-review/lab.md) | 40 min | Well-Architected review: exposure, SPOF, scale-out |
| 10 | [Capstone — Full Multi-Tier Architecture](labs/lab-10-capstone-multi-tier/lab.md) | 40 min | End-to-end five-tier validation and failure recovery |

Total guided lab time: about 400 minutes (6.5 hours).

## Quick start

```bash
git clone https://github.com/mohanpothula/aws-saa.git
cd aws-saa/labs/lab-01-iam-account-security
docker compose up -d
```

Then follow that lab's `lab.md`. Finish every lab with `docker compose down -v` before starting the next.

## Ports

Every lab uses its own ports, so a stack left running will not block the next one — but stopping each lab when you finish keeps memory free.

| Lab | Host port(s) | What is there |
|---|---|---|
| 1 | 4566 | LocalStack (IAM, STS, S3) |
| 2 | 8080, 4567 | Simulated ALB · LocalStack (S3, KMS) |
| 3 | 8083, 15683 | Path-routing load balancer · RabbitMQ console |
| 4 | 8084 | HAProxy failover endpoint |
| 5 | — | `docker exec` only |
| 6 | 8086 | Flask service |
| 7 | 8087 | Caching edge proxy |
| 8 | — | `docker exec` / `docker stats` only |
| 9 | 8089 | Reverse proxy |
| 10 | 8090 | Multi-tier entry point |

## Repository structure

```text
aws-saa/
├── README.md
├── CHANGELOG.md
├── courseware/                  # original editable student guides (.docx)
└── labs/
    └── lab-NN-<topic>/
        ├── lab.md               # step-by-step lab guide
        ├── lab.pdf              # printable lab guide
        ├── docker-compose.yml   # the lab environment
        └── …                    # configs, scripts and app code for that lab
```

## Courseware package

| File | Description |
|---|---|
| [Lab 1 Student Guide (.docx)](courseware/AWS_SAA_Lab1_Student_Guide.docx) | Original editable student guide — IAM & Account Security Design |
| [Lab 2 Student Guide (.docx)](courseware/AWS_SAA_Lab2_Student_Guide.docx) | Original editable student guide — Secure VPC & Data Protection |
| [Lab 3 Student Guide (.docx)](courseware/AWS_SAA_Lab3_Student_Guide.docx) | Original editable student guide — Scalable Loosely-Coupled Architecture |
| [Lab 4 Student Guide (.docx)](courseware/AWS_SAA_Lab4_Student_Guide.docx) | Original editable student guide — Highly Available & Fault-Tolerant Architecture |
| [Lab 5 Student Guide (.docx)](courseware/AWS_SAA_Lab5_Student_Guide.docx) | Original editable student guide — High-Performance Storage & Database Selection |
| [Lab 6 Student Guide (.docx)](courseware/AWS_SAA_Lab6_Student_Guide.docx) | Original editable student guide — Elastic Compute, Containers & Serverless |
| [Lab 7 Student Guide (.docx)](courseware/AWS_SAA_Lab7_Student_Guide.docx) | Original editable student guide — Networking, Edge & Data Ingestion |
| [Lab 8 Student Guide (.docx)](courseware/AWS_SAA_Lab8_Student_Guide.docx) | Original editable student guide — Cost Optimisation — Storage & Compute |
| [Lab 9 Student Guide (.docx)](courseware/AWS_SAA_Lab9_Student_Guide.docx) | Original editable student guide — Well-Architected Review & Cost Controls |
| [Lab 10 Student Guide (.docx)](courseware/AWS_SAA_Lab10_Student_Guide.docx) | Original editable student guide — Capstone — Full Multi-Tier Architecture |

## Prerequisites

- A Windows 10/11, macOS 12+ or Ubuntu 22.04+ laptop with at least 8 GB RAM
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Docker Engine with the Compose plugin), with at least 4 GB of memory allocated under **Settings → Resources** — the LocalStack labs and the five-service capstone are the heaviest
- `git` and `curl` on the command line
- About 3 GB of free disk space for the container images

On Windows, run the labs from Git Bash or WSL so the `curl`, `sleep` and `time` commands work as written.

## Reference documentation

- [AWS Certified Solutions Architect – Associate](https://aws.amazon.com/certification/certified-solutions-architect-associate/)
- [AWS Certified Solutions Architect – Associate (SAA-C03) exam guide](https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html)
- [AWS Well-Architected Framework](https://docs.aws.amazon.com/wellarchitected/latest/framework/welcome.html)
- [AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [What is Amazon VPC?](https://docs.aws.amazon.com/vpc/latest/userguide/what-is-amazon-vpc.html)
- [What is an Application Load Balancer?](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html)
- [Amazon S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- [Amazon RDS User Guide](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Welcome.html)
- [Amazon ElastiCache](https://docs.aws.amazon.com/AmazonElastiCache/latest/dg/WhatIs.html)
- [Amazon CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html)
- [Amazon Kinesis Data Streams](https://docs.aws.amazon.com/streams/latest/dev/introduction.html)
- [Amazon SQS Developer Guide](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/welcome.html)
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/latest/dg/welcome.html)
- [Amazon ECS Developer Guide](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/Welcome.html)
- [Well-Architected Cost Optimization Pillar](https://docs.aws.amazon.com/wellarchitected/latest/cost-optimization-pillar/welcome.html)
- [LocalStack documentation](https://docs.localstack.cloud/)
- [awslocal (AWS CLI wrapper for LocalStack)](https://github.com/localstack/awscli-local)
- [Docker Compose](https://docs.docker.com/compose/)

Each lab's `lab.md` lists the specific AWS and tool documentation for that lab.

Author: [Mohan Pothula](https://github.com/mohanpothula)
