# 🗄️ Nginx Caching Strategies Complete Guide

## 📋 Overview

**Duration**: 4-6 Hours  
**Skill Level**: Advanced  
**Prerequisites**: Monitoring and Logging completed  

Master comprehensive caching strategies with Nginx, including proxy caching, FastCGI caching, browser caching, and CDN integration for maximum performance.

## 🎯 Learning Objectives

- Implement advanced proxy caching strategies
- Configure FastCGI and microcaching
- Set up browser caching and cache control
- Integrate with CDN and edge caching
- Implement cache invalidation and purging strategies

## 📚 Caching Fundamentals

### Cache Types Overview
```nginx
# Different cache types in Nginx
http {
    # 1. Proxy Cache - for reverse proxy responses
    proxy_cache_path /var/cache/nginx/proxy 
                     levels=1:2 
                     keys_zone=proxy_cache:100m 
                     max_size=10g 
                     inactive=60m 
                     use_temp_path=off;
    
    # 2. FastCGI Cache - for PHP/dynamic content
    fastcgi_cache_path /var/cache/nginx/fastcgi 
                       levels=1:2 
                       keys_zone=fastcgi_cache:100m 
                       max_size=5g 
                       inactive=60m 
                       use_temp_path=off;
    
    # 3. uWSGI Cache - for Python applications
    uwsgi_cache_path /var/cache/nginx/uwsgi 
                     levels=1:2 
                     keys_zone=uwsgi_cache:50m 
                     max_size=2g 
                     inactive=30m 
                     use_temp_path=off;
    
    # 4. SCGI Cache - for other applications
    scgi_cache_path /var/cache/nginx/scgi 
                    levels=1:2 
                    keys_zone=scgi_cache:50m 
                    max_size=2g 
                    inactive=30m 
                    use_temp_path=off;
}
```

### Basic Proxy Caching
```nginx
server {
    listen 80;
    server_name cached.example.com;
    
    location / {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 302 5m;
        proxy_cache_valid 301 1h;
        proxy_cache_valid 404 1m;
        proxy_cache_valid any 1m;
        
        # Cache control
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503 http_504;
        proxy_cache_background_update on;
        proxy_cache_lock on;
        proxy_cache_lock_timeout 5s;
        
        # Cache bypass conditions
        proxy_cache_bypass $cookie_nocache $arg_nocache $arg_comment;
        proxy_no_cache $cookie_nocache $arg_nocache $arg_comment;
        
        # Headers
        add_header X-Cache-Status $upstream_cache_status always;
        add_header X-Cache-Key "$scheme$request_method$host$request_uri$args" always;
        
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🚀 Advanced Caching Strategies

### Intelligent Cache Keys
```nginx
# Dynamic cache key generation
map $request_uri $cache_key_suffix {
    ~^/api/products/(\d+) "product_$1";
    ~^/api/categories/(\d+) "category_$1";
    ~^/api/users/(\d+) "user_$1";
    default "general";
}

map $http_accept_language $lang_suffix {
    ~^en "en";
    ~^es "es";
    ~^fr "fr";
    default "en";
}

map $http_user_agent $device_type {
    ~*mobile "mobile";
    ~*tablet "tablet";
    default "desktop";
}

