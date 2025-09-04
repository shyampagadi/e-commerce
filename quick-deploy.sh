#!/bin/bash
# Quick deployment script for different environments

ENV=${1:-dev}

case $ENV in
  "dev")
    echo "🚀 Starting development environment..."
    docker-compose -f docker-compose.dev.yml up -d
    ;;
  "prod")
    echo "🚀 Starting production environment..."
    docker-compose -f docker-compose.prod.yml up -d
    ;;
  "k8s")
    echo "🚀 Deploying to Kubernetes..."
    kubectl apply -f k8s-manifests.yml
    ;;
  "stop")
    echo "🛑 Stopping all environments..."
    docker-compose down
    docker-compose -f docker-compose.dev.yml down
    docker-compose -f docker-compose.prod.yml down
    ;;
  *)
    echo "Usage: $0 {dev|prod|k8s|stop}"
    exit 1
    ;;
esac
