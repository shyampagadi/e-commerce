# 🌐 Nginx API Gateway & Microservices

## 📋 Overview

**Duration**: 4-5 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Load Balancing Advanced completed  

Master Nginx as an API Gateway for microservices architecture, including service discovery, authentication, rate limiting, and request transformation.

## 🎯 Learning Objectives

- Configure Nginx as a comprehensive API Gateway
- Implement microservices routing and service discovery
- Set up authentication and authorization for APIs
- Configure rate limiting and request transformation
- Implement API versioning and circuit breaker patterns

## 📚 API Gateway Fundamentals

### Basic API Gateway Configuration
```nginx
# Microservices upstream definitions
upstream user_service {
    server user-svc-1:8001 weight=2;
    server user-svc-2:8002 weight=1;
    keepalive 32;
}

upstream product_service {
    server product-svc-1:8003 weight=3;
    server product-svc-2:8004 weight=2;
    keepalive 32;
}

upstream order_service {
    server order-svc-1:8005;
    server order-svc-2:8006;
    keepalive 32;
}

upstream payment_service {
    server payment-svc-1:8007 max_fails=2 fail_timeout=30s;
    server payment-svc-2:8008 max_fails=2 fail_timeout=30s;
    keepalive 16;
}

# API Gateway server
server {
    listen 443 ssl http2;
    server_name api.example.com;
    
    ssl_certificate /etc/ssl/certs/api.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.example.com.key;
    
    # Global API headers
    add_header X-API-Gateway "nginx" always;
    add_header X-Request-ID $request_id always;
    
    # User service routes
    location /api/v1/users/ {
        proxy_pass http://user_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Service "user-service";
    }
    
    # Product service routes
    location /api/v1/products/ {
        proxy_pass http://product_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Service "product-service";
    }
    
    # Order service routes
    location /api/v1/orders/ {
        proxy_pass http://order_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Service "order-service";
    }
    
    # Payment service routes
    location /api/v1/payments/ {
        proxy_pass http://payment_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Service "payment-service";
    }
}
```

## 🔐 Authentication & Authorization

### JWT Authentication
```nginx
# JWT validation (requires lua module or auth service)
map $http_authorization $jwt_token {
    ~^Bearer\s+(.+)$ $1;
    default "";
}

# Authentication service
upstream auth_service {
    server auth-svc:8000;
    keepalive 16;
}

server {
    listen 443 ssl http2;
    server_name secure-api.example.com;
    
    # Authentication endpoint
    location = /auth {
        internal;
        proxy_pass http://auth_service/validate;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URI $request_uri;
        proxy_set_header X-JWT-Token $jwt_token;
    }
    
    # Protected API routes
    location /api/v1/protected/ {
        auth_request /auth;
        
        # Pass auth headers to backend
        auth_request_set $user_id $upstream_http_x_user_id;
        auth_request_set $user_role $upstream_http_x_user_role;
        
        proxy_pass http://backend_service/;
        proxy_set_header X-User-ID $user_id;
        proxy_set_header X-User-Role $user_role;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Public API routes (no auth required)
    location /api/v1/public/ {
        proxy_pass http://backend_service/public/;
        proxy_set_header Host $host;
        proxy_set_header X-Request-ID $request_id;
    }
}
```

### API Key Authentication
```nginx
# API key validation
map $http_x_api_key $api_key_valid {
    default 0;
    "key1234567890" 1;
    "abcdef123456" 1;
    # In production, use external validation service
}

server {
    listen 443 ssl http2;
    server_name api-key.example.com;
    
    # API key validation
    location /api/ {
        if ($api_key_valid = 0) {
            return 401 '{"error":"Invalid API key"}';
        }
        
        proxy_pass http://backend_service/;
        proxy_set_header X-API-Key $http_x_api_key;
        proxy_set_header X-Request-ID $request_id;
    }
}
```

## ⚡ Rate Limiting & Throttling

### Advanced Rate Limiting
```nginx
# Rate limiting zones for different API tiers
limit_req_zone $http_x_api_key zone=api_basic:10m rate=10r/s;
limit_req_zone $http_x_api_key zone=api_premium:10m rate=100r/s;
limit_req_zone $http_x_api_key zone=api_enterprise:10m rate=1000r/s;

# Rate limiting by endpoint
limit_req_zone $binary_remote_addr zone=search:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=auth:10m rate=2r/s;

# API tier mapping
map $http_x_api_key $api_tier {
    default "basic";
    "premium_key_123" "premium";
    "enterprise_key_456" "enterprise";
}

server {
    listen 443 ssl http2;
    server_name throttled-api.example.com;
    
    # Authentication endpoints (strict limiting)
    location /api/v1/auth/ {
        limit_req zone=auth burst=5 nodelay;
        
        proxy_pass http://auth_service/;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Search endpoints (moderate limiting)
    location /api/v1/search/ {
        limit_req zone=search burst=10 nodelay;
        
        proxy_pass http://search_service/;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Tiered API access
    location /api/v1/data/ {
        # Apply rate limiting based on API tier
        if ($api_tier = "basic") {
            limit_req zone=api_basic burst=20 nodelay;
        }
        if ($api_tier = "premium") {
            limit_req zone=api_premium burst=200 nodelay;
        }
        if ($api_tier = "enterprise") {
            limit_req zone=api_enterprise burst=2000 nodelay;
        }
        
        proxy_pass http://data_service/;
        proxy_set_header X-API-Tier $api_tier;
        proxy_set_header X-Request-ID $request_id;
    }
}
```

