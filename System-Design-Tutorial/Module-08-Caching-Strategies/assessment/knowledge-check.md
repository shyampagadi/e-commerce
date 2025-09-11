# Knowledge Check: Caching Strategies

## Instructions
- **Duration**: 60 minutes
- **Total Questions**: 50
- **Question Types**: Multiple Choice, True/False, Scenario-based
- **Passing Score**: 70% (35 out of 50 questions)
- **Resources**: No external resources allowed

## Section 1: Cache Architecture Patterns (15 questions)

### Question 1
In the Cache-Aside pattern, what is the primary responsibility of the application?

A) The cache automatically loads data on miss
B) The application manages cache operations directly
C) The database handles all cache operations
D) The cache handles all database operations

**Answer**: B) The application manages cache operations directly

### Question 2
Which cache pattern provides the highest write performance?

A) Write-Through
B) Write-Behind
C) Write-Around
D) Read-Through

**Answer**: B) Write-Behind

### Question 3
In the Read-Through pattern, when does the cache load data from the data store?

A) When the application explicitly requests it
B) When the cache is first initialized
C) Automatically when data is not found in cache
D) Only during scheduled maintenance

**Answer**: C) Automatically when data is not found in cache

### Question 4
What is the main advantage of the Write-Through pattern?

A) High write performance
B) Immediate consistency between cache and database
C) Reduced memory usage
D) Simplified error handling

**Answer**: B) Immediate consistency between cache and database

### Question 5
Which pattern is best suited for applications that can tolerate eventual consistency?

A) Write-Through
B) Write-Behind
C) Read-Through
D) Cache-Aside

**Answer**: B) Write-Behind

### Question 6
In a multi-level cache hierarchy, which level typically has the lowest latency?

A) L1 (Application) cache
B) L2 (Distributed) cache
C) L3 (CDN) cache
D) Database cache

**Answer**: A) L1 (Application) cache

### Question 7
What is the primary trade-off in the Cache-Aside pattern?

A) Performance vs. Memory usage
B) Control vs. Complexity
C) Consistency vs. Availability
D) Latency vs. Throughput

**Answer**: B) Control vs. Complexity

### Question 8
Which cache pattern is most suitable for read-heavy workloads?

A) Write-Through
B) Write-Behind
C) Read-Through
D) Write-Around

**Answer**: C) Read-Through

### Question 9
In the Write-Around pattern, where is data written?

A) Only to the cache
B) Only to the database
C) To both cache and database
D) To neither cache nor database

**Answer**: B) Only to the database

### Question 10
What is the main disadvantage of the Write-Through pattern?

A) Eventual consistency
B) Higher write latency
C) Complex implementation
D) Memory overhead

**Answer**: B) Higher write latency

### Question 11
Which pattern provides the most control over cache behavior?

A) Read-Through
B) Write-Through
C) Cache-Aside
D) Write-Behind

**Answer**: C) Cache-Aside

### Question 12
In a cache hierarchy, which level typically has the highest capacity?

A) L1 (Application) cache
B) L2 (Distributed) cache
C) L3 (CDN) cache
D) Database cache

**Answer**: C) L3 (CDN) cache

### Question 13
What is the primary benefit of using multiple cache levels?

A) Reduced complexity
B) Better performance and cost optimization
C) Simplified monitoring
D) Easier maintenance

**Answer**: B) Better performance and cost optimization

### Question 14
Which pattern is most suitable for critical financial data?

A) Write-Behind
B) Write-Through
C) Read-Through
D) Write-Around

**Answer**: B) Write-Through

### Question 15
What is the main risk of the Write-Behind pattern?

A) High write latency
B) Data loss if cache fails
C) Complex implementation
D) Memory overhead

**Answer**: B) Data loss if cache fails

## Section 2: Cache Invalidation Strategies (10 questions)

### Question 16
What does TTL stand for in caching?

A) Time To Live
B) Total Time Limit
C) Time To Load
D) Time To Leave

**Answer**: A) Time To Live

### Question 17
Which invalidation strategy provides the most immediate cache updates?

A) TTL-based
B) Event-driven
C) Manual
D) Version-based

**Answer**: B) Event-driven

### Question 18
What is the main advantage of TTL-based invalidation?

A) Immediate updates
B) Automatic expiration
C) Complex implementation
D) High performance

**Answer**: B) Automatic expiration

### Question 19
In event-driven invalidation, what triggers cache invalidation?

A) Time-based events
B) Data change events
C) User actions
D) System maintenance

**Answer**: B) Data change events

### Question 20
Which invalidation strategy is most suitable for frequently changing data?

A) TTL-based
B) Event-driven
C) Manual
D) Version-based

**Answer**: B) Event-driven

### Question 21
What is the main disadvantage of manual invalidation?

A) High performance
B) Requires application logic
C) Automatic expiration
D) Simple implementation

**Answer**: B) Requires application logic

### Question 22
In version-based invalidation, what determines when to invalidate?

A) Time elapsed
B) Data changes
C) Version number changes
D) User actions

**Answer**: C) Version number changes

### Question 23
Which invalidation strategy is most suitable for static data?

A) TTL-based
B) Event-driven
C) Manual
D) Version-based

**Answer**: A) TTL-based

### Question 24
What is the main advantage of tag-based invalidation?

A) Simple implementation
B) Can invalidate related data
C) High performance
D) Automatic expiration

**Answer**: B) Can invalidate related data

### Question 25
Which invalidation strategy provides the most control?

A) TTL-based
B) Event-driven
C) Manual
D) Version-based

**Answer**: C) Manual

## Section 3: Cache Consistency Models (10 questions)

### Question 26
Which consistency model provides the strongest guarantees?