server {
    listen 80;
    server_name smart-cache.example.com;
    
    location /api/ {
        proxy_cache proxy_cache;
        
        # Intelligent cache key with multiple factors
        proxy_cache_key "$scheme$request_method$host$request_uri$cache_key_suffix$lang_suffix$device_type";
        
        # Different cache times for different content
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        
        # Vary cache based on headers
        proxy_cache_vary $http_accept_language $http_user_agent;
        
        proxy_pass http://backend;
        add_header X-Cache-Status $upstream_cache_status always;
        add_header X-Cache-Key "$cache_key_suffix-$lang_suffix-$device_type" always;
    }
}
```

### Microcaching Strategy
```nginx
# Microcaching for dynamic content
server {
    listen 80;
    server_name microcache.example.com;
    
    # Very short cache for dynamic content
    location /api/live/ {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        proxy_cache_valid 200 1s;  # 1 second microcache
        proxy_cache_valid 404 1s;
        
        # Allow stale content during updates
        proxy_cache_use_stale updating;
        proxy_cache_background_update on;
        proxy_cache_lock on;
        
        # Bypass cache for authenticated users
        proxy_cache_bypass $cookie_auth_token;
        proxy_no_cache $cookie_auth_token;
        
        proxy_pass http://backend;
        add_header X-Microcache $upstream_cache_status always;
    }
    
    # Medium cache for semi-dynamic content
    location /api/products/ {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        
        proxy_pass http://backend;
    }
    
    # Long cache for static API responses
    location /api/config/ {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri";
        proxy_cache_valid 200 1h;
        proxy_cache_valid 404 5m;
        
        proxy_pass http://backend;
    }
}
```

## 🎯 E-Commerce Caching Implementation

### Complete E-Commerce Cache Strategy
```nginx
# E-commerce specific cache zones
proxy_cache_path /var/cache/nginx/products 
                 levels=1:2 
                 keys_zone=products:200m 
                 max_size=5g 
                 inactive=1h 
                 use_temp_path=off;

proxy_cache_path /var/cache/nginx/categories 
                 levels=1:2 
                 keys_zone=categories:50m 
                 max_size=1g 
                 inactive=6h 
                 use_temp_path=off;

proxy_cache_path /var/cache/nginx/users 
                 levels=1:2 
                 keys_zone=users:100m 
                 max_size=2g 
                 inactive=30m 
                 use_temp_path=off;

# Cache bypass conditions for e-commerce
map $cookie_cart_id $bypass_cache {
    default 0;
    ~.+ 1;  # Bypass cache if cart cookie exists
}

map $cookie_user_id $user_cache {
    default 0;
    ~.+ 1;  # Different caching for logged-in users
}

server {
    listen 443 ssl http2;
    server_name shop.example.com;
    
    # Product catalog (aggressive caching)
    location /api/products/ {
        proxy_cache products;
        proxy_cache_key "$scheme$request_method$host$request_uri$args$http_accept_language";
        proxy_cache_valid 200 1h;
        proxy_cache_valid 404 5m;
        
        # Cache optimization
        proxy_cache_use_stale error timeout updating http_500 http_502 http_503;
        proxy_cache_background_update on;
        proxy_cache_lock on;
        
        # Bypass cache for admin users
        proxy_cache_bypass $cookie_admin_token;
        
        proxy_pass http://backend;
        add_header X-Cache-Status $upstream_cache_status always;
        add_header Cache-Control "public, max-age=3600" always;
    }
    
    # Categories (long-term caching)
    location /api/categories/ {
        proxy_cache categories;
        proxy_cache_key "$scheme$request_method$host$request_uri$http_accept_language";
        proxy_cache_valid 200 6h;
        proxy_cache_valid 404 1h;
        
        proxy_pass http://backend;
        add_header X-Cache-Status $upstream_cache_status always;
        add_header Cache-Control "public, max-age=21600" always;
    }
    
    # User-specific content (personalized caching)
    location /api/users/ {
        proxy_cache users;
        proxy_cache_key "$scheme$request_method$host$request_uri$cookie_user_id";
        proxy_cache_valid 200 5m;
        proxy_cache_valid 404 1m;
        
        # Only cache for authenticated users
        proxy_cache_bypass $user_cache;
        proxy_no_cache $user_cache;
        
        proxy_pass http://backend;
        add_header X-Cache-Status $upstream_cache_status always;
        add_header Cache-Control "private, max-age=300" always;
    }
    
    # Shopping cart (no caching)
    location /api/cart/ {
        # Never cache cart operations
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        
        proxy_pass http://backend;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
        add_header Pragma "no-cache" always;
        add_header Expires "0" always;
    }
    
    # Orders (no caching)
    location /api/orders/ {
        proxy_no_cache 1;
        proxy_cache_bypass 1;
        
        proxy_pass http://backend;
        add_header Cache-Control "no-cache, no-store, must-revalidate" always;
    }
    
    # Search results (short caching)
    location /api/search/ {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 2m;
        proxy_cache_valid 404 30s;
        
        # Bypass cache for personalized search
        proxy_cache_bypass $cookie_user_id;
        
        proxy_pass http://backend;
        add_header X-Cache-Status $upstream_cache_status always;
    }
}
```

### Cache Warming Strategy
```bash
#!/bin/bash
# cache-warmer.sh - Automated cache warming