## 🔄 Request Transformation

### Request/Response Modification
```nginx
server {
    listen 443 ssl http2;
    server_name transform-api.example.com;
    
    # Add common headers to all requests
    location /api/ {
        # Request transformation
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Request-Start $msec;
        proxy_set_header X-Client-IP $remote_addr;
        
        # Response transformation
        proxy_hide_header X-Powered-By;
        proxy_hide_header Server;
        
        # Add security headers
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;
        add_header X-XSS-Protection "1; mode=block" always;
        
        proxy_pass http://backend_service/;
    }
    
    # API versioning through headers
    location /api/users/ {
        # Default to v1 if no version specified
        set $api_version "v1";
        
        if ($http_accept ~ "application/vnd\.api\+json;version=2") {
            set $api_version "v2";
        }
        
        proxy_pass http://user_service_$api_version/;
        proxy_set_header X-API-Version $api_version;
    }
    
    # Request body transformation (requires lua)
    location /api/transform/ {
        # Transform request body before forwarding
        access_by_lua_block {
            -- Custom Lua logic for request transformation
            ngx.req.read_body()
            local body = ngx.req.get_body_data()
            -- Transform body here
            ngx.req.set_body_data(transformed_body)
        }
        
        proxy_pass http://backend_service/;
    }
}
```

## 🎯 E-Commerce Microservices Gateway

