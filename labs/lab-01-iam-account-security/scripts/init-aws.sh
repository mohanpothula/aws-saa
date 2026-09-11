#!/bin/bash
set -euo pipefail

echo "=== LAB 1: IAM & Account Security Design ==="

awslocal iam create-group --group-name Developers
awslocal iam create-group --group-name Operators
awslocal iam create-group --group-name ReadOnly

awslocal iam create-user --user-name dev1
awslocal iam create-user --user-name operator1
awslocal iam create-user --user-name auditor1

awslocal iam add-user-to-group --user-name dev1 --group-name Developers
awslocal iam add-user-to-group --user-name operator1 --group-name Operators
awslocal iam add-user-to-group --user-name auditor1 --group-name ReadOnly

awslocal s3 mb s3://lab1-secure-data
echo "Confidential Training Data" >/tmp/secret.txt
awslocal s3 cp /tmp/secret.txt s3://lab1-secure-data/secret.txt

cat >/tmp/developer-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ListBucket",
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::lab1-secure-data"
    },
    {
      "Sid": "ReadObjects",
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::lab1-secure-data/*"
    },
    {
      "Sid": "ExplicitDenyDelete",
      "Effect": "Deny",
      "Action": "s3:DeleteObject",
      "Resource": "arn:aws:s3:::lab1-secure-data/*"
    }
  ]
}
EOF

POLICY_ARN=$(awslocal iam create-policy \
  --policy-name DeveloperS3ReadOnly \
  --policy-document file:///tmp/developer-policy.json \
  --query 'Policy.Arn' --output text)

awslocal iam attach-group-policy \
  --group-name Developers \
  --policy-arn "$POLICY_ARN"

cat >/tmp/trust-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

awslocal iam create-role \
  --role-name AppRole \
  --assume-role-policy-document file:///tmp/trust-policy.json

cat >/tmp/app-role-policy.json <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::lab1-secure-data"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::lab1-secure-data/*"
    }
  ]
}
EOF

awslocal iam put-role-policy \
  --role-name AppRole \
  --policy-name AppS3ReadOnly \
  --policy-document file:///tmp/app-role-policy.json

echo
echo "=== USERS ==="
awslocal iam list-users --query 'Users[].UserName'

echo "=== GROUPS ==="
awslocal iam list-groups --query 'Groups[].GroupName'

echo "=== ROLES ==="
awslocal iam list-roles --query 'Roles[].RoleName'

echo "=== S3 ==="
awslocal s3 ls s3://lab1-secure-data

echo
echo "LAB 1 resources created successfully."
