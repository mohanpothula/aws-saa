# Lab 01 — IAM & Account Security Design

Practise IAM users, groups, roles, least-privilege policies and explicit DENY against a local IAM and S3 emulator — no AWS account needed.

**Lab environment:** Docker Desktop + LocalStack — runs locally, no AWS account needed  
**Estimated time:** 35–40 minutes  
**SAA-C03 domain:** Design Secure Architectures

---

## Overview

| Local component | AWS equivalent |
|---|---|
| `dev1`, `operator1`, `auditor1` | IAM users |
| `Developers`, `Operators`, `ReadOnly` | IAM groups |
| `DeveloperS3ReadOnly` (with `ExplicitDenyDelete`) | Customer-managed IAM policy |
| `AppRole` (trusted by EC2) | IAM role for an application |
| `lab1-secure-data` | Amazon S3 bucket |

> These resources are created automatically by `scripts/init-aws.sh` when LocalStack starts. MFA, IAM Access Analyzer, CloudTrail and Organizations/SCPs are outside the scope of this local lab.

---

## Step 1 — Get the lab source and start the lab

```bash
git clone https://github.com/mohanpothula/aws-saa.git
cd aws-saa/labs/lab-01-iam-account-security
docker compose up -d
# wait for the init script to finish creating the IAM resources
until docker compose logs localstack 2>&1 | grep -q "created successfully"; do sleep 2; done; echo READY
docker exec -it aws-saa-lab1 bash
```

> LocalStack reports *healthy* several seconds before its init script has finished creating the users and groups. Wait for `READY` before running the exercises, or `list-users` may come back empty. Every command below runs **inside** the container.

---

## Step 2 — Inspect the IAM environment

**Task:** Identify the existing users, groups and roles.

```bash
awslocal iam list-users --query 'Users[].UserName'
awslocal iam list-groups --query 'Groups[].GroupName'
awslocal iam list-roles --query 'Roles[].RoleName'
```

**Expected result:** Users `dev1`, `operator1`, `auditor1`; groups `Developers`, `Operators`, `ReadOnly`; role `AppRole`.

---

## Step 3 — Create a student identity

**Task:** Create `student1` and `LabDevelopers`, then assign membership.

```bash
awslocal iam create-user --user-name student1
awslocal iam create-group --group-name LabDevelopers
awslocal iam add-user-to-group --user-name student1 --group-name LabDevelopers
awslocal iam list-groups-for-user --user-name student1
```

**Expected result:** `LabDevelopers` is shown for `student1`.

---

## Step 4 — Create a least-privilege policy

**Task:** Allow only `s3:ListBucket` and `s3:GetObject`.

```bash
cat >/tmp/student-s3-policy.json <<'EOF'
{"Version":"2012-10-17","Statement":[
{"Effect":"Allow","Action":"s3:ListBucket","Resource":"arn:aws:s3:::lab1-secure-data"},
{"Effect":"Allow","Action":"s3:GetObject","Resource":"arn:aws:s3:::lab1-secure-data/*"}]}
EOF
awslocal iam create-policy --policy-name StudentS3ReadOnly --policy-document file:///tmp/student-s3-policy.json
```

**Expected result:** `StudentS3ReadOnly` appears under local policies.

---

## Step 5 — Attach the policy

**Task:** Attach the read-only policy to `LabDevelopers`.

```bash
POLICY_ARN=$(awslocal iam list-policies --scope Local --query "Policies[?PolicyName=='StudentS3ReadOnly'].Arn | [0]" --output text)
awslocal iam attach-group-policy --group-name LabDevelopers --policy-arn "$POLICY_ARN"
awslocal iam list-attached-group-policies --group-name LabDevelopers
```

**Expected result:** `StudentS3ReadOnly` is attached.

---

## Step 6 — Explicit DENY challenge

**Task:** Inspect the existing Developers policy and locate the `DeleteObject` DENY.

```bash
awslocal iam get-policy-version --policy-arn $(awslocal iam list-policies --scope Local --query "Policies[?PolicyName=='DeveloperS3ReadOnly'].Arn | [0]" --output text) --version-id v1
```

**Expected result:** You identify the `ExplicitDenyDelete` statement and can explain why an explicit DENY always wins over any ALLOW.

---

## Verification

| Check | Expected |
|---|---|
| Step 2 — Inspect the IAM environment | Users `dev1`, `operator1`, `auditor1`; groups `Developers`, `Operators`, `ReadOnly`; role `AppRole` |
| Step 3 — Create a student identity | `LabDevelopers` is shown for `student1` |
| Step 4 — Create a least-privilege policy | `StudentS3ReadOnly` appears under local policies |
| Step 5 — Attach the policy | `StudentS3ReadOnly` is attached |
| Step 6 — Explicit DENY challenge | You identify the `ExplicitDenyDelete` statement and can explain why an explicit DENY always wins over any ALLOW |

## Completion check

- [ ] `student1` and `LabDevelopers` created
- [ ] Least-privilege S3 policy attached
- [ ] You can explain user vs group vs role
- [ ] You can explain explicit DENY

---

## Cleanup

```bash
docker compose down -v
```

`-v` also removes the lab's volumes, so the next run starts from a clean state.

---

## Reference

- Lab source code: https://github.com/mohanpothula/aws-saa/tree/main/labs/lab-01-iam-account-security
- Original student guide: [`courseware/AWS_SAA_Lab1_Student_Guide.docx`](../../courseware/AWS_SAA_Lab1_Student_Guide.docx)
- [AWS IAM User Guide](https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html)
- [IAM security best practices (least privilege)](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [IAM policy evaluation logic (explicit deny)](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- [IAM roles](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html)
- [Amazon S3 User Guide](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html)
- [LocalStack documentation](https://docs.localstack.cloud/)
- [LocalStack initialization hooks](https://docs.localstack.cloud/references/init-hooks/)
- [awslocal (AWS CLI wrapper for LocalStack)](https://github.com/localstack/awscli-local)
