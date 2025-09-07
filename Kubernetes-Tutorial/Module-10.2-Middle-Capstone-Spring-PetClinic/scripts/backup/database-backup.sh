#!/bin/bash

# Database backup script for Spring PetClinic
NAMESPACE="petclinic"
BACKUP_DIR="/tmp/petclinic-backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

echo "🗄️ Starting database backup..."

# Backup customers database
kubectl exec -n $NAMESPACE mysql-customers-0 -- mysqldump -u root -prootpassword123 petclinic > $BACKUP_DIR/customers_$DATE.sql

# Backup vets database  
kubectl exec -n $NAMESPACE mysql-vets-0 -- mysqldump -u root -prootpassword123 petclinic > $BACKUP_DIR/vets_$DATE.sql

# Backup visits database
kubectl exec -n $NAMESPACE mysql-visits-0 -- mysqldump -u root -prootpassword123 petclinic > $BACKUP_DIR/visits_$DATE.sql

echo "✅ Backup completed: $BACKUP_DIR"
ls -la $BACKUP_DIR/*$DATE.sql
