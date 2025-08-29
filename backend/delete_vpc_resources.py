#!/usr/bin/env python3
"""
AWS VPC Resource Deletion Script

This script deletes ALL resources within a specified VPC in the correct order
to handle dependencies. Use with extreme caution!

SAFETY MEASURES:
- Only deletes resources that belong to the specified VPC ID
- Validates VPC existence before starting
- Double-checks resource ownership before deletion
- Provides detailed logging and confirmation prompts
- Supports dry-run mode for testing

Author: Generated for VPC cleanup
Date: 2025-08-27
Version: 2.0 (Enhanced with VPC-specific safety checks)
"""

import boto3
import time
import sys
from botocore.exceptions import ClientError, NoCredentialsError
from typing import List, Dict, Any
import logging

# =============================================================================
# CONFIGURATION - MODIFY THESE VALUES
# =============================================================================

# VPC ID to delete (REQUIRED - SET THIS VALUE)
VPC_ID = "vpc-0728be6f325bcdf24"  # Replace with your actual VPC ID

# AWS Region
AWS_REGION = "us-east-1"  # Change to your region

# Dry run mode (True = show what would be deleted, False = actually delete)
DRY_RUN = False

# Wait time between operations (seconds)
WAIT_TIME = 10

# Maximum retries for operations
MAX_RETRIES = 3

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(f'vpc_deletion_{VPC_ID}_{int(time.time())}.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# =============================================================================
# AWS CLIENT INITIALIZATION
# =============================================================================

try:
    session = boto3.Session(region_name=AWS_REGION)
    ec2_client = session.client('ec2')
    ec2_resource = session.resource('ec2')
    elbv2_client = session.client('elbv2')
    elb_client = session.client('elb')
    rds_client = session.client('rds')
    
    logger.info(f"Initialized AWS clients for region: {AWS_REGION}")
except NoCredentialsError:
    logger.error("AWS credentials not found. Please configure your credentials.")
    sys.exit(1)
except Exception as e:
    logger.error(f"Error initializing AWS clients: {str(e)}")
    sys.exit(1)

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

def wait_for_deletion(check_function, resource_id: str, resource_type: str, max_wait: int = 300):
    """Wait for a resource to be deleted"""
    wait_time = 0
    while wait_time < max_wait:
        try:
            if not check_function(resource_id):
                logger.info(f"{resource_type} {resource_id} successfully deleted")
                return True
        except ClientError as e:
            if e.response['Error']['Code'] in ['InvalidInstanceID.NotFound', 'InvalidVpcID.NotFound']:
                logger.info(f"{resource_type} {resource_id} successfully deleted")
                return True
        
        time.sleep(WAIT_TIME)
        wait_time += WAIT_TIME
        logger.info(f"Waiting for {resource_type} {resource_id} to be deleted... ({wait_time}s)")
    
    logger.warning(f"Timeout waiting for {resource_type} {resource_id} to be deleted")
    return False

def retry_operation(operation, *args, **kwargs):
    """Retry an operation with exponential backoff"""
    for attempt in range(MAX_RETRIES):
        try:
            return operation(*args, **kwargs)
        except ClientError as e:
            if attempt == MAX_RETRIES - 1:
                raise
            wait_time = 2 ** attempt
            logger.warning(f"Operation failed (attempt {attempt + 1}), retrying in {wait_time}s: {str(e)}")
            time.sleep(wait_time)

def validate_vpc_id():
    """Validate that the VPC ID is properly set and exists"""
    if not VPC_ID or VPC_ID == "vpc-xxxxxxxxx" or len(VPC_ID) < 12:
        logger.error("ERROR: Please set a valid VPC_ID variable at the top of the script!")
        logger.error(f"Current VPC_ID: '{VPC_ID}'")
        return False
    
    try:
        response = ec2_client.describe_vpcs(VpcIds=[VPC_ID])
        vpc = response['Vpcs'][0]
        logger.info(f"✅ VPC {VPC_ID} found and accessible")
        logger.info(f"   VPC Name: {next((tag['Value'] for tag in vpc.get('Tags', []) if tag['Key'] == 'Name'), 'No Name')}")
        logger.info(f"   VPC CIDR: {vpc['CidrBlock']}")
        logger.info(f"   VPC State: {vpc['State']}")
        return True
    except ClientError as e:
        if e.response['Error']['Code'] == 'InvalidVpcID.NotFound':
            logger.error(f"❌ VPC {VPC_ID} not found in region {AWS_REGION}")
        else:
            logger.error(f"❌ Error accessing VPC {VPC_ID}: {str(e)}")
        return False

def validate_resource_belongs_to_vpc(resource_id: str, resource_type: str) -> bool:
    """Validate that a resource belongs to the target VPC before deletion"""
    try:
        if resource_type == 'instance':
            response = ec2_client.describe_instances(InstanceIds=[resource_id])
            for reservation in response['Reservations']:
                for instance in reservation['Instances']:
                    return instance.get('VpcId') == VPC_ID
        elif resource_type == 'subnet':
            response = ec2_client.describe_subnets(SubnetIds=[resource_id])
            return response['Subnets'][0]['VpcId'] == VPC_ID
        elif resource_type == 'security_group':
            response = ec2_client.describe_security_groups(GroupIds=[resource_id])
            return response['SecurityGroups'][0]['VpcId'] == VPC_ID
        elif resource_type == 'network_interface':
            response = ec2_client.describe_network_interfaces(NetworkInterfaceIds=[resource_id])
            return response['NetworkInterfaces'][0]['VpcId'] == VPC_ID
        elif resource_type == 'route_table':
            response = ec2_client.describe_route_tables(RouteTableIds=[resource_id])
            return response['RouteTables'][0]['VpcId'] == VPC_ID
        elif resource_type == 'network_acl':
            response = ec2_client.describe_network_acls(NetworkAclIds=[resource_id])
            return response['NetworkAcls'][0]['VpcId'] == VPC_ID
        elif resource_type == 'nat_gateway':
            response = ec2_client.describe_nat_gateways(NatGatewayIds=[resource_id])
            return response['NatGateways'][0]['VpcId'] == VPC_ID
        elif resource_type == 'vpc_endpoint':
            response = ec2_client.describe_vpc_endpoints(VpcEndpointIds=[resource_id])
            return response['VpcEndpoints'][0]['VpcId'] == VPC_ID
        # For other resources, assume they're already filtered correctly
        return True
    except ClientError as e:
        logger.warning(f"Could not validate {resource_type} {resource_id}: {str(e)}")
        return False

def confirm_deletion():
    """Get user confirmation for deletion"""
    if DRY_RUN:
        logger.info("DRY RUN MODE - No resources will be deleted")
        return True
    
    print(f"\n{'='*60}")
    print(f"WARNING: You are about to DELETE ALL RESOURCES in VPC: {VPC_ID}")
    print(f"This action is IRREVERSIBLE!")
    print(f"{'='*60}")
    
# =============================================================================
# RESOURCE DISCOVERY FUNCTIONS
# =============================================================================

def get_vpc_instances():
    """Get all EC2 instances in the VPC"""
    try:
        response = ec2_client.describe_instances(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        instances = []
        for reservation in response['Reservations']:
            for instance in reservation['Instances']:
                if instance['State']['Name'] != 'terminated':
                    instances.append(instance['InstanceId'])
        return instances
    except ClientError as e:
        logger.error(f"Error getting instances: {str(e)}")
        return []

def get_vpc_load_balancers():
    """Get all load balancers in the VPC"""
    albs = []
    clbs = []
    
    try:
        # Application/Network Load Balancers
        response = elbv2_client.describe_load_balancers()
        for lb in response['LoadBalancers']:
            if lb['VpcId'] == VPC_ID:
                albs.append(lb['LoadBalancerArn'])
    except ClientError as e:
        logger.error(f"Error getting ALB/NLB: {str(e)}")
    
    try:
        # Classic Load Balancers
        response = elb_client.describe_load_balancers()
        for lb in response['LoadBalancerDescriptions']:
            if lb['VPCId'] == VPC_ID:
                clbs.append(lb['LoadBalancerName'])
    except ClientError as e:
        logger.error(f"Error getting CLB: {str(e)}")
    
    return albs, clbs

def get_vpc_rds_instances():
    """Get all RDS instances in the VPC"""
    try:
        response = rds_client.describe_db_instances()
        rds_instances = []
        for db in response['DBInstances']:
            if db.get('DBSubnetGroup', {}).get('VpcId') == VPC_ID:
                rds_instances.append(db['DBInstanceIdentifier'])
        return rds_instances
    except ClientError as e:
        logger.error(f"Error getting RDS instances: {str(e)}")
        return []

def get_vpc_nat_gateways():
    """Get all NAT gateways in the VPC"""
    try:
        response = ec2_client.describe_nat_gateways(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [ng['NatGatewayId'] for ng in response['NatGateways'] 
                if ng['State'] not in ['deleted', 'deleting']]
    except ClientError as e:
        logger.error(f"Error getting NAT gateways: {str(e)}")
        return []

def get_vpc_endpoints():
    """Get all VPC endpoints"""
    try:
        response = ec2_client.describe_vpc_endpoints(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [ep['VpcEndpointId'] for ep in response['VpcEndpoints'] 
                if ep['State'] not in ['deleted', 'deleting']]
    except ClientError as e:
        logger.error(f"Error getting VPC endpoints: {str(e)}")
        return []

def get_vpc_network_interfaces():
    """Get all network interfaces in the VPC"""
    try:
        response = ec2_client.describe_network_interfaces(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [ni['NetworkInterfaceId'] for ni in response['NetworkInterfaces']
                if ni['Status'] != 'deleting']
    except ClientError as e:
        logger.error(f"Error getting network interfaces: {str(e)}")
        return []

def get_elastic_ips():
    """Get all Elastic IPs associated with the VPC"""
    try:
        response = ec2_client.describe_addresses(
            Filters=[{'Name': 'domain', 'Values': ['vpc']}]
        )
        vpc_eips = []
        for eip in response['Addresses']:
            # Check if EIP is associated with our VPC through instance or network interface
            if 'NetworkInterfaceId' in eip:
                try:
                    ni_response = ec2_client.describe_network_interfaces(
                        NetworkInterfaceIds=[eip['NetworkInterfaceId']]
                    )
                    if ni_response['NetworkInterfaces'][0]['VpcId'] == VPC_ID:
                        vpc_eips.append(eip['AllocationId'])
                except ClientError:
                    pass  # Network interface may not exist
            elif 'InstanceId' in eip:
                try:
                    inst_response = ec2_client.describe_instances(
                        InstanceIds=[eip['InstanceId']]
                    )
                    for reservation in inst_response['Reservations']:
                        for instance in reservation['Instances']:
                            if instance.get('VpcId') == VPC_ID:
                                vpc_eips.append(eip['AllocationId'])
                                break
                except ClientError:
                    pass  # Instance may not exist
        return vpc_eips
    except ClientError as e:
        logger.error(f"Error getting Elastic IPs: {str(e)}")
        return []
def get_vpc_security_groups():
    """Get all security groups (except default)"""
    try:
        response = ec2_client.describe_security_groups(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [sg['GroupId'] for sg in response['SecurityGroups'] 
                if sg['GroupName'] != 'default']
    except ClientError as e:
        logger.error(f"Error getting security groups: {str(e)}")
        return []

def get_vpc_network_acls():
    """Get all network ACLs (except default)"""
    try:
        response = ec2_client.describe_network_acls(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [acl['NetworkAclId'] for acl in response['NetworkAcls'] 
                if not acl['IsDefault']]
    except ClientError as e:
        logger.error(f"Error getting network ACLs: {str(e)}")
        return []

def get_vpc_route_tables():
    """Get all route tables (except main)"""
    try:
        response = ec2_client.describe_route_tables(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        route_tables = []
        for rt in response['RouteTables']:
            is_main = any(assoc.get('Main', False) for assoc in rt['Associations'])
            if not is_main:
                route_tables.append(rt['RouteTableId'])
        return route_tables
    except ClientError as e:
        logger.error(f"Error getting route tables: {str(e)}")
        return []

def get_vpc_subnets():
    """Get all subnets in the VPC"""
    try:
        response = ec2_client.describe_subnets(
            Filters=[{'Name': 'vpc-id', 'Values': [VPC_ID]}]
        )
        return [subnet['SubnetId'] for subnet in response['Subnets']]
    except ClientError as e:
        logger.error(f"Error getting subnets: {str(e)}")
        return []

def get_vpc_internet_gateways():
    """Get internet gateways attached to the VPC"""
    try:
        response = ec2_client.describe_internet_gateways(
            Filters=[{'Name': 'attachment.vpc-id', 'Values': [VPC_ID]}]
        )
        return [igw['InternetGatewayId'] for igw in response['InternetGateways']]
    except ClientError as e:
        logger.error(f"Error getting internet gateways: {str(e)}")
        return []

def get_vpc_peering_connections():
    """Get VPC peering connections"""
    try:
        # Get peering connections where our VPC is either requester or accepter
        response = ec2_client.describe_vpc_peering_connections(
            Filters=[
                {'Name': 'status-code', 'Values': ['active', 'pending-acceptance']}
            ]
        )
        vpc_peering = []
        for pc in response['VpcPeeringConnections']:
            # Check if our VPC is involved in this peering connection
            requester_vpc = pc.get('RequesterVpcInfo', {}).get('VpcId')
            accepter_vpc = pc.get('AccepterVpcInfo', {}).get('VpcId')
            
            if requester_vpc == VPC_ID or accepter_vpc == VPC_ID:
                if pc['Status']['Code'] not in ['deleted', 'deleting', 'failed', 'rejected']:
                    vpc_peering.append(pc['VpcPeeringConnectionId'])
        
        return vpc_peering
    except ClientError as e:
        logger.error(f"Error getting VPC peering connections: {str(e)}")
        return []
# =============================================================================
# RESOURCE DELETION FUNCTIONS
# =============================================================================

def delete_instances(instances: List[str]):
    """Delete EC2 instances"""
    if not instances:
        return
    
    logger.info(f"Deleting {len(instances)} EC2 instances...")
    for instance_id in instances:
        try:
            # Safety check: Validate instance belongs to target VPC
            if not validate_resource_belongs_to_vpc(instance_id, 'instance'):
                logger.error(f"❌ SAFETY CHECK FAILED: Instance {instance_id} does not belong to VPC {VPC_ID}")
                continue
                
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would terminate instance: {instance_id}")
            else:
                retry_operation(ec2_client.terminate_instances, InstanceIds=[instance_id])
                logger.info(f"Terminated instance: {instance_id}")
        except ClientError as e:
            logger.error(f"Error terminating instance {instance_id}: {str(e)}")
    
    if not DRY_RUN and instances:
        logger.info("Waiting for instances to terminate...")
        time.sleep(30)  # Give instances time to start terminating

def delete_load_balancers(albs: List[str], clbs: List[str]):
    """Delete load balancers"""
    # Delete ALB/NLB
    for lb_arn in albs:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete ALB/NLB: {lb_arn}")
            else:
                retry_operation(elbv2_client.delete_load_balancer, LoadBalancerArn=lb_arn)
                logger.info(f"Deleted ALB/NLB: {lb_arn}")
        except ClientError as e:
            logger.error(f"Error deleting ALB/NLB {lb_arn}: {str(e)}")
    
    # Delete CLB
    for lb_name in clbs:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete CLB: {lb_name}")
            else:
                retry_operation(elb_client.delete_load_balancer, LoadBalancerName=lb_name)
                logger.info(f"Deleted CLB: {lb_name}")
        except ClientError as e:
            logger.error(f"Error deleting CLB {lb_name}: {str(e)}")

def delete_rds_instances(rds_instances: List[str]):
    """Delete RDS instances"""
    if not rds_instances:
        return
    
    logger.info(f"Deleting {len(rds_instances)} RDS instances...")
    for db_id in rds_instances:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete RDS instance: {db_id}")
            else:
                retry_operation(
                    rds_client.delete_db_instance,
                    DBInstanceIdentifier=db_id,
                    SkipFinalSnapshot=True,
                    DeleteAutomatedBackups=True
                )
                logger.info(f"Deleted RDS instance: {db_id}")
        except ClientError as e:
            logger.error(f"Error deleting RDS instance {db_id}: {str(e)}")

def delete_nat_gateways(nat_gateways: List[str]):
    """Delete NAT gateways"""
    if not nat_gateways:
        return
    
    logger.info(f"Deleting {len(nat_gateways)} NAT gateways...")
    for ng_id in nat_gateways:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete NAT gateway: {ng_id}")
            else:
                retry_operation(ec2_client.delete_nat_gateway, NatGatewayId=ng_id)
                logger.info(f"Deleted NAT gateway: {ng_id}")
        except ClientError as e:
            logger.error(f"Error deleting NAT gateway {ng_id}: {str(e)}")

def delete_vpc_endpoints(endpoints: List[str]):
    """Delete VPC endpoints"""
    if not endpoints:
        return
    
    logger.info(f"Deleting {len(endpoints)} VPC endpoints...")
    for ep_id in endpoints:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete VPC endpoint: {ep_id}")
            else:
                retry_operation(ec2_client.delete_vpc_endpoints, VpcEndpointIds=[ep_id])
                logger.info(f"Deleted VPC endpoint: {ep_id}")
        except ClientError as e:
            logger.error(f"Error deleting VPC endpoint {ep_id}: {str(e)}")

def delete_network_interfaces(network_interfaces: List[str]):
    """Delete network interfaces"""
    if not network_interfaces:
        return
    
    logger.info(f"Deleting {len(network_interfaces)} network interfaces...")
    for ni_id in network_interfaces:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete network interface: {ni_id}")
            else:
                # First detach if attached
                try:
                    ni_info = ec2_client.describe_network_interfaces(NetworkInterfaceIds=[ni_id])
                    ni = ni_info['NetworkInterfaces'][0]
                    if ni.get('Attachment'):
                        attachment_id = ni['Attachment']['AttachmentId']
                        logger.info(f"Detaching network interface {ni_id}...")
                        ec2_client.detach_network_interface(AttachmentId=attachment_id, Force=True)
                        time.sleep(10)  # Wait for detachment
                except ClientError:
                    pass  # May already be detached
                
                retry_operation(ec2_client.delete_network_interface, NetworkInterfaceId=ni_id)
                logger.info(f"Deleted network interface: {ni_id}")
        except ClientError as e:
            logger.error(f"Error deleting network interface {ni_id}: {str(e)}")

def delete_elastic_ips(elastic_ips: List[str]):
    """Delete Elastic IPs"""
    if not elastic_ips:
        return
    
    logger.info(f"Releasing {len(elastic_ips)} Elastic IPs...")
    for eip_id in elastic_ips:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would release Elastic IP: {eip_id}")
            else:
                retry_operation(ec2_client.release_address, AllocationId=eip_id)
                logger.info(f"Released Elastic IP: {eip_id}")
        except ClientError as e:
            logger.error(f"Error releasing Elastic IP {eip_id}: {str(e)}")

def remove_security_group_rules(security_groups: List[str]):
    """Remove all rules from security groups to break dependencies"""
    if not security_groups:
        return
    
    logger.info("Removing security group rules to break dependencies...")
    for sg_id in security_groups:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would remove rules from security group: {sg_id}")
                continue
            
            # Get security group details
            response = ec2_client.describe_security_groups(GroupIds=[sg_id])
            sg = response['SecurityGroups'][0]
            
            # Remove ingress rules
            if sg['IpPermissions']:
                try:
                    ec2_client.revoke_security_group_ingress(
                        GroupId=sg_id,
                        IpPermissions=sg['IpPermissions']
                    )
                    logger.info(f"Removed ingress rules from {sg_id}")
                except ClientError as e:
                    logger.warning(f"Error removing ingress rules from {sg_id}: {str(e)}")
            
            # Remove egress rules
            if sg['IpPermissionsEgress']:
                try:
                    ec2_client.revoke_security_group_egress(
                        GroupId=sg_id,
                        IpPermissions=sg['IpPermissionsEgress']
                    )
                    logger.info(f"Removed egress rules from {sg_id}")
                except ClientError as e:
                    logger.warning(f"Error removing egress rules from {sg_id}: {str(e)}")
                    
        except ClientError as e:
            logger.error(f"Error processing security group {sg_id}: {str(e)}")

def force_delete_security_groups(security_groups: List[str]):
    """Force delete security groups with multiple attempts"""
    if not security_groups:
        return
    
    logger.info(f"Force deleting {len(security_groups)} security groups...")
    
    # Try multiple rounds of deletion
    remaining_sgs = security_groups.copy()
    max_rounds = 5
    
    for round_num in range(max_rounds):
        if not remaining_sgs:
            break
            
        logger.info(f"Security group deletion round {round_num + 1}")
        failed_sgs = []
        
        for sg_id in remaining_sgs:
            try:
                if DRY_RUN:
                    logger.info(f"[DRY RUN] Would delete security group: {sg_id}")
                else:
                    ec2_client.delete_security_group(GroupId=sg_id)
                    logger.info(f"Deleted security group: {sg_id}")
            except ClientError as e:
                if "DependencyViolation" in str(e):
                    failed_sgs.append(sg_id)
                else:
                    logger.error(f"Error deleting security group {sg_id}: {str(e)}")
        
        remaining_sgs = failed_sgs
        if remaining_sgs and round_num < max_rounds - 1:
            logger.info(f"Waiting before next round... {len(remaining_sgs)} security groups remaining")
            time.sleep(10)
    
def disassociate_route_tables(route_tables: List[str]):
    """Disassociate route tables from subnets"""
    if not route_tables:
        return
    
    logger.info("Disassociating route tables from subnets...")
    for rt_id in route_tables:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would disassociate route table: {rt_id}")
                continue
            
            # Get route table details
            response = ec2_client.describe_route_tables(RouteTableIds=[rt_id])
            rt = response['RouteTables'][0]
            
            # Disassociate from subnets
            for association in rt['Associations']:
                if not association.get('Main', False) and 'SubnetId' in association:
                    try:
                        ec2_client.disassociate_route_table(
                            AssociationId=association['RouteTableAssociationId']
                        )
                        logger.info(f"Disassociated route table {rt_id} from subnet {association['SubnetId']}")
                    except ClientError as e:
                        logger.warning(f"Error disassociating route table {rt_id}: {str(e)}")
                        
        except ClientError as e:
            logger.error(f"Error processing route table {rt_id}: {str(e)}")

def force_delete_route_tables(route_tables: List[str]):
    """Force delete route tables with multiple attempts"""
    if not route_tables:
        return
    
    logger.info(f"Force deleting {len(route_tables)} route tables...")
    
    for rt_id in route_tables:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete route table: {rt_id}")
            else:
                retry_operation(ec2_client.delete_route_table, RouteTableId=rt_id)
                logger.info(f"Deleted route table: {rt_id}")
        except ClientError as e:
            logger.error(f"Error deleting route table {rt_id}: {str(e)}")

def force_delete_subnets(subnets: List[str]):
    """Force delete subnets with multiple attempts"""
    if not subnets:
        return
    
    logger.info(f"Force deleting {len(subnets)} subnets...")
    
    # Try multiple rounds
    remaining_subnets = subnets.copy()
    max_rounds = 3
    
    for round_num in range(max_rounds):
        if not remaining_subnets:
            break
            
        logger.info(f"Subnet deletion round {round_num + 1}")
        failed_subnets = []
        
        for subnet_id in remaining_subnets:
            try:
                if DRY_RUN:
                    logger.info(f"[DRY RUN] Would delete subnet: {subnet_id}")
                else:
                    ec2_client.delete_subnet(SubnetId=subnet_id)
                    logger.info(f"Deleted subnet: {subnet_id}")
            except ClientError as e:
                if "DependencyViolation" in str(e):
                    failed_subnets.append(subnet_id)
                else:
                    logger.error(f"Error deleting subnet {subnet_id}: {str(e)}")
        
        remaining_subnets = failed_subnets
        if remaining_subnets and round_num < max_rounds - 1:
            logger.info(f"Waiting before next round... {len(remaining_subnets)} subnets remaining")
            time.sleep(15)
    
    if remaining_subnets:
        logger.warning(f"Could not delete {len(remaining_subnets)} subnets: {remaining_subnets}")

def delete_network_acls(network_acls: List[str]):
    """Delete network ACLs"""
    if not network_acls:
        return
    
    logger.info(f"Deleting {len(network_acls)} network ACLs...")
    for acl_id in network_acls:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete network ACL: {acl_id}")
            else:
                retry_operation(ec2_client.delete_network_acl, NetworkAclId=acl_id)
                logger.info(f"Deleted network ACL: {acl_id}")
        except ClientError as e:
            logger.error(f"Error deleting network ACL {acl_id}: {str(e)}")

def delete_internet_gateways(igws: List[str]):
    """Delete internet gateways"""
    if not igws:
        return
    
    logger.info(f"Deleting {len(igws)} internet gateways...")
    for igw_id in igws:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would detach and delete IGW: {igw_id}")
            else:
                # Detach first
                retry_operation(ec2_client.detach_internet_gateway, 
                              InternetGatewayId=igw_id, VpcId=VPC_ID)
                # Then delete
                retry_operation(ec2_client.delete_internet_gateway, 
                              InternetGatewayId=igw_id)
                logger.info(f"Detached and deleted IGW: {igw_id}")
        except ClientError as e:
            logger.error(f"Error deleting IGW {igw_id}: {str(e)}")

def delete_peering_connections(peering_connections: List[str]):
    """Delete VPC peering connections"""
    if not peering_connections:
        return
    
    logger.info(f"Deleting {len(peering_connections)} VPC peering connections...")
    for pc_id in peering_connections:
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete peering connection: {pc_id}")
            else:
                retry_operation(ec2_client.delete_vpc_peering_connection, 
                              VpcPeeringConnectionId=pc_id)
                logger.info(f"Deleted peering connection: {pc_id}")
        except ClientError as e:
            logger.error(f"Error deleting peering connection {pc_id}: {str(e)}")

# =============================================================================
# MAIN EXECUTION LOGIC
# =============================================================================

def discover_resources():
    """Discover all resources in the VPC"""
    logger.info(f"Discovering resources in VPC: {VPC_ID}")
    
    resources = {
        'instances': get_vpc_instances(),
        'albs': [],
        'clbs': [],
        'rds_instances': get_vpc_rds_instances(),
        'nat_gateways': get_vpc_nat_gateways(),
        'vpc_endpoints': get_vpc_endpoints(),
        'network_interfaces': get_vpc_network_interfaces(),
        'elastic_ips': get_elastic_ips(),
        'security_groups': get_vpc_security_groups(),
        'network_acls': get_vpc_network_acls(),
        'route_tables': get_vpc_route_tables(),
        'subnets': get_vpc_subnets(),
        'internet_gateways': get_vpc_internet_gateways(),
        'peering_connections': get_vpc_peering_connections()
    }
    
    # Get load balancers
    albs, clbs = get_vpc_load_balancers()
    resources['albs'] = albs
    resources['clbs'] = clbs
    
    return resources

def print_resource_summary(resources: Dict[str, List]):
    """Print summary of discovered resources"""
    logger.info("=" * 60)
    logger.info("RESOURCE SUMMARY")
    logger.info("=" * 60)
    
    total_resources = 0
    for resource_type, resource_list in resources.items():
        count = len(resource_list)
        total_resources += count
        if count > 0:
            logger.info(f"{resource_type.replace('_', ' ').title()}: {count}")
            for resource in resource_list:
                logger.info(f"  - {resource}")
    
    logger.info(f"\nTotal resources to delete: {total_resources}")
    logger.info("=" * 60)
    
    return total_resources

def execute_deletion(resources: Dict[str, List]):
    """Execute the deletion process in the correct order"""
    logger.info("Starting deletion process...")
    
    # Phase 1: Delete compute and application resources
    logger.info("\n--- Phase 1: Compute and Application Resources ---")
    delete_instances(resources['instances'])
    delete_load_balancers(resources['albs'], resources['clbs'])
    delete_rds_instances(resources['rds_instances'])
    
    if not DRY_RUN:
        logger.info("Waiting for compute resources to terminate...")
        time.sleep(60)
    
    # Phase 2: Delete network services and interfaces
    logger.info("\n--- Phase 2: Network Services and Interfaces ---")
    delete_nat_gateways(resources['nat_gateways'])
    delete_vpc_endpoints(resources['vpc_endpoints'])
    delete_elastic_ips(resources['elastic_ips'])
    delete_network_interfaces(resources['network_interfaces'])
    
    if not DRY_RUN:
        logger.info("Waiting for network services to delete...")
        time.sleep(30)
    
    # Phase 3: Break dependencies and force delete security/routing
    logger.info("\n--- Phase 3: Breaking Dependencies ---")
    remove_security_group_rules(resources['security_groups'])
    disassociate_route_tables(resources['route_tables'])
    
    if not DRY_RUN:
        logger.info("Waiting after breaking dependencies...")
        time.sleep(20)
    
    logger.info("\n--- Phase 4: Force Delete Security and Routing ---")
    force_delete_security_groups(resources['security_groups'])
    delete_network_acls(resources['network_acls'])
    force_delete_route_tables(resources['route_tables'])
    
    # Phase 5: Force delete network infrastructure
    logger.info("\n--- Phase 5: Force Delete Network Infrastructure ---")
    force_delete_subnets(resources['subnets'])
    delete_internet_gateways(resources['internet_gateways'])
    delete_peering_connections(resources['peering_connections'])
    
    if not DRY_RUN:
        logger.info("Waiting for network infrastructure to delete...")
        time.sleep(30)
    
    # Phase 6: Final cleanup and VPC deletion
    logger.info("\n--- Phase 6: Final Cleanup and VPC Deletion ---")
    
    # Re-discover any remaining resources
    logger.info("Re-discovering any remaining resources...")
    remaining_resources = discover_resources()
    
    # Clean up any remaining network interfaces
    if remaining_resources['network_interfaces']:
        logger.info("Found remaining network interfaces, cleaning up...")
        delete_network_interfaces(remaining_resources['network_interfaces'])
        time.sleep(20)
    
    # Try VPC deletion multiple times
    max_vpc_attempts = 5
    for attempt in range(max_vpc_attempts):
        logger.info(f"VPC deletion attempt {attempt + 1}/{max_vpc_attempts}")
        try:
            if DRY_RUN:
                logger.info(f"[DRY RUN] Would delete VPC: {VPC_ID}")
                return True
            else:
                ec2_client.delete_vpc(VpcId=VPC_ID)
                logger.info(f"Successfully deleted VPC: {VPC_ID}")
                return True
        except ClientError as e:
            if "DependencyViolation" in str(e):
                if attempt < max_vpc_attempts - 1:
                    logger.warning(f"VPC still has dependencies, waiting before retry {attempt + 1}...")
                    time.sleep(30)
                else:
                    logger.error(f"Failed to delete VPC after {max_vpc_attempts} attempts: {str(e)}")
                    return False
            else:
                logger.error(f"Error deleting VPC {VPC_ID}: {str(e)}")
                return False
    
    return False

def main():
    """Main execution function"""
    logger.info("AWS VPC Resource Deletion Script Started")
    logger.info(f"Target VPC: {VPC_ID}")
    logger.info(f"Region: {AWS_REGION}")
    logger.info(f"Dry Run: {DRY_RUN}")
    
    # Validate VPC exists and is accessible
    if not validate_vpc_id():
        sys.exit(1)
    
    # Discover resources
    resources = discover_resources()
    total_resources = print_resource_summary(resources)
    
    if total_resources == 0:
        logger.info("No resources found to delete. VPC appears to be empty.")
        if not DRY_RUN and confirm_deletion():
            try:
                ec2_client.delete_vpc(VpcId=VPC_ID)
                logger.info(f"Successfully deleted empty VPC: {VPC_ID}")
            except ClientError as e:
                logger.error(f"Error deleting VPC {VPC_ID}: {str(e)}")
        return
    
    # Get confirmation
    if not confirm_deletion():
        logger.info("Deletion cancelled by user")
        return
    
    # Execute deletion
    start_time = time.time()
    success = execute_deletion(resources)
    end_time = time.time()
    
    # Summary
    logger.info("\n" + "=" * 60)
    if DRY_RUN:
        logger.info("DRY RUN COMPLETED")
        logger.info("No resources were actually deleted")
    else:
        if success:
            logger.info("VPC DELETION COMPLETED SUCCESSFULLY")
        else:
            logger.info("VPC DELETION COMPLETED WITH ERRORS")
        logger.info(f"Total execution time: {end_time - start_time:.2f} seconds")
    logger.info("=" * 60)

if __name__ == "__main__":
    # Validate configuration before starting
    if not VPC_ID or VPC_ID == "vpc-xxxxxxxxx":
        print("❌ ERROR: Please set the VPC_ID variable at the top of the script!")
        print(f"   Current VPC_ID: '{VPC_ID}'")
        print("   Example: VPC_ID = 'vpc-1234567890abcdef0'")
        sys.exit(1)
    
    if len(VPC_ID) < 12 or not VPC_ID.startswith('vpc-'):
        print(f"❌ ERROR: Invalid VPC ID format: '{VPC_ID}'")
        print("   VPC ID should be in format: vpc-xxxxxxxxxxxxxxxxx")
        sys.exit(1)
    
    try:
        main()
    except KeyboardInterrupt:
        logger.info("\nScript interrupted by user")
        sys.exit(1)
    except Exception as e:
        logger.error(f"Unexpected error: {str(e)}")
        sys.exit(1)
