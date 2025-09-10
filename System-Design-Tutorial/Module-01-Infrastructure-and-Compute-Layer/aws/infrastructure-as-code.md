# Infrastructure as Code (CloudFormation/CDK)

## Overview

Infrastructure as Code (IaC) allows you to define and manage infrastructure using code, enabling version control, repeatability, and automation.

## CloudFormation

### Templates
- **JSON/YAML**: Declarative syntax
- **Resources**: Define AWS resources
- **Parameters**: Make templates reusable
- **Outputs**: Export values for other stacks

### Example Template
```yaml
Resources:
  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-12345678
      InstanceType: t3.medium
      SecurityGroups:
        - !Ref WebServerSecurityGroup
```

## AWS CDK

### Programming Languages
- **TypeScript**: Most popular
- **Python**: Easy to learn
- **Java**: Enterprise applications
- **C#**: .NET applications

### Example CDK
```typescript
import * as ec2 from '@aws-cdk/aws-ec2';

const vpc = new ec2.Vpc(this, 'MyVPC');
const instance = new ec2.Instance(this, 'WebServer', {
  vpc,
  instanceType: ec2.InstanceType.of(ec2.InstanceClass.T3, ec2.InstanceSize.MEDIUM),
  machineImage: ec2.MachineImage.latestAmazonLinux()
});
```

## Best Practices

### 1. Template Design
- **Modular**: Break into smaller templates
- **Reusable**: Use parameters and conditions
- **Documented**: Add comments and documentation
- **Tested**: Test templates before deployment

### 2. Version Control
- **Git**: Use version control
- **Branches**: Use feature branches
- **Reviews**: Code review process
- **Tags**: Tag releases

### 3. Deployment
- **Staging**: Test in staging first
- **Rollback**: Plan for rollbacks
- **Monitoring**: Monitor deployments
- **Automation**: Use CI/CD pipelines