A) Eventual consistency
B) Strong consistency
C) Session consistency
D) Monotonic read consistency

**Answer**: B) Strong consistency

### Question 27
In eventual consistency, when is consistency achieved?

A) Immediately
B) After a short delay
C) Eventually over time
D) Never

**Answer**: C) Eventually over time

### Question 28
Which consistency model is most suitable for high-performance systems?

A) Strong consistency
B) Eventual consistency
C) Session consistency
D) Monotonic read consistency

**Answer**: B) Eventual consistency

### Question 29
In session consistency, what is the scope of consistency?

A) Global
B) Per-user session
C) Per-request
D) Per-database

**Answer**: B) Per-user session

### Question 30
Which consistency model prevents reads from going backwards in time?

A) Strong consistency
B) Eventual consistency
C) Session consistency
D) Monotonic read consistency

**Answer**: D) Monotonic read consistency

### Question 31
What is the main trade-off in consistency models?

A) Performance vs. Complexity
B) Consistency vs. Performance
C) Memory vs. CPU
D) Latency vs. Throughput

**Answer**: B) Consistency vs. Performance

### Question 32
Which consistency model is most suitable for financial data?

A) Eventual consistency
B) Strong consistency
C) Session consistency
D) Monotonic read consistency

**Answer**: B) Strong consistency

### Question 33
In causal consistency, what is maintained?

A) Global order
B) Causal order
C) Time order
D) Random order

**Answer**: B) Causal order

### Question 34
Which consistency model provides the best performance?

A) Strong consistency
B) Eventual consistency
C) Session consistency
D) Monotonic read consistency

**Answer**: B) Eventual consistency

### Question 35
What is the main advantage of strong consistency?

A) High performance
B) Predictable behavior
C) Simple implementation
D) Low latency

**Answer**: B) Predictable behavior

## Section 4: Performance Optimization (10 questions)

### Question 36
What is the primary goal of cache warming?

A) Reduce memory usage
B) Improve cache hit ratio
C) Reduce complexity
D) Increase security

**Answer**: B) Improve cache hit ratio

### Question 37
Which eviction policy is most suitable for frequently accessed data?

A) LRU (Least Recently Used)
B) LFU (Least Frequently Used)
C) FIFO (First In, First Out)
D) Random

**Answer**: A) LRU (Least Recently Used)

### Question 38
What is the main benefit of cache compression?

A) Improved performance
B) Reduced memory usage
C) Better consistency
D) Simplified implementation

**Answer**: B) Reduced memory usage

### Question 39
Which optimization technique is most suitable for reducing cache misses?

A) Compression
B) Warming
C) Partitioning
D) Replication

**Answer**: B) Warming

### Question 40
What is the main advantage of cache partitioning?

A) Improved consistency
B) Better performance
C) Reduced complexity
D) Increased security

**Answer**: B) Better performance

### Question 41
Which optimization technique is most suitable for high availability?

A) Compression
B) Warming
C) Partitioning
D) Replication

**Answer**: D) Replication

### Question 42
What is the main benefit of cache sharding?

A) Improved consistency
B) Better scalability
C) Reduced complexity
D) Increased security

**Answer**: B) Better scalability

### Question 43
Which optimization technique is most suitable for reducing latency?

A) Compression
B) Warming
C) Partitioning
D) Replication

**Answer**: B) Warming

### Question 44
What is the main advantage of cache preloading?

A) Improved consistency
B) Better performance
C) Reduced complexity
D) Increased security

**Answer**: B) Better performance

### Question 45
Which optimization technique is most suitable for reducing memory usage?

A) Compression
B) Warming
C) Partitioning
D) Replication

**Answer**: A) Compression

## Section 5: CDN and Edge Caching (5 questions)

### Question 46
What is the primary benefit of CDN caching?

A) Improved consistency
B) Reduced latency
C) Better security
D) Simplified implementation

**Answer**: B) Reduced latency

### Question 47
In CDN caching, where are edge servers typically located?

A) Near data centers
B) Near users
C) Near databases
D) Near applications

**Answer**: B) Near users

### Question 48
What is the main advantage of edge computing?

A) Improved consistency
B) Reduced latency
C) Better security
D) Simplified implementation

**Answer**: B) Reduced latency

### Question 49
Which CDN feature is most suitable for dynamic content?

A) Static caching
B) Dynamic caching
C) Edge computing
D) Origin shielding

**Answer**: C) Edge computing

### Question 50
What is the main benefit of origin shielding?

A) Improved consistency
B) Reduced origin load
C) Better security
D) Simplified implementation

**Answer**: B) Reduced origin load

## Scoring Guide

### Score Calculation
- **Total Points**: 50
- **Passing Score**: 35 (70%)
- **Excellent Score**: 45 (90%)

### Grade Distribution
- **A (90-100%)**: 45-50 correct
- **B (80-89%)**: 40-44 correct
- **C (70-79%)**: 35-39 correct
- **D (60-69%)**: 30-34 correct
- **F (0-59%)**: 0-29 correct

### Review Process
1. **Immediate Results**: Score and correct answers provided
2. **Detailed Feedback**: Explanation for each question
3. **Study Recommendations**: Areas for improvement
4. **Retake Policy**: One retake allowed for scores < 70%

## Study Resources

### Recommended Reading
- Module 08 concept documents
- AWS ElastiCache documentation
- Redis best practices guide
- CDN optimization strategies

### Practice Materials
- Module exercises and solutions
- Practice quizzes and tests
- Case study analyses
- Hands-on labs

### Additional Resources
- Caching pattern documentation
- Performance optimization guides
- Real-world case studies
- Industry best practices

This knowledge check provides a comprehensive evaluation of caching strategy knowledge and serves as a foundation for the more advanced assessments in the module.
