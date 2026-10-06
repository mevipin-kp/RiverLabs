#!/usr/bin/env bash
set -Eeuo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$repo_dir/cicd/lightsail.env"
if [[ ! -f "$config_file" ]]; then
  echo "Copy cicd/lightsail.env.example to cicd/lightsail.env first." >&2
  exit 1
fi

while IFS= read -r config_line || [[ -n "$config_line" ]]; do
  config_line="${config_line%$'\r'}"
  [[ "$config_line" =~ ^[[:space:]]*$ || "$config_line" =~ ^[[:space:]]*# ]] && continue
  if [[ "$config_line" != *=* ]]; then
    echo "Invalid line in cicd/lightsail.env; expected KEY=value." >&2
    exit 1
  fi
  config_key="${config_line%%=*}"
  config_value="${config_line#*=}"
  case "$config_key" in
    LIGHTSAIL_REGION|LIGHTSAIL_SERVICE_NAME|LIGHTSAIL_POWER|LIGHTSAIL_SCALE) ;;
    *) echo "Unknown setting in cicd/lightsail.env: $config_key" >&2; exit 1 ;;
  esac
  printf -v "$config_key" '%s' "$config_value"
done < "$config_file"

: "${LIGHTSAIL_REGION:?Set LIGHTSAIL_REGION in cicd/lightsail.env}"
: "${LIGHTSAIL_SERVICE_NAME:?Set LIGHTSAIL_SERVICE_NAME in cicd/lightsail.env}"
LIGHTSAIL_POWER="${LIGHTSAIL_POWER:-nano}"
LIGHTSAIL_SCALE="${LIGHTSAIL_SCALE:-1}"
export LIGHTSAIL_REGION LIGHTSAIL_SERVICE_NAME

for command_name in aws docker python3; do
  command -v "$command_name" >/dev/null || { echo "$command_name is required." >&2; exit 1; }
done
command -v lightsailctl >/dev/null || {
  echo "lightsailctl is required. On macOS install it with: brew install aws/tap/lightsailctl" >&2
  exit 1
}
aws_version="$(aws --version 2>&1 || true)"
if [[ "$aws_version" != aws-cli/2.* ]]; then
  echo "AWS CLI v2 is required (found: $aws_version)." >&2
  exit 1
fi
aws sts get-caller-identity --output text >/dev/null

# Pass short-lived AWS CLI credentials to lightsailctl when the CLI uses aws login.
credential_values="$(aws configure export-credentials --format process | python3 -c 'import json,sys; c=json.load(sys.stdin); print("\t".join((c["AccessKeyId"], c["SecretAccessKey"], c.get("SessionToken", ""))))')"
IFS=$'\t' read -r AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN <<< "$credential_values"
export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_DEFAULT_REGION="$LIGHTSAIL_REGION"
if [[ -n "$AWS_SESSION_TOKEN" ]]; then export AWS_SESSION_TOKEN; else unset AWS_SESSION_TOKEN; fi
unset credential_values

if [[ ! "$LIGHTSAIL_SERVICE_NAME" =~ ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$ ]]; then
  echo "LIGHTSAIL_SERVICE_NAME must be lowercase letters, digits, and interior hyphens." >&2
  exit 1
fi
case "$LIGHTSAIL_POWER" in nano|micro|small|medium|large|xlarge) ;; *)
  echo "LIGHTSAIL_POWER must be nano, micro, small, medium, large, or xlarge." >&2; exit 1 ;;
esac
if ! [[ "$LIGHTSAIL_SCALE" =~ ^[1-9][0-9]*$ ]] || (( LIGHTSAIL_SCALE > 20 )); then
  echo "LIGHTSAIL_SCALE must be an integer from 1 to 20." >&2; exit 1
fi

