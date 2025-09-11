# Security Groups and Network ACLs

## Overview
AWS provides two layers of network security: Security Groups (instance-level firewalls) and Network Access Control Lists (subnet-level firewalls). Understanding their differences and proper implementation is crucial for secure network architecture.

## Security Groups vs Network ACLs

### Comparison Matrix
| Feature | Security Groups | Network ACLs |
|---------|----------------|--------------|
| **Level** | Instance level | Subnet level |
| **Rules** | Allow rules only | Allow and deny rules |
| **State** | Stateful | Stateless |
| **Rule Evaluation** | All rules evaluated | Rules evaluated in order |
| **Default Behavior** | Deny all inbound, allow all outbound | Allow all traffic |
| **Association** | Multiple per instance | One per subnet |

## Security Groups

### Basic Security Group Configuration
```bash
# Create security group for web servers
aws ec2 create-security-group \
    --group-name web-server-sg \
    --description "Security group for web servers" \
    --vpc-id vpc-12345678

# Add HTTP access rule
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

# Add HTTPS access rule
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# Add SSH access from bastion host
aws ec2 authorize-security-group-ingress \
    --group-id sg-12345678 \
    --protocol tcp \
    --port 22 \
    --source-group sg-bastion-12345678
```

### Advanced Security Group Patterns

#### 1. Multi-Tier Application Security
```bash
# Web tier security group
aws ec2 create-security-group \
    --group-name web-tier-sg \
    --description "Web tier security group" \
    --vpc-id vpc-12345678

# Application tier security group
aws ec2 create-security-group \
    --group-name app-tier-sg \
    --description "Application tier security group" \
    --vpc-id vpc-12345678

# Database tier security group
aws ec2 create-security-group \
    --group-name db-tier-sg \
    --description "Database tier security group" \
    --vpc-id vpc-12345678

# Web tier rules (internet-facing)
aws ec2 authorize-security-group-ingress \
    --group-id sg-web-12345678 \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0

aws ec2 authorize-security-group-ingress \
    --group-id sg-web-12345678 \
    --protocol tcp \
    --port 443 \
    --cidr 0.0.0.0/0

# App tier rules (only from web tier)
aws ec2 authorize-security-group-ingress \
    --group-id sg-app-12345678 \
    --protocol tcp \
    --port 8080 \
    --source-group sg-web-12345678

# Database tier rules (only from app tier)
aws ec2 authorize-security-group-ingress \
    --group-id sg-db-12345678 \
    --protocol tcp \
    --port 3306 \
    --source-group sg-app-12345678
```

#### 2. Dynamic Security Group Management
```python
import boto3

class SecurityGroupManager:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
    
    def create_application_security_groups(self, vpc_id, app_name):
        """Create a complete set of security groups for a multi-tier application"""
        
        security_groups = {}
        
        # Web tier
        web_sg = self.ec2.create_security_group(
            GroupName=f'{app_name}-web-sg',
            Description=f'Web tier security group for {app_name}',
            VpcId=vpc_id
        )
        security_groups['web'] = web_sg['GroupId']
        
        # App tier
        app_sg = self.ec2.create_security_group(
            GroupName=f'{app_name}-app-sg',
            Description=f'Application tier security group for {app_name}',
            VpcId=vpc_id
        )
        security_groups['app'] = app_sg['GroupId']
        
        # Database tier
        db_sg = self.ec2.create_security_group(
            GroupName=f'{app_name}-db-sg',
            Description=f'Database tier security group for {app_name}',
            VpcId=vpc_id
        )
        security_groups['db'] = db_sg['GroupId']
        
        # Configure rules
        self.configure_web_tier_rules(security_groups['web'])
        self.configure_app_tier_rules(security_groups['app'], security_groups['web'])
        self.configure_db_tier_rules(security_groups['db'], security_groups['app'])
        
        return security_groups
    
    def configure_web_tier_rules(self, sg_id):
        """Configure web tier security group rules"""
        rules = [
            {'IpProtocol': 'tcp', 'FromPort': 80, 'ToPort': 80, 'IpRanges': [{'CidrIp': '0.0.0.0/0'}]},
            {'IpProtocol': 'tcp', 'FromPort': 443, 'ToPort': 443, 'IpRanges': [{'CidrIp': '0.0.0.0/0'}]}
        ]
        
        self.ec2.authorize_security_group_ingress(
            GroupId=sg_id,
            IpPermissions=rules
        )
    
    def configure_app_tier_rules(self, sg_id, web_sg_id):
        """Configure application tier security group rules"""
        rules = [
            {
                'IpProtocol': 'tcp',
                'FromPort': 8080,
                'ToPort': 8080,
                'UserIdGroupPairs': [{'GroupId': web_sg_id}]
            }
        ]
        
        self.ec2.authorize_security_group_ingress(
            GroupId=sg_id,
            IpPermissions=rules
        )
    
    def configure_db_tier_rules(self, sg_id, app_sg_id):
        """Configure database tier security group rules"""
        rules = [
            {
                'IpProtocol': 'tcp',
                'FromPort': 3306,
                'ToPort': 3306,
                'UserIdGroupPairs': [{'GroupId': app_sg_id}]
            }
        ]
        
        self.ec2.authorize_security_group_ingress(
            GroupId=sg_id,
            IpPermissions=rules
        )
```

