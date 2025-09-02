# Mid-Capstone Project 3: Enterprise DevOps Platform
**Modules Combined**: All Modules 1-11 + Advanced Integration

## Project Overview
Build a complete enterprise DevOps platform integrating all learned concepts: Linux administration, Docker fundamentals, advanced Dockerfiles, Nginx configurations, Docker Compose orchestration, AWS deployment, advanced Docker techniques, container services, CI/CD pipelines, monitoring, and multi-language containerization.

## Project Requirements

### Architecture
```
┌─────────────────────────────────────────────────────────────────┐
│                    Enterprise DevOps Platform                   │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │   GitLab    │  │   Jenkins   │  │  SonarQube  │  │  Nexus  │ │
│  │   (SCM)     │  │   (CI/CD)   │  │  (Quality)  │  │ (Repo)  │ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │ Prometheus  │  │   Grafana   │  │    ELK      │  │ Jaeger  │ │
│  │ (Metrics)   │  │ (Dashboards)│  │ (Logging)   │ │(Tracing)│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────┐ │
│  │   Nginx     │  │  Traefik    │  │   Vault     │  │  Consul │ │
│  │(Load Bal.)  │  │ (Gateway)   │  │ (Secrets)   │ │(Service)│ │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Comprehensive Module Integration

### Module 1 (Linux Foundation) - 20 points
**Enterprise Linux Administration**

#### 1. System Configuration (8 points)
```bash
# System hardening and configuration
#!/bin/bash
# system-setup.sh

# Configure timezone and locale
timedatectl set-timezone UTC
localectl set-locale LANG=en_US.UTF-8

# Configure system limits
cat >> /etc/security/limits.conf << EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc 32768
* hard nproc 32768
EOF

# Configure kernel parameters
cat >> /etc/sysctl.conf << EOF
vm.max_map_count=262144
fs.file-max=2097152
net.core.somaxconn=65535
net.ipv4.tcp_max_syn_backlog=65535
EOF

sysctl -p