DOMAIN="shop.example.com"
CACHE_WARM_URLS=(
    "/api/products/"
    "/api/categories/"
    "/api/products/featured"
    "/api/products/bestsellers"
    "/api/categories/electronics"
    "/api/categories/clothing"
)

echo "=== Cache Warming Started ==="
echo "Timestamp: $(date)"

for url in "${CACHE_WARM_URLS[@]}"; do
    echo "Warming cache for: $url"
    
    # Make request to warm cache
    RESPONSE=$(curl -s -w "%{http_code}:%{time_total}" -o /dev/null "https://$DOMAIN$url")
    HTTP_CODE=$(echo $RESPONSE | cut -d: -f1)
    TIME_TOTAL=$(echo $RESPONSE | cut -d: -f2)
    
    if [ $HTTP_CODE -eq 200 ]; then
        echo "✅ Success: $url (${TIME_TOTAL}s)"
    else
        echo "❌ Failed: $url (HTTP $HTTP_CODE)"
    fi
    
    # Small delay to avoid overwhelming the server
    sleep 0.5
done

echo "Cache warming completed"

# Warm cache for different languages
LANGUAGES=("en" "es" "fr" "de")
for lang in "${LANGUAGES[@]}"; do
    echo "Warming cache for language: $lang"
    curl -s -H "Accept-Language: $lang" "https://$DOMAIN/api/products/" > /dev/null
done
```

## 🔄 Cache Invalidation and Purging

### Cache Purging Implementation
```nginx
# Cache purging configuration
server {
    listen 80;
    server_name cache-admin.example.com;
    
    # Restrict access to cache management
    allow 127.0.0.1;
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    # Purge specific cache entries
    location ~ /purge/proxy/(.+) {
        proxy_cache_purge proxy_cache "$scheme$request_method$host/$1";
        return 200 "Purged: $1\n";
        add_header Content-Type text/plain;
    }
    
    # Purge product cache
    location ~ /purge/products/(.+) {
        proxy_cache_purge products "$scheme$request_method$host/api/products/$1";
        return 200 "Purged product: $1\n";
        add_header Content-Type text/plain;
    }
    
    # Purge category cache
    location ~ /purge/categories/(.+) {
        proxy_cache_purge categories "$scheme$request_method$host/api/categories/$1";
        return 200 "Purged category: $1\n";
        add_header Content-Type text/plain;
    }
    
    # Purge all cache
    location /purge/all {
        # This would require a custom script
        return 200 "Cache purge initiated\n";
        add_header Content-Type text/plain;
    }
    
    # Cache statistics
    location /cache/stats {
        return 200 '{"proxy_cache":"active","products_cache":"active","categories_cache":"active","timestamp":"$time_iso8601"}';
        add_header Content-Type application/json;
    }
}
```

### Automated Cache Management
```bash
#!/bin/bash
# cache-manager.sh - Automated cache management

CACHE_DIRS=(
    "/var/cache/nginx/proxy"
    "/var/cache/nginx/products"
    "/var/cache/nginx/categories"
    "/var/cache/nginx/users"
)

PURGE_URL="http://cache-admin.example.com/purge"
MAX_CACHE_SIZE="10G"

echo "=== Cache Management Report ==="
echo "Timestamp: $(date)"

# Check cache sizes
echo "1. Cache Directory Sizes:"
for dir in "${CACHE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        SIZE=$(du -sh "$dir" | cut -f1)
        echo "  $dir: $SIZE"
    fi
