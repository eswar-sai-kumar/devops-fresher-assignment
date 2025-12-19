#!/bin/bash
set -e

NAMESPACE=$1
IMAGE_TAG=$2

# 1. Update Kubeconfig to talk to EKS
aws eks update-kubeconfig --name expense-eks --region us-east-1

# 2. Get the AWS Account ID dynamically
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 3. Create Namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# 4. Replace Placeholders in deployment.yaml
# We use a temporary file to avoid overwriting the original for subsequent jobs
sed -e "s/\${AWS_ACCOUNT_ID}/$ACCOUNT_ID/g" \
    -e "s/\${AWS_REGION}/us-east-1/g" \
    -e "s/\${IMAGE_TAG}/$IMAGE_TAG/g" \
    kubernetes/deployment.yaml > deployment_ready.yaml

# 5. Apply the manifest
kubectl apply -f deployment_ready.yaml -n $NAMESPACE

echo "Successfully deployed to $NAMESPACE"