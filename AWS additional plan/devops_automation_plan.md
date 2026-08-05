# 🛠️ DevOps Automation Plan — AWS IaC & Configuration Management

This plan specifies the automation architecture using **Terraform** for Infrastructure as Code (IaC) and **Ansible** for configuration management to provision, deploy, and operate the AWS AI RAG backend.

---

## 1. Architectural Automation Flow

```
   [ Developer Commit ] ──► [ GitHub Actions CI/CD ]
                                  │
            ┌─────────────────────┴─────────────────────┐
            ▼ (Infrastructure)                          ▼ (Configuration & Deploy)
    [ Terraform Apply ]                         [ Ansible Playbook ]
            │                                           │
            ▼ (Provisions)                              ▼ (Deploys & Starts)
    - VPC & Networking                          - Inject API Secrets (.env)
    - IAM Bedrock Access                        - Pull ECS Fargate Images
    - OpenSearch Serverless                     - Verify Container Health
    - ECS Cluster & ALB                         - Configure CloudWatch logs
```

---

## 2. Infrastructure as Code (IaC) with Terraform

Terraform will provision a secure, private network and all AWS resources required for the AI backend.

### A. Directory Structure
```
terraform/
├── main.tf                 # Primary orchestrator
├── variables.tf            # Input configuration
├── outputs.tf              # API URLs, cluster IDs
├── modules/
│   ├── vpc/                # Private subnetting
│   ├── iam/                # Bedrock & OpenSearch access roles
│   ├── opensearch/         # OpenSearch Serverless collection
│   └── ecs_fargate/        # ECS Cluster, ALB, Task Definitions
└── terraform.tfvars        # Deployment config (AWS Region, Quota limits)
```

### B. Resources Provisioned
1. **Network**: VPC with 2 public subnets (for ALB) and 2 private subnets (for ECS containers) using NAT Gateways.
2. **Security & IAM**: Least-privilege IAM roles allowing the Fargate containers to invoke:
   * `bedrock:InvokeModel` (for Claude 3.5 Haiku & Sonnet)
   * `polly:SynthesizeSpeech`
   * `transcribe:StartTranscriptionJob`
3. **Database**: **Amazon OpenSearch Serverless** vector collection.
4. **Compute**: **AWS ECS Fargate** cluster running:
   * Service A: `backend-orchestrator` container (exposing port 8000 via ALB).
   * Service B: `kms-core-ai` container (exposing port 8001 internally).

---

## 3. Configuration Management & Deployment with Ansible

Ansible handles the environment configuration, secrets injection, and application lifecycle management on the target nodes.

### A. Directory Structure
```
ansible/
├── group_vars/
│   └── all.yml             # Common variables (model names, ports)
├── inventory.ini           # Deployment target IPs (Staging/Production)
├── deploy_backend.yml      # Primary playbook
└── roles/
    ├── common/             # Docker engine & environment checks
    ├── secrets/            # Decrypts and injects API credentials (.env)
    └── deploy/             # ECS Task updating and health check validations
```

### B. Playbook Operations
1. **System Prep**: Ensure Docker, `aws-cli`, and logging agents are correctly installed and configured.
2. **Secrets Decryption**: Decrypt secret credentials (like `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `OPENAI_API_KEY`) stored securely via **Ansible Vault**, and write them into local container environments.
3. **Deployment Trigger**: Trigger the AWS ECS task definition update, forcing the cluster to pull the latest Docker image tag.
4. **Health Validation**: Poll the gateway health check endpoint (`GET /api/v1/health`) for a successful `200 OK` status, rolling back the deployment if the container fails to start within 60 seconds.

---

## 4. Accelerated CI/CD Pipeline (GitHub Actions)

To ensure smooth operations under the August 10 deadline, the deployment is fully automated on push to the `main` branch:

```yaml
name: Deploy Backend to AWS
on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3

      - name: Terraform Apply
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve

      - name: Setup Ansible
        run: pip install ansible

      - name: Run Ansible Playbook
        run: |
          cd ansible
          ansible-playbook -i inventory.ini deploy_backend.yml --vault-password-file .vault_pass
```