done

# Check total cache usage
TOTAL_SIZE=$(du -sh /var/cache/nginx | cut -f1)
echo "Total cache size: $TOTAL_SIZE"

# Purge old cache entries (older than 24 hours)
echo -e "\n2. Cleaning old cache entries:"
find /var/cache/nginx -type f -mtime +1 -delete
echo "Old cache entries cleaned"

# Check cache hit rates from logs
echo -e "\n3. Cache Hit Rate Analysis:"
HIT_COUNT=$(grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/access.log | grep "X-Cache-Status: HIT" | wc -l)
TOTAL_COUNT=$(grep "$(date '+%d/%b/%Y:%H')" /var/log/nginx/access.log | wc -l)

if [ $TOTAL_COUNT -gt 0 ]; then
    HIT_RATE=$(echo "scale=2; $HIT_COUNT * 100 / $TOTAL_COUNT" | bc)
    echo "Cache hit rate (current hour): $HIT_RATE% ($HIT_COUNT/$TOTAL_COUNT)"
else
    echo "No requests in current hour"
fi

# Selective cache purging based on conditions
echo -e "\n4. Selective Cache Purging:"

# Purge product cache if inventory updated (example condition)
if [ -f "/tmp/inventory_updated" ]; then
    echo "Inventory updated, purging product cache..."
    curl -s "$PURGE_URL/products/" > /dev/null
    rm -f "/tmp/inventory_updated"
    echo "Product cache purged"
fi

# Purge category cache if categories modified
if [ -f "/tmp/categories_updated" ]; then
    echo "Categories updated, purging category cache..."
    curl -s "$PURGE_URL/categories/" > /dev/null
    rm -f "/tmp/categories_updated"
    echo "Category cache purged"
fi
```

## 🌐 CDN Integration

### CDN-Optimized Caching
```nginx
# CDN integration with origin caching
server {
    listen 80;
    server_name cdn-origin.example.com;
    
    # CDN-friendly headers
    location /static/ {
        root /var/www;
        
        # Long-term caching for CDN
        expires 1y;
        add_header Cache-Control "public, max-age=31536000, immutable";
        
        # CDN headers
        add_header X-CDN-Cache "MISS" always;
        add_header Vary "Accept-Encoding, Accept";
        
        # CORS for CDN
        add_header Access-Control-Allow-Origin "*" always;
        
        # ETag for cache validation
        etag on;
    }
    
    # API responses for CDN caching
    location /api/public/ {
        proxy_cache proxy_cache;
        proxy_cache_key "$scheme$request_method$host$request_uri$args";
        proxy_cache_valid 200 5m;
        
        # CDN-friendly cache headers
        proxy_hide_header Set-Cookie;
        add_header Cache-Control "public, max-age=300";
        add_header Vary "Accept-Encoding, Accept-Language";
        
        proxy_pass http://backend;
    }
    
    # Cache purge for CDN
    location /cdn-purge/ {
        allow 192.168.1.0/24;  # CDN provider IPs
        deny all;
        
        # Custom CDN purge logic
        return 200 "CDN purge requested\n";
        add_header Content-Type text/plain;
    }
}
```

### Edge Caching Strategy
```nginx
# Edge caching with geographic optimization
map $geoip_country_code $edge_cache_time {
    default 5m;
    US 10m;      # Longer cache for US users
    CA 10m;      # Longer cache for Canadian users
    GB 8m;       # Medium cache for UK users
    DE 8m;       # Medium cache for German users
}

server {
    listen 80;
    server_name edge.example.com;
    
    location /api/products/ {
        proxy_cache products;
        proxy_cache_key "$scheme$request_method$host$request_uri$geoip_country_code";
        proxy_cache_valid 200 $edge_cache_time;
        
        # Geographic optimization
        add_header X-Edge-Cache $upstream_cache_status always;
        add_header X-Country-Code $geoip_country_code always;
        add_header X-Cache-Time $edge_cache_time always;
        
        proxy_pass http://backend;
    }
}
```

## 📊 Cache Performance Monitoring

### Cache Analytics
```bash
#!/bin/bash
# cache-analytics.sh - Comprehensive cache performance analysis

