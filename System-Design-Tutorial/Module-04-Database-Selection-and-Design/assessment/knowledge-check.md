# Module-04: Database Selection and Design - Knowledge Check

## Instructions

- **Duration**: 60 minutes
- **Total Questions**: 25
- **Question Types**: Multiple Choice, True/False, Short Answer
- **Passing Score**: 70% (18/25 correct)
- **Open Book**: Yes (documentation and notes allowed)
- **Calculator**: Allowed for capacity planning questions

## Part A: Database Architecture Patterns (5 questions)

### Question 1
Which database architecture pattern is best suited for a microservices application where each service needs independent data management?

A) Monolithic Database
B) Database per Service
C) Shared Database
D) Event Sourcing

**Answer**: B) Database per Service

**Explanation**: Database per Service pattern provides service independence, allowing each microservice to manage its own data without affecting other services.

### Question 2
What is the primary advantage of the CQRS (Command Query Responsibility Segregation) pattern?

A) Simplified data modeling
B) Improved read and write performance through optimized models
C) Reduced storage requirements
D) Better data consistency

**Answer**: B) Improved read and write performance through optimized models

**Explanation**: CQRS separates read and write models, allowing each to be optimized for their specific use cases, leading to better performance.

### Question 3
In Event Sourcing, what is stored instead of the current state?

A) Database snapshots
B) Events that led to the current state
C) Transaction logs
D) Backup copies

**Answer**: B) Events that led to the current state

**Explanation**: Event Sourcing stores events that represent state changes, allowing the current state to be reconstructed by replaying events.

### Question 4
Which pattern is most suitable for applications requiring strong consistency across all operations?

A) Database per Service
B) Event Sourcing
C) Monolithic Database
D) CQRS

**Answer**: C) Monolithic Database

**Explanation**: Monolithic databases provide ACID transactions and strong consistency across all operations within the same database.

### Question 5
What is the main trade-off when using Database per Service pattern?

A) Increased complexity
B) Reduced performance
C) Data consistency challenges
D) Higher storage costs

**Answer**: C) Data consistency challenges

**Explanation**: Database per Service pattern makes it difficult to maintain ACID transactions across services, leading to eventual consistency challenges.

## Part B: RDBMS vs NoSQL Selection (5 questions)

### Question 6
Which type of database is best for storing financial transaction data that requires ACID properties?

A) Document Database
B) Key-Value Store
C) Relational Database
D) Graph Database

**Answer**: C) Relational Database

**Explanation**: Relational databases provide ACID properties which are essential for financial transactions requiring strong consistency.

### Question 7
What is the primary advantage of NoSQL databases over RDBMS?

A) Better data consistency
B) Horizontal scalability
C) Complex query support
D) ACID transactions

**Answer**: B) Horizontal scalability

**Explanation**: NoSQL databases are designed to scale horizontally across multiple servers, making them suitable for large-scale applications.

### Question 8
Which NoSQL database type is best for storing product catalogs with flexible schemas?

A) Key-Value Store
B) Column-Family Database
C) Document Database
D) Graph Database

**Answer**: C) Document Database

**Explanation**: Document databases like MongoDB are ideal for product catalogs due to their flexible schema and JSON-like document structure.

### Question 9
What is the main disadvantage of using NoSQL databases?

A) Limited scalability
B) Lack of ACID properties
C) Complex data modeling
D) Poor performance

**Answer**: B) Lack of ACID properties

**Explanation**: Most NoSQL databases sacrifice ACID properties for better scalability and performance, which can be a disadvantage for applications requiring strong consistency.

### Question 10
Which database type is most suitable for storing user session data with high read/write performance requirements?

A) Relational Database
B) Document Database
C) Key-Value Store
D) Graph Database

**Answer**: C) Key-Value Store

**Explanation**: Key-value stores like Redis are optimized for simple key-value operations and provide excellent performance for session data.

## Part C: Database Internals and Algorithms (5 questions)

### Question 11
What is the primary advantage of B+Tree over B-Tree for database indexing?

A) Faster insertions
B) Better range query performance
C) Lower memory usage
D) Simpler implementation

**Answer**: B) Better range query performance

**Explanation**: B+Trees store all data in leaf nodes and link them together, making range queries more efficient.

### Question 12
Which data structure is used in LSM (Log-Structured Merge) trees to optimize write performance?

A) Hash tables
B) B-Trees
C) Sorted arrays
D) Linked lists

**Answer**: C) Sorted arrays

**Explanation**: LSM trees use sorted arrays (runs) that are merged periodically, optimizing for write-heavy workloads.

### Question 13
What is the main purpose of Write-Ahead Logging (WAL)?

A) Improve query performance
B) Ensure data durability
C) Reduce storage requirements
D) Simplify data modeling

**Answer**: B) Ensure data durability

**Explanation**: WAL ensures that changes are written to a log before being applied to the database, guaranteeing durability even in case of system failures.

### Question 14
Which indexing structure is most suitable for full-text search?

A) B-Tree
B) Hash Index
C) Inverted Index
D) R-Tree

**Answer**: C) Inverted Index

**Explanation**: Inverted indexes map terms to documents containing those terms, making them ideal for full-text search operations.

### Question 15
What is the primary advantage of column-oriented storage over row-oriented storage?

A) Better for OLTP workloads
B) Better compression and analytics performance
C) Simpler data modeling
D) Faster individual record retrieval

