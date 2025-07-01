#!/usr/bin/env bash

# Change to the directory containing docker-compose.yml
cd /Users/djklim87/Documents/work/msmarko || {
    echo "Failed to change directory"
    exit 1
}

# Number of shards
proc=32

# Maximum number of parallel indexer processes
MAX_PARALLEL=10

# Ensure data directory exists and has correct permissions
echo "Initializing data directory..."
docker exec manticore bash -c "mkdir -p /var/lib/manticore/data && chown manticore:manticore /var/lib/manticore/data && chmod 755 /var/lib/manticore/data"

# Run indexer for all shards with retry logic
echo "Starting indexing for $proc shards..."
docker exec -e proc=$proc -e MAX_PARALLEL=$MAX_PARALLEL manticore bash -c '
failed_shards=""
for attempt in 1 2 3 4 5; do
    current_failed=""
    for n in $(seq 0 $((proc-1))); do
        # Skip shards that already succeeded
        [ -f "/var/lib/manticore/data/msmarco_docs_$n.sph" ] && continue
        if [ $(jobs | wc -l) -ge $MAX_PARALLEL ]; then
            wait -n
        fi
        (indexer --noprogress -c /etc/manticoresearch/manticore.conf msmarco_docs_$n | tee /tmp/msmarco_docs_$n.log || current_failed="$current_failed $n") &
    done
    wait
    if [ -z "$current_failed" ]; then
        break
    fi
    failed_shards="$failed_shards $current_failed"
    echo "Attempt $attempt failed for shards:$current_failed. Retrying..."
done
if [ -n "$failed_shards" ]; then
    echo "Failed shards after retries:$failed_shards" >&2
    exit 1
fi'

# Check exit status
if [ $? -ne 0 ]; then
    echo "Indexing failed for some shards. Check logs in /tmp/msmarco_docs_*.log"
    exit 1
fi

# Check for errors in logs
echo "Checking for indexing errors..."
docker exec manticore bash -c 'grep -i "ERROR" /tmp/msmarco_docs_*.log || echo "No errors found in logs"'

# Restart Manticore service
echo "Restarting Manticore service..."
docker compose restart manticore || {
    echo "Failed to restart Manticore service"
    exit 1
}

echo "Indexing and restart completed successfully"