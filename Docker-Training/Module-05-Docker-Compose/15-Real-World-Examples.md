# Real-World Docker Compose Examples

## Table of Contents
1. [E-Commerce Platform](#e-commerce-platform)
2. [Content Management System](#content-management-system)
3. [DevOps Toolchain](#devops-toolchain)
4. [Data Analytics Pipeline](#data-analytics-pipeline)
5. [Microservices Architecture](#microservices-architecture)
6. [Development Environment](#development-environment)

## E-Commerce Platform

### Complete E-Commerce Stack
```yaml
version: '3.8'

services:
  # Frontend (React)
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.prod
    ports:
      - "80:80"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - frontend
    depends_on:
      - api-gateway
    restart: unless-stopped

  # API Gateway
  api-gateway:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./gateway/nginx.conf:/etc/nginx/nginx.conf:ro
    networks:
      - frontend
      - backend
    depends_on:
      - user-service
      - product-service
      - order-service
    restart: unless-stopped

  # User Service
  user-service:
    build: ./services/user
    environment:
      - DATABASE_URL=postgresql://user_svc:${USER_DB_PASS}@user-db:5432/users
      - JWT_SECRET=${JWT_SECRET}
      - REDIS_URL=redis://redis:6379/0
    networks:
      - backend
      - user-db-net
    depends_on:
      user-db:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  # Product Service
  product-service:
    build: ./services/product
    environment:
      - DATABASE_URL=postgresql://product_svc:${PRODUCT_DB_PASS}@product-db:5432/products
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - REDIS_URL=redis://redis:6379/1
    networks:
      - backend
      - product-db-net
      - search-net
    depends_on:
      product-db:
        condition: service_healthy
      elasticsearch:
        condition: service_healthy
    restart: unless-stopped

  # Order Service
  order-service:
    build: ./services/order
    environment:
      - DATABASE_URL=postgresql://order_svc:${ORDER_DB_PASS}@order-db:5432/orders
      - USER_SERVICE_URL=http://user-service:3000
      - PRODUCT_SERVICE_URL=http://product-service:3000
      - PAYMENT_SERVICE_URL=http://payment-service:3000
      - RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672/
    networks:
      - backend
      - order-db-net
      - message-net
    depends_on:
      order-db:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
    restart: unless-stopped

  # Payment Service
  payment-service:
    build: ./services/payment
    environment:
      - DATABASE_URL=postgresql://payment_svc:${PAYMENT_DB_PASS}@payment-db:5432/payments
      - STRIPE_SECRET_KEY=${STRIPE_SECRET_KEY}
      - RABBITMQ_URL=amqp://guest:guest@rabbitmq:5672/
    networks:
      - backend
      - payment-db-net
      - message-net
    depends_on:
      payment-db:
        condition: service_healthy
    restart: unless-stopped

  # Databases
  user-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: user_svc
      POSTGRES_PASSWORD: ${USER_DB_PASS}
    volumes:
      - user_db_data:/var/lib/postgresql/data
    networks:
      - user-db-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user_svc -d users"]
      interval: 30s
    restart: unless-stopped

  product-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: products
      POSTGRES_USER: product_svc
      POSTGRES_PASSWORD: ${PRODUCT_DB_PASS}
    volumes:
      - product_db_data:/var/lib/postgresql/data
    networks:
      - product-db-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U product_svc -d products"]
      interval: 30s
    restart: unless-stopped

  order-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: order_svc
      POSTGRES_PASSWORD: ${ORDER_DB_PASS}
    volumes:
      - order_db_data:/var/lib/postgresql/data
    networks:
      - order-db-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U order_svc -d orders"]
      interval: 30s
    restart: unless-stopped

  payment-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: payments
      POSTGRES_USER: payment_svc
      POSTGRES_PASSWORD: ${PAYMENT_DB_PASS}
    volumes:
      - payment_db_data:/var/lib/postgresql/data
    networks:
      - payment-db-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U payment_svc -d payments"]
      interval: 30s
    restart: unless-stopped

  # Cache and Search
  redis:
    image: redis:alpine
    volumes:
      - redis_data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
    restart: unless-stopped

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - search-net
    healthcheck:
      test: ["CMD-SHELL", "curl -f http://localhost:9200/_cluster/health"]
      interval: 30s
    restart: unless-stopped

  # Message Queue
  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      RABBITMQ_DEFAULT_USER: guest
      RABBITMQ_DEFAULT_PASS: guest
    volumes:
      - rabbitmq_data:/var/lib/rabbitmq
    networks:
      - message-net
    ports:
      - "15672:15672"  # Management UI
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "ping"]
      interval: 30s
    restart: unless-stopped

volumes:
  user_db_data:
  product_db_data:
  order_db_data:
  payment_db_data:
  redis_data:
  elasticsearch_data:
  rabbitmq_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  user-db-net:
    driver: bridge
    internal: true
  product-db-net:
    driver: bridge
    internal: true
  order-db-net:
    driver: bridge
    internal: true
  payment-db-net:
    driver: bridge
    internal: true
  search-net:
    driver: bridge
    internal: true
  message-net:
    driver: bridge
    internal: true
```

## Content Management System

### WordPress with Advanced Setup
```yaml
version: '3.8'

services:
  # Load Balancer
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
      - wordpress_files:/var/www/html:ro
    networks:
      - frontend
    depends_on:
      - wordpress1
      - wordpress2
    restart: unless-stopped

  # WordPress Instances
  wordpress1:
    image: wordpress:php8.1-fpm-alpine
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${WP_DB_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_REDIS_HOST', 'redis');
        define('WP_REDIS_PORT', 6379);
        define('WP_CACHE', true);
    volumes:
      - wordpress_files:/var/www/html
      - ./wp-config-extra.php:/usr/local/etc/php/conf.d/wp-config-extra.php:ro
    networks:
      - frontend
      - backend
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_healthy
    restart: unless-stopped

  wordpress2:
    image: wordpress:php8.1-fpm-alpine
    environment:
      WORDPRESS_DB_HOST: mysql
      WORDPRESS_DB_USER: wordpress
      WORDPRESS_DB_PASSWORD: ${WP_DB_PASSWORD}
      WORDPRESS_DB_NAME: wordpress
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_REDIS_HOST', 'redis');
        define('WP_REDIS_PORT', 6379);
        define('WP_CACHE', true);
    volumes:
      - wordpress_files:/var/www/html
    networks:
      - frontend
      - backend
    depends_on:
      mysql:
        condition: service_healthy
    restart: unless-stopped

  # Database
  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: wordpress
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${WP_DB_PASSWORD}
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
    volumes:
      - mysql_data:/var/lib/mysql
      - ./mysql/my.cnf:/etc/mysql/conf.d/my.cnf:ro
    networks:
      - backend
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
    restart: unless-stopped

  # Cache
  redis:
    image: redis:alpine
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    networks:
      - backend
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
    restart: unless-stopped

  # Backup Service
  backup:
    image: mysql:8.0
    environment:
      MYSQL_HOST: mysql
      MYSQL_USER: wordpress
      MYSQL_PASSWORD: ${WP_DB_PASSWORD}
      MYSQL_DATABASE: wordpress
    volumes:
      - mysql_data:/var/lib/mysql:ro
      - wordpress_files:/var/www/html:ro
      - ./backups:/backups
      - ./scripts/backup.sh:/backup.sh:ro
    command: >
      sh -c "
        while true; do
          sleep 86400  # Daily backup
          /backup.sh
        done
      "
    networks:
      - backend
    depends_on:
      - mysql
    restart: unless-stopped

volumes:
  wordpress_files:
  mysql_data:
  redis_data:

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
```

## DevOps Toolchain

### Complete CI/CD Pipeline
```yaml
version: '3.8'

services:
  # Jenkins
  jenkins:
    image: jenkins/jenkins:lts
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock:ro
    environment:
      - JAVA_OPTS=-Djenkins.install.runSetupWizard=false
    networks:
      - devops
    restart: unless-stopped

  # GitLab
  gitlab:
    image: gitlab/gitlab-ce:latest
    hostname: gitlab.local
    ports:
      - "80:80"
      - "443:443"
      - "22:22"
    volumes:
      - gitlab_config:/etc/gitlab
      - gitlab_logs:/var/log/gitlab
      - gitlab_data:/var/opt/gitlab
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.local'
        gitlab_rails['gitlab_shell_ssh_port'] = 22
    networks:
      - devops
    restart: unless-stopped

  # SonarQube
  sonarqube:
    image: sonarqube:community
    ports:
      - "9000:9000"
    environment:
      SONAR_JDBC_URL: jdbc:postgresql://postgres:5432/sonar
      SONAR_JDBC_USERNAME: sonar
      SONAR_JDBC_PASSWORD: ${SONAR_DB_PASSWORD}
    volumes:
      - sonarqube_data:/opt/sonarqube/data
      - sonarqube_extensions:/opt/sonarqube/extensions
      - sonarqube_logs:/opt/sonarqube/logs
    networks:
      - devops
      - db-network
    depends_on:
      postgres:
        condition: service_healthy
    restart: unless-stopped

  # Nexus Repository
  nexus:
    image: sonatype/nexus3:latest
    ports:
      - "8081:8081"
    volumes:
      - nexus_data:/nexus-data
    environment:
      - INSTALL4J_ADD_VM_PARAMS=-Xms1g -Xmx1g -XX:MaxDirectMemorySize=2g
    networks:
      - devops
    restart: unless-stopped

  # PostgreSQL for SonarQube
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: sonar
      POSTGRES_USER: sonar
      POSTGRES_PASSWORD: ${SONAR_DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - db-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U sonar -d sonar"]
      interval: 30s
    restart: unless-stopped

  # Monitoring
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
      - prometheus_data:/prometheus
    networks:
      - devops
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}
    volumes:
      - grafana_data:/var/lib/grafana
    networks:
      - devops
    restart: unless-stopped

volumes:
  jenkins_home:
  gitlab_config:
  gitlab_logs:
  gitlab_data:
  sonarqube_data:
  sonarqube_extensions:
  sonarqube_logs:
  nexus_data:
  postgres_data:
  prometheus_data:
  grafana_data:

networks:
  devops:
    driver: bridge
  db-network:
    driver: bridge
    internal: true
```

## Data Analytics Pipeline

### Big Data Processing Stack
```yaml
version: '3.8'

services:
  # Apache Kafka
  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    volumes:
      - zookeeper_data:/var/lib/zookeeper/data
    networks:
      - kafka-net
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    volumes:
      - kafka_data:/var/lib/kafka/data
    networks:
      - kafka-net
    restart: unless-stopped

  # Apache Spark
  spark-master:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=master
      - SPARK_RPC_AUTHENTICATION_ENABLED=no
      - SPARK_RPC_ENCRYPTION_ENABLED=no
      - SPARK_LOCAL_STORAGE_ENCRYPTION_ENABLED=no
      - SPARK_SSL_ENABLED=no
    ports:
      - "8080:8080"
      - "7077:7077"
    volumes:
      - spark_data:/opt/bitnami/spark/data
    networks:
      - spark-net
    restart: unless-stopped

  spark-worker:
    image: bitnami/spark:latest
    environment:
      - SPARK_MODE=worker
      - SPARK_MASTER_URL=spark://spark-master:7077
      - SPARK_WORKER_MEMORY=2G
      - SPARK_WORKER_CORES=2
    depends_on:
      - spark-master
    volumes:
      - spark_data:/opt/bitnami/spark/data
    networks:
      - spark-net
    deploy:
      replicas: 2
    restart: unless-stopped

  # Elasticsearch
  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - "ES_JAVA_OPTS=-Xms2g -Xmx2g"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data
    networks:
      - elastic-net
    restart: unless-stopped

  # Kibana
  kibana:
    image: kibana:8.8.0
    ports:
      - "5601:5601"
    environment:
      ELASTICSEARCH_HOSTS: http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - elastic-net
    restart: unless-stopped

  # Apache Airflow
  airflow-webserver:
    image: apache/airflow:2.6.0
    environment:
      - AIRFLOW__CORE__EXECUTOR=LocalExecutor
      - AIRFLOW__DATABASE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@postgres:5432/airflow
      - AIRFLOW__CORE__FERNET_KEY=${AIRFLOW_FERNET_KEY}
    ports:
      - "8081:8080"
    volumes:
      - ./dags:/opt/airflow/dags
      - ./logs:/opt/airflow/logs
      - ./plugins:/opt/airflow/plugins
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - airflow-net
      - db-net
    restart: unless-stopped

  # PostgreSQL for Airflow
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: airflow
      POSTGRES_USER: airflow
      POSTGRES_PASSWORD: airflow
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - db-net
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U airflow -d airflow"]
      interval: 30s
    restart: unless-stopped

volumes:
  zookeeper_data:
  kafka_data:
  spark_data:
  elasticsearch_data:
  postgres_data:

networks:
  kafka-net:
    driver: bridge
  spark-net:
    driver: bridge
  elastic-net:
    driver: bridge
  airflow-net:
    driver: bridge
  db-net:
    driver: bridge
    internal: true
```

## Microservices Architecture

### Event-Driven Microservices
```yaml
version: '3.8'

services:
  # API Gateway
  kong:
    image: kong:latest
    environment:
      KONG_DATABASE: "off"
      KONG_DECLARATIVE_CONFIG: /kong/declarative/kong.yml
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: 0.0.0.0:8001
    volumes:
      - ./kong/kong.yml:/kong/declarative/kong.yml:ro
    ports:
      - "80:8000"
      - "8001:8001"
    networks:
      - public
      - services
    restart: unless-stopped

  # Service Discovery
  consul:
    image: consul:latest
    ports:
      - "8500:8500"
    command: agent -server -bootstrap -ui -client=0.0.0.0
    volumes:
      - consul_data:/consul/data
    networks:
      - services
    restart: unless-stopped

  # User Service
  user-service:
    build: ./services/user
    environment:
      - SERVICE_NAME=user-service
      - SERVICE_PORT=3000
      - CONSUL_URL=http://consul:8500
      - DATABASE_URL=postgresql://user:pass@user-db:5432/users
      - NATS_URL=nats://nats:4222
    networks:
      - services
      - user-db-net
      - message-net
    depends_on:
      - consul
      - user-db
      - nats
    deploy:
      replicas: 2
    restart: unless-stopped

  # Product Service
  product-service:
    build: ./services/product
    environment:
      - SERVICE_NAME=product-service
      - SERVICE_PORT=3000
      - CONSUL_URL=http://consul:8500
      - DATABASE_URL=mongodb://product-db:27017/products
      - NATS_URL=nats://nats:4222
    networks:
      - services
      - product-db-net
      - message-net
    depends_on:
      - consul
      - product-db
      - nats
    deploy:
      replicas: 2
    restart: unless-stopped

  # Order Service
  order-service:
    build: ./services/order
    environment:
      - SERVICE_NAME=order-service
      - SERVICE_PORT=3000
      - CONSUL_URL=http://consul:8500
      - DATABASE_URL=postgresql://order:pass@order-db:5432/orders
      - NATS_URL=nats://nats:4222
    networks:
      - services
      - order-db-net
      - message-net
    depends_on:
      - consul
      - order-db
      - nats
    deploy:
      replicas: 2
    restart: unless-stopped

  # Message Broker (NATS)
  nats:
    image: nats:alpine
    ports:
      - "4222:4222"
      - "8222:8222"
    command: "--http_port 8222"
    networks:
      - message-net
    restart: unless-stopped

  # Databases
  user-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: users
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
    volumes:
      - user_db_data:/var/lib/postgresql/data
    networks:
      - user-db-net
    restart: unless-stopped

  product-db:
    image: mongo:6-jammy
    volumes:
      - product_db_data:/data/db
    networks:
      - product-db-net
    restart: unless-stopped

  order-db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: orders
      POSTGRES_USER: order
      POSTGRES_PASSWORD: pass
    volumes:
      - order_db_data:/var/lib/postgresql/data
    networks:
      - order-db-net
    restart: unless-stopped

volumes:
  consul_data:
  user_db_data:
  product_db_data:
  order_db_data:

networks:
  public:
    driver: bridge
  services:
    driver: bridge
    internal: true
  user-db-net:
    driver: bridge
    internal: true
  product-db-net:
    driver: bridge
    internal: true
  order-db-net:
    driver: bridge
    internal: true
  message-net:
    driver: bridge
    internal: true
```

## Development Environment

### Full-Stack Development Setup
```yaml
version: '3.8'

services:
  # Frontend Development
  frontend-dev:
    build:
      context: ./frontend
      target: development
    ports:
      - "3000:3000"
    volumes:
      - ./frontend:/app
      - /app/node_modules
    environment:
      - REACT_APP_API_URL=http://localhost:8080
      - CHOKIDAR_USEPOLLING=true
    networks:
      - dev-network
    command: npm start

  # Backend Development
  backend-dev:
    build:
      context: ./backend
      target: development
    ports:
      - "8080:8080"
      - "9229:9229"  # Debug port
    volumes:
      - ./backend:/app
      - /app/node_modules
    environment:
      - NODE_ENV=development
      - DEBUG=*
      - DATABASE_URL=postgresql://dev:dev@postgres-dev:5432/devdb
      - REDIS_URL=redis://redis-dev:6379
    networks:
      - dev-network
    depends_on:
      - postgres-dev
      - redis-dev
    command: npm run dev:debug

  # Development Database
  postgres-dev:
    image: postgres:15-alpine
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: dev
    volumes:
      - postgres_dev_data:/var/lib/postgresql/data
      - ./database/init:/docker-entrypoint-initdb.d:ro
    networks:
      - dev-network

  # Development Redis
  redis-dev:
    image: redis:alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_dev_data:/data
    networks:
      - dev-network

  # Database Admin
  pgadmin:
    image: dpage/pgadmin4:latest
    ports:
      - "5050:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@dev.local
      PGADMIN_DEFAULT_PASSWORD: admin
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    networks:
      - dev-network

  # Redis Admin
  redis-commander:
    image: rediscommander/redis-commander:latest
    ports:
      - "8081:8081"
    environment:
      REDIS_HOSTS: local:redis-dev:6379
    networks:
      - dev-network
    depends_on:
      - redis-dev

  # Mail Catcher
  mailhog:
    image: mailhog/mailhog:latest
    ports:
      - "1025:1025"  # SMTP
      - "8025:8025"  # Web UI
    networks:
      - dev-network

  # File Watcher (for hot reload)
  file-watcher:
    image: alpine:latest
    volumes:
      - ./:/workspace
    command: >
      sh -c "
        apk add --no-cache inotify-tools &&
        while inotifywait -r -e modify,create,delete /workspace; do
          echo 'Files changed, triggering reload...'
        done
      "

volumes:
  postgres_dev_data:
  redis_dev_data:
  pgadmin_data:

networks:
  dev-network:
    driver: bridge
```

These real-world examples demonstrate comprehensive Docker Compose applications covering various domains and use cases, from simple web applications to complex microservices architectures and development environments.