**Answer**: B) Better compression and analytics performance

**Explanation**: Column-oriented storage groups similar data together, enabling better compression and more efficient analytical queries.

## Part D: ACID vs BASE Properties (5 questions)

### Question 16
What does the "A" in ACID stand for?

A) Availability
B) Atomicity
C) Accuracy
D) Authentication

**Answer**: B) Atomicity

**Explanation**: Atomicity ensures that all operations in a transaction succeed or all fail, maintaining data consistency.

### Question 17
Which consistency model is used by most NoSQL databases?

A) Strong Consistency
B) Eventual Consistency
C) Session Consistency
D) Monotonic Consistency

**Answer**: B) Eventual Consistency

**Explanation**: Most NoSQL databases use eventual consistency, where data will become consistent over time but not immediately.

### Question 18
What is the main trade-off in the CAP theorem?

A) Consistency vs Performance
B) Consistency vs Availability vs Partition Tolerance
C) Cost vs Performance
D) Security vs Usability

**Answer**: B) Consistency vs Availability vs Partition Tolerance

**Explanation**: The CAP theorem states that in a distributed system, you can only guarantee two of: Consistency, Availability, and Partition Tolerance.

### Question 19
Which property ensures that committed changes persist even after system failures?

A) Atomicity
B) Consistency
C) Isolation
D) Durability

**Answer**: D) Durability

**Explanation**: Durability ensures that once a transaction is committed, its changes persist even if the system fails.

### Question 20
What does "BASE" stand for in database consistency models?

A) Basic, Available, Scalable, Efficient
B) Basically Available, Soft state, Eventual consistency
C) Balanced, Accessible, Secure, Efficient
D) Big, Available, Scalable, Eventual

**Answer**: B) Basically Available, Soft state, Eventual consistency

**Explanation**: BASE stands for Basically Available, Soft state, Eventual consistency, which prioritizes availability over strong consistency.

## Part E: Query Optimization and Performance (5 questions)

### Question 21
What is the primary purpose of database indexing?

A) Reduce storage requirements
B) Improve query performance
C) Ensure data consistency
D) Simplify data modeling

**Answer**: B) Improve query performance

**Explanation**: Indexes are data structures that improve query performance by providing faster access to data.

### Question 22
Which type of index is most suitable for range queries?

A) Hash Index
B) B-Tree Index
C) Bitmap Index
D) Inverted Index

**Answer**: B) B-Tree Index

**Explanation**: B-Tree indexes maintain sorted order, making them ideal for range queries and ordered data access.

### Question 23
What is the main disadvantage of creating too many indexes?

A) Increased storage requirements
B) Slower insert/update operations
C) Reduced query performance
D) Data inconsistency

**Answer**: B) Slower insert/update operations

**Explanation**: Each index must be updated when data changes, so too many indexes can slow down insert and update operations.

### Question 24
Which query optimization technique involves rewriting queries to use more efficient execution plans?

A) Indexing
B) Query rewriting
C) Caching
D) Partitioning

**Answer**: B) Query rewriting

**Explanation**: Query rewriting involves transforming queries into more efficient forms that produce the same results but with better performance.

### Question 25
What is the primary benefit of database partitioning?

A) Improved data consistency
B) Better query performance on large tables
C) Reduced storage requirements
D) Simplified data modeling

**Answer**: B) Better query performance on large tables

**Explanation**: Partitioning divides large tables into smaller, more manageable pieces, improving query performance by reducing the amount of data that needs to be scanned.

## Scoring Guide

### Score Calculation
- **Correct Answer**: 4 points
- **Incorrect Answer**: 0 points
- **Total Possible**: 100 points
- **Passing Score**: 70 points (70%)

### Grade Scale
- **90-100%**: Excellent (A)
- **80-89%**: Good (B)
- **70-79%**: Satisfactory (C)
- **60-69%**: Needs Improvement (D)
- **Below 60%**: Unsatisfactory (F)

### Performance Analysis
After completing the knowledge check, review your performance in each section:

- **Part A (Database Architecture Patterns)**: ___/20 points
- **Part B (RDBMS vs NoSQL Selection)**: ___/20 points
- **Part C (Database Internals and Algorithms)**: ___/20 points
- **Part D (ACID vs BASE Properties)**: ___/20 points
- **Part E (Query Optimization and Performance)**: ___/20 points

### Areas for Improvement
Identify areas where you scored below 80% and focus your study on:
- [ ] Database architecture patterns
- [ ] Technology selection criteria
- [ ] Database internals and algorithms
- [ ] Consistency models
- [ ] Query optimization techniques

## Study Resources

### Recommended Reading
- Database Design Best Practices
- NoSQL Data Modeling Guidelines
- Query Optimization Techniques
- Database Performance Tuning
- Distributed Systems Concepts

### Practice Exercises
- Database schema design problems
- Query optimization challenges
- Technology selection scenarios
- Performance tuning exercises
- Consistency model analysis

### Additional Resources
- Database documentation
- Performance tuning guides
- Best practices articles
- Case study analyses
- Expert recommendations

## Next Steps

After completing the knowledge check:
1. Review your answers and explanations
2. Identify areas for improvement
3. Study weak areas using recommended resources
4. Practice with additional exercises
5. Prepare for the design challenge assessment

---

**Good luck with your knowledge check!** Take your time, read each question carefully, and apply the concepts you've learned throughout the module.
