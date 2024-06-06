#!/bin/bash
docker compose down
docker compose -f lgtm.yml down

rm -rf grafana_data/ loki-data/ pg_data/ prometheus_data/ tempo-data/

