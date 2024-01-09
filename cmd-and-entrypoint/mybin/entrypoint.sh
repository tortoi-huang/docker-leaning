#!/bin/bash
echo "entrypoint: $@"

whoami

while true; do 
  sleep 5
  echo "entrypoint running"
done