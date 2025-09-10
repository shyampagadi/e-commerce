# Module-01 Architecture Decision Records

## Overview

This directory contains Architecture Decision Records (ADRs) for Module-01: Infrastructure and Compute Layer decisions.

## Decision Records

### ADR-001: Compute Technology Selection
- **Status**: Proposed
- **Date**: 2024-01-15
- **Context**: Choosing between VMs, containers, and serverless
- **Decision**: Multi-technology approach based on use case
- **Consequences**: Increased complexity but better optimization

### ADR-002: Auto-Scaling Strategy
- **Status**: Accepted
- **Date**: 2024-01-15
- **Context**: Implementing auto-scaling for web applications
- **Decision**: Predictive + reactive scaling with multiple metrics
- **Consequences**: Better performance and cost optimization

### ADR-003: Infrastructure as Code Tool
- **Status**: Accepted
- **Date**: 2024-01-15
- **Context**: Selecting IaC tool for AWS deployments
- **Decision**: CloudFormation for AWS-native, Terraform for multi-cloud
- **Consequences**: Better AWS integration, vendor lock-in risk

### ADR-004: Container Orchestration Platform
- **Status**: Proposed
- **Date**: 2024-01-15
- **Context**: Choosing between ECS and EKS
- **Decision**: ECS for simplicity, EKS for portability
- **Consequences**: Trade-off between simplicity and flexibility

## Template

See [ADR-TEMPLATE.md](./templates/ADR-TEMPLATE.md) for the standard template.

