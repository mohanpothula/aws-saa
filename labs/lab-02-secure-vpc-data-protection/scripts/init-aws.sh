#!/bin/bash
set -euo pipefail

echo "=== LAB 2: Secure VPC & Data Protection ==="

echo "Creating KMS key..."
KEY_ID=$(awslocal kms create-key \
  --description "LAB2 S3 encryption key" \
  --query 'KeyMetadata.KeyId' --output text)

awslocal kms create-alias \
  --alias-name alias/lab2-s3-key \
  --target-key-id "$KEY_ID"

echo "Creating encrypted S3 bucket..."
awslocal s3api create-bucket --bucket lab2-secure-data

awslocal s3api put-bucket-encryption \
  --bucket lab2-secure-data \
  --server-side-encryption-configuration "{
    \"Rules\": [{
      \"ApplyServerSideEncryptionByDefault\": {
        \"SSEAlgorithm\": \"aws:kms\",
        \"KMSMasterKeyID\": \"$KEY_ID\"
      }
    }]
  }"

echo "Secure LAB2 object" >/tmp/secure.txt
awslocal s3 cp /tmp/secure.txt s3://lab2-secure-data/secure.txt

echo
echo "=== KMS KEY ==="
awslocal kms list-aliases \
  --query "Aliases[?AliasName=='alias/lab2-s3-key'].[AliasName,TargetKeyId]"

echo
echo "=== S3 ENCRYPTION ==="
awslocal s3api get-bucket-encryption --bucket lab2-secure-data

echo
echo "=== S3 OBJECTS ==="
awslocal s3 ls s3://lab2-secure-data

echo
echo "LAB 2 AWS-style resources created successfully."
