#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
cat > infra/docker/Dockerfile <<'EOF'
FROM python:3.12-slim
WORKDIR /app
COPY app /app/app
RUN useradd -r -u 1001 runner
USER runner
EXPOSE 8080
ENTRYPOINT ["python", "-m", "app"]
EOF
cat > infra/k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
      containers:
      - name: app
        image: app:0.1.0
        ports:
        - containerPort: 8080
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
EOF
cat > infra/terraform/main.tf <<'EOF'
variable "region" { default = "us-east-1" }
variable "replicas" { default = 2 }
output "region" { value = var.region }
output "replicas" { value = var.replicas }
EOF