## Network Access Control Lists (NACLs)

### Basic NACL Configuration
```bash
# Create custom NACL
aws ec2 create-network-acl --vpc-id vpc-12345678

# Add inbound rule (allow HTTP)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0

# Add inbound rule (allow HTTPS)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0

# Add outbound rule (allow all)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-12345678 \
    --rule-number 100 \
    --protocol -1 \
    --rule-action allow \
    --cidr-block 0.0.0.0/0 \
    --egress

# Associate NACL with subnet
aws ec2 associate-network-acl \
    --network-acl-id acl-12345678 \
    --subnet-id subnet-12345678
```

### Advanced NACL Patterns

#### 1. DMZ Network ACL
```bash
# Create DMZ NACL for public subnets
aws ec2 create-network-acl --vpc-id vpc-12345678

# Inbound rules
# Allow HTTP from internet
aws ec2 create-network-acl-entry \
    --network-acl-id acl-dmz-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=80,To=80 \
    --cidr-block 0.0.0.0/0

# Allow HTTPS from internet
aws ec2 create-network-acl-entry \
    --network-acl-id acl-dmz-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=443,To=443 \
    --cidr-block 0.0.0.0/0

# Allow SSH from management network
aws ec2 create-network-acl-entry \
    --network-acl-id acl-dmz-12345678 \
    --rule-number 120 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=22,To=22 \
    --cidr-block 10.0.100.0/24

# Allow ephemeral ports for return traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-dmz-12345678 \
    --rule-number 130 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=1024,To=65535 \
    --cidr-block 0.0.0.0/0

# Outbound rules
# Allow all outbound traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-dmz-12345678 \
    --rule-number 100 \
    --protocol -1 \
    --rule-action allow \
    --cidr-block 0.0.0.0/0 \
    --egress
```

#### 2. Private Subnet NACL
```bash
# Create private subnet NACL
aws ec2 create-network-acl --vpc-id vpc-12345678

# Inbound rules
# Allow traffic from DMZ subnet
aws ec2 create-network-acl-entry \
    --network-acl-id acl-private-12345678 \
    --rule-number 100 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=8080,To=8080 \
    --cidr-block 10.0.1.0/24

# Allow return traffic on ephemeral ports
aws ec2 create-network-acl-entry \
    --network-acl-id acl-private-12345678 \
    --rule-number 110 \
    --protocol tcp \
    --rule-action allow \
    --port-range From=1024,To=65535 \
    --cidr-block 0.0.0.0/0

# Deny all other inbound traffic
aws ec2 create-network-acl-entry \
    --network-acl-id acl-private-12345678 \
    --rule-number 200 \
    --protocol -1 \
    --rule-action deny \
    --cidr-block 0.0.0.0/0

# Outbound rules
# Allow outbound to internet (for updates, etc.)
aws ec2 create-network-acl-entry \
    --network-acl-id acl-private-12345678 \
    --rule-number 100 \
    --protocol -1 \
    --rule-action allow \
    --cidr-block 0.0.0.0/0 \
    --egress
```

## Security Best Practices