# Configure log rotation
cat > /etc/logrotate.d/docker-containers << EOF
/var/lib/docker/containers/*/*.log {
    rotate 7
    daily
    compress
    size=1M
    missingok
    delaycompress
    copytruncate
}
EOF
```

#### 2. Security Hardening (6 points)
```bash
# security-hardening.sh
#!/bin/bash

# Configure firewall
ufw --force enable
ufw default deny incoming
ufw default allow outgoing

# Allow specific ports
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 8080/tcp  # Jenkins
ufw allow 9090/tcp  # Prometheus

# Configure fail2ban
apt-get install -y fail2ban
systemctl enable fail2ban
systemctl start fail2ban

# Configure SSH hardening
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

#### 3. Monitoring and Logging (6 points)
```bash
# monitoring-setup.sh
#!/bin/bash

# Configure rsyslog for centralized logging
cat >> /etc/rsyslog.conf << EOF
# Send logs to centralized server
*.* @@logstash:5140
EOF

# Configure log monitoring
cat > /etc/logwatch/conf/logwatch.conf << EOF
Output = mail
Format = html
Encode = base64
MailTo = admin@company.com
MailFrom = logwatch@$(hostname)
EOF

# Setup system monitoring
cat > /usr/local/bin/system-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    echo "$(date): CPU: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)%, Memory: $(free | grep Mem | awk '{printf("%.1f%%", $3/$2 * 100.0)}'), Disk: $(df / | tail -1 | awk '{print $5}')"
    sleep 60
done
EOF

chmod +x /usr/local/bin/system-monitor.sh
```

### Module 2 (Docker Fundamentals) - 20 points
**Advanced Docker Operations**

#### 1. Docker Engine Configuration (8 points)
```json
// /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "live-restore": true,
  "userland-proxy": false,
  "experimental": false,
  "metrics-addr": "0.0.0.0:9323",
  "experimental": true,
  "features": {
    "buildkit": true
  }
}
```

#### 2. Container Management (6 points)
```bash
#!/bin/bash
# container-management.sh

# Container lifecycle management
manage_containers() {
    echo "Managing container lifecycle..."
    
    # Health check all containers
    for container in $(docker ps -q); do
        health=$(docker inspect --format='{{.State.Health.Status}}' $container 2>/dev/null)
        if [ "$health" = "unhealthy" ]; then
            echo "Restarting unhealthy container: $container"
            docker restart $container
        fi
    done
    
    # Clean up stopped containers
    docker container prune -f
    
    # Clean up unused images
    docker image prune -f
    
    # Clean up unused volumes
    docker volume prune -f
    
    # Clean up unused networks
    docker network prune -f
}

# Resource monitoring
monitor_resources() {
    echo "Monitoring container resources..."
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Backup volumes
backup_volumes() {
    echo "Backing up Docker volumes..."
    for volume in $(docker volume ls -q); do
        docker run --rm -v $volume:/data -v $(pwd)/backups:/backup alpine tar czf /backup/$volume-$(date +%Y%m%d).tar.gz -C /data .
    done
}
```

#### 3. Network Management (6 points)
```bash
#!/bin/bash
# network-management.sh

# Create enterprise networks
create_networks() {
    # DMZ network for public services
    docker network create --driver bridge \
        --subnet=172.20.0.0/16 \
        --gateway=172.20.0.1 \
        --opt com.docker.network.bridge.name=dmz-bridge \
        dmz-network
    
    # Internal network for backend services
    docker network create --driver bridge \
        --subnet=172.21.0.0/16 \
        --gateway=172.21.0.1 \
        --internal \
        backend-network
    
    # Management network for monitoring
    docker network create --driver bridge \
        --subnet=172.22.0.0/16 \
        --gateway=172.22.0.1 \
        monitoring-network
}

# Network diagnostics
network_diagnostics() {
    echo "Running network diagnostics..."
    
    # Test connectivity between networks
    docker run --rm --network dmz-network alpine ping -c 3 172.20.0.1
    docker run --rm --network backend-network alpine ping -c 3 172.21.0.1
    
    # Check network configuration
    docker network ls
    docker network inspect dmz-network
}
```

### Module 3 (Dockerfile Mastery) - 25 points
**Production-Grade Container Images**

#### 1. Multi-Stage Enterprise Dockerfiles (10 points)
```dockerfile
# Enterprise Jenkins with plugins
FROM jenkins/jenkins:lts AS base
USER root
RUN apt-get update && apt-get install -y \
    docker.io \
    docker-compose \
    && rm -rf /var/lib/apt/lists/*

FROM base AS plugin-installer
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt

FROM base AS security-hardened
COPY --from=plugin-installer /usr/share/jenkins/ref/plugins /usr/share/jenkins/ref/plugins
COPY jenkins.yaml /var/jenkins_home/casc_configs/jenkins.yaml
COPY security.groovy /usr/share/jenkins/ref/init.groovy.d/security.groovy
USER jenkins
EXPOSE 8080 50000
HEALTHCHECK --interval=30s --timeout=10s --retries=5 \
    CMD curl -f http://localhost:8080/login || exit 1

# Enterprise GitLab with custom configuration
FROM gitlab/gitlab-ce:latest AS gitlab-base
COPY gitlab.rb /etc/gitlab/gitlab.rb
COPY ssl/ /etc/gitlab/ssl/

FROM gitlab-base AS gitlab-production
RUN gitlab-ctl reconfigure
EXPOSE 80 443 22
HEALTHCHECK --interval=60s --timeout=30s --retries=3 \
    CMD gitlab-healthcheck --fail || exit 1
VOLUME ["/var/opt/gitlab", "/var/log/gitlab", "/etc/gitlab"]

# Enterprise monitoring stack
FROM prom/prometheus:latest AS prometheus-base
COPY prometheus.yml /etc/prometheus/prometheus.yml
COPY rules/ /etc/prometheus/rules/

FROM prometheus-base AS prometheus-production
USER nobody
EXPOSE 9090
VOLUME ["/prometheus"]
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:9090/-/healthy || exit 1
```

#### 2. Security-First Images (8 points)
```dockerfile
# Security scanner integration
FROM alpine:3.18 AS security-base
RUN apk add --no-cache ca-certificates tzdata
RUN adduser -D -s /bin/sh -u 1001 appuser

FROM aquasec/trivy:latest AS scanner
WORKDIR /app
COPY . .
RUN trivy fs --exit-code 1 --severity HIGH,CRITICAL .

FROM security-base AS hardened-app
COPY --from=scanner /app /app
USER appuser
WORKDIR /app
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/health || exit 1

# Distroless production image
FROM gcr.io/distroless/java:11 AS distroless-app
COPY --from=maven:3.8-openjdk-11 /app/target/app.jar /app.jar
USER 1001
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "/app.jar"]
```

#### 3. Performance Optimized Images (7 points)
```dockerfile
# Performance-optimized Node.js
FROM node:18-alpine AS node-base
RUN apk add --no-cache --virtual .build-deps python3 make g++
WORKDIR /app

FROM node-base AS dependencies
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production --no-audit --no-fund
RUN apk del .build-deps

FROM node:18-alpine AS runtime
RUN apk add --no-cache dumb-init
COPY --from=dependencies /app/node_modules ./node_modules
COPY . .
USER 1001
EXPOSE 3000
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.js"]

# Performance-optimized Go service
FROM golang:1.21-alpine AS go-builder
RUN apk add --no-cache git ca-certificates
WORKDIR /app
COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod go mod download
COPY . .
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o app .

FROM scratch AS go-runtime
COPY --from=go-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=go-builder /app/app /app
USER 1001
EXPOSE 8080
ENTRYPOINT ["/app"]
```

### Module 4 (Nginx Mastery) - 20 points
**Enterprise Load Balancing and Security**

#### 1. Advanced Load Balancing (8 points)
```nginx
# nginx/enterprise-lb.conf
upstream jenkins_backend {
    least_conn;
    server jenkins-1:8080 max_fails=3 fail_timeout=30s weight=3;
    server jenkins-2:8080 max_fails=3 fail_timeout=30s weight=2;
    server jenkins-3:8080 max_fails=3 fail_timeout=30s weight=1 backup;
}

upstream gitlab_backend {
    ip_hash;  # Session persistence for GitLab
    server gitlab-1:80 max_fails=2 fail_timeout=60s;
    server gitlab-2:80 max_fails=2 fail_timeout=60s;
}

upstream monitoring_backend {
    server prometheus:9090;
    server grafana:3000;
    server kibana:5601;
}

# Rate limiting zones
limit_req_zone $binary_remote_addr zone=jenkins:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=gitlab:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=api:10m rate=20r/s;

server {
    listen 80;
    server_name devops.company.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name devops.company.com;
    
    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=63072000" always;
    add_header X-Frame-Options SAMEORIGIN always;
    add_header X-Content-Type-Options nosniff always;
    add_header Referrer-Policy strict-origin-when-cross-origin always;
    
    location /jenkins/ {
        limit_req zone=jenkins burst=20 nodelay;
        proxy_pass http://jenkins_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    location /gitlab/ {
        limit_req zone=gitlab burst=10 nodelay;
        proxy_pass http://gitlab_backend/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### 2. Caching and Performance (6 points)
```nginx
# nginx/caching.conf
proxy_cache_path /var/cache/nginx/static levels=1:2 keys_zone=static_cache:10m max_size=1g inactive=60m;
proxy_cache_path /var/cache/nginx/api levels=1:2 keys_zone=api_cache:10m max_size=500m inactive=30m;

server {
    location ~* \.(jpg|jpeg|png|gif|ico|css|js)$ {
        proxy_cache static_cache;
        proxy_cache_valid 200 302 24h;
        proxy_cache_valid 404 1m;
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header X-Cache-Status $upstream_cache_status;
    }
    
    location /api/ {
        proxy_cache api_cache;
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_lock on;
        add_header X-Cache-Status $upstream_cache_status;
    }
}
```

#### 3. Security and WAF (6 points)
```nginx
# nginx/security.conf
# ModSecurity WAF rules
load_module modules/ngx_http_modsecurity_module.so;

http {
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsec/main.conf;
    
    # DDoS protection
    limit_conn_zone $binary_remote_addr zone=conn_limit_per_ip:10m;
    limit_req_zone $binary_remote_addr zone=req_limit_per_ip:10m rate=5r/s;
    
    server {
        # Connection limits
        limit_conn conn_limit_per_ip 10;
        limit_req zone=req_limit_per_ip burst=10 nodelay;
        
        # Block common attacks
        location ~* (eval\(|javascript:|vbscript:|onload=) {
            return 403;
        }
        
        # Block SQL injection attempts
        location ~* (union.*select|select.*from|insert.*into|delete.*from) {
            return 403;
        }
        
        # Block file inclusion attacks
        location ~* (\.\.\/|\.\.\\) {
            return 403;
        }
    }
}
```

### Module 5 (Docker Compose) - 15 points
**Enterprise Orchestration**

#### 1. Production Compose Stack (15 points)
```yaml
# docker-compose.enterprise.yml
version: '3.8'

x-logging: &default-logging
  driver: json-file
  options:
    max-size: "10m"
    max-file: "3"
    labels: "service,environment"

x-deploy: &default-deploy
  restart_policy:
    condition: on-failure
    delay: 5s
    max_attempts: 3
  update_config:
    parallelism: 1
    delay: 30s
    failure_action: rollback
    monitor: 60s

services:
  # Load Balancer
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/enterprise-lb.conf:/etc/nginx/nginx.conf:ro
      - ./nginx/ssl:/etc/nginx/ssl:ro
      - nginx_cache:/var/cache/nginx
    networks:
      - dmz-network
      - backend-network
    logging: *default-logging
    deploy:
      <<: *default-deploy
      resources:
        limits:
          cpus: '0.50'
          memory: 512M
    healthcheck:
      test: ["CMD", "nginx", "-t"]
      interval: 30s

  # CI/CD Services
  jenkins:
    build: ./jenkins
    environment:
      - JAVA_OPTS=-Xmx2g -Xms1g
      - JENKINS_OPTS=--httpPort=8080
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - backend-network
    logging: *default-logging
    deploy:
      <<: *default-deploy
      resources:
        limits:
          cpus: '2.0'
          memory: 4G
        reservations:
          cpus: '1.0'
          memory: 2G

  gitlab:
    image: gitlab/gitlab-ce:latest
    hostname: gitlab.company.com
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'https://gitlab.company.com'
        nginx['listen_port'] = 80
        nginx['listen_https'] = false
    volumes:
      - gitlab_config:/etc/gitlab
      - gitlab_logs:/var/log/gitlab
      - gitlab_data:/var/opt/gitlab
    networks:
      - backend-network
    logging: *default-logging
    deploy:
      <<: *default-deploy
      resources:
        limits:
          cpus: '4.0'
          memory: 8G

  # Quality and Security
  sonarqube:
    image: sonarqube:community
    environment:
      - SONAR_JDBC_URL=jdbc:postgresql://postgres:5432/sonar
      - SONAR_JDBC_USERNAME=sonar
      - SONAR_JDBC_PASSWORD_FILE=/run/secrets/sonar_db_password
    secrets:
      - sonar_db_password
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
    networks:
      - backend-network
      - database-network
    logging: *default-logging
    deploy: *default-deploy

  # Monitoring Stack
  prometheus:
    image: prom/prometheus:latest
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention.time=30d'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
      - '--web.enable-lifecycle'
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - ./prometheus/rules:/etc/prometheus/rules:ro
      - prometheus_data:/prometheus
    networks:
      - monitoring-network
      - backend-network
    logging: *default-logging
    deploy: *default-deploy

  grafana:
    image: grafana/grafana:latest
    environment:
      - GF_SECURITY_ADMIN_PASSWORD_FILE=/run/secrets/grafana_admin_password
      - GF_INSTALL_PLUGINS=grafana-piechart-panel,grafana-worldmap-panel
    secrets:
      - grafana_admin_password
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning:ro
    networks:
      - monitoring-network
    logging: *default-logging
    deploy: *default-deploy

  # ELK Stack
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - logging-network
    logging: *default-logging
    deploy:
      <<: *default-deploy
      resources:
        limits:
          cpus: '2.0'
          memory: 4G

  logstash:
    image: logstash:8.8.0
    volumes:
      - ./logstash/logstash.conf:/usr/share/logstash/pipeline/logstash.conf:ro
    environment:
      - "LS_JAVA_OPTS=-Xmx1g -Xms1g"
    networks:
      - logging-network
    logging: *default-logging
    deploy: *default-deploy
    depends_on:
      - elasticsearch

  kibana:
    image: kibana:8.8.0
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    networks:
      - logging-network
      - backend-network
    logging: *default-logging
    deploy: *default-deploy
    depends_on:
      - elasticsearch

secrets:
  sonar_db_password:
    external: true
  grafana_admin_password:
    external: true

volumes:
  nginx_cache:
  jenkins_home:
  gitlab_config:
  gitlab_logs:
  gitlab_data:
  sonarqube_data:
  sonarqube_extensions:
  prometheus_data:
  grafana_data:
  elasticsearch_data:

networks:
  dmz-network:
    external: true
  backend-network:
    external: true
  monitoring-network:
    external: true
  logging-network:
    driver: bridge
    internal: true
  database-network:
    driver: bridge
    internal: true
```

## Implementation Timeline: 10 Days

### Days 1-2: Infrastructure Setup
- Linux system configuration and hardening
- Docker engine optimization
- Network and security setup

### Days 3-4: Core Services Development
- Jenkins configuration and plugins
- GitLab setup and integration
- SonarQube and Nexus deployment

### Days 5-6: Monitoring and Logging
- Prometheus and Grafana setup
- ELK stack configuration
- Custom dashboards and alerts

### Days 7-8: Load Balancing and Security
- Advanced Nginx configurations
- SSL/TLS implementation
- WAF and security rules

### Days 9-10: Integration and Testing
- Complete system integration
- Performance testing and optimization
- Documentation and presentation

## Deliverables (100 points total)

### 1. Complete DevOps Platform (40 points)
- Fully functional CI/CD pipeline
- Integrated monitoring and logging
- Security and compliance features
- High availability configuration

### 2. Advanced Configurations (35 points)
- Production-grade Dockerfiles
- Enterprise Nginx setup
- Complex Docker Compose orchestration
- Security hardening implementation

### 3. Documentation and Testing (25 points)
- Comprehensive architecture documentation
- Deployment and operation guides
- Automated testing and validation
- Performance benchmarks and optimization

## Success Criteria
- All services operational and integrated
- CI/CD pipeline functional end-to-end
- Monitoring and alerting working
- Security scans passing
- Performance targets met
- Zero-downtime deployment capability
- Complete disaster recovery procedures

This enterprise capstone project demonstrates mastery of all five modules in a real-world, production-ready DevOps platform implementation.