service_json="$(aws lightsail get-container-services --region "$LIGHTSAIL_REGION" --output json)"
service_exists="$(python3 -c 'import json,os,sys; d=json.load(sys.stdin); print(str(any(s["containerServiceName"]==os.environ["LIGHTSAIL_SERVICE_NAME"] for s in d.get("containerServices", []))).lower())' <<< "$service_json")"
if [[ "$service_exists" != true ]]; then
  echo "Creating Lightsail Container Service '$LIGHTSAIL_SERVICE_NAME' ($LIGHTSAIL_POWER, scale $LIGHTSAIL_SCALE)."
  aws lightsail create-container-service \
    --region "$LIGHTSAIL_REGION" --service-name "$LIGHTSAIL_SERVICE_NAME" \
    --power "$LIGHTSAIL_POWER" --scale "$LIGHTSAIL_SCALE" >/dev/null
  for attempt in {1..60}; do
    state="$(aws lightsail get-container-services --region "$LIGHTSAIL_REGION" --query "containerServices[?containerServiceName=='$LIGHTSAIL_SERVICE_NAME']|[0].state" --output text)"
    [[ "$state" == READY || "$state" == RUNNING ]] && break
    if [[ "$state" == None || "$state" == FAILED ]]; then echo "Service creation reached unexpected state: $state" >&2; exit 1; fi
    sleep 10
  done
  if [[ "${state:-}" != READY && "${state:-}" != RUNNING ]]; then echo "Timed out waiting for Lightsail Container Service." >&2; exit 1; fi
fi

"$repo_dir/cicd/build-release.sh"
stamp="$(date -u +%Y%m%d%H%M%S)"
label="riverlabs-$stamp"
aws lightsail push-container-image --region "$LIGHTSAIL_REGION" \
  --service-name "$LIGHTSAIL_SERVICE_NAME" --label "$label" \
  --image riverlabs-web:production >/dev/null

image_ref="$(aws lightsail get-container-images --region "$LIGHTSAIL_REGION" --service-name "$LIGHTSAIL_SERVICE_NAME" --query "containerImages[?contains(image, '$label')].image | [0]" --output text)"
if [[ -z "$image_ref" || "$image_ref" == None ]]; then echo "Could not register the pushed RiverLabs image." >&2; exit 1; fi

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
chmod 700 "$work_dir"
python3 - "$work_dir/containers.json" "$work_dir/endpoint.json" "$image_ref" <<'PY'
import json
import sys

containers_path, endpoint_path, image = sys.argv[1:]
with open(containers_path, "w", encoding="utf-8") as stream:
    json.dump({"riverlabs": {"image": image, "ports": {"8000": "HTTP"}}}, stream)
with open(endpoint_path, "w", encoding="utf-8") as stream:
    json.dump({"containerName": "riverlabs", "containerPort": 8000, "healthCheck": {
        "path": "/api/health", "successCodes": "200-399", "healthyThreshold": 2,
        "unhealthyThreshold": 5, "timeoutSeconds": 10, "intervalSeconds": 30,
    }}, stream)
PY
chmod 600 "$work_dir/containers.json" "$work_dir/endpoint.json"

prior_version="$(aws lightsail get-container-services --region "$LIGHTSAIL_REGION" --query "containerServices[?containerServiceName=='$LIGHTSAIL_SERVICE_NAME']|[0].currentDeployment.version" --output text)"
prior_version="${prior_version:-None}"
echo "Submitting the RiverLabs deployment."
aws lightsail create-container-service-deployment --region "$LIGHTSAIL_REGION" \
  --service-name "$LIGHTSAIL_SERVICE_NAME" \
  --containers "file://$work_dir/containers.json" \
  --public-endpoint "file://$work_dir/endpoint.json" >/dev/null

for attempt in {1..90}; do
  service_json="$(aws lightsail get-container-services --region "$LIGHTSAIL_REGION" --output json)"
  deployment_info="$(python3 -c 'import json,sys; d=json.load(sys.stdin); s=next((x for x in d.get("containerServices",[]) if x["containerServiceName"]==sys.argv[1]),{}); c=s.get("currentDeployment") or {}; n=s.get("nextDeployment") or {}; print(c.get("state", "UNKNOWN"), c.get("version", "None"), n.get("state", "None"))' "$LIGHTSAIL_SERVICE_NAME" <<< "$service_json")"
  read -r deployment_state current_version next_state <<< "$deployment_info"
  if [[ "$deployment_state" == ACTIVE && "$current_version" != "$prior_version" ]]; then break; fi
  if [[ "$deployment_state" == FAILED || "$next_state" == FAILED ]]; then echo "Deployment failed; inspect the Lightsail container logs." >&2; exit 1; fi
  sleep 10
done
if [[ "${deployment_state:-}" != ACTIVE || "${current_version:-None}" == "$prior_version" ]]; then
  echo "Timed out waiting for the deployment; check its status and logs in Lightsail." >&2
  exit 1
fi

service_url="$(python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((x.get("url", "") for x in d.get("containerServices",[]) if x["containerServiceName"]==sys.argv[1]), ""))' "$LIGHTSAIL_SERVICE_NAME" <<< "$service_json")"
echo "RiverLabs deployment is active: $service_url"
