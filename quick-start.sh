#!/bin/bash

echo "Starting kong-database..."

docker compose up -d kong-database

STATUS="starting"

while [ "$STATUS" != "healthy" ]
do
    STATUS=$(docker inspect --format {{.State.Health.Status}} kong-database)
    echo "kong-database state = $STATUS"
    sleep 5
done


echo "Running database migrations..."

docker compose run --rm kong kong migrations bootstrap --vv

echo "Starting kong..."

docker compose up -d kong

echo "Kong admin running http://127.0.0.1:8001/"
echo "Kong proxy running http://127.0.0.1/"

echo "Starting httpbin"
docker compose up -d httpbin

echo "Create Directory"
mkdir -p grafana_data prometheus_data tempo-data && chown -R 472:472 grafana_data && chown -R 65534:65534 prometheus_data && chown -R 10001:10001 tempo-data

echo "Running LGTM"
docker compose -f lgtm.yml up -d

echo "Running Add Services"
curl -i -s -X POST http://localhost:8001/services \
  --data name=httpbin \
  --data url='http://httpbin:80'

curl -i -X POST http://localhost:8001/services/httpbin/routes \
  --data 'paths[]=/' \
  --data name=httpbin_route

echo "Running Add Plugin"
curl -i -X POST http://localhost:8001/plugins \
    --data "name=prometheus"  \
    --data "config.per_consumer=true" \
    --data "config.status_code_metrics=true" \
    --data "config.latency_metrics=true" \
    --data "config.bandwidth_metrics=true" \
    --data "config.upstream_health_metrics=true" 

curl -i -X POST http://localhost:8001/plugins \
    --data "name=tcp-log"  \
    --data "config.host=fluentbit"  \
    --data "config.port=5170"

curl -i -X POST http://localhost:8001/plugins \
    --data "name=zipkin"  \
    --data "config.http_endpoint=http://tempo:9411/api/v2/spans"  \
    --data "config.sample_ratio=1"  \
    --data "config.local_service_name=kong-zipkin" \
    --data "config.http_span_name=method_path" \
    --data "config.include_credential=true"
