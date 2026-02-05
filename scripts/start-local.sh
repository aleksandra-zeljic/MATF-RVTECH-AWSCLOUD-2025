#!/usr/bin/env bash
set -euo pipefail

export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:-test}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:-test}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
export AWS_PAGER=""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_DIR"

echo "[start-local] Checking LocalStack..."
if ! docker ps --format '{{.Names}}' | grep -q '^moj-rvtech-localstack$'; then
  echo "[start-local] LocalStack not running, starting..."
  npm run up
fi

echo "[start-local] Waiting for LocalStack health..."
for i in {1..30}; do
  status="$(curl -s -o /dev/null -w "%{http_code}" http://localhost:4566/health || true)"
  if [[ "$status" == "200" ]]; then
    echo "[start-local] LocalStack is healthy."
    break
  fi
  sleep 2
done

echo "[start-local] Deploying backend..."
npm run deploy

echo "[start-local] Updating API ID..."
npm run update-api-id

echo "[start-local] Ensuring API Gateway stage..."
API_ID="$(node -e "const fs=require('fs');const html=fs.readFileSync('web/index.html','utf8');const m=html.match(/const API_ID\\s*=\\s*\"([a-z0-9]+)\"/i);if(m)console.log(m[1]);")"
if [[ -n "${API_ID}" ]]; then
  if ! aws --endpoint-url=http://localhost:4566 apigateway get-stages --rest-api-id "${API_ID}" --region "${AWS_DEFAULT_REGION}" | grep -q '"stageName"'; then
    aws --endpoint-url=http://localhost:4566 apigateway create-deployment --rest-api-id "${API_ID}" --stage-name dev --region "${AWS_DEFAULT_REGION}" >/dev/null
  fi
fi

echo "[start-local] Deploying frontend..."
npm run deploy-frontend

APP_URL="http://punjaci-website-rvtech.s3-website.localhost.localstack.cloud:4566"
echo "[start-local] App URL: ${APP_URL}"

if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "${APP_URL}" >/dev/null 2>&1 || true
else
  echo "[start-local] xdg-open nije dostupno; otvori link ručno."
fi

echo "[start-local] Done."