### 1. Principle of Least Privilege
```python
class SecurityGroupBestPractices:
    def __init__(self):
        self.best_practices = {
            'port_ranges': {
                'avoid': 'Using 0.0.0.0/0 for SSH (port 22)',
                'prefer': 'Specific IP ranges or bastion host security groups'
            },
            'protocols': {
                'avoid': 'Opening all protocols (-1)',
                'prefer': 'Specific protocols (tcp, udp, icmp)'
            },
            'sources': {
                'avoid': 'Using 0.0.0.0/0 for internal services',
                'prefer': 'Specific security groups or IP ranges'
            }
        }
    
    def validate_security_group_rules(self, rules):
        violations = []
        
        for rule in rules:
            # Check for overly permissive SSH access
            if (rule.get('FromPort') == 22 and 
                any(ip_range.get('CidrIp') == '0.0.0.0/0' for ip_range in rule.get('IpRanges', []))):
                violations.append('SSH access open to internet')
            
            # Check for all protocols open
            if rule.get('IpProtocol') == '-1':
                violations.append('All protocols allowed')
            
            # Check for wide port ranges
            if (rule.get('FromPort', 0) == 0 and rule.get('ToPort', 0) == 65535):
                violations.append('All ports open')
        
        return violations
```

### 2. Defense in Depth Strategy
```yaml
Security Layers:
  Layer 1 - Network ACLs:
    - Subnet-level filtering
    - Stateless rules
    - Broad traffic control
    
  Layer 2 - Security Groups:
    - Instance-level filtering
    - Stateful rules
    - Granular access control
    
  Layer 3 - Host-based Firewalls:
    - OS-level filtering
    - Application-specific rules
    - Process-level control
    
  Layer 4 - Application Security:
    - Input validation
    - Authentication/authorization
    - Encryption
```

### 3. Automated Security Group Management
```python
import boto3
import json

class AutomatedSecurityManagement:
    def __init__(self):
        self.ec2 = boto3.client('ec2')
        self.config = boto3.client('config')
    
    def audit_security_groups(self):
        """Audit all security groups for compliance violations"""
        security_groups = self.ec2.describe_security_groups()
        violations = []
        
        for sg in security_groups['SecurityGroups']:
            sg_violations = self.check_security_group_compliance(sg)
            if sg_violations:
                violations.append({
                    'SecurityGroupId': sg['GroupId'],
                    'GroupName': sg['GroupName'],
                    'Violations': sg_violations
                })
        
        return violations
    
    def check_security_group_compliance(self, security_group):
        """Check individual security group for compliance"""
        violations = []
        
        for rule in security_group.get('IpPermissions', []):
            # Check for SSH open to world
            if (rule.get('FromPort') == 22 and 
                any(ip_range.get('CidrIp') == '0.0.0.0/0' 
                    for ip_range in rule.get('IpRanges', []))):
                violations.append('SSH_OPEN_TO_WORLD')
            
            # Check for RDP open to world
            if (rule.get('FromPort') == 3389 and 
                any(ip_range.get('CidrIp') == '0.0.0.0/0' 
                    for ip_range in rule.get('IpRanges', []))):
                violations.append('RDP_OPEN_TO_WORLD')
            
            # Check for database ports open to world
            db_ports = [3306, 5432, 1433, 27017]
            if (rule.get('FromPort') in db_ports and 
                any(ip_range.get('CidrIp') == '0.0.0.0/0' 
                    for ip_range in rule.get('IpRanges', []))):
                violations.append('DATABASE_OPEN_TO_WORLD')
        
        return violations
    
    def remediate_security_group_violations(self, security_group_id, violations):
        """Automatically remediate common security group violations"""
        for violation in violations:
            if violation == 'SSH_OPEN_TO_WORLD':
                self.restrict_ssh_access(security_group_id)
            elif violation == 'RDP_OPEN_TO_WORLD':
                self.restrict_rdp_access(security_group_id)
            elif violation == 'DATABASE_OPEN_TO_WORLD':
                self.restrict_database_access(security_group_id)
    
    def restrict_ssh_access(self, security_group_id):
        """Remove SSH access from 0.0.0.0/0 and add bastion host access"""
        # Remove overly permissive rule
        self.ec2.revoke_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=[{
                'IpProtocol': 'tcp',
                'FromPort': 22,
                'ToPort': 22,
                'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
            }]
        )
        
        # Add restricted access (example: company IP range)
        self.ec2.authorize_security_group_ingress(
            GroupId=security_group_id,
            IpPermissions=[{
                'IpProtocol': 'tcp',
                'FromPort': 22,
                'ToPort': 22,
                'IpRanges': [{'CidrIp': '203.0.113.0/24', 'Description': 'Company IP range'}]
            }]
        )
```

