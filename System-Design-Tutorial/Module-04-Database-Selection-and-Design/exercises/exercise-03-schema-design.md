# Exercise 03: Schema Design

## Overview
This exercise focuses on designing database schemas for different database types and use cases. You'll learn to apply normalization principles, design patterns, and optimization techniques.

## Learning Objectives
- Apply database normalization principles
- Design schemas for different database types
- Implement database design patterns
- Optimize schemas for performance and scalability

## Scenario
You are designing a comprehensive e-commerce platform with the following entities:
- Users (customers, vendors, admins)
- Products (with categories, variants, attributes)
- Orders (with line items, payments, shipping)
- Reviews and Ratings
- Inventory Management
- Content Management
- Analytics and Reporting

## Exercise Tasks

### Task 1: Relational Database Schema Design
Design a normalized relational database schema for the e-commerce platform:

**Entities to Include:**
- Users (customers, vendors, admins)
- Products (with categories, variants, attributes)
- Orders (with line items, payments, shipping)
- Reviews and Ratings
- Inventory Management
- Content Management

**Requirements:**
- Follow 3NF normalization
- Include all necessary relationships
- Design primary and foreign keys
- Consider indexing strategy
- Include audit fields (created_at, updated_at, etc.)

**Instructions:**
1. Create an Entity-Relationship Diagram (ERD)
2. Write CREATE TABLE statements
3. Define all constraints and relationships
4. Specify indexing strategy
5. Document design decisions and trade-offs

### Task 2: Document Database Schema Design
Design a document database schema for the same e-commerce platform:

**Collections to Include:**
- Users
- Products
- Orders
- Reviews
- Content
- Analytics

**Requirements:**
- Optimize for read performance
- Minimize joins and relationships
- Include embedded documents where appropriate
- Design for horizontal scaling
- Consider query patterns

**Instructions:**
1. Design document structures for each collection
2. Show embedded vs referenced relationships
3. Specify indexing strategy
4. Consider denormalization opportunities
5. Document query patterns and access patterns

### Task 3: Key-Value Database Schema Design
Design a key-value database schema for caching and session management:

**Data Types to Include:**
- User sessions
- Shopping carts
- Product cache
- Search results
- API responses
- Configuration data

**Requirements:**
- Optimize for fast access
- Design efficient key structures
- Consider data expiration
- Plan for data serialization
- Design for horizontal scaling

**Instructions:**
1. Design key naming conventions
2. Specify data structures and serialization
3. Define expiration strategies
4. Plan for data partitioning
5. Document access patterns

### Task 4: Column-Family Database Schema Design
Design a column-family database schema for analytics and time-series data:

**Column Families to Include:**
- User Analytics
- Product Analytics
- Order Analytics
- System Metrics
- Performance Data

**Requirements:**
- Optimize for write performance
- Design for time-series queries
- Consider data retention policies
- Plan for aggregation queries
- Design for horizontal scaling

**Instructions:**
1. Design column family structures
2. Specify row key design
3. Define column qualifiers
4. Plan for data partitioning
5. Document query patterns

### Task 5: Graph Database Schema Design
Design a graph database schema for recommendation and relationship data:

**Node Types to Include:**
- Users
- Products
- Categories
- Orders
- Reviews
- Content

**Relationship Types to Include:**
- User-Product interactions
- Product-Product relationships
- User-User relationships
- Category hierarchies
- Recommendation paths

**Requirements:**
- Optimize for relationship queries
- Design efficient traversal patterns
- Consider graph algorithms
- Plan for graph partitioning
- Design for real-time updates

**Instructions:**
1. Design node and relationship schemas
2. Specify property structures
3. Define traversal patterns
4. Plan for graph algorithms
5. Document query patterns

## Evaluation Criteria

### Task 1: Relational Database Schema (25 points)
- **Normalization (10 points)**: Proper application of normalization principles
- **Relationships (10 points)**: Correct and complete relationships
- **Indexing (5 points)**: Appropriate indexing strategy

### Task 2: Document Database Schema (25 points)
- **Document Design (10 points)**: Well-designed document structures
- **Embedding vs Referencing (10 points)**: Appropriate use of embedding and referencing
- **Query Optimization (5 points)**: Schema optimized for query patterns

### Task 3: Key-Value Database Schema (25 points)
- **Key Design (10 points)**: Efficient and logical key structures
- **Data Organization (10 points)**: Well-organized data structures
- **Access Patterns (5 points)**: Schema optimized for access patterns

### Task 4: Column-Family Database Schema (25 points)
- **Column Family Design (10 points)**: Well-designed column families
- **Row Key Design (10 points)**: Efficient row key design
- **Query Optimization (5 points)**: Schema optimized for analytics queries

### Task 5: Graph Database Schema (25 points)
- **Node Design (10 points)**: Well-designed node schemas
- **Relationship Design (10 points)**: Appropriate relationship design
- **Traversal Optimization (5 points)**: Schema optimized for graph traversals

## Total Points: 125

## Submission Requirements

1. **ERD Diagram**: Entity-Relationship Diagram for relational schema
2. **SQL Scripts**: CREATE TABLE statements and indexes
3. **Document Schemas**: JSON examples of document structures
4. **Key-Value Schemas**: Key naming conventions and data structures
5. **Column-Family Schemas**: Column family and row key designs
6. **Graph Schemas**: Node and relationship schemas
7. **Documentation**: Design decisions and trade-offs

## Additional Resources

- [Database Normalization](../concepts/database-normalization.md)
- [Database Design Patterns](../patterns/)
- [Database Architecture Patterns](../concepts/database-architecture-patterns.md)
- [Database Optimization Techniques](../concepts/database-optimization.md)

## Tips for Success

1. **Understand Requirements**: Clearly understand the data and query requirements
2. **Apply Principles**: Use appropriate database design principles
3. **Consider Performance**: Design for performance and scalability
4. **Think About Queries**: Design schemas based on query patterns
5. **Document Decisions**: Record your design decisions and reasoning

## Time Estimate
- **Task 1**: 4-5 hours
- **Task 2**: 3-4 hours
- **Task 3**: 2-3 hours
- **Task 4**: 3-4 hours
- **Task 5**: 3-4 hours
- **Total**: 15-20 hours

---

**Next Steps**: After completing this exercise, review the solution and compare your approach with the provided solution.
