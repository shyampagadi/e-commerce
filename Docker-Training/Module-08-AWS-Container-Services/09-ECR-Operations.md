# ECR Operations

## 🎯 Practical Objective
Master ECR registry operations: image lifecycle management, security scanning, cross-region replication, and CI/CD integration.

## 🚀 Lab 1: ECR Repository Setup and Image Management
```bash
# Create ECR repository
aws ecr create-repository \
    --repository-name my-app \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256

# Set lifecycle policy
cat > lifecycle-policy.json << EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 10 production images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["prod", "release"],
                "countType": "imageCountMoreThan",
                "countNumber": 10
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Delete untagged images after 1 day",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF

aws ecr put-lifecycle-policy \
    --repository-name my-app \
    --lifecycle-policy-text file://lifecycle-policy.json

# Build and push image
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

docker build -t my-app:latest .
docker tag my-app:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:latest
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/my-app:latest
```

## 🚀 Lab 2: Security Scanning and Compliance
```python
import boto3
import json

class ECRSecurityManager:
    def __init__(self):
        self.ecr = boto3.client('ecr')
        self.inspector = boto3.client('inspector2')
    
    def enable_enhanced_scanning(self, repository_name):
        # Enable enhanced scanning with Inspector v2
        response = self.ecr.put_registry_scanning_configuration(
            scanType='ENHANCED',
            rules=[
                {
                    'scanFrequency': 'CONTINUOUS_SCAN',
                    'repositoryFilters': [
                        {
                            'filter': repository_name,
                            'filterType': 'WILDCARD'
                        }
                    ]
                }
            ]
        )
        return response
    
    def get_vulnerability_report(self, repository_name, image_tag):
        # Get scan results
        response = self.ecr.describe_image_scan_findings(
            repositoryName=repository_name,
            imageId={'imageTag': image_tag}
        )
        
        findings = response['imageScanFindings']['findings']
        
        # Categorize vulnerabilities
        vulnerability_summary = {
            'CRITICAL': 0,
            'HIGH': 0,
            'MEDIUM': 0,
            'LOW': 0,
            'INFORMATIONAL': 0
        }
        
        for finding in findings:
            severity = finding['severity']
            vulnerability_summary[severity] += 1
        
        return {
            'summary': vulnerability_summary,
            'total_findings': len(findings),
            'scan_status': response['imageScanStatus']['status']
        }

# Usage
security_manager = ECRSecurityManager()
security_manager.enable_enhanced_scanning('my-app')
report = security_manager.get_vulnerability_report('my-app', 'latest')
print(json.dumps(report, indent=2))
```

## 🚀 Lab 3: Cross-Region Replication
```bash
# Set up replication configuration
cat > replication-config.json << EOF
{
    "rules": [
        {
            "destinations": [
                {
                    "region": "us-east-1",
                    "registryId": "123456789012"
                },
                {
                    "region": "eu-west-1",
                    "registryId": "123456789012"
                }
            ],
            "repositoryFilters": [
                {
                    "filter": "prod-*",
                    "filterType": "PREFIX_MATCH"
                }
            ]
        }
    ]
}
EOF

aws ecr put-replication-configuration \
    --replication-configuration file://replication-config.json
```

## 🎯 Assessment Questions
1. How do you implement automated image lifecycle management?
2. What are the security scanning capabilities of ECR?
3. How do you set up cross-region replication for disaster recovery?
4. What are the best practices for ECR repository organization?

---

**Great! You've mastered ECR operations. Ready for advanced topics?** 🚀
