# Module 03 Knowledge Check

## Storage Protocols and Technologies (25 points)

### Question 1: SCSI vs NVMe Architecture (5 points)
Compare SCSI and NVMe protocols in terms of:
- Queue architecture and parallelism
- Command overhead and latency
- Performance characteristics for different workloads

**Expected Answer:**
- SCSI: Single queue, higher command overhead, optimized for HDDs
- NVMe: Multiple queues (up to 64K), lower latency, optimized for SSDs
- NVMe provides 6x lower latency and higher IOPS for random workloads

### Question 2: RAID Mathematics (10 points)
Calculate the following for a RAID 5 array with 4 drives (each 1TB, AFR 0.5%):
- Usable capacity
- MTTDL (Mean Time To Data Loss)
- Performance impact during rebuild

**Expected Answer:**
- Usable capacity: 3TB (n-1 drives)
- MTTDL: ~200,000 hours (considering URE and rebuild time)
- Performance impact: 20-50% degradation during rebuild

### Question 3: Storage Efficiency Techniques (10 points)
Explain how the following techniques work and their typical compression ratios:
- Data deduplication (block-level vs file-level)
- Compression algorithms (LZ4, GZIP, ZSTD)
- Thin provisioning implementation

**Expected Answer:**
- Deduplication: 2-10x reduction depending on data type
- Compression: 2-4x for text, 1.2-1.5x for mixed data
- Thin provisioning: Allocates storage on-demand, prevents over-provisioning

## AWS Storage Services (25 points)

### Question 4: EBS Volume Types (10 points)
Compare gp3, io2, st1, and sc1 volume types:
- Performance characteristics (IOPS, throughput)
- Use cases and cost considerations
- When to use each type

**Expected Answer:**
- gp3: 3,000-16,000 IOPS, general purpose, cost-effective
- io2: Up to 64,000 IOPS, mission-critical applications, highest cost
- st1: 500 MB/s throughput, big data workloads, lower cost
- sc1: 250 MB/s throughput, cold data, lowest cost

### Question 5: S3 Storage Classes (10 points)
Design a lifecycle policy for the following data:
- Frequently accessed for 30 days
- Occasionally accessed for 90 days
- Rarely accessed but must be available within hours
- Archive data for 7 years for compliance

**Expected Answer:**
```json
{
  "Rules": [{
    "Transitions": [
      {"Days": 30, "StorageClass": "STANDARD_IA"},
      {"Days": 90, "StorageClass": "GLACIER"},
      {"Days": 2555, "StorageClass": "DEEP_ARCHIVE"}
    ]
  }]
}
```

### Question 6: EFS vs FSx Selection (5 points)
When would you choose EFS vs FSx for Windows vs FSx for Lustre?

**Expected Answer:**
- EFS: Linux workloads, NFS protocol, automatic scaling
- FSx for Windows: Windows environments, SMB protocol, AD integration
- FSx for Lustre: HPC workloads, high-performance computing, scratch storage

## Data Durability and Protection (25 points)

### Question 7: Durability Calculations (15 points)
Calculate the annual data loss probability for:
- Single EBS volume (99.999% durability)
- RAID 1 configuration with two volumes
- Cross-region replication setup

**Expected Answer:**
- Single volume: 0.001% annual loss probability
- RAID 1: 0.000001% (10^-8) annual loss probability
- Cross-region: 0.0000000001% (10^-12) with independent failures

### Question 8: Backup Strategies (10 points)
Design a backup strategy with:
- RTO: 4 hours
- RPO: 1 hour
- 7-year retention
- Cost optimization

**Expected Answer:**
- Continuous replication for 1-hour RPO
- Automated snapshots every hour
- Cross-region backup for disaster recovery
- Lifecycle policies: IA after 30 days, Glacier after 90 days

## Performance Optimization (25 points)

### Question 9: I/O Pattern Optimization (15 points)
Optimize storage for these workloads:
- Database with 70% random reads, 30% sequential writes
- Video streaming with large sequential reads
- Log processing with append-only writes

**Expected Answer:**
- Database: io2 volumes, read replicas, caching layer
- Video streaming: st1 volumes, CloudFront CDN, multi-AZ
- Log processing: gp3 volumes, log aggregation, compression

### Question 10: Cache Hierarchy Design (10 points)
Design a multi-level cache hierarchy for a content management system:
- Application cache
- Database cache
- CDN cache
- Storage cache

**Expected Answer:**
- Application: Redis/ElastiCache for session data
- Database: Query result caching, connection pooling
- CDN: CloudFront for static content, edge locations
- Storage: EBS-optimized instances, instance store for temp data

## Scoring Rubric

### Excellent (90-100 points)
- Demonstrates deep understanding of storage internals
- Provides accurate calculations with proper methodology
- Shows practical AWS implementation knowledge
- Explains trade-offs and optimization strategies

### Good (80-89 points)
- Good understanding of core concepts
- Minor errors in calculations or implementation details
- Shows AWS service knowledge with some gaps
- Basic understanding of optimization principles

### Satisfactory (70-79 points)
- Basic understanding of storage concepts
- Significant gaps in calculations or AWS knowledge
- Limited optimization understanding
- Requires improvement in practical application

### Needs Improvement (60-69 points)
- Limited understanding of storage fundamentals
- Major errors in calculations and concepts
- Poor AWS service knowledge
- Cannot apply optimization strategies

### Unsatisfactory (Below 60 points)
- No understanding of storage concepts
- Cannot perform basic calculations
- No AWS knowledge demonstrated
- Requires comprehensive review and additional study

## Additional Practice Questions

### Scenario-Based Questions
1. **High-Traffic Website**: Design storage for 1M daily users with 10TB of images
2. **Data Analytics Platform**: Optimize storage for 100TB dataset with complex queries
3. **Backup Solution**: Create enterprise backup strategy for 500TB with compliance requirements
4. **Global Application**: Design multi-region storage with consistency requirements

### Troubleshooting Scenarios
1. **Performance Issues**: EBS volume showing high latency and low IOPS
2. **Cost Optimization**: S3 bill increased 300% without traffic increase
3. **Data Recovery**: Accidental deletion of critical database
4. **Capacity Planning**: Storage running out of space faster than expected

## Study Resources

### AWS Documentation
- [EBS Performance Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-performance.html)
- [S3 Storage Classes](https://aws.amazon.com/s3/storage-classes/)
- [EFS Performance](https://docs.aws.amazon.com/efs/latest/ug/performance.html)

### Additional Reading
- "Database Internals" by Alex Petrov
- "Designing Data-Intensive Applications" by Martin Kleppmann
- AWS Storage Specialty Certification Guide