## Monitoring and Alerting

### VPC Flow Logs for Security Monitoring
```bash
# Enable VPC Flow Logs
aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-ids vpc-12345678 \
    --traffic-type ALL \
    --log-destination-type cloud-watch-logs \
    --log-group-name VPCFlowLogs \
    --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flowlogsRole

# Query flow logs for security analysis
aws logs filter-log-events \
    --log-group-name VPCFlowLogs \
    --filter-pattern '[version, account, eni, source, destination, srcport, destport="22", protocol="6", packets, bytes, windowstart, windowend, action="REJECT"]'
```

### CloudWatch Alarms for Security Events
```bash
# Create alarm for rejected SSH connections
aws cloudwatch put-metric-alarm \
    --alarm-name "SSH-Connection-Rejected" \
    --alarm-description "Alert on rejected SSH connections" \
    --metric-name "SSH_Rejected_Connections" \
    --namespace "VPC/FlowLogs" \
    --statistic "Sum" \
    --period 300 \
    --threshold 10 \
    --comparison-operator "GreaterThanThreshold" \
    --evaluation-periods 2

# Create alarm for unusual outbound traffic
aws cloudwatch put-metric-alarm \
    --alarm-name "Unusual-Outbound-Traffic" \
    --alarm-description "Alert on unusual outbound traffic patterns" \
    --metric-name "OutboundBytes" \
    --namespace "VPC/FlowLogs" \
    --statistic "Sum" \
    --period 300 \
    --threshold 1000000000 \
    --comparison-operator "GreaterThanThreshold" \
    --evaluation-periods 1
```

## Troubleshooting Common Issues

### Security Group Troubleshooting
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids sg-12345678

# Test connectivity
telnet target-host 80
nc -zv target-host 80

# Check instance security groups
aws ec2 describe-instances --instance-ids i-12345678 --query 'Reservations[*].Instances[*].SecurityGroups'

# Verify rule evaluation order (NACLs)
aws ec2 describe-network-acls --network-acl-ids acl-12345678 --query 'NetworkAcls[*].Entries'
```

### Common Connectivity Issues
```python
class NetworkTroubleshooting:
    def __init__(self):
        self.common_issues = {
            'connection_timeout': [
                'Check security group inbound rules',
                'Verify NACL allows traffic',
                'Confirm target service is running',
                'Check route table configuration'
            ],
            'connection_refused': [
                'Verify service is listening on correct port',
                'Check host-based firewall rules',
                'Confirm application configuration',
                'Validate security group rules'
            ],
            'intermittent_connectivity': [
                'Check NACL stateless nature',
                'Verify ephemeral port ranges',
                'Monitor for capacity issues',
                'Check for asymmetric routing'
            ]
        }
    
    def diagnose_connectivity_issue(self, source_ip, destination_ip, port):
        """Systematic approach to diagnosing connectivity issues"""
        checks = [
            self.check_security_groups(destination_ip, port),
            self.check_network_acls(destination_ip, port),
            self.check_route_tables(source_ip, destination_ip),
            self.check_service_availability(destination_ip, port)
        ]
        
        return {
            'source': source_ip,
            'destination': destination_ip,
            'port': port,
            'checks': checks
        }
```

## Best Practices Summary

### Security Groups
1. **Use descriptive names** and descriptions for all security groups
2. **Apply principle of least privilege** - only allow necessary traffic
3. **Use security group references** instead of IP addresses when possible
4. **Regularly audit** security group rules for compliance
5. **Tag security groups** for better organization and management

### Network ACLs
1. **Use NACLs as subnet-level controls** for additional security layer
2. **Remember stateless nature** - configure both inbound and outbound rules
3. **Plan rule numbering** carefully for future modifications
4. **Test thoroughly** as NACL misconfigurations can break connectivity
5. **Document rule purposes** for maintenance and troubleshooting

### General Network Security
1. **Implement defense in depth** with multiple security layers
2. **Monitor network traffic** using VPC Flow Logs
3. **Automate compliance checking** to catch violations early
4. **Use AWS Config rules** for continuous compliance monitoring
5. **Regular security assessments** and penetration testing