ACCESS_LOG="/var/log/nginx/access.log"
CACHE_DIR="/var/cache/nginx"

echo "=== Cache Performance Analytics ==="
echo "Generated: $(date)"

# Cache hit rate analysis
echo "1. Cache Hit Rate (last 24 hours):"
TOTAL_REQUESTS=$(grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | wc -l)
HIT_REQUESTS=$(grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | grep "X-Cache-Status: HIT" | wc -l)
MISS_REQUESTS=$(grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | grep "X-Cache-Status: MISS" | wc -l)

if [ $TOTAL_REQUESTS -gt 0 ]; then
    HIT_RATE=$(echo "scale=2; $HIT_REQUESTS * 100 / $TOTAL_REQUESTS" | bc)
    MISS_RATE=$(echo "scale=2; $MISS_REQUESTS * 100 / $TOTAL_REQUESTS" | bc)
    
    echo "  Total requests: $TOTAL_REQUESTS"
    echo "  Cache hits: $HIT_REQUESTS ($HIT_RATE%)"
    echo "  Cache misses: $MISS_REQUESTS ($MISS_RATE%)"
fi

# Cache size analysis
echo -e "\n2. Cache Storage Analysis:"
for cache_type in proxy products categories users; do
    if [ -d "$CACHE_DIR/$cache_type" ]; then
        SIZE=$(du -sh "$CACHE_DIR/$cache_type" | cut -f1)
        FILES=$(find "$CACHE_DIR/$cache_type" -type f | wc -l)
        echo "  $cache_type cache: $SIZE ($FILES files)"
    fi
done

# Response time improvement
echo -e "\n3. Response Time Analysis:"
CACHED_AVG=$(grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | \
grep "X-Cache-Status: HIT" | awk '{print $NF}' | \
awk '{sum+=$1; count++} END {if(count>0) printf "%.3f", sum/count}')

UNCACHED_AVG=$(grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | \
grep "X-Cache-Status: MISS" | awk '{print $NF}' | \
awk '{sum+=$1; count++} END {if(count>0) printf "%.3f", sum/count}')

echo "  Average cached response time: ${CACHED_AVG}s"
echo "  Average uncached response time: ${UNCACHED_AVG}s"

if [ -n "$CACHED_AVG" ] && [ -n "$UNCACHED_AVG" ]; then
    IMPROVEMENT=$(echo "scale=2; ($UNCACHED_AVG - $CACHED_AVG) * 100 / $UNCACHED_AVG" | bc)
    echo "  Performance improvement: ${IMPROVEMENT}%"
fi

# Top cached URLs
echo -e "\n4. Top Cached URLs (last 24 hours):"
grep "$(date -d '1 day ago' '+%d/%b/%Y')" $ACCESS_LOG | \
grep "X-Cache-Status: HIT" | awk '{print $7}' | \
sort | uniq -c | sort -nr | head -10
```

## 🎯 Practical Exercises

### Exercise 1: Multi-Level Caching
Implement comprehensive caching:
- Proxy caching for APIs
- FastCGI caching for PHP
- Browser caching for static content
- Performance measurement

### Exercise 2: E-Commerce Cache Strategy
Set up e-commerce specific caching:
- Product catalog caching
- User-specific content caching
- Cart and order exclusions
- Cache warming and purging

### Exercise 3: CDN Integration
Configure CDN-ready caching:
- Origin server optimization
- Cache headers for CDN
- Geographic optimization
- Performance analytics

---

**🎯 Next**: Module 4 final assessment and certification  
**📚 Resources**: [Nginx Caching Guide](https://nginx.org/en/docs/http/ngx_http_proxy_module.html#proxy_cache)  
**🔧 Tools**: Use cache analysis tools and monitoring to optimize performance