### Complete E-Commerce API Gateway
```nginx
# E-commerce microservices configuration
upstream user_management {
    server user-mgmt-1:8001 weight=2;
    server user-mgmt-2:8002 weight=1;
    keepalive 32;
}

upstream product_catalog {
    server catalog-1:8003 weight=3;
    server catalog-2:8004 weight=2;
    keepalive 32;
}

upstream inventory_service {
    server inventory-1:8005;
    server inventory-2:8006;
    keepalive 16;
}

upstream order_management {
    server order-mgmt-1:8007;
    server order-mgmt-2:8008;
    keepalive 32;
}

upstream payment_processing {
    server payment-1:8009 max_fails=1 fail_timeout=10s;
    server payment-2:8010 max_fails=1 fail_timeout=10s;
    keepalive 8;
}

upstream notification_service {
    server notification-1:8011;
    server notification-2:8012;
    keepalive 16;
}

# Rate limiting for e-commerce
limit_req_zone $binary_remote_addr zone=ecom_api:10m rate=20r/s;
limit_req_zone $binary_remote_addr zone=ecom_auth:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=ecom_payment:10m rate=2r/s;
limit_req_zone $binary_remote_addr zone=ecom_search:10m rate=10r/s;

server {
    listen 443 ssl http2;
    server_name api.shop.example.com;
    
    ssl_certificate /etc/ssl/certs/api.shop.example.com.crt;
    ssl_certificate_key /etc/ssl/private/api.shop.example.com.key;
    
    # Global API configuration
    add_header X-API-Gateway "ecommerce-nginx" always;
    add_header X-Request-ID $request_id always;
    add_header X-Response-Time $upstream_response_time always;
    
    # Authentication service
    location /api/v1/auth/ {
        limit_req zone=ecom_auth burst=10 nodelay;
        
        proxy_pass http://user_management/auth/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        
        # Log authentication attempts
        access_log /var/log/nginx/auth_api.log;
    }
    
    # User management
    location /api/v1/users/ {
        limit_req zone=ecom_api burst=30 nodelay;
        
        # Authentication required
        auth_request /auth-validate;
        
        proxy_pass http://user_management/users/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Product catalog (public + cached)
    location /api/v1/products/ {
        limit_req zone=ecom_api burst=50 nodelay;
        
        # Cache product responses
        proxy_cache products_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        
        proxy_pass http://product_catalog/;
        proxy_set_header Host $host;
        proxy_set_header X-Request-ID $request_id;
        
        add_header X-Cache-Status $upstream_cache_status always;
    }
    
    # Inventory service
    location /api/v1/inventory/ {
        limit_req zone=ecom_api burst=20 nodelay;
        
        # Real-time inventory, no caching
        proxy_pass http://inventory_service/;
        proxy_set_header Host $host;
        proxy_set_header X-Request-ID $request_id;
        
        # Short timeout for inventory checks
        proxy_connect_timeout 5s;
        proxy_send_timeout 10s;
        proxy_read_timeout 10s;
    }
    
    # Order management (authenticated)
    location /api/v1/orders/ {
        limit_req zone=ecom_api burst=15 nodelay;
        
        # Authentication required
        auth_request /auth-validate;
        
        proxy_pass http://order_management/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Payment processing (high security)
    location /api/v1/payments/ {
        limit_req zone=ecom_payment burst=3 nodelay;
        
        # Strict authentication and logging
        auth_request /auth-validate;
        access_log /var/log/nginx/payment_api.log;
        
        # Enhanced security headers
        add_header X-Content-Type-Options nosniff always;
        add_header X-Frame-Options DENY always;
        
        proxy_pass http://payment_processing/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
        proxy_set_header X-Payment-Gateway "nginx" always;
        
        # Strict timeouts for payments
        proxy_connect_timeout 3s;
        proxy_send_timeout 15s;
        proxy_read_timeout 15s;
    }
    
    # Search service
    location /api/v1/search/ {
        limit_req zone=ecom_search burst=20 nodelay;
        
        # Cache search results briefly
        proxy_cache search_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 2m;
        
        proxy_pass http://product_catalog/search/;
        proxy_set_header Host $host;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Notifications (internal service)
    location /api/v1/notifications/ {
        # Internal service access only
        allow 10.0.0.0/8;
        allow 192.168.0.0/16;
        deny all;
        
        proxy_pass http://notification_service/;
        proxy_set_header X-Request-ID $request_id;
    }
    
    # Health check aggregation
    location /api/health {
        access_log off;
        
        # Custom health check logic
        return 200 '{"status":"healthy","services":{"users":"up","products":"up","orders":"up","payments":"up"},"timestamp":"$time_iso8601"}';
        add_header Content-Type application/json;
    }
    
    # API documentation
    location /api/docs {
        # Serve API documentation
        root /var/www/api-docs;
        try_files $uri $uri/ /index.html;
    }
    
    # Internal auth validation
    location = /auth-validate {
        internal;
        proxy_pass http://user_management/validate;
        proxy_pass_request_body off;
        proxy_set_header Content-Length "";
        proxy_set_header X-Original-URI $request_uri;
        proxy_set_header X-Original-Method $request_method;
    }
}
```

## 📊 Service Discovery & Health Checks

### Dynamic Service Discovery
```nginx
# Service registry integration (requires custom module or lua)
upstream_conf /etc/nginx/conf.d/upstreams.conf;

# Health check configuration
server {
    listen 8080;
    server_name localhost;
    
    allow 127.0.0.1;
    allow 10.0.0.0/8;
    deny all;
    
    # Service health aggregation
    location /services/health {
        content_by_lua_block {
            local services = {
                {name = "user_service", url = "http://user-svc:8001/health"},
                {name = "product_service", url = "http://product-svc:8003/health"},
                {name = "order_service", url = "http://order-svc:8007/health"}
            }
            
            local results = {}
            for _, service in ipairs(services) do
                local res = ngx.location.capture("/check/" .. service.name)
                results[service.name] = {
                    status = res.status == 200 and "healthy" or "unhealthy",
                    response_time = res.header["X-Response-Time"]
                }
            end
            
            ngx.header.content_type = "application/json"
            ngx.say(cjson.encode({
                gateway = "healthy",
                services = results,
                timestamp = ngx.time()
            }))
        }
    }
    
    # Individual service checks
    location ~ ^/check/(.+)$ {
        internal;
        proxy_pass http://$1/health;
        proxy_set_header Host $host;
    }
}
```

## 🎯 Practical Exercises

### Exercise 1: Basic API Gateway Setup
Configure Nginx as API Gateway:
- Multiple microservice routing
- Authentication integration
- Rate limiting implementation
- Request/response transformation

### Exercise 2: E-Commerce Gateway
Implement complete e-commerce gateway:
- Service-specific configurations
- Security policies
- Performance optimization
- Health check aggregation

### Exercise 3: Advanced Features
Add advanced gateway features:
- Circuit breaker patterns
- Service discovery integration
- API versioning strategies
- Monitoring and analytics

---

**🎯 Next**: SSL/TLS Configuration  
**📚 Resources**: [Nginx API Gateway Patterns](https://nginx.org/en/docs/http/ngx_http_upstream_module.html)  
**🔧 Tools**: Use service mesh tools like Istio for advanced API gateway features
