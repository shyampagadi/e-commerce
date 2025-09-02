# Certificate Manager Setup

## Table of Contents
1. [SSL/TLS Certificate Fundamentals](#ssltls-certificate-fundamentals)
2. [AWS Certificate Manager Overview](#aws-certificate-manager-overview)
3. [Certificate Request and Validation](#certificate-request-and-validation)
4. [Certificate Deployment](#certificate-deployment)
5. [Certificate Management](#certificate-management)
6. [Troubleshooting](#troubleshooting)

## SSL/TLS Certificate Fundamentals

### Certificate Types
```bash
# Domain Validated (DV) Certificates:
# - Validates domain ownership only
# - Automated validation process
# - Suitable for most web applications
# - Free with AWS Certificate Manager

# Organization Validated (OV) Certificates:
# - Validates domain ownership and organization
# - Manual validation process
# - Higher trust level
# - Not available through ACM (use third-party)

# Extended Validation (EV) Certificates:
# - Highest level of validation
# - Green address bar in browsers
# - Manual validation process
# - Not available through ACM
```

### Certificate Components
```bash
# Certificate Chain:
# Root CA Certificate (Certificate Authority)
# ↓
# Intermediate CA Certificate
# ↓
# End-Entity Certificate (Your Domain)

# Certificate Information:
# - Subject: Domain name(s) the certificate is issued for
# - Issuer: Certificate Authority that issued the certificate
# - Validity Period: Start and end dates
# - Public Key: Used for encryption
# - Signature: CA's digital signature
# - Extensions: Additional certificate features (SAN, etc.)
```

## AWS Certificate Manager Overview

### ACM Benefits
```bash
# Free SSL/TLS Certificates:
# - No cost for certificates used with AWS services
# - Automatic renewal
# - Integration with AWS services

# Supported Services:
# - Elastic Load Balancing (ALB, NLB)
# - Amazon CloudFront
# - Amazon API Gateway
# - AWS App Runner
# - Amazon Cognito

# Certificate Features:
# - Domain validation
# - Wildcard certificates
# - Subject Alternative Names (SAN)
# - Automatic renewal
# - Integration with Route 53
```

### ACM Limitations
```bash
# Limitations to Consider:
# - Certificates can only be used with AWS services
# - Cannot export private keys
# - Limited to DV certificates only
# - Regional service (certificates are region-specific)
# - CloudFront requires certificates in us-east-1

# When to Use Third-Party Certificates:
# - Need to export private key
# - Require OV or EV certificates
# - Use with non-AWS services
# - Need specific CA requirements
```

## Certificate Request and Validation

### Request Certificate via CLI
```bash
# Request certificate for single domain
aws acm request-certificate \
    --domain-name example.com \
    --validation-method DNS \
    --subject-alternative-names www.example.com \
    --tags Key=Name,Value=Example-SSL-Cert Key=Environment,Value=Production

# Request wildcard certificate
aws acm request-certificate \
    --domain-name "*.example.com" \
    --validation-method DNS \
    --subject-alternative-names example.com \
    --tags Key=Name,Value=Wildcard-SSL-Cert

# Request certificate with multiple domains
aws acm request-certificate \
    --domain-name example.com \
    --subject-alternative-names www.example.com,api.example.com,admin.example.com \
    --validation-method DNS
```

### DNS Validation Process
```bash
# Get certificate details and validation records
CERT_ARN="arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012"

aws acm describe-certificate \
    --certificate-arn $CERT_ARN \
    --query 'Certificate.DomainValidationOptions'

# Example output:
[
    {
        "DomainName": "example.com",
        "ValidationDomain": "example.com",
        "ValidationStatus": "PENDING_VALIDATION",
        "ResourceRecord": {
            "Name": "_acme-challenge.example.com.",
            "Type": "CNAME",
            "Value": "_12345678-1234-1234-1234-123456789012.acm-validations.aws."
        },
        "ValidationMethod": "DNS"
    }
]
```

### Automated DNS Validation
```bash
#!/bin/bash
# auto-validate-certificate.sh

CERT_ARN=$1
HOSTED_ZONE_ID=$2

if [ -z "$CERT_ARN" ] || [ -z "$HOSTED_ZONE_ID" ]; then
    echo "Usage: $0 <certificate-arn> <hosted-zone-id>"
    exit 1
fi

echo "Setting up DNS validation for certificate: $CERT_ARN"

# Get validation records
VALIDATION_RECORDS=$(aws acm describe-certificate \
    --certificate-arn $CERT_ARN \
    --query 'Certificate.DomainValidationOptions[*].ResourceRecord' \
    --output json)

# Create DNS records for validation
echo "$VALIDATION_RECORDS" | jq -r '.[] | @base64' | while read record; do
    decoded=$(echo $record | base64 -d)
    name=$(echo $decoded | jq -r '.Name')
    type=$(echo $decoded | jq -r '.Type')
    value=$(echo $decoded | jq -r '.Value')
    
    echo "Creating validation record: $name ($type) -> $value"
    
    aws route53 change-resource-record-sets \
        --hosted-zone-id $HOSTED_ZONE_ID \
        --change-batch '{
            "Changes": [{
                "Action": "CREATE",
                "ResourceRecordSet": {
                    "Name": "'$name'",
                    "Type": "'$type'",
                    "TTL": 300,
                    "ResourceRecords": [{"Value": "'$value'"}]
                }
            }]
        }'
done

echo "DNS validation records created. Waiting for certificate validation..."

# Wait for certificate to be issued
aws acm wait certificate-validated --certificate-arn $CERT_ARN

echo "Certificate validated successfully!"
```

### Email Validation (Alternative)
```bash
# Request certificate with email validation
aws acm request-certificate \
    --domain-name example.com \
    --validation-method EMAIL \
    --subject-alternative-names www.example.com

# Email validation addresses:
# - admin@example.com
# - administrator@example.com
# - hostmaster@example.com
# - postmaster@example.com
# - webmaster@example.com
# - admin@domain.com (if different from certificate domain)
```

## Certificate Deployment

### Application Load Balancer Integration
```bash
# Create HTTPS listener with SSL certificate
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer/1234567890123456 \
    --protocol HTTPS \
    --port 443 \
    --certificates CertificateArn=arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012 \
    --ssl-policy ELBSecurityPolicy-TLS-1-2-2017-01 \
    --default-actions Type=forward,TargetGroupArn=arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/1234567890123456

# Create HTTP to HTTPS redirect
aws elbv2 create-listener \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/my-load-balancer/1234567890123456 \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=redirect,RedirectConfig='{Protocol=HTTPS,Port=443,StatusCode=HTTP_301}'
```

### CloudFront Integration
```bash
# Create CloudFront distribution with custom SSL certificate
aws cloudfront create-distribution \
    --distribution-config '{
        "CallerReference": "'$(date +%s)'",
        "Comment": "Docker application with custom SSL",
        "DefaultCacheBehavior": {
            "TargetOriginId": "ALB-Origin",
            "ViewerProtocolPolicy": "redirect-to-https",
            "TrustedSigners": {
                "Enabled": false,
                "Quantity": 0
            },
            "ForwardedValues": {
                "QueryString": false,
                "Cookies": {"Forward": "none"}
            },
            "MinTTL": 0
        },
        "Origins": {
            "Quantity": 1,
            "Items": [
                {
                    "Id": "ALB-Origin",
                    "DomainName": "my-load-balancer-1234567890.us-east-1.elb.amazonaws.com",
                    "CustomOriginConfig": {
                        "HTTPPort": 80,
                        "HTTPSPort": 443,
                        "OriginProtocolPolicy": "https-only",
                        "OriginSslProtocols": {
                            "Quantity": 1,
                            "Items": ["TLSv1.2"]
                        }
                    }
                }
            ]
        },
        "Enabled": true,
        "Aliases": {
            "Quantity": 2,
            "Items": ["example.com", "www.example.com"]
        },
        "ViewerCertificate": {
            "ACMCertificateArn": "arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012",
            "SSLSupportMethod": "sni-only",
            "MinimumProtocolVersion": "TLSv1.2_2021"
        }
    }'
```

## Certificate Management

### Certificate Renewal
```bash
# ACM handles automatic renewal, but monitor the process

# Check certificate status
aws acm describe-certificate \
    --certificate-arn arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012 \
    --query 'Certificate.[Status,NotAfter,RenewalEligibility]'

# List certificates nearing expiration
aws acm list-certificates \
    --certificate-statuses ISSUED \
    --query 'CertificateSummaryList[?NotAfter<=`2024-01-01`].[DomainName,NotAfter]' \
    --output table
```

### Certificate Monitoring
```bash
#!/bin/bash
# certificate-monitor.sh

# Monitor certificate expiration
monitor_certificates() {
    echo "Monitoring SSL certificate expiration..."
    
    # Get all certificates
    CERTIFICATES=$(aws acm list-certificates --certificate-statuses ISSUED --query 'CertificateSummaryList[*].CertificateArn' --output text)
    
    for cert_arn in $CERTIFICATES; do
        # Get certificate details
        CERT_INFO=$(aws acm describe-certificate --certificate-arn $cert_arn)
        DOMAIN=$(echo $CERT_INFO | jq -r '.Certificate.DomainName')
        EXPIRY=$(echo $CERT_INFO | jq -r '.Certificate.NotAfter')
        STATUS=$(echo $CERT_INFO | jq -r '.Certificate.Status')
        
        # Calculate days until expiration
        EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
        CURRENT_EPOCH=$(date +%s)
        DAYS_UNTIL_EXPIRY=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))
        
        echo "Certificate: $DOMAIN"
        echo "  Status: $STATUS"
        echo "  Expires: $EXPIRY"
        echo "  Days until expiry: $DAYS_UNTIL_EXPIRY"
        
        # Alert if expiring soon (should not happen with ACM auto-renewal)
        if [ $DAYS_UNTIL_EXPIRY -lt 30 ]; then
            echo "  ⚠️  WARNING: Certificate expires in less than 30 days!"
            # Send alert (SNS, email, etc.)
        fi
        
        echo ""
    done
}

# Test certificate connectivity
test_certificate() {
    local domain=$1
    local port=${2:-443}
    
    echo "Testing SSL certificate for $domain:$port"
    
    # Test SSL connection
    echo | openssl s_client -servername $domain -connect $domain:$port 2>/dev/null | openssl x509 -noout -dates -subject -issuer
    
    # Check certificate chain
    echo | openssl s_client -servername $domain -connect $domain:$port -showcerts 2>/dev/null
    
    # Test with curl
    curl -I https://$domain/ --connect-timeout 10
}

# Certificate validation check
validate_certificate() {
    local domain=$1
    
    echo "Validating certificate for $domain..."
    
    # Check certificate validity
    CERT_INFO=$(echo | openssl s_client -servername $domain -connect $domain:443 2>/dev/null | openssl x509 -noout -text)
    
    # Extract important information
    echo "Subject: $(echo "$CERT_INFO" | grep "Subject:" | head -1)"
    echo "Issuer: $(echo "$CERT_INFO" | grep "Issuer:" | head -1)"
    echo "Validity: $(echo "$CERT_INFO" | grep -A 2 "Validity")"
    echo "SAN: $(echo "$CERT_INFO" | grep -A 1 "Subject Alternative Name")"
    
    # Test SSL Labs rating (external service)
    echo "SSL Labs test: https://www.ssllabs.com/ssltest/analyze.html?d=$domain"
}

# Run monitoring
case "${1:-help}" in
    "monitor")
        monitor_certificates
        ;;
    "test")
        test_certificate "${2:-example.com}"
        ;;
    "validate")
        validate_certificate "${2:-example.com}"
        ;;
    *)
        echo "Usage: $0 {monitor|test|validate} [domain]"
        ;;
esac
```

### Certificate Backup and Export
```bash
# Note: ACM certificates cannot be exported
# For exportable certificates, use AWS Private CA or third-party

# Create private CA (for internal certificates)
aws acm-pca create-certificate-authority \
    --certificate-authority-configuration '{
        "KeyAlgorithm": "RSA_2048",
        "SigningAlgorithm": "SHA256WITHRSA",
        "Subject": {
            "Country": "US",
            "Organization": "Example Corp",
            "OrganizationalUnit": "IT Department",
            "CommonName": "Example Corp Internal CA"
        }
    }' \
    --certificate-authority-type ROOT \
    --tags Key=Name,Value=Internal-CA

# Issue certificate from private CA (exportable)
aws acm-pca issue-certificate \
    --certificate-authority-arn arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/12345678-1234-1234-1234-123456789012 \
    --csr file://certificate-request.csr \
    --signing-algorithm SHA256WITHRSA \
    --validity Value=365,Type=DAYS
```

## Troubleshooting

### Common Certificate Issues
```bash
# Issue 1: Certificate validation failing
# Check DNS records for validation
dig _acme-challenge.example.com CNAME

# Verify validation record exists
aws route53 list-resource-record-sets \
    --hosted-zone-id /hostedzone/Z1234567890123 \
    --query 'ResourceRecordSets[?contains(Name, `_acme-challenge`)]'

# Issue 2: Certificate not appearing in load balancer
# Ensure certificate is in the same region as load balancer
aws acm list-certificates --region us-east-1

# Issue 3: Browser showing certificate warnings
# Check certificate chain and SAN entries
openssl s_client -servername example.com -connect example.com:443 -showcerts

# Issue 4: Certificate renewal failing
# Check certificate status and renewal eligibility
aws acm describe-certificate \
    --certificate-arn $CERT_ARN \
    --query 'Certificate.[Status,RenewalEligibility,DomainValidationOptions[*].ValidationStatus]'
```

### Certificate Testing Script
```bash
#!/bin/bash
# test-ssl-certificate.sh

DOMAIN=${1:-example.com}
PORT=${2:-443}

echo "Testing SSL certificate for $DOMAIN:$PORT"
echo "================================================"

# Test 1: Basic connectivity
echo "1. Testing basic SSL connectivity..."
if timeout 10 bash -c "</dev/tcp/$DOMAIN/$PORT"; then
    echo "✓ SSL port is accessible"
else
    echo "✗ SSL port is not accessible"
    exit 1
fi

# Test 2: Certificate validity
echo "2. Checking certificate validity..."
CERT_EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null | openssl x509 -noout -enddate | cut -d= -f2)
EXPIRY_EPOCH=$(date -d "$CERT_EXPIRY" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS_UNTIL_EXPIRY=$(( (EXPIRY_EPOCH - CURRENT_EPOCH) / 86400 ))

echo "Certificate expires: $CERT_EXPIRY"
echo "Days until expiry: $DAYS_UNTIL_EXPIRY"

if [ $DAYS_UNTIL_EXPIRY -gt 30 ]; then
    echo "✓ Certificate is valid"
else
    echo "⚠️  Certificate expires soon!"
fi

# Test 3: Certificate chain
echo "3. Verifying certificate chain..."
CHAIN_VALID=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null | openssl verify)
if [[ $CHAIN_VALID == *"OK"* ]]; then
    echo "✓ Certificate chain is valid"
else
    echo "✗ Certificate chain validation failed"
fi

# Test 4: Protocol support
echo "4. Testing TLS protocol support..."
for protocol in tls1_2 tls1_3; do
    if echo | openssl s_client -$protocol -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null | grep -q "Verify return code: 0"; then
        echo "✓ $protocol supported"
    else
        echo "✗ $protocol not supported"
    fi
done

# Test 5: HTTP to HTTPS redirect
echo "5. Testing HTTP to HTTPS redirect..."
HTTP_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" http://$DOMAIN/)
if [ "$HTTP_RESPONSE" = "301" ] || [ "$HTTP_RESPONSE" = "302" ]; then
    echo "✓ HTTP to HTTPS redirect working"
else
    echo "✗ HTTP to HTTPS redirect not configured (HTTP response: $HTTP_RESPONSE)"
fi

# Test 6: Security headers
echo "6. Checking security headers..."
HEADERS=$(curl -s -I https://$DOMAIN/)

if echo "$HEADERS" | grep -q "Strict-Transport-Security"; then
    echo "✓ HSTS header present"
else
    echo "⚠️  HSTS header missing"
fi

if echo "$HEADERS" | grep -q "X-Content-Type-Options"; then
    echo "✓ X-Content-Type-Options header present"
else
    echo "⚠️  X-Content-Type-Options header missing"
fi

echo "================================================"
echo "SSL certificate test completed for $DOMAIN"
```

### Certificate Automation
```bash
#!/bin/bash
# certificate-automation.sh

# Automated certificate management for multiple domains
DOMAINS=("example.com" "api.example.com" "admin.example.com")
HOSTED_ZONE_ID="/hostedzone/Z1234567890123"
REGION="us-east-1"

# Function to request and validate certificate
request_certificate() {
    local primary_domain=$1
    shift
    local san_domains=("$@")
    
    echo "Requesting certificate for $primary_domain..."
    
    # Build SAN list
    local san_args=""
    for domain in "${san_domains[@]}"; do
        san_args="$san_args --subject-alternative-names $domain"
    done
    
    # Request certificate
    CERT_ARN=$(aws acm request-certificate \
        --domain-name $primary_domain \
        $san_args \
        --validation-method DNS \
        --region $REGION \
        --query 'CertificateArn' --output text)
    
    echo "Certificate requested: $CERT_ARN"
    
    # Wait a moment for validation records to be generated
    sleep 10
    
    # Get validation records and create DNS entries
    VALIDATION_RECORDS=$(aws acm describe-certificate \
        --certificate-arn $CERT_ARN \
        --region $REGION \
        --query 'Certificate.DomainValidationOptions[*].ResourceRecord')
    
    # Create validation DNS records
    echo "$VALIDATION_RECORDS" | jq -r '.[] | @base64' | while read record; do
        decoded=$(echo $record | base64 -d)
        name=$(echo $decoded | jq -r '.Name')
        type=$(echo $decoded | jq -r '.Type')
        value=$(echo $decoded | jq -r '.Value')
        
        aws route53 change-resource-record-sets \
            --hosted-zone-id $HOSTED_ZONE_ID \
            --change-batch '{
                "Changes": [{
                    "Action": "UPSERT",
                    "ResourceRecordSet": {
                        "Name": "'$name'",
                        "Type": "'$type'",
                        "TTL": 300,
                        "ResourceRecords": [{"Value": "'$value'"}]
                    }
                }]
            }'
    done
    
    # Wait for validation
    echo "Waiting for certificate validation..."
    aws acm wait certificate-validated --certificate-arn $CERT_ARN --region $REGION
    
    echo "Certificate validated: $CERT_ARN"
    return 0
}

# Request certificates for all domains
request_certificate "example.com" "www.example.com"
request_certificate "api.example.com"
request_certificate "admin.example.com"

echo "All certificates requested and validated!"
```

This comprehensive guide covers AWS Certificate Manager setup and SSL/TLS certificate management for secure containerized applications on AWS.
